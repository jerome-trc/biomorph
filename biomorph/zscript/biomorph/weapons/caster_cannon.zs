/// A BFG9000 counterpart.
/// Derived from Final Doomer's Quantum Accelerator.
class BIO_CasterCannon : BIO_Weapon
{
	Default
	{
		Tag "$BIO_CASTERCANNON_TAG";
		Obituary "$BIO_CASTERCANNON_OB";
		// Inventory.Icon 'FDQAZ0';
		Inventory.PickupMessage "$BIO_CASTERCANNON_PKUP";
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;
	}

	States
	{
		// ???
	}
}
