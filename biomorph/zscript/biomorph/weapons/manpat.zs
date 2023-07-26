/// A Rocket Launcher counterpart.
/// "Man-portable anti-tank".
class biom_MANPAT : biom_Weapon
{
	protected biom_wdat_MANPAT data;

	Default
	{
		Tag "$BIOM_MANPAT_TAG";
		Obituary "$BIOM_MANPAT_OB";

		// Inventory.Icon 'MANPZ0';
		Inventory.PickupMessage "$BIOM_MANPAT_PKUP";

		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;

		biom_Weapon.DataClass 'biom_wdat_MANPAT';
		biom_Weapon.Grade BIOM_WEAPGRADE_3;
		biom_Weapon.Family BIOM_WEAPFAM_LAUNCHER;
	}

	States
	{
		// ???
	}
}

class biom_wdat_MANPAT : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
