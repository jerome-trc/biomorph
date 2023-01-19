/// A Shotgun counterpart.
class BIO_RiotStormgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_RIOTSTORMGUN_TAG";
		Obituary "$BIO_RIOTSTORMGUN_OB";
		// Inventory.Icon 'RIOTZ0';
		Inventory.PickupMessage "$BIO_RIOTSTORMGUN_PKUP";
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;
	}

	States
	{
		// ???
	}
}
