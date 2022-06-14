class BIO_WMGNode play
{
	// Corresponds to node's place in `BIO_WeaponModGraph::Nodes`.
	// Also dictates modifier application order.
	uint UUID;
	uint HomeDistance; // 0 for the home node, of course.
	int PosX, PosY; // Home is (0, 0), adjacent west is (-1, 0), etc.
	Array<uint> Neighbors; // Each element is another node's UUID.
	bool FreeAccess;

	private class<BIO_ModifierGene> GeneType;
	private BIO_WeaponModifier Modifier;

	bool Active() const
	{
		return Modifier != null || UUID == 0;
	}

	void InsertModifier(BIO_ModifierGene gene)
	{
		if (gene == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"`BIO_WMGNode::InsertModifier()` received a null pointer."
			);
		}

		GeneType = gene.GetClass();
		Modifier = gene.ExtractModifier();
	}

	BIO_WeaponModifier ExtractModifier()
	{
		GeneType = null;
		let ret = Modifier;
		Modifier = null;
		return ret;
	}

	void ClearModifier()
	{
		GeneType = null;
		Modifier = null;
	}

	void Apply(BIO_Weapon weap)
	{
		Modifier.Apply(weap);
	}

	class<BIO_Gene> GetGeneType() const { return GeneType; }
	readOnly<BIO_WeaponModifier> GetModifier() const { return Modifier.AsConst(); }
}

// Each weapon instance has a pointer to one of these.
class BIO_WeaponModGraph play
{
	Array<BIO_WMGNode> Nodes;

	static BIO_WeaponModGraph Create(uint qualityMin = 0, uint qualityMax = 0)
	{
		let ret = new('BIO_WeaponModGraph');

		ret.Nodes.Push(new('BIO_WMGNode'));
		// All home fields left to their defaults

		if (qualityMax < qualityMin)
		{
			Console.Printf(
				Biomorph.LOGPFX_WARN ..
				"Invalid quality arguments given to `BIO_WeaponModGraph::Create()`: "
				"%d min., %d max.", qualityMin, qualityMax
			);
		}
		else if (qualityMin > 0 && qualityMax > 0)
		{
			ret.TryGenerateNodes(Random[BIO_WMod](qualityMin, qualityMax));
		}

		return ret;
	}

