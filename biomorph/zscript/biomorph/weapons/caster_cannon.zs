/// A BFG9000 counterpart.
/// Derived from Final Doomer's Quantum Accelerator.
class BIOM_CasterCannon : BIOM_Weapon
{
	Default
	{
		Tag "$BIOM_CASTERCANNON_TAG";
		Obituary "$BIOM_CASTERCANNON_OB";
		// Inventory.Icon 'FDQAZ0';
		Inventory.PickupMessage "$BIOM_CASTERCANNON_PKUP";
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;
	}

	States
	{
		// ???
	}
}
