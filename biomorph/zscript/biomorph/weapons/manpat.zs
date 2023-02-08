/// A Rocket Launcher counterpart.
/// "Man-portable anti-tank".
class BIOM_MANPAT : BIOM_Weapon
{
	protected BIOM_WeapDat_MANPAT data;

	Default
	{
		Tag "$BIOM_MANPAT_TAG";
		Obituary "$BIOM_MANPAT_OB";

		// Inventory.Icon 'MANPZ0';
		Inventory.PickupMessage "$BIOM_MANPAT_PKUP";

		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;

		BIOM_Weapon.DataClass 'BIOM_WeapDat_MANPAT';
		BIOM_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class BIOM_WeapDat_MANPAT : BIOM_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
