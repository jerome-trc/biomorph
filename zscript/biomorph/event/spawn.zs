extend class BIO_EventHandler
{
	override void WorldThingSpawned(WorldEvent event)
	{
		if (event.Thing == null || event.Thing.bMissile || event.Thing.bIsMonster)
			return;

		if (event.Thing is "Inventory")
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

		if (ReplaceShotgun(event) || ReplaceChaingun(event))
			return;

		if (ReplaceArmor(event))
			return;
	}

	private void FinalizeSpawn(Class<Actor> toSpawn, Actor eventThing) const
	{
		if (toSpawn == null)
		{
			Actor.Spawn("Unknown", eventThing.Pos, NO_REPLACE);
			// For diagnostic purposes, don't destroy the original thing
		}
		else
		{
			Actor.Spawn(toSpawn, eventThing.Pos);
			eventThing.Destroy();
		}
	}

	private bool ReplaceSmallAmmo(WorldEvent event) const
	{
		if (event.Thing.GetClass() == 'Clip')
			FinalizeSpawn('BIO_Clip', event.Thing);
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

		if (Random(0, 8) == 0)
			Actor.Spawn('BIO_WeaponUpgradeKitSpawner', event.Thing.Pos);

		FinalizeSpawn(choice, event.Thing);
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

	private bool ReplaceShotgun(WorldEvent event) const
	{
		if (event.Thing.GetClass() != 'BIO_Shotgun') return false;

		// If a Shotgun has been dropped (as opposed to hand-placed on the map),
		// almost always replace it with an ammo pickup
		if (Level.MapTime > 0 && Random(0, 15) != 0)
			FinalizeSpawn('BIO_Shell', event.Thing);

		return true;
	}

	private bool ReplaceChaingun(WorldEvent event) const
	{
		if (event.Thing.GetClass() != 'BIO_Chaingun') return false;

		// If a Chaingun has been dropped (as opposed to hand-placed on the map),
		// almost always replace it with an ammo pickup
		if (Level.MapTime > 0 && Random(0, 15) != 0)
			FinalizeSpawn('BIO_Clip', event.Thing);

		return true;
	}
}
