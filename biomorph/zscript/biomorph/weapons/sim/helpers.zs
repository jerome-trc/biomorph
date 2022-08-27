// Introspection.
extend class BIO_WeaponModSimulator
{
	// Skips upgrade nodes.
	uint RealNodeSize() const
	{
		uint ret = 0;

		for (uint i = 0; i < Nodes.Size(); i++)
			if (!Nodes[i].IsMorph())
				ret++;

		return ret;
	}

	// Never returns the home node (0).
	uint RandomNode(bool accessible = false, bool unoccupied = false) const
	{
		Array<uint> eligibles;

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (accessible && !NodeAccessible(i))
				continue;

			if (unoccupied && Nodes[i].IsOccupied())
				continue;

			eligibles.Push(i);
		}

		return eligibles[Random[BIO_WMod](0, eligibles.Size() - 1)];
	}

	uint GeneValue() const
	{
		uint ret = 0;

		for (uint i = 0; i < Nodes.Size(); i++)
			if (Nodes[i].IsOccupied())
				ret += 1;

		return Weap.ModCost(ret);
	}

	uint CommitCost() const
	{
		uint ret = 0;

		for (uint i = 0; i < Weap.ModGraph.Nodes.Size(); i++)
		{
			let realNode = Weap.ModGraph.Nodes[i];
			let simNode = Nodes[i];

			// Is this node pending occupation or extraction?
			if (realNode.GeneType != simNode.GetGeneType())
				ret += 1;
		}

		return Weap.ModCost(ret);
	}

	uint MorphCost(uint node) const
	{
		uint ret = GeneValue() + CommitCost();
		let morph = Nodes[node].MorphRecipe;
		ret *= morph.MutagenCostMultiplier();
		ret += morph.MutagenCostAdded();
		return ret;
	}

	class<BIO_Gene> GetGeneType(uint gene, bool node) const
	{
		class<BIO_Gene> ret = null;

		if (node)
			ret = Nodes[gene].Gene.GetType();
		else
			ret = Genes[gene].GetType();

		return ret;
	}

	uint LowestGeneLootWeight() const
	{
		uint ret = BIO_Gene.LOOTWEIGHT_MAX;

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let gene_t = Nodes[i].GetGeneType();

			if (gene_t == null)
				continue;

			let defs = GetDefaultByType(gene_t);

			if (defs.LootWeight < ret)
				ret = defs.LootWeight;
		}

		return ret;
	}

	bool ContainsGeneOfType(class<BIO_Gene> type) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
			if (Nodes[i].GetGeneType() == type)
				return true;

		return false;
	}

	bool HasModifierWithCoreFlags(BIO_WeaponCoreModFlags flags,
		uint count = 1, bool ignoreMultiplier = true) const
	{
		uint c = 0;

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let mod = Nodes[i].GetModifier();

			if (mod == null)
				continue;

			BIO_WeaponCoreModFlags cf = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags _ = BIO_WPMF_NONE;
			[cf, _] = mod.Flags();

			if ((cf & flags) == flags)
			{
				if (ignoreMultiplier)
					c++;
				else
					c += Nodes[i].Multiplier;
			}
		}

		return c >= count;
	}

	bool HasModifierWithPipelineFlags(BIO_WeaponPipelineModFlags flags,
		uint count = 1, bool ignoreMultiplier = true) const
	{
		uint c = 0;

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let mod = Nodes[i].GetModifier();

			if (mod == null)
				continue;

			BIO_WeaponCoreModFlags _ = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags pf = BIO_WPMF_NONE;
			[_, pf] = mod.Flags();

			if ((pf & flags) == flags)
			{
				if (ignoreMultiplier)
					c++;
				else
					c += Nodes[i].Multiplier;
			}
		}

		return c >= count;
	}

	bool HasModifierWithFlags(
		BIO_WeaponCoreModFlags coreFlags,
		BIO_WeaponPipelineModFlags pipelineFlags,
		uint count = 1, bool ignoreMultiplier = true) const
	{
		uint c = 0;

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let mod = Nodes[i].GetModifier();

			if (mod == null)
				continue;

			BIO_WeaponCoreModFlags cf = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags pf = BIO_WPMF_NONE;
			[cf, pf] = mod.Flags();

			if (((cf & coreFlags) == coreFlags) &&
				((pf & pipelineFlags) == pipelineFlags))
			{
				if (ignoreMultiplier)
					c++;
				else
					c += Nodes[i].Multiplier;
			}
		}

		return c >= count;
	}

	// Note that a gene will pass the check if its loot weight is lower or equal.
	bool ContainsGeneByLootWeight(uint lootWeight) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			let gene_t = Nodes[i].GetGeneType();

			if (gene_t == null)
				continue;

			let defs = GetDefaultByType(gene_t);

			if (defs.LootWeight <= lootWeight)
				return true;
		}

		return false;
	}

	// Includes a node's multiplier.
	uint CountGene(class<BIO_Gene> type) const
	{
		uint ret = 0;

		for (uint i = 0; i < Nodes.Size(); i++)
			if (Nodes[i].GetGeneType() == type)
				ret += Nodes[i].Multiplier;

		return ret;
	}

	bool NodeHasFirstOfGene(uint node, class<BIO_Gene> type) const
	{
		if (Nodes[node].GetGeneType() != type)
			return false;

		bool ret = true;
		Array<uint> nodesWithGene;

		for (uint i = 0; i < Nodes.Size(); i++)
		{
			if (Nodes[i].GetGeneType() == type)
				nodesWithGene.Push(i);
		}

		return nodesWithGene[0] == node;
	}

	BIO_WeaponModSimNode GetNodeByPosition(int x, int y, bool includeFake = false)
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			if (!includeFake && Nodes[i].IsMorph())
				continue;

			if (Nodes[i].Basis.PosX == x && Nodes[i].Basis.PosY == y)
				return Nodes[i];
		}
	
		return null;
	}

	uint FirstOpenInventorySlot() const
	{
		for (uint i = 0; i < Genes.Size(); i++)
			if (Genes[i] == null)
				return i;

		return Genes.Size();
	}

	uint FirstOpenNode() const
	{
		for (uint i = 1; i < Nodes.Size(); i++)
			if (!Nodes[i].IsOccupied())
				return i;

		return Nodes.Size();
	}

	bool InventoryFull() const
	{
		for (uint i = 0; i < Genes.Size(); i++)
			if (Genes[i] == null)
				return false;

		return true;
	}

	bool GraphIsFull() const
	{
		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (Nodes[i].IsMorph())
				continue;

			if (!Nodes[i].IsOccupied())
				return false;
		}

		return true;
	}

	// Will return `true` if every node in the graph is unoccupied.
	bool GraphIsHomogeneous() const
	{
		Array<class<BIO_Gene> > types;

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (Nodes[i].IsMorph())
				continue;
		
			let gene_t = Nodes[i].GetGeneType();

			if (types.Find(gene_t) == types.Size())
				types.Push(gene_t);
		}

		return types.Size() == 1;
	}

	bool AnyPendingGraphChanges() const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
			if (Nodes[i].Basis.GeneType != Nodes[i].GetGeneType())
				return true;

		return false;
	}

	bool IsValid() const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
			if (!Nodes[i].Valid)
				return false;

		return true;
	}
}