	void Apply(BIO_Weapon weap)
	{
		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (Nodes[i].Active())
				Nodes[i].Apply(weap);
		}
	}

	void TryGenerateNodes(uint count = 1)
	{
		Array<BIO_WMGNode> cNodes;

		for (uint i = 0; i < count; i++)
		{
			cNodes.Copy(Nodes);

			for (uint j = cNodes.Size() - 1; j >= 0; j--)
			{
				// If a node has a neighbor on each cardinal side,
				// nothing can be put next to it
				if (cNodes[j].Neighbors.Size() >= 4)
				{
					cNodes.Delete(j);
					continue;
				}

				let candidate = cNodes[j];

				// Which adjacent slots are available?
				Array<int> availX, availY;
				GetOpenAdjacencies(candidate, availX, availY);

				if (availX.Size() < 1 || availY.Size() < 1)
				{
					cNodes.Delete(j);
					continue;
				}
			}

			if (cNodes.Size() < 1)
				return;

			let n = Random[BIO_WMod](0, cNodes.Size() - 1);
			let neighbor = cNodes[n];

			let node = new('BIO_WMGNode');
			node.UUID = Nodes.Push(node);

			Array<int> availX, availY;
			GetOpenAdjacencies(neighbor, availX, availY);
			let p = Random[BIO_WMod](0, availX.Size() - 1);
			node.PosX = availX[p] + neighbor.PosX;
			node.PosY = availY[p] + neighbor.PosY;

			node.HomeDistance = neighbor.HomeDistance + 1;

			node.Neighbors.Push(neighbor.UUID);
			neighbor.Neighbors.Push(node.UUID);

			cNodes.Clear();
		}
	}

	private void GetOpenAdjacencies(BIO_WMGNode candidate,
		in out Array<int> availX, in out Array<int> availY) const
	{
		availX.PushV(-1, 1, 0, 0);
		availY.PushV(0, 0, -1, 1);
		uint obstructed = 0;

		for (uint k = 0; k < Nodes.Size(); k++)
		{
			if (Nodes[k].PosX == candidate.PosX - 1 &&
				Nodes[k].PosY == candidate.PosY)
			{
				obstructed |= (1 << 0);
				continue;
			}

			if (Nodes[k].PosX == candidate.PosX + 1 &&
				Nodes[k].PosY == candidate.PosY)
			{
				obstructed |= (1 << 1);
				continue;
			}

			if (Nodes[k].PosX == candidate.PosX &&
				Nodes[k].PosY == candidate.PosY - 1)
			{
				obstructed |= (1 << 2);
				continue;
			}

			if (Nodes[k].PosX == candidate.PosX &&
				Nodes[k].PosY == candidate.PosY + 1)
			{
				obstructed |= (1 << 3);
				continue;
			}
		}

		for (uint k = availX.Size() - 1; k >= 0; k--)
		{
			if (obstructed & (1 << k))
			{
				availX.Delete(k);
				availY.Delete(k);
			}
		}
	}

	// Accessibility checker ///////////////////////////////////////////////////

	bool NodeAccessible(uint node) const
	{
		if (node >= Nodes.Size())
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Queried accessibility of illegal node %d.", node);
			return false;
		}

		if (node == 0) // Home node
			return true;

		// Completely unconnected nodes are permanently accessible
		if (Nodes[node].Neighbors.Size() < 1 ||
			Nodes[node].FreeAccess)
			return true;

		Array<uint> visited;

		if (NodeAccessibleViaFreeAccess(node, visited))
			return true;

		return NodeAccessibleImpl(node, 0, visited);
	}

	private bool NodeAccessibleImpl(uint tgt, uint cur,
		in out Array<uint> visited) const
	{
		if (cur == tgt)
			return true;

		visited.Push(cur);
		bool curActive = Nodes[cur].Active();

		for (uint i = 0; i < Nodes[cur].Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;

			for (uint j = 0; j < Nodes[ndx].Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Neighbors[j];

				if (Nodes[nb].Active() && curActive &&
					NodeAccessibleImpl(tgt, ndx, visited))
					return true;
			}
		}

		return false;
	}

	private bool NodeAccessibleViaFreeAccess(uint tgt,
		in out Array<uint> visited) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].FreeAccess) continue;

			for (uint j = 0; j < Nodes[i].Neighbors.Size(); j++)
			{
				let nb = Nodes[i].Neighbors[j];

				if (NodeAccessibleImpl(tgt, i, visited))
					return true;
			}
		}

		return false;
	}

	// Extended accessibility checker //////////////////////////////////////////

	// This function and its helpers below allow the user to submit a custom array
	// of nodes which are actually active. This was useful in the 2nd prototype's
	// perk tree, which needed to append the current menu selection to the
	// real active nodes for determining accessibility. Now, it's just an unused
	// holdover, waiting for another moment to become useful.

	bool NodeAccessibleEx(uint node, in out Array<uint> active) const
	{
		if (node >= Nodes.Size())
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Queried accessibility of illegal node %d.", node);
			return false;
		}

		if (node == 0) // Home node
			return true;

		// Completely unconnected nodes are permanently accessible
		if (Nodes[node].Neighbors.Size() < 1 ||
			Nodes[node].FreeAccess)
			return true;

		Array<uint> visited;

		if (NodeAccessibleViaFreeAccessEx(node, active, visited))
			return true;

		return NodeAccessibleExImpl(node, 0, active, visited);
	}

	private bool NodeAccessibleExImpl(uint tgt, uint cur,
		in out Array<uint> active, in out Array<uint> visited) const
	{
		if (cur == tgt)
			return true;

		visited.Push(cur);
		bool curActive = active.Find(cur) != active.Size();

		for (uint i = 0; i < Nodes[cur].Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;

			for (uint j = 0; j < Nodes[ndx].Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Neighbors[j];

				if (active.Find(nb) != active.Size() && curActive &&
					NodeAccessibleExImpl(tgt, ndx, active, visited))
					return true;
			}
		}

		return false;
	}

	private bool NodeAccessibleViaFreeAccessEx(uint tgt,
		in out Array<uint> active, in out Array<uint> visited) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].FreeAccess) continue;

			for (uint j = 0; j < Nodes[i].Neighbors.Size(); j++)
			{
				let nb = Nodes[i].Neighbors[j];

				if (NodeAccessibleExImpl(tgt, i, active, visited))
					return true;
			}
		}

		return false;
	}

	// Other introspective helpers /////////////////////////////////////////////

	bool NodeHasNeighborNorth(uint index) const
	{
		for (uint i = 0; i < Nodes[index].Neighbors.Size(); i++)
		{
			let nbr = Nodes[Nodes[index].Neighbors[i]];

			if (nbr.PosX == Nodes[index].PosX &&
				nbr.PosY == (Nodes[index].PosY + 1))
			{
				return true;
			}
		}

		return false;
	}

	bool NodeHasNeighborEast(uint index) const
	{
		for (uint i = 0; i < Nodes[index].Neighbors.Size(); i++)
		{
			let nbr = Nodes[Nodes[index].Neighbors[i]];

			if (nbr.PosX == (Nodes[index].PosX + 1) &&
				nbr.PosY == Nodes[index].PosY)
			{
				return true;
			}
		}

		return false;
	}

	bool NodeHasNeighborSouth(uint index) const
	{
		for (uint i = 0; i < Nodes[index].Neighbors.Size(); i++)
		{
			let nbr = Nodes[Nodes[index].Neighbors[i]];

			if (nbr.PosX == Nodes[index].PosX &&
				nbr.PosY == (Nodes[index].PosY - 1))
			{
				return true;
			}
		}

		return false;
	}

	bool NodeHasNeighborWest(uint index) const
	{
		for (uint i = 0; i < Nodes[index].Neighbors.Size(); i++)
		{
			let nbr = Nodes[Nodes[index].Neighbors[i]];

			if (nbr.PosX == (Nodes[index].PosX - 1) &&
				nbr.PosY == Nodes[index].PosY)
			{
				return true;
			}
		}

		return false;
	}

	BIO_WMGNode GetNodeByPosition(int x, int y) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
			if (Nodes[i].PosX == x && Nodes[i].PosY == y)
				return Nodes[i];

		return null;
	}

	bool TestDuplicateAllowance(BIO_Gene gene) const
	{
		let mgene = BIO_ModifierGene(gene);

		if (mgene != null)
		{
			if (mgene.GetModifier().AllowMultiple())
				return true;

			for (uint i = 0; i < Nodes.Size(); i++)
			{
				let mod = Nodes[i].GetModifier();

				if (mod == null)
					continue;

				if (mod.GetClass() == mgene.GetModifier().GetClass())
					return false;
			}
		}

		return true;
	}

	readOnly<BIO_WeaponModGraph> AsConst() const { return self; }
}
