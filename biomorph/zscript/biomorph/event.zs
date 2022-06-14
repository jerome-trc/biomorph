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
	enum BIO_WeapModOp
	{
		WEAPMODOP_ADD,
		WEAPMODOP_REMOVE,
		WEAPMODOP_REFRESH,
		WEAPMODOP_COMMIT
	}

	const EVENT_WEAPMOD = "bio_wmod";

	final override void NetworkProcess(ConsoleEvent event)
	{
		// Normal gameplay events

		NetEvent_WeapMod(event);
	}

	private static void NetEvent_WeapMod(ConsoleEvent event)
	{
		if (event.Name.Length() < 8 || !(event.Name.Left(8) ~== EVENT_WEAPMOD))
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
		case WEAPMODOP_ADD:
			WeapMod_Add(weap, uint(event.Args[1]), event.Args[2]);
			break;
		case WEAPMODOP_REMOVE:
			WeapMod_Remove(weap, uint(event.Args[1]), event.Args[2]);
			break;
		case WEAPMODOP_REFRESH:
			weap.Refresh();
			break;
		case WEAPMODOP_COMMIT:
			WeapMod_Commit(pawn, event.Args[1]);
			break;
		}
	}

	private static void WeapMod_Add(BIO_Weapon weap, uint node, int geneTID)
	{
		let gene = BIO_Gene.FindByTID(geneTID);

		if (gene is 'BIO_ModifierGene')
		{
			weap.ModGraph.Nodes[node].InsertModifier(BIO_ModifierGene(gene));
		}
	}

	private static void WeapMod_Remove(BIO_Weapon weap, uint node, int geneTID)
	{
		let gene = BIO_Gene.FindByTID(geneTID);

		if (gene is 'BIO_ModifierGene')
		{
			let mod = weap.ModGraph.Nodes[node].ExtractModifier();
			BIO_ModifierGene(gene).ReinsertModifier(mod);
		}
	}

	private static void WeapMod_Commit(BIO_Player pawn, int geneTID)
	{
		if (pawn.CountInv('BIO_Muta_General') <
			BIO_Weapon(pawn.Player.ReadyWeapon).ModCost)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Player %s has insufficient mutagen to commit modifications.",
				pawn.Player.GetUserName()
			);
			return;
		}

		pawn.TakeInventory(
			'BIO_Muta_General',
			BIO_Weapon(pawn.Player.ReadyWeapon).ModCost
		);

		let gene = BIO_Gene.FindByTID(geneTID);
		gene.DepleteOrDestroy();
		pawn.A_StartSound("bio/mutation/general");
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
			"\c[Gold]Console events:\c-\n"
			"\tbio_help_\n"
			"\tbio_wmod:<weapon mod class name> [>1 to force] [>1 to pre-reset]");
	}

	private static ui void ConEvent_MonsVal(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_monsval"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_monsval`.");
			return;
		}

		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Total monster value in this level: %d",
			MapTotalMonsterValue());
	}
}

// Death handling.
extend class BIO_EventHandler
{
	const LOOT_VALUE_THRESHOLD = 3200;

	private uint LootValueBuffer;

	// Assigned in `OnRegister()`
	// (will be null if LegenDoom or its Lite version isn't loaded).
	private class<Inventory> LDToken;

	static clearscope uint GetMonsterValue(Actor mons)
	{
		let ret = uint(Max(mons.Default.Health, mons.GetMaxHealth(true)));
		// TODO: Refine
		return ret;
	}

	static clearscope uint MapTotalMonsterValue()
	{
		let iter = ThinkerIterator.Create('Actor');
		uint ret = 0;

		while (true)
		{
			let mons = Actor(iter.Next());

			if (mons == null)
				break;

			if (!mons.bIsMonster || MonsterIsLostSoul(mons))
				continue;

			ret += GetMonsterValue(mons);
		}

		return ret;
	}

	static clearscope bool MonsterIsLostSoul(Actor mons)
	{
		// TODO: Support for however many monster packs
		return
			(mons is 'LostSoul');
	}

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster)
			return;

		if (event.Thing.FindInventory(LDToken))
		{
			// TODO:
			// If we made it here, this was a legendary monster from LegenDoom
			// or LegenDoom Lite. Drop some extra-special loot
		}
		else if (MonsterIsLostSoul(event.Thing))
		{
			// There's no way to know if a Lost Soul was a Pain Elemental spawn,
			// so just forbid Lost Souls from giving anything to prevent farming
			return;
		}

		LootValueBuffer += GetMonsterValue(event.Thing);

		while (LootValueBuffer >= LOOT_VALUE_THRESHOLD)
		{
			event.Thing.A_SpawnItemEx(
				Globals.RandomMutagenType(),
				0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0)
			);

			LootValueBuffer -= LOOT_VALUE_THRESHOLD;
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
	static clearscope void AddGene(uint node, int geneTID)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_ADD,
			node, geneTID
		);
	}

	static clearscope void RemoveGene(uint node, int geneTID)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_REMOVE,
			node, geneTID
		);
	}

	static clearscope void RefreshWeapon()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_REFRESH	
		);
	}

	static clearscope void CommitGene(int geneTID)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_COMMIT,
			geneTID
		);
	}
}
