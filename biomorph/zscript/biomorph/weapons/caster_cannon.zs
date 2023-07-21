/// A BFG9000 counterpart.
/// Derived from Final Doomer's Quantum Accelerator.
class biom_CasterCannon : biom_Weapon
{
	protected biom_wdat_CasterCannon data;

	Default
	{
		Tag "$BIOM_CASTERCANNON_TAG";
		Obituary "$BIOM_CASTERCANNON_OB";

		// Inventory.Icon 'FDQAZ0';
		Inventory.PickupMessage "$BIOM_CASTERCANNON_PKUP";

		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;

		biom_Weapon.DataClass 'biom_wdat_CasterCannon';
		biom_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}


class biom_wdat_CasterCannon : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
