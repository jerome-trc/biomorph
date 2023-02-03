/// Take note that there's no discrete Chainsaw replacement in Biomorph. The item
/// that replaces Chainsaw pickups is just an upgrade for the player's melee.
class BIOM_Melee : BIOM_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIOM_MELEE_TAG";
		Obituary "$BIOM_MELEE_OB";
		// Inventory.Icon 'MELEZ0';
		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;
	}

	States
	{
		// ???
	}
}
