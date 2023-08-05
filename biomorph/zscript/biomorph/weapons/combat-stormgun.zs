/// A Super Shotgun counterpart.
/// Collecting one overrides the currently-head Shotgun counterpart, if any.
class biom_CombatStormgun : biom_Weapon
{
	Default
	{
		Tag "$BIOM_COMBATSTORMGUN_TAG";
		Obituary "$BIOM_COMBATSTORMGUN_OB";

		// Inventory.Icon `TYPHZ0`;
		Inventory.PickupMessage "$BIOM_COMBATSTORMGUN_PKUP";

		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;

		biom_Weapon.DataClass 'biom_wdat_CombatStormgun';
		biom_Weapon.Grade BIOM_WEAPGRADE_2;
		biom_Weapon.Family BIOM_WEAPFAM_SUPERSHOTGUN;
	}

	States
	{
		// ???
	}
}

class biom_wdat_CombatStormgun : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
