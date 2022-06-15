class BIO_WeaponModSimNode
{
	// This is a reflection of the real state of the weapon's mod graph.
	// Only gets altered when the simulation gets committed, so it and the graph
	// are always in perfect sync.
	BIO_WMGNode Basis;
	// Null if no gene is being simulated in this node.
	// Acts as a representative for what will end up in `Basis.GeneType`.
	BIO_WeaponModSimGene Gene;
	bool Valid;
	string InvalidMessage;

	bool IsOccupied() const { return Gene != null; }
	bool IsActive() const { return IsOccupied() || Basis.UUID == 0; }

	BIO_WeaponModifier GetModifier() const
	{
		return Gene == null ? null : Gene.Modifier;
	}

	void UpdateModifier()
	{
		if (Gene != null)
			Gene.UpdateModifier();
	}

	class<BIO_Gene> GetGeneType() const
	{
		return Gene == null ? null : Gene.GetType();
	}
}

// (Rat): Not a sum type, but close enough.
class BIO_WeaponModSimGene abstract
{
	BIO_WeaponModifier Modifier;

	abstract void UpdateModifier();
	abstract class<BIO_Gene> GetType() const;
}

// When representing genes that can be moved around the simulated graph, this
// is used for genes which were in the player's inventory at simulation start.
class BIO_WeaponModSimGeneReal : BIO_WeaponModSimGene
{
	BIO_Gene Gene;

	final override void UpdateModifier()
	{
		if (Gene is 'BIO_ModifierGene')
			Modifier = BIO_WeaponModifier(new(BIO_ModifierGene(Gene).ModType));
		else
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A weapon mod sim gene object has a null internal pointer."
			);
		}
	}

	final override class<BIO_Gene> GetType() const { return Gene.GetClass(); }
}

// When representing genes that can be moved around the simulated graph, this
// is used for genes which were slotted into the tree at simulation start,
// since those genes have no associated items.
class BIO_WeaponModSimGeneVirtual : BIO_WeaponModSimGene
{
	class<BIO_Gene> Type;

	final override void UpdateModifier()
	{
		if (Type is 'BIO_ModifierGene')
		{
			let mgene_t = (class<BIO_ModifierGene>)(Type);
			let defs = GetDefaultByType(mgene_t);
			Modifier = BIO_WeaponModifier(new(defs.ModType));
		}
		else
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A weapon mod sim gene object has a null internal class."
			);
		}
	}

	final override class<BIO_Gene> GetType() const { return Type; }
}

class BIO_WeaponModSimulator : Thinker
{
	const STATNUM = Thinker.STAT_STATIC + 1;

	private BIO_Weapon Weap;
	private bool Valid;

	// Representation for the state of the player's gene inventory. Upon commit,
	// genes are given to/taken away from the player according to this.
	// Is sized against `BIO_Player::MaxGenesHeld`.
	Array<BIO_WeaponModSimGene> Genes;
	// Upon commit, the weapon's mod graph is rebuilt to reflect this.
	Array<BIO_WeaponModSimNode> Nodes;

	// Operations //////////////////////////////////////////////////////////////

	static BIO_WeaponModSimulator Create(BIO_Weapon weap)
	{
		if (weap.ModGraph == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Attempted illegal creation of a weapon mod simulator "
				"for a weapon with no mod graph (%s).", weap.GetClassName()
			);
			return null;
		}

		let ret = new('BIO_WeaponModSimulator');
		ret.ChangeStatNum(STATNUM);
		ret.Weap = weap;
		let graph = ret.Weap.ModGraph;

		for (uint i = 0; i < graph.Nodes.Size(); i++)
		{
			let simNode = new('BIO_WeaponModSimNode');
			simNode.Basis = graph.Nodes[i].Copy();

			if (simNode.Basis.GeneType != null)
			{
				let g = new('BIO_WeaponModSimGeneVirtual');
				g.Type = simNode.Basis.GeneType;
				simNode.Gene = g;
			}

			simNode.Valid = true;
			simNode.UpdateModifier();
			ret.Nodes.Push(simNode);
		}

