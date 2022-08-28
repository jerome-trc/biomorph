// Critical path operations.
extend class BIO_WeaponModSimulator
{
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
			let simNode = new('BIO_WMS_Node');
			simNode.Basis = graph.Nodes[i].Copy();
			simNode.Basis.Flags &= ~BIO_WMGNF_MUTED;

			if (simNode.Basis.GeneType != null)
			{
				let g = new('BIO_WMS_GeneVirtual');
				g.Type = simNode.Basis.GeneType;
				simNode.Gene = g;
			}

			simNode.Multiplier = 1;
			simNode.Valid = true;
			simNode.Update();
			ret.Nodes.Push(simNode);
		}

		let globals = BIO_Global.Get();
		Array<BIO_WeaponMorphRecipe> recipes;
		globals.GetMorphsFromWeaponType(Weap.GetClass(), recipes);

		for (uint i = 0; i < recipes.Size(); i++)
		{
			let simNode = new('BIO_WMS_Node');
			simNode.Basis = new('BIO_WMGNode');
			[simNode.Basis.PosX, simNode.Basis.PosY] =
				graph.RandomAvailableAdjacency();
			simNode.MorphRecipe = recipes[i];
			simNode.Basis.UUID = ret.Nodes.Push(simNode);
		}

		ret.RebuildGeneInventory();

		// Simulators are created when opening the weapon mod menu,
		// at which point the graph is necessarily in a valid state
		ret.Simulate();
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

	void Simulate()
	{
		Weap.Reset();

		if (Weap.OperatingMode1 != null)
			Weap.OpModes[0] = BIO_WeaponOperatingMode.Create(Weap.OperatingMode1, Weap);
		if (Weap.OperatingMode2 != null)
			Weap.OpModes[1] = BIO_WeaponOperatingMode.Create(Weap.OperatingMode2, Weap);

		Weap.SetDefaults();

		if (Weap.OpModes[0] != null)
			Weap.OpModes[0].SideEffects(Weap);
		if (Weap.OpModes[1] != null)
			Weap.OpModes[1].SideEffects(Weap);

		Weap.SetupAmmo();
		Weap.SetupMagazines();

		// First pass sets node defaults
		// Additionally, check if any nodes are disconnected,
		// and if any per-gene-type limits are being exceeded

		Array<class<BIO_Gene> > genetypes;
		Array<uint> genecounts;

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			Nodes[i].Multiplier = 1;
			Nodes[i].Valid = true;
			Nodes[i].Message = "";

			if (Nodes[i].IsOccupied())
			{
				if (!NodeAccessible(i))
				{
					Nodes[i].Valid = false;
					Nodes[i].Message = "$BIO_MENU_WEAPMOD_INACCESSIBLE";
				}

				let gene_t = Nodes[i].GetGeneType();
				let gtc = genetypes.Find(gene_t);

				if (gtc == genetypes.Size())
				{
					gtc = genetypes.Push(gene_t);
					genecounts.Push(0);
				}

				let defs = GetDefaultByType(gene_t);

				if (++genecounts[gtc] > defs.Limit)
				{
					let template = defs.Limit == 1 ?
						StringTable.Localize("$BIO_MENU_WEAPMOD_OVERLIMIT_SINGULAR") :
						StringTable.Localize("$BIO_MENU_WEAPMOD_OVERLIMIT_PLURAL");

					Nodes[i].Valid = false;
					Nodes[i].Message = String.Format(template, defs.Limit);
				}
			}
		}

		// Second pass invokes supports

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].Valid)
				continue;

			let gene_t = Nodes[i].GetGeneType();

			if (!(gene_t is 'BIO_SupportGene'))
				continue;

			let node = Nodes[i];

			BIO_GeneContext context;
			context.Sim = AsConst();
			context.Weap = Weap.AsConst();
			context.Node = i;
			context.NodeCount = node.Multiplier;
			context.TotalCount = CountGene(gene_t);
			context.First = NodeHasFirstOfGene(i, gene_t);

			string _ = "";
			[node.Valid, node.Message] = node.Compatible(AsConst(), context);

			if (!node.Valid)
				continue;

			node.Message = node.Apply(Weap, self, context);
		}

		// Third pass applies modifiers

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].Valid)
				continue;

			let gene_t = Nodes[i].GetGeneType();

			if (!(gene_t is 'BIO_ModifierGene'))
				continue;

			let node = Nodes[i];
			string _ = "";

			BIO_GeneContext context;
			context.Sim = AsConst();
			context.Weap = Weap.AsConst();
			context.Node = i;
			context.NodeCount = node.Multiplier;
			context.TotalCount = CountGene(gene_t);
			context.First = NodeHasFirstOfGene(i, gene_t);

			[node.Valid, node.Message] = node.Compatible(AsConst(), context);

			if (!node.Valid)
				continue;

			if (!node.Basis.IsMuted())
			{
				node.Message = node.Apply(Weap, self, context);
				Weap.SetupAmmo();
				Weap.SetupMagazines();
			}
		}

		// Fourth pass applies actives

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].Valid)
				continue;

			let gene_t =  Nodes[i].GetGeneType();

			if (!(gene_t is 'BIO_ActiveGene'))
				continue;

			let node = Nodes[i];
			string _ = "";

			BIO_GeneContext context;
			context.Sim = AsConst();
			context.Weap = Weap.AsConst();
			context.Node = i;
			context.NodeCount = node.Multiplier;
			context.TotalCount = CountGene(gene_t);
			context.First = NodeHasFirstOfGene(i, gene_t);

			[node.Valid, node.Message] = node.Compatible(AsConst(), context);

			if (!node.Valid)
				continue;

			node.Message = node.Apply(Weap, self, context);
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
			if (Nodes[i].IsMorph())
				break;

			let gene_t = Nodes[i].GetGeneType();

			Nodes[i].Basis.GeneType = gene_t;

			if (gene_t != null)
			{
				let defs = GetDefaultByType(gene_t);

				if (defs.LockOnCommit)
				{
					Nodes[i].Basis.Lock();
				}
			}

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
			let rGene = BIO_WMS_GeneReal(Nodes[i].Gene);

			if (rGene == null)
				continue;

			if (rGene.Gene == null)
				Nodes[i].Gene = rGene.VirtualCopy(Nodes[i].Basis.GeneType);
		}
	}

	void Revert()
	{
		RebuildGeneInventory();

		for (uint i = 0; i < Weap.ModGraph.Nodes.Size(); i++)
		{
			Nodes[i] = new('BIO_WMS_Node');
			Nodes[i].Basis = Weap.ModGraph.Nodes[i].Copy();

			if (Nodes[i].Basis.GeneType != null)
			{
				let g = new('BIO_WMS_GeneVirtual');
				g.Type = Nodes[i].Basis.GeneType;
				Nodes[i].Gene = g;
			}

			Nodes[i].Multiplier = 1;
			Nodes[i].Valid = true;
			Nodes[i].Update();
		}

		Simulate();
	}

	void CommitAndClose()
	{
		Commit();
		PostCommit();
		Destroy();
	}

	void RunAndClose()
	{
		Simulate();
		CommitAndClose();
	}
}
