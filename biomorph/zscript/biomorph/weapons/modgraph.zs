enum BIO_WeaponModGraphNodeFlags : uint8
{
	BIO_WMGNF_NONE = 0,
	BIO_WMGNF_MUTED = 1 << 0,
	BIO_WMGNF_FREEACCESS = 1 << 1,
	BIO_WMGNF_LOCKED = 1 << 2
}

class BIO_WMGNode play
{
	// Corresponds to this node's place in `BIO_WeaponModGraph::Nodes`.
	// Also dictates modifier application order.
	uint UUID;
	uint HomeDistance; // 0 for the home node, of course.
	int PosX, PosY; // Home is (0, 0), adjacent west is (-1, 0), etc.
	Array<uint> Neighbors; // Each element is another node's UUID.
	BIO_WeaponModGraphNodeFlags Flags;

	class<BIO_Gene> GeneType;

	bool Active() const { return GeneType != null || UUID == 0; }
	bool FreeAccess() const { return Flags & BIO_WMGNF_FREEACCESS; }
	bool IsLocked() const { return Flags & BIO_WMGNF_LOCKED; }
	bool IsMuted() const { return Flags & BIO_WMGNF_MUTED; }

	BIO_WMGNode Copy() const
	{
		let ret = new('BIO_WMGNode');
		ret.UUID = UUID;
		ret.HomeDistance = HomeDistance;
		ret.PosX = PosX;
		ret.PosY = PosY;
		ret.Neighbors.Copy(Neighbors);
		ret.Flags = Flags;
		ret.GeneType = GeneType;
		return ret;
	}

	void Serialize(in out Dictionary dict) const
	{
		string base = String.Format("modgraph.%d.", UUID);

		dict.Insert(base .. "home_distance", String.Format("%d", HomeDistance));
		dict.Insert(base .. "pos_x", String.Format("%d", PosX));
		dict.Insert(base .. "pos_y", String.Format("%d", PosY));
		dict.Insert(base .. "flags", String.Format("%d", Flags));
		
		if (GeneType != null)
			dict.Insert(base .. "gene_type", GeneType.GetClassName());
		else
			dict.Insert(base .. "gene_type", "null");

		for (uint i = 0; i < Neighbors.Size(); i++)
		{
			dict.Insert(
				String.Format(base .. "neighbors.%d", i),
				String.Format("%d", Neighbors[i])
			);
		}
	}

	static BIO_WMGNode Deserialize(Dictionary dict, uint uuid)
	{
		string base = String.Format("modgraph.%d.", uuid);
		let ret = new('BIO_WMGNode');

		ret.UUID = uuid;
		ret.HomeDistance = dict.At(base .. "home_distance").ToInt();
		ret.PosX = dict.At(base .. "pos_x").ToInt();
		ret.PosY = dict.At(base .. "pos_y").ToInt();
		ret.Flags = dict.At(base .. "flags").ToInt();
		
		let gene_tn = dict.At(base .. "gene_type");
		
		if (gene_tn != "null")
			ret.GeneType = gene_tn;

		uint nbi = 0;

		do
		{
			let key = base .. String.Format("neighbors.%d", nbi++);
			let val = dict.At(key);

			if (val.Length() < 1)
				break;

			ret.Neighbors.Push(val.ToInt());
		} while (true);

		return ret;
	}

	void Lock() { Flags |= BIO_WMGNF_LOCKED; }
	void Unlock() { Flags &= ~BIO_WMGNF_LOCKED; }
}

// Each weapon instance has a pointer to one of these.
class BIO_WeaponModGraph play
{
	Array<BIO_WMGNode> Nodes;

	static BIO_WeaponModGraph Create(uint numNodes = 0)
	{
		let ret = new('BIO_WeaponModGraph');

		ret.Nodes.Push(new('BIO_WMGNode'));
		// All fields of the home node left to their defaults

		if (numNodes > 0)
			ret.TryGenerateNodes(numNodes);

		return ret;
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

	int, int RandomAvailableAdjacency() const
	{
		Array<BIO_WMGNode> cNodes;
		cNodes.Copy(Nodes);

		for (uint i = cNodes.Size() - 1; i >= 0; i--)
		{
			// If a node has a neighbor on each cardinal side,
			// nothing can be put next to it
			if (cNodes[i].Neighbors.Size() >= 4)
			{
				cNodes.Delete(i);
				continue;
			}

			let candidate = cNodes[i];

			// Which adiacent slots are available?
			Array<int> availX, availY;
			GetOpenAdjacencies(candidate, availX, availY);

			if (availX.Size() < 1 || availY.Size() < 1)
			{
				cNodes.Delete(i);
				continue;
			}
		}

		let neighbor = cNodes[Random[BIO_WMod](0, cNodes.Size() - 1)];
		Array<int> availX, availY;
		GetOpenAdjacencies(neighbor, availX, availY);
		let p = Random[BIO_WMod](0, availX.Size() - 1);
		return neighbor.PosX + availX[p], neighbor.PosY + availY[p];
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

	readOnly<BIO_WeaponModGraph> AsConst() const { return self; }
}
