/// A BFG9000 counterpart.
/// Derived from Final Doomer's Quantum Accelerator.
class BIOM_CasterCannon : BIOM_Weapon
{
	protected BIOM_WeapDat_CasterCannon data;

	Default
	{
		Tag "$BIOM_CASTERCANNON_TAG";
		Obituary "$BIOM_CASTERCANNON_OB";

		// Inventory.Icon 'FDQAZ0';
		Inventory.PickupMessage "$BIOM_CASTERCANNON_PKUP";

		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;

		BIOM_Weapon.DataClass 'BIOM_WeapDat_CasterCannon';
		BIOM_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}


class BIOM_WeapDat_CasterCannon : BIOM_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
