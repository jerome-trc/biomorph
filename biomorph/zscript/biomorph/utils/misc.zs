class biom_Utils abstract
{
	static play void GivePowerup(Actor target, class<Powerup> type, int tics)
	{
		let giver = biom_PowerupGiver(Actor.Spawn('biom_PowerupGiver', target.pos));

		if (giver == null)
		{
			Console.PrintF(Biomorph.LOGPFX_ERR ..
				"Failed to grant powerup %s to %s.",
				target.GetClassName(), type.GetClassName()
			);

			return;
		}

		giver.powerupType = type;
		giver.effectTics = tics;
		giver.AttachToOwner(target);
		giver.Use(false);
		target.TakeInventory('biom_PowerupGiver', 1);
	}

	/// Use to ensure that an attempt to give an actor an item always succeeds.
	static play Inventory GiveOrDrop(
		Actor target,
		class<Inventory> type,
		int quantity = 1,
		bool findSubclass = false
	)
	{
		Inventory ret = null;

		if (target.FindInventory(type, findSubclass))
		{
			bool success = false;
			Actor spawned = null;

			for (uint i = 0; i < quantity; i++)
			{
				[success, spawned] = target.A_SpawnItemEx(type,
					1.0, 0.0, 32.0,
					5.0, 0.0, 0.0,
					0.0
				);
				ret = Inventory(spawned);
			}
		}
		else
		{
			target.GiveInventory(type, quantity);
			ret = target.FindInventory(type);
		}

		return ret;
	}

	/// So that actor types can be retrieved from DECORATE code in one line.
	static class<Actor> TypeFromName(name typename) { return typename; }
}
