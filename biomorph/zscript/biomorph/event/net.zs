// Network event handling.
extend class BIO_EventHandler
{
	enum GlobalRegen
	{
		GLOBALREGEN_LOOTCORE,
		GLOBALREGEN_WEAPLOOT,
		GLOBALREGEN_MUTALOOT,
		GLOBALREGEN_GENELOOT,
		GLOBALREGEN_MORPH
	}

	enum WeapModOp
	{
		WEAPMODOP_START,
		WEAPMODOP_INSERT,
		WEAPMODOP_NODEMOVE,
		WEAPMODOP_INVMOVE,
		WEAPMODOP_EXTRACT,
		WEAPMODOP_SWAPNODEANDSLOT,
		WEAPMODOP_SIMULATE,
		WEAPMODOP_COMMIT,
		WEAPMODOP_REVERT,
		WEAPMODOP_MORPH,
		WEAPMODOP_STOP
	}

	const EVENT_WEAPMOD = "bio_wmod";

	final override void NetworkProcess(ConsoleEvent event)
	{
		// Normal gameplay events

		NetEvent_WeapMod(event);

		// Debugging events

		NetEvent_GlobalDataRegen(event);
	}

	private static void NetEvent_WeapMod(ConsoleEvent event)
	{
		if (!(event.Name ~== EVENT_WEAPMOD))
			return;

		if (event.Player != ConsolePlayer)
			return;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return;
		}

		let pawn = BIO_Player(Players[ConsolePlayer].MO);

		if (pawn == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR .. EVENT_WEAPMOD ..
				" was illegally invoked by a non-Biomorph player pawn."
			);
			return;
		}

		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);

		if (weap == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR .. EVENT_WEAPMOD ..
				" was illegally invoked for a non-Biomorph weapon."
			);
			return;
		}

		switch (event.Args[0])
		{
		case WEAPMODOP_START:
			BIO_WeaponModSimulator.Create(weap);
			break;
		case WEAPMODOP_INSERT:
			BIO_WeaponModSimulator.Get(weap).InsertGene(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_NODEMOVE:
			BIO_WeaponModSimulator.Get(weap).NodeMove(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_INVMOVE:
			BIO_WeaponModSimulator.Get(weap).InventoryMove(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_SWAPNODEANDSLOT:
			BIO_WeaponModSimulator.Get(weap).SwapNodeAndSlot(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_EXTRACT:
			BIO_WeaponModSimulator.Get(weap).ExtractGene(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_SIMULATE:
			BIO_WeaponModSimulator.Get(weap).Simulate();
			break;
		case WEAPMODOP_COMMIT:
			WeapMod_Commit(pawn, event.Args[1]);
			break;
		case WEAPMODOP_REVERT:
			BIO_WeaponModSimulator.Get(weap).Revert();
			break;
		case WEAPMODOP_MORPH:
			WeapMod_Morph(pawn, uint(event.Args[1]));
			break;
		case WEAPMODOP_STOP:
			BIO_WeaponModSimulator.Get(weap).Destroy();
			break;
		default:
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal weapon mod. operation requested: %d",
				event.Args[0]
			);
			break;
		}
	}

	private static void WeapMod_Commit(BIO_Player pawn, int geneTID)
	{
		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);
		let sim = BIO_WeaponModSimulator.Get(weap);
		let cost = sim.CommitCost();

		if (pawn.CountInv('BIO_Muta_General') < cost)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Player %s has insufficient mutagen to commit modifications.",
				pawn.Player.GetUserName()
			);
			return;
		}

		Array<class<BIO_Gene> > toGive;
		Array<Inventory> toDestroy;

		for (uint i = 0; i < sim.Genes.Size(); i++)
		{
			if (sim.Genes[i] == null)
				continue;

			toGive.Push(sim.Genes[i].GetType());
		}

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
		{
			if (i is 'BIO_Gene')
				toDestroy.Push(i);
		}

		sim.Commit();

		for (uint i = 0; i < toDestroy.Size(); i++)	
		{
			toDestroy[i].Amount = 0;
			toDestroy[i].DepleteOrDestroy();
		}

		for (uint i = 0; i < toGive.Size(); i++)
			pawn.GiveInventory(toGive[i], 1);

		sim.PostCommit();
		pawn.TakeInventory('BIO_Muta_General', cost);
		pawn.A_StartSound("bio/mutation/general");
	}

	private static void WeapMod_Morph(BIO_Player pawn, uint node)
	{
		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);
		let sim = BIO_WeaponModSimulator.Get(weap);
		let cost = sim.MorphCost(node);

		if (pawn.CountInv('BIO_Muta_General') < cost)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Player %s has insufficient mutagen to morph weapon %s.",
				pawn.Player.GetUserName(), weap.GetClassName()
			);
			return;
		}

		let morph = sim.Nodes[node].MorphRecipe;
		Array<class<BIO_Gene> > toGive;
		Array<Inventory> toDestroy;

		for (uint i = 0; i < sim.Genes.Size(); i++)
		{
			if (sim.Genes[i] == null)
				continue;

			toGive.Push(sim.Genes[i].GetType());
		}

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
		{
			if (i is 'BIO_Gene')
				toDestroy.Push(i);
		}

		for (uint i = 0; i < toDestroy.Size(); i++)	
		{
			toDestroy[i].Amount = 0;
			toDestroy[i].DepleteOrDestroy();
		}

		for (uint i = 0; i < toGive.Size(); i++)
			pawn.GiveInventory(toGive[i], 1);

		uint qual = weap.InheritedGraphQuality() + morph.QualityAdded();

		weap.Amount = 0;
		weap.DepleteOrDestroy();

		pawn.GiveInventory(morph.Output(), 1);
		let output = BIO_Weapon(pawn.FindInventory(morph.Output()));
		output.Mutate();
		output.ModGraph.TryGenerateNodes(qual);

		pawn.TakeInventory('BIO_Muta_General', cost);
		pawn.A_StartSound("bio/mutation/general");
		pawn.A_SelectWeapon(morph.Output());
	}

	private void NetEvent_GlobalDataRegen(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_globalregen"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Net event `bio_globalregen` can only be manually invoked."
			);
			return;
		}

		if (event.Player != Net_Arbitrator)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Net event `bio_globalregen` "
				"can only be invoked by the network arbitrator."
			);
			return;
		}

		switch (event.Args[0])
		{
		case GLOBALREGEN_LOOTCORE:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating loot core subsystem..."
			);
			Globals.RegenLootCore();
			return;
		case GLOBALREGEN_WEAPLOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating weapon loot tables..."
			);
			Globals.RegenWeaponLoot();
			return;
		case GLOBALREGEN_MUTALOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating mutagen loot table..."
			);
			Globals.RegenMutagenLoot();
			return;
		case GLOBALREGEN_GENELOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating gene loot table..."
			);
			Globals.RegenGeneLoot();
			return;
		case GLOBALREGEN_MORPH:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating weapon morph recipe cache..."
			);
			Globals.RegenWeaponMorphCache();
			return;
		default:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Invalid global regen requested: %d", event.Args[0]
			);
		}
	}
}
