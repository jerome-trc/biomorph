/// A Super Shotgun counterpart.
/// Collecting one overrides the currently-head Shotgun counterpart, if any.
class BIOM_CombatStormgun : BIOM_Weapon
{
	protected BIOM_WeapDat_CombatStormgun data;

	Default
	{
		Tag "$BIOM_COMBATSTORMGUN_TAG";
		Obituary "$BIOM_COMBATSTORMGUN_OB";

		// Inventory.Icon `TYPHZ0`;
		Inventory.PickupMessage "$BIOM_COMBATSTORMGUN_PKUP";

		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;

		BIOM_Weapon.DataClass 'BIOM_WeapDat_CombatStormgun';
		BIOM_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class BIOM_WeapDat_CombatStormgun : BIOM_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
