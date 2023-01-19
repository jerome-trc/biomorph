/// A Pistol counterpart.
/// Infinite ammo, 7-round magazine, highly damaging.
class BIO_Pistol : BIO_Weapon
{
	Default
	{
		Tag "$BIO_PISTOL_TAG";
		Obituary "$BIO_PISTOL_OB";
		// Inventory.Icon 'HGUNZ0';
		Inventory.PickupMessage "$BIO_PISTOL_PKUP";
		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 2;
	}

	States
	{
		// ???
	}
}
