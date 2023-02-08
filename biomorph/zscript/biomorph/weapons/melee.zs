/// Take note that there's no discrete Chainsaw replacement in Biomorph. The item
/// that replaces Chainsaw pickups is just an upgrade for the player's melee.
class BIOM_Melee : BIOM_Weapon
{
	protected BIOM_WeapDat_Melee data;

	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIOM_MELEE_TAG";
		Obituary "$BIOM_MELEE_OB";

		// Inventory.Icon 'MELEZ0';

		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;

		BIOM_Weapon.DataClass 'BIOM_WeapDat_Melee';
		BIOM_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class BIOM_WeapDat_Melee : BIOM_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
