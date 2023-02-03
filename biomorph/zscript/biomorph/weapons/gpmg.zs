/// A Chaingun counterpart. "General purpose machine gun".
/// Works almost the same as its vanilla cousin but without the 2-round burst.
class BIOM_GPMG : BIOM_Weapon
{
	Default
	{
		Tag "$BIOM_GPMG_TAG";
		Obituary "$BIOM_GPMG_OB";
		// Inventory.Icon 'GPMGZ0';
		Inventory.PickupMessage "$BIOM_GPMG_PKUP";
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
	}

	States
	{
		// ???
	}
}
