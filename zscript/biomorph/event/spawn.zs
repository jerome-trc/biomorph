extend class BIO_EventHandler
{
	final override void WorldThingSpawned(WorldEvent event)
	{
		if (event.Thing == null || event.Thing.bMissile || event.Thing.bIsMonster)
			return;

		if (event.Thing is 'Inventory')
		{
			let item = Inventory(event.Thing);
			if (item.Owner != null || item.Master != null)
			{
				super.WorldThingSpawned(event);
				return;
			}
		}

		if (ReplaceSmallAmmo(event) || ReplaceBigAmmo(event))
			return;

		if (ReplaceWeapon(event) || ReplaceArmor(event))
			return;

		if (ContextFlags & BIO_EHCF_NOSUPPLYBOXES)
			return;

		TrySpawnSupplyBox(event);
	}

	private void FinalizeSpawn(Class<Actor> toSpawn, Actor eventThing) const
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

	private Class<Ammo> ThriftyClip_T; // Initialized dynamically for fast checks

	private bool ReplaceSmallAmmo(WorldEvent event) const
	{
		if (event.Thing.GetClass() == 'Clip' ||
			event.Thing.GetClass() == ThriftyClip_T)
		{
			if (Random(1, 10) == 1)
				FinalizeSpawn(Globals.LootWeaponType(
					BIO_WEAPCAT_PISTOL), event.Thing);
			else
				FinalizeSpawn('BIO_Clip', event.Thing);
		}
		else if (event.Thing.GetClass() == 'Shell')
			FinalizeSpawn('BIO_Shell', event.Thing);
		else if (event.Thing.GetClass() == 'RocketAmmo')
			FinalizeSpawn('BIO_RocketAmmo', event.Thing);
		else if (event.Thing.GetClass() == 'Cell')
			FinalizeSpawn('BIO_Cell', event.Thing);
		else
			return false;

		return true;
	}

	private bool ReplaceBigAmmo(WorldEvent event) const
	{
		Class<Actor> choice = null;

		if (event.Thing.GetClass() == 'ClipBox')
			choice = 'BIO_ClipBox';
		else if (event.Thing.GetClass() == 'ShellBox')
			choice = 'BIO_ShellBox';
		else if (event.Thing.GetClass() == 'RocketBox')
			choice = 'BIO_RocketBox';
		else if (event.Thing.GetClass() == 'CellPack')
			choice = 'BIO_CellPack';
		else
			return false;

		FinalizeSpawn(choice, event.Thing);
		return true;
	}

	// Initialized dynamically for fast checks
	private Class<Weapon> ValiantShotgun_T, ValiantSSG_T, ValiantChaingun_T;

	private bool ReplaceWeapon(WorldEvent event) const
	{
		Class<Actor> t = event.Thing.GetClass();

		if (t == 'Shotgun')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_SHOTGUN), event.Thing);
		}
		else if (event.Thing.GetClass() == 'Chaingun')
		{
			if (Random(0, 1) == 0)
				FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_RIFLE), event.Thing);
			else
				FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_AUTOGUN), event.Thing);
		}
		else if (t == 'SuperShotgun')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_SSG), event.Thing);
		}
		else if (t == 'RocketLauncher')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_LAUNCHER), event.Thing);
		}
		else if (t == 'PlasmaRifle')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_ENERGY), event.Thing);
		}
		else if (t == 'BFG9000')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_SUPER), event.Thing);
		}
		else if (t == 'Chainsaw')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_MELEE), event.Thing);
		}
		else if (t == 'Pistol')
		{
			FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_PISTOL), event.Thing);
		}
		else if (ContextFlags & BIO_EHCF_VALIANT)
		{
			if (t == ValiantShotgun_T)
				FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_SHOTGUN), event.Thing);
			else if (t == ValiantSSG_T)
				FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_SSG), event.Thing);
			else if (t == ValiantChaingun_T)
			{
				if (Level.MapTime < 1)
				{
					FinalizeSpawn('BIO_ValiantChaingun', event.Thing);
				}
				else
				{
					if (Random(0, 1) == 0)
						FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_RIFLE), event.Thing);
					else
						FinalizeSpawn(Globals.LootWeaponType(BIO_WEAPCAT_AUTOGUN), event.Thing);
				}
			}
		}
		else
			return false;

		return true;
	}

	private bool ReplaceArmor(WorldEvent event) const
	{
		if (event.Thing.GetClass() == 'GreenArmor')
			FinalizeSpawn('BIO_StandardArmor', event.Thing);
		else if (event.Thing.GetClass() == 'BlueArmor')
		{
			if (Random(1, 6) == 1)
				FinalizeSpawn('BIO_ClassifiedArmor', event.Thing);
			else
				FinalizeSpawn('BIO_SpecialtyArmor', event.Thing);
		}
		else
			return false;

		return true;
	}

	static const Class<Actor> SUPPLY_BOX_SPAWNSPOTS[] = {
		'Berserk',
		'PowerupGiver',
		'MapRevealer',
		'Megasphere',
		'Soulsphere'
	};

	private bool TrySpawnSupplyBox(WorldEvent event) const
	{
		for (uint i = 0; i < SUPPLY_BOX_SPAWNSPOTS.Size(); i++)
		{
			if (!(event.Thing is SUPPLY_BOX_SPAWNSPOTS[i])) continue;
			Actor.Spawn('BIO_SupplyBoxSpawner', event.Thing.Pos);
		}

		return false;
	}
}
