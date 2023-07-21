/// A Pistol counterpart.
/// Infinite ammo, 7-round magazine, highly damaging.
class biom_Pistol : biom_Weapon
{
	protected biom_WeapDat_Pistol data;

	Default
	{
		Tag "$BIOM_PISTOL_TAG";
		Obituary "$BIOM_PISTOL_OB";

		// Inventory.Icon 'HGUNZ0';
		Inventory.PickupMessage "$BIOM_PISTOL_PKUP";

		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 2;

		biom_Weapon.DataClass 'biom_WeapDat_Pistol';
		biom_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class biom_WeapDat_Pistol : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
