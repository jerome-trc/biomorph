/// A Plasma Rifle counterpart.
class biom_BiteRifle : biom_Weapon
{
	protected biom_wdat_BiteRifle data;

	Default
	{
		Tag "$BIOM_BITERIFLE_TAG";
		Obituary "$BIOM_BITERIFLE_OB";

		// Inventory.Icon 'BNRPZ0';
		Inventory.PickupMessage "$BIOM_BITERIFLE_PKUP";

		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;

		biom_Weapon.DataClass 'biom_wdat_BiteRifle';
		biom_Weapon.Grade BIOM_WEAPGRADE_2;
		biom_Weapon.Family BIOM_WEAPFAM_ENERGY;
	}

	States
	{
		// ???
	}
}

class biom_wdat_BiteRifle : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
