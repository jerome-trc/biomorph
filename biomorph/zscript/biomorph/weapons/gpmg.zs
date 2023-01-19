/// A Chaingun counterpart. "General purpose machine gun".
/// Works almost the same as its vanilla cousin but without the 2-round burst.
class BIO_GPMG : BIO_Weapon
{
	Default
	{
		Tag "$BIO_GPMG_TAG";
		Obituary "$BIO_GPMG_OB";
		// Inventory.Icon 'GPMGZ0';
		Inventory.PickupMessage "$BIO_GPMG_PKUP";
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
	}

	States
	{
		// ???
	}
}
