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
			Actor.Spawn(toSpawn, eventThing.Pos);
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
