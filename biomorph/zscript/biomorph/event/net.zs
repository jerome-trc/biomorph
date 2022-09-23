// Network event handling.
extend class BIO_EventHandler
{
	enum Regen
	{
		REGEN_GLOBAL_LOOTCORE,
		REGEN_GLOBAL_WEAPLOOT,
		REGEN_GLOBAL_MUTALOOT,
		REGEN_GLOBAL_GENELOOT,
		REGEN_GLOBAL_MORPH,
		REGEN_MAGAZINES
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

	enum UserNetEvent
	{
		USREVENT_NET_GLOBALREGEN
	}

	const EVENT_WEAPMOD = "bio_wmod";

	final override void NetworkProcess(ConsoleEvent event)
	{
		// Normal gameplay events

		NetEvent_WeapMod(event);

		// Debugging events

		NetEvent_User(event);
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
			WeapMod_Commit(pawn);
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

	private static void WeapMod_Commit(BIO_Player pawn)
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

		Array<BIO_GeneData> toGive;
		Array<Inventory> toDestroy;

		for (uint i = 0; i < sim.Genes.Size(); i++)
		{
			if (sim.Genes[i] == null)
				continue;

			toGive.Push(sim.Genes[i].Drain());
		}

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
			if (i is 'BIO_Gene')
				toDestroy.Push(i);

		sim.Commit();

		for (uint i = 0; i < toDestroy.Size(); i++)	
		{
			toDestroy[i].Amount = 0;
			toDestroy[i].DepleteOrDestroy();
		}

		for (uint i = 0; i < toGive.Size(); i++)
		{
			let given = BIO_Gene(Actor.Spawn(toGive[i].GetActorType(), pawn.Pos));
			given.Fill(toGive[i]);
			given.AttachToOwner(pawn);
		}

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
		Array<BIO_GeneData> toGive;
		Array<Inventory> toDestroy;

		for (uint i = 0; i < sim.Genes.Size(); i++)
		{
			if (sim.Genes[i] == null)
				continue;

			toGive.Push(sim.Genes[i].Drain());
		}

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
			if (i is 'BIO_Gene')
				toDestroy.Push(i);

		for (uint i = 0; i < toDestroy.Size(); i++)	
		{
			toDestroy[i].Amount = 0;
			toDestroy[i].DepleteOrDestroy();
		}

		for (uint i = 0; i < toGive.Size(); i++)
		{
			let given = BIO_Gene(Actor.Spawn(toGive[i].GetActorType(), pawn.Pos));
			given.AttachToOwner(pawn);
			given.Fill(toGive[i]);
		}

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

	private void NetEvent_User(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_usrnet"))
			return;
	
		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_usrnet`."
			);
			return;
		}

		if (event.Player != Net_Arbitrator)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Net event `bio_usrnet` "
				"can only be invoked by the network arbitrator."
			);
			return;
		}

		switch (event.Args[0])
		{
		case USREVENT_NET_GLOBALREGEN:
			NetEvent_Regen(event);
			break;
		default:
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal user network event argument: %d",
				event.Args[0]
			);
			return;
		}
	}

	private void NetEvent_Regen(ConsoleEvent event)
	{
		switch (event.Args[1])
		{
		case REGEN_GLOBAL_LOOTCORE:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating loot core subsystem..."
			);
			Globals.RegenLootCore();
			return;
		case REGEN_GLOBAL_WEAPLOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating weapon loot tables..."
			);
			Globals.RegenWeaponLoot();
			return;
		case REGEN_GLOBAL_MUTALOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating mutagen loot table..."
			);
			Globals.RegenMutagenLoot();
			return;
		case REGEN_GLOBAL_GENELOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating gene loot table..."
			);
			Globals.RegenGeneLoot();
			return;
		case REGEN_GLOBAL_MORPH:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating weapon morph recipe cache..."
			);
			Globals.RegenWeaponMorphCache();
			return;
		case REGEN_MAGAZINES:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating all players' magazine collections..."
			);

			for (uint i = 0; i < MAXPLAYERS; i++)
				if (PlayerInGame[i] && Players[i].MO is 'BIO_Player')
					BIO_Player(Players[i].MO).RegenMagazines();

			return;
		default:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Invalid global regen requested: %d", event.Args[0]
			);
		}
	}
}
