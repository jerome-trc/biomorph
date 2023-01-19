/// A Rocket Launcher counterpart.
/// "Man-portable anti-tank".
class BIO_MANPAT : BIO_Weapon
{
	Default
	{
		Tag "$BIO_MANPAT_TAG";
		Obituary "$BIO_MANPAT_OB";
		// Inventory.Icon 'MANPZ0';
		Inventory.PickupMessage "$BIO_MANPAT_PKUP";
		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;
	}

	States
	{
		// ???
	}
}
