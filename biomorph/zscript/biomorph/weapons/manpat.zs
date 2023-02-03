/// A Rocket Launcher counterpart.
/// "Man-portable anti-tank".
class BIOM_MANPAT : BIOM_Weapon
{
	Default
	{
		Tag "$BIOM_MANPAT_TAG";
		Obituary "$BIOM_MANPAT_OB";
		// Inventory.Icon 'MANPZ0';
		Inventory.PickupMessage "$BIOM_MANPAT_PKUP";
		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;
	}

	States
	{
		// ???
	}
}