		ret.RebuildGeneInventory();

		// Simulators are created when opening the weapon mod menu,
		// at which point the graph is necessarily in a valid state
		ret.Valid = true;
		return ret;
	}

	static clearscope BIO_WeaponModSimulator Get(
		BIO_Weapon weap, bool fallible = false)
	{
		let iter = ThinkerIterator.Create('BIO_WeaponModSimulator', STATNUM);
		BIO_WeaponModSimulator ret = null;

		while (ret = BIO_WeaponModSimulator(iter.Next(true)))
		{
			if (ret.Weap == weap)
				return ret;
		}

		if (!fallible)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Failed to find weapon modification simulator for weapon: %p (%s)",
				weap, weap.GetClassName()
			);
		}

		return null;
	}

	// Take a gene out of the inventory and put it into a node.
	void InsertGene(uint node, uint slot)
	{
		if (Nodes[node].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to add gene to occupied node %d.",
				node
			);
			return;
		}

		if (Genes[slot] == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to add gene from empty slot %d.",
				slot
			);
			return;
		}

		Nodes[node].Gene = Genes[slot];
		Genes[slot] = null;
	}

	// Move a gene from one node to another.
	void NodeMove(uint fromNode, uint toNode)
	{
		if (!Nodes[fromNode].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene from unfilled node %d.",
				fromNode
			);
			return;
		}

		if (Nodes[toNode].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene to occupied node %d.",
				toNode
			);
			return;
		}

		let temp = Nodes[toNode].Gene;
		Nodes[toNode].Gene = Nodes[fromNode].Gene;
		Nodes[fromNode].Gene = temp;
	}

	// Move a gene from one inventory slot to another.
	void InventoryMove(uint fromSlot, uint toSlot)
	{
		if (Genes[fromSlot] == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene from empty slot %d.",
				fromSlot
			);
			return;
		}

		if (Genes[toSlot] != null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene to occupied slot %d.",
				toSlot
			);
			return;
		}

		Genes[toSlot] = Genes[fromSlot];
		Genes[fromSlot] = null;
	}

	// Take a gene out of a node and put it back into the inventory.
	// If `slot >= Genes.Size()`, the first available slot is used.
	void ExtractGene(uint node, uint slot)
	{
		if (!Nodes[node].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to remove gene from gene-less node %d.",
				node
			);
			return;
		}

		if (slot >= Genes.Size())
		{
			for (uint i = 0; i < Genes.Size(); i++)
			{
				if (Genes[i] != null)
					continue;

				Genes[i] = Nodes[node].Gene;
				Nodes[node].Gene = null;
				return;
			}

			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Found no open inventory slot for gene extracted from node %d.",
				node
			);
		}

		// User specified a slot to return the gene to
		if (Genes[slot] != null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to extract gene into occupied slot %d.",
				slot
			);
			return;
		}

		Genes[slot] = Nodes[node].Gene;
		Nodes[node].Gene = null;
	}

	void Simulate()
	{
		Valid = true;

		Weap.Reset();
		Weap.SetDefaults();

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			Nodes[i].Valid = true;

			if (Nodes[i].GetModifier() == null)
				continue;

			[Nodes[i].Valid, Nodes[i].InvalidMessage] =
				Nodes[i].GetModifier().Compatible(weap.AsConst());

			if (Nodes[i].Valid)
				Nodes[i].Basis.Apply(weap);
			else
				Valid = false;
		}
	}

	void Commit()
	{
		if (!IsValid())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Attempted to commit a weapon mod simulator in an invalid state."
			);
			return;
		}

		weap.ModGraph.Nodes.Clear();

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			Nodes[i].Basis.GeneType = Nodes[i].GetGeneType();
			weap.ModGraph.Nodes.Push(Nodes[i].Basis.Copy());
		}

		Simulate();
	}

	void PostCommit()
	{
		RebuildGeneInventory();

		// Nodes which contained a pointer to a real gene item will have had
		// their data invalidated by whoever manipulates the player's inventory
		// after calling `Commit()`. Convert them to virtual genes
		
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let rGene = BIO_WeaponModSimGeneReal(Nodes[i].Gene);

			if (rGene == null)
				continue;

			if (rGene.Gene == null)
			{
				rGene = null;
				let g = new('BIO_WeaponModSimGeneVirtual');
				g.Type = Nodes[i].Basis.GeneType;
				Nodes[i].Gene = g;
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
		if (Nodes[node].Basis.Neighbors.Size() < 1 ||
			Nodes[node].Basis.FreeAccess)
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
		bool curActive = Nodes[cur].IsActive();

		for (uint i = 0; i < Nodes[cur].Basis.Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Basis.Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;

			for (uint j = 0; j < Nodes[ndx].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Basis.Neighbors[j];

				if (Nodes[nb].IsActive() && curActive &&
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
			if (!Nodes[i].Basis.FreeAccess) continue;

			for (uint j = 0; j < Nodes[i].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[i].Basis.Neighbors[j];

				if (NodeAccessibleImpl(tgt, i, visited))
					return true;
			}
		}

		return false;
	}

	// Extended accessibility checker //////////////////////////////////////////

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
		if (Nodes[node].Basis.Neighbors.Size() < 1 ||
			Nodes[node].Basis.FreeAccess)
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

		for (uint i = 0; i < Nodes[cur].Basis.Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Basis.Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;

			for (uint j = 0; j < Nodes[ndx].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Basis.Neighbors[j];

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
			if (!Nodes[i].Basis.FreeAccess) continue;

			for (uint j = 0; j < Nodes[i].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[i].Basis.Neighbors[j];

				if (NodeAccessibleExImpl(tgt, i, active, visited))
					return true;
			}
		}

		return false;
	}

	// Other introspective helpers /////////////////////////////////////////////

	class<BIO_Gene> GetGeneType(uint gene, bool node) const
	{
		class<BIO_Gene> ret = null;

		if (node)
			ret = Nodes[gene].Gene.GetType();
		else
			ret = Genes[gene].GetType();

		return ret;
	}

	// If `node` is `false`, test `Genes[gene]` instead of `Nodes[gene]`.
	bool TestDuplicateAllowance(uint gene, bool node) const
	{
		BIO_WeaponModSimGene toTest;
		
		if (node)
		{
			if (!Nodes[node].IsOccupied())
			{
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"Attempted to test duplicate allowance of gene at unoccupied node %d.",
					gene
				);
				return false;
			}

			toTest = Nodes[gene].Gene;
		}
		else
		{
			if (Genes[gene] == null)
			{
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"Attempted to test duplicate allowance of gene at empty slot %d.",
					gene
				);
				return false;
			}

			toTest = Genes[gene];
		}

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let mod = Nodes[i].GetModifier();

			if (mod == null)
				continue;

			if (mod.AllowMultiple())
				continue;

			if (mod.GetClass() == toTest.Modifier.GetClass())
				return false;
		}

		return true;
	}

	// Returns `false` if there's no gene to remove, or if removing the gene
	// would render other nodes inaccessible.
	bool CanRemoveGeneFrom(uint node) const
	{
		if (!Nodes[node].IsOccupied())
			return false;

		Array<uint> active;
		active.Push(0);

		for (uint i = 1; i < Nodes.Size(); i++)
			if (Nodes[i].IsActive() && i != node)
				active.Push(i);

		for (uint i = 1; i < active.Size(); i++)
		{
			if (!NodeAccessibleEx(active[i], active))
				return false;
		}

		return true;
	}

	clearscope bool IsValid() const { return Valid; }

	// Other internal implementation details ///////////////////////////////////

	private void RebuildGeneInventory()
	{
		Genes.Clear();

		for (Inventory i = weap.Owner.Inv; i != null; i = i.Inv)
		{
			let gene = BIO_Gene(i);

			if (gene == null)
				continue;

			let simGene = new('BIO_WeaponModSimGeneReal');
			simGene.Gene = gene;
			simGene.UpdateModifier();
			Genes.Push(simGene);
		}

		while (Genes.Size() < BIO_Player(weap.Owner).MaxGenesHeld)
			Genes.Push(null);
	}
}
