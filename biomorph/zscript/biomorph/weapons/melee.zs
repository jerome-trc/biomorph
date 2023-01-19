/// Take note that there's no discrete Chainsaw replacement in Biomorph. The item
/// that replaces Chainsaw pickups is just an upgrade for the player's melee.
class BIO_Melee : BIO_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_MELEE_TAG";
		Obituary "$BIO_MELEE_OB";
		// Inventory.Icon 'MELEZ0';
		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;
	}

	States
	{
		// ???
	}
}
