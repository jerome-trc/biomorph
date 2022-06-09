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
	final override void NetworkProcess(ConsoleEvent event)
	{
		if (event.Name.Length() < 5 || !(event.Name.Left(4) ~== "bio_"))
			return;
	}
}

// Console event handling.
extend class BIO_EventHandler
{
	final override void ConsoleProcess(ConsoleEvent event)
	{
		if (event.Name.Length() < 5 || !(event.Name.Left(4) ~== "bio_"))
			return;

		// Debugging events

		ConEvent_Help(event);
		ConEvent_MonsVal(event);
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
	// Assigned in `OnRegister()`
	// (will be null if LegenDoom or its Lite version isn't loaded).
	private class<Inventory> LDToken;

	static clearscope uint GetMonsterValue(Actor mons)
	{
		let ret = uint(Max(mons.Default.Health, mons.GetMaxHealth(true)));
		// LATER: Refine
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
		// LATER: Support for however many monster packs
		return
			(mons is 'LostSoul');
	}

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster)
			return;

		if (event.Thing.FindInventory(LDToken))
		{
			// LATER:
			// If we made it here, this was a legendary monster from LegenDoom
			// or LegenDoom Lite. Drop some extra-special loot
		}
		else if (MonsterIsLostSoul(event.Thing))
		{
			// There's no way to know if a Lost Soul was a Pain Elemental spawn,
			// so just forbid Lost Souls from giving anything to prevent farming
			return;
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

	private bool OnAmmoSpawn(WorldEvent event) const
	{
		if (event.Thing.GetClass() == 'Clip')
			FinalizeSpawn('BIO_Clip', event.Thing);
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
