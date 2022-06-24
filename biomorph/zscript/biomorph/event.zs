// Note to reader: classes are defined using `extend` blocks for code folding.

// Class declaration, registration/unregistration, new-game.
class BIO_EventHandler : EventHandler
{
	private BIO_Global Globals;

	final override void OnRegister()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Registering event handler...");

		if (Globals == null)
			Globals = BIO_Global.Get();

		name ldtoken_tn = 'LDLegendaryMonsterToken';
		LDToken = ldtoken_tn;
	}

	final override void OnUnregister()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Unregistering event handler...");
	}

	final override void NewGame()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling NewGame event...");

		Globals = BIO_Global.Create();
	}

	const EVENT_FIRSTPKUP = "bio_firstpkup";

	static clearscope void BroadcastFirstPickup(name typeName)
	{
		EventHandler.SendNetworkEvent(EVENT_FIRSTPKUP .. ":" .. typeName);
	}
}

// Network event handling.
extend class BIO_EventHandler
{
	enum GlobalRegen
	{
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

		weap.Amount = 0;
		weap.DepleteOrDestroy();

		pawn.GiveInventory(morph.Output(), 1);
		let output = pawn.FindInventory(morph.Output());

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

// Console event handling.
extend class BIO_EventHandler
{
	final override void ConsoleProcess(ConsoleEvent event)
	{
		if (event.Name.Length() < 5 || !(event.Name.Left(4) ~== "bio_"))
			return;

		// Normal gameplay events

		ConEvent_WeapModMenu(event);

		// Debugging events

		ConEvent_Help(event);
		ConEvent_MonsVal(event);
	}

	private static ui void ConEvent_WeapModMenu(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_weapmodmenu")) return;

		if (GameState != GS_LEVEL)
			return;

		if (Players[ConsolePlayer].Health <= 0)
			return;

		if (!(Players[ConsolePlayer].MO is 'BIO_Player'))
			return;

		if (Menu.GetCurrentMenu() is 'BIO_WeaponModMenu')
			return;

		if (!(Players[ConsolePlayer].ReadyWeapon is 'BIO_Weapon'))
			return;

		Menu.SetMenu('BIO_WeaponModMenu');
	}

	private static ui void ConEvent_Help(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_help"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_help`.");
			return;
		}

		Console.Printf(
			Biomorph.LOGPFX_INFO .. "\n"
			"\c[Gold]Console events:\c-\n"
			"\tbio_help_\n"
			"\tbio_monsval_\n"
			"\c[Gold]Network events:\c-\n"
			"\tbio_weaplootregen_\n"
			"\tbio_mutalootregen_\n"
			"\tbio_genelootregen_\n"
			"\tbio_morphregen_"
		);
	}

	private ui void ConEvent_MonsVal(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_monsval"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_monsval`."
			);
			return;
		}

		let val = MapTotalMonsterValue();
		let loot = val / BIO_Global.LOOT_VALUE_THRESHOLD;

		Console.Printf(
			Biomorph.LOGPFX_INFO ..
			"Total monster value in this level: %d", val
		);
		Console.Printf(
			Biomorph.LOGPFX_INFO ..
			"Number of times loot value threshold crossed: %d", loot
		);
	}
}

// Death handling.
extend class BIO_EventHandler
{
	// Assigned in `OnRegister()`
	// (will be null if LegenDoom or its Lite version isn't loaded).
	private class<Inventory> LDToken;

	clearscope uint MapTotalMonsterValue() const
	{
		let iter = ThinkerIterator.Create('Actor');
		uint ret = 0;

		while (true)
		{
			let mons = Actor(iter.Next());

			if (mons == null)
				break;

			if (!mons.bIsMonster)
				continue;

			ret += Globals.GetMonsterValue(mons);
		}

		return ret;
	}

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster)
			return;

		let pawn = BIO_Player(event.Thing.Target);

		if (pawn != null)
			pawn.OnKill(event.Thing, event.Inflictor);

		if (event.Thing.FindInventory(LDToken))
		{
			// TODO:
			// If we made it here, this was a legendary monster from LegenDoom
			// or LegenDoom Lite. Drop some extra-special loot
		}

		Globals.LootValueBuffer += Globals.GetMonsterValue(event.Thing);

		while (Globals.DrainLootValueBuffer())
		{
			if (Random[BIO_Loot](1, 20) == 1)
			{
				event.Thing.A_SpawnItemEx(
					Globals.RandomGeneType(),
					0.0, 0.0, 32.0,
					FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
					FRandom(0.0, 360.0)
				);
			}
			else
			{
				event.Thing.A_SpawnItemEx(
					Globals.RandomMutagenType(),
					0.0, 0.0, 32.0,
					FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
					FRandom(0.0, 360.0)
				);
			}
		}
	}
}

