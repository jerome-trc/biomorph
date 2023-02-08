/// A Plasma Rifle counterpart.
class BIOM_BiteRifle : BIOM_Weapon
{
	protected BIOM_WeapDat_BiteRifle data;

	Default
	{
		Tag "$BIOM_BITERIFLE_TAG";
		Obituary "$BIOM_BITERIFLE_OB";

		// Inventory.Icon 'BNRPZ0';
		Inventory.PickupMessage "$BIOM_BITERIFLE_PKUP";

		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;

		BIOM_Weapon.DataClass 'BIOM_WeapDat_BiteRifle';
		BIOM_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class BIOM_WeapDat_BiteRifle : BIOM_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
