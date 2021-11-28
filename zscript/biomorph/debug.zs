class BIO_All : Inventory
{
	Default
	{
		-COUNTITEM
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.AUTOACTIVATE

		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
	}

	override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		bioPlayer.GiveInventory('BIO_Backpack', 1);

		uint mwh = bioPlayer.MaxWeaponsHeld;
		bioPlayer.MaxWeaponsHeld = uint.MAX;

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let t = (Class<Inventory>)(AllActorClasses[i]);

			if (t is 'BIO_Weapon')
			{
				// Don't attempt to instantiate any abstract classes
				if (t == 'BIO_Weapon' || t == 'BIO_DualWieldWeapon')
					continue;

				if (t == 'BIO_Fist') continue;
				if (bioPlayer.FindInventory(t)) continue;

				bioPlayer.GiveInventory(t, 1);
			}
			else if (t is 'BIO_Mutagen' && t != 'BIO_Mutagen')
			{
				bioPlayer.GiveInventory(t, GetDefaultByType(t).MaxAmount);
			}
			else if (t is 'Ammo')
			{
				let defs = GetDefaultByType(t);
				if (defs.bIgnoreSkill) continue; // Skip magazines
				bioPlayer.GiveInventory(t, defs.MaxAmount);
			}
		}

		bioPlayer.MaxWeaponsHeld = mwh;
		return true;
	}
}
