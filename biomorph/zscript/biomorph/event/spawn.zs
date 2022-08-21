// Spawn event handler.
extend class BIO_EventHandler
{
	final override void WorldThingSpawned(WorldEvent event)
	{
		if (event.Thing is 'Inventory')
		{
			{
				let item = Inventory(event.Thing);

				if (item.Owner != null || item.Master != null)
					return;
			}

			OnAmmoSpawn(event);
		}
		else if (event.Thing is 'BIO_WeaponReplacer')
		{
			OnWeaponSpawn(event);
		}
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
			let spawned = Actor.Spawn(toSpawn, eventThing.Pos);
			
			spawned.ChangeTID(eventThing.TID);
			spawned.Special = eventThing.Special;
			spawned.Args[0] = eventThing.Args[0];
			spawned.Args[1] = eventThing.Args[1];
			spawned.Args[2] = eventThing.Args[2];
			spawned.Args[3] = eventThing.Args[3];
			spawned.Args[4] = eventThing.Args[4];

			eventThing.Destroy();
		}
	}

	private void OnWeaponSpawn(WorldEvent event) const
	{
		let replacer = BIO_WeaponReplacer(event.Thing);

		if (replacer == null)
			return;

		class<BIO_Weapon> lwt = Globals.LootWeaponType(replacer.SpawnCategory);

		if (GetDefaultByType(lwt).Unique)
			S_StartSound("bio/loot/unique", CHAN_AUTO);

		FinalizeSpawn(lwt, event.Thing);
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

extend class BIO_EventHandler
{
	static const name VALIANT_REPLACEES[] = {
		'ValiantPistol',
		'ValiantShotgun',
		'ValiantSSG',
		'ValiantChaingun'
	};

	static const class<BIO_WeaponReplacer> VALIANT_REPLACEMENTS[] = {
		'BIO_WeaponReplacer_Pistol',
		'BIO_WeaponReplacer_Shotgun',
		'BIO_WeaponReplacer_SSG',
		'BIO_WeaponReplacer_Chaingun'
	};

	final override void CheckReplacement(ReplaceEvent event)
	{
		// `DestroyAllThinkers` with CCards can VM abort if not for this check
		if (Globals == null)
			return;

		if (!Globals.InValiant())
			return;

		for (uint i = 0; i < VALIANT_REPLACEES.Size(); i++)
		{
			if (event.Replacee == VALIANT_REPLACEES[i])
			{
				event.Replacement = VALIANT_REPLACEMENTS[i];
				return;
			}
		}
	}
}
