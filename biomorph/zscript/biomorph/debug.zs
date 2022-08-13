// Acts as a more specialised alternative to `give all`.
class BIO_All : Inventory
{
	Default
	{
		-COUNTITEM
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.AUTOACTIVATE

		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
		Inventory.RestrictedTo 'BIO_Player';
	}

	final override bool Use(bool pickup)
	{
		let pawn = BIO_Player(Owner);
		pawn.GiveInventory('BIO_Backpack', 1);

		uint mwh = pawn.MaxWeaponsHeld, mgh = pawn.MaxGenesHeld;

		pawn.MaxWeaponsHeld = uint.MAX;
		pawn.MaxGenesHeld = uint.MAX;

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let t = (class<Inventory>)(AllActorClasses[i]);

			if (t == null || t.IsAbstract())
				continue;

			if (t is 'BIO_Weapon')
			{
				if (t == 'BIO_Unarmed')
					continue;

				if (pawn.FindInventory(t))
					continue;

				pawn.GiveInventory(t, 1);
			}
			else if (t is 'BIO_Mutagen')
			{
				pawn.GiveInventory(t, GetDefaultByType(t).MaxAmount);
			}
			else if (t is 'Ammo' && !(t is 'BIO_Magazine'))
			{
				pawn.GiveInventory(t, GetDefaultByType(t).MaxAmount);
			}
			else if (t is 'BIO_Gene')
			{
				pawn.GiveInventory(t, GetDefaultByType(t).MaxAmount);
			}
		}

		pawn.MaxWeaponsHeld = mwh;
		pawn.MaxGenesHeld = mgh;
		return true;
	}
}