// Spawn event handler.
extend class BIO_EventHandler
{
	final override void WorldThingSpawned(WorldEvent event)
	{
		if (!(event.Thing is 'Inventory') || event.Thing == null)
			return;

		{
			let item = Inventory(event.Thing);

			if (item.Owner != null || item.Master != null)
				return;
		}

		if (OnWeaponSpawn(event))
			return;

		OnAmmoSpawn(event);
	}

	private static void FinalizeSpawn(class<Actor> toSpawn, Actor eventThing)
	{
		if (toSpawn == null)
		{
			Actor.Spawn('Unknown', eventThing.Pos, NO_REPLACE);
			// For diagnostic purposes, don't destroy the original thing
		}
		else
		{
			Actor.Spawn(toSpawn, eventThing.Pos);
			eventThing.Destroy();
		}
	}

	private bool OnWeaponSpawn(WorldEvent event) const
	{
		class<Actor> t = event.Thing.GetClass();

		if (t == 'Shotgun')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_SHOTGUN), event.Thing);
		else if (t == 'Chaingun')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_CHAINGUN), event.Thing);
		else if (t == 'SuperShotgun')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_SSG), event.Thing);
		else if (t == 'RocketLauncher')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_RLAUNCHER), event.Thing);
		else if (t == 'PlasmaRifle')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_PLASRIFLE), event.Thing);
		else if (t == 'BFG9000')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_BFG9000), event.Thing);
		else if (t == 'Chainsaw')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_CHAINSAW), event.Thing);
		else if (t == 'Pistol')
			FinalizeSpawn(Globals.LootWeaponType(BIO_WSCAT_PISTOL), event.Thing);
		else
			return false;

		return true;
	}

	private bool OnAmmoSpawn(WorldEvent event) const
	{
		if (event.Thing.GetClass() == 'Clip')
		{
			if (Random[BIO_Loot](1, 50) == 1)
			{
				Actor.Spawn(
					Globals.LootWeaponType(BIO_WSCAT_PISTOL),
					event.Thing.Pos
				);
			}

			FinalizeSpawn('BIO_Clip', event.Thing);
		}
		else if (event.Thing.GetClass() == 'Shell')
			FinalizeSpawn('BIO_Shell', event.Thing);
		else if (event.Thing.GetClass() == 'RocketAmmo')
			FinalizeSpawn('BIO_RocketAmmo', event.Thing);
		else if (event.Thing.GetClass() == 'Cell')
			FinalizeSpawn('BIO_Cell', event.Thing);
		else if (event.Thing.GetClass() == 'ClipBox')
			FinalizeSpawn('BIO_ClipBox', event.Thing);
		else if (event.Thing.GetClass() == 'ShellBox')
			FinalizeSpawn('BIO_ShellBox', event.Thing);
		else if (event.Thing.GetClass() == 'RocketBox')
			FinalizeSpawn('BIO_RocketBox', event.Thing);
		else if (event.Thing.GetClass() == 'CellPack')
			FinalizeSpawn('BIO_CellPack', event.Thing);
		else
			return false;

		return true;
	}
}

// Static helpers for sending network events.
extend class BIO_EventHandler
{
	static clearscope void WeapModSim_Start()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_START
		);
	}

	static clearscope void WeapModSim_InsertGeneFromInventory(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_INSERT,
			node, slot
		);
	}

	static clearscope void WeapModSim_MoveGeneBetweenNodes(
		uint fromNode, uint toNode)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_NODEMOVE,
			fromNode, toNode
		);
	}

	static clearscope void WeapModSim_MoveGeneBetweenInventorySlots(
		uint fromSlot, uint toSlot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_INVMOVE,
			fromSlot, toSlot
		);
	}

	static clearscope void WeapModSim_ExtractGeneFromNode(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_EXTRACT,
			node, slot
		);
	}

	static clearscope void WeapModSim_Run()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_SIMULATE	
		);
	}

	static clearscope void WeapModSim_Commit()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_COMMIT
		);
	}

	static clearscope void WeapModSim_Revert()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_REVERT
		);
	}

	static clearscope void WeapModSim_Morph(uint node)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_MORPH,
			node
		);
	}

	static clearscope void WeapModSim_Stop()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_STOP
		);
	}
}
