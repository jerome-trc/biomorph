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

			if (simNode.Basis.Gene != null)
			{
				let g = new('BIO_WMS_GeneVirtual');
				g.Gene = simNode.Basis.Gene;
				simNode.Gene = g;
			}

			simNode.Reset();
			ret.Nodes.Push(simNode);
			ret.Snapshots.Push(BIO_WeaponSnapshot.FromReal(weap.AsConst()));
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
		BIO_Weapon weap,
		bool fallible = false
	)
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
		Weap.SetDefaults();
		Snapshots[0].ImitateReal(Weap.AsConst());

		// Pass 0: set node defaults
		// Additionally, check if any nodes are disconnected,
		// and if any per-modifier-type limits are being exceeded

		Array<class<BIO_WeaponModifier> > modTypes;
		Array<uint> modCounts;

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			Nodes[i].Reset();

			if (!Nodes[i].IsOccupied())
				continue;

			if (!NodeAccessible(i))
			{
				Nodes[i].Valid = false;
				Nodes[i].Message = "$BIO_MENU_WEAPMOD_INACCESSIBLE";
			}

			if (Nodes[i].Gene.IncrementModTypeCounts(modTypes, modCounts))
			{
				let limit = Nodes[i].Gene.Data().Limit();

				let template = limit == 1 ?
					StringTable.Localize("$BIO_MENU_WEAPMOD_OVERLIMIT_SINGULAR") :
					StringTable.Localize("$BIO_MENU_WEAPMOD_OVERLIMIT_PLURAL");

				Nodes[i].Valid = false;
				Nodes[i].Message = String.Format(template, limit);
			}
		}

		BIO_GeneContext context;
		SimPass(BIO_SIMPASS_GRAPHMOD, context); // For node multipliers, flags
		SimPass(BIO_SIMPASS_WEAPMOD, context); // Everything else
	}

	private void SimPass(
		BIO_WeaponModSimPass pass,
		in out BIO_GeneContext context
	)
	{
		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].Valid || !Nodes[i].IsOccupied())
				continue;
			if (Nodes[i].IsMorph())
				break;

			context.Sim = AsConst();
			context.Weap = Weap.AsConst();
			context.Node = i;
			context.NodeCount = Nodes[i].Multiplier;

			Nodes[i].Apply(Weap, self, context, pass);

			if (pass == BIO_SIMPASS_WEAPMOD)
				Snapshots[i].ImitateReal(Weap.AsConst());
		}
	}

	void Commit()
	{
		if (!IsValid())
		{
			string msg =
				"Attempted to commit a weapon mod simulator in an invalid state.";
			
			msg = msg .. "\n\tGenes:\n";

			for (uint i = 1; i < Nodes.Size(); i++)
			{
				let data = Nodes[i].GetGeneData();
			
				if (data == null)
					continue;

				msg.AppendFormat("\t\t%s", data.Repr());

				if (!Nodes[i].Valid)
					msg.AppendFormat(" (%s)", Nodes[i].Message);

				msg = msg .. "\n";
			}

			msg.DeleteLastCharacter();
			Console.Printf(Biomorph.LOGPFX_ERR .. msg);
			return;
		}

		BIO_GeneContext context;
		SimPass(BIO_SIMPASS_ONCOMMIT, context);

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			if (Nodes[i].IsMorph())
				break;

			Nodes[i].Basis.Gene = Nodes[i].GetGeneData();
			Weap.ModGraph.Nodes[i].Imitate(Nodes[i].Basis);
		}

		Simulate();
	}

	void PostCommit()
	{
		Weap.PostSimCommit();
		RebuildGeneInventory();

		// Nodes which contained a pointer to a real gene item will have had
		// their data invalidated by whoever manipulates the player's inventory
		// after calling `Commit()`. Convert them to virtual genes

		for (uint i = 1; i < Nodes.Size(); i++)
		{
			let rGene = BIO_WMS_GeneReal(Nodes[i].Gene);

			if (rGene == null)
				continue;

			if (rGene.Gene == null)
			{
				let virt = new('BIO_WMS_GeneVirtual');
				virt.Gene = Nodes[i].Basis.Gene;
				Nodes[i].Gene = virt;
			}
		}
	}

	void Revert()
	{
		RebuildGeneInventory();

		for (uint i = 0; i < Weap.ModGraph.Nodes.Size(); i++)
		{
			Nodes[i] = new('BIO_WMS_Node');
			Nodes[i].Basis = Weap.ModGraph.Nodes[i].Copy();

			if (Nodes[i].Basis.Gene != null)
			{
				let g = new('BIO_WMS_GeneVirtual');
				g.Gene = Nodes[i].Basis.Gene;
				Nodes[i].Gene = g;
			}

			Nodes[i].Reset();
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
