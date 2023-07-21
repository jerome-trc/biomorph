/// A Chaingun counterpart. "General purpose machine gun".
/// Works almost the same as its vanilla cousin but without the 2-round burst.
class biom_GPMG : biom_Weapon
{
	protected biom_wdat_GPMG data;

	Default
	{
		Tag "$BIOM_GPMG_TAG";
		Obituary "$BIOM_GPMG_OB";

		// Inventory.Icon 'GPMGZ0';
		Inventory.PickupMessage "$BIOM_GPMG_PKUP";

		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;

		biom_Weapon.DataClass 'biom_wdat_GPMG';
		biom_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class biom_wdat_GPMG : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
