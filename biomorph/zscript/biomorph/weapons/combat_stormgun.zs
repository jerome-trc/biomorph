/// A Super Shotgun counterpart.
/// Collecting one overrides the currently-head Shotgun counterpart, if any.
class BIO_CombatStormgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_COMBATSTORMGUN_TAG";
		Obituary "$BIO_COMBATSTORMGUN_OB";
		// Inventory.Icon `TYPHZ0`;
		Inventory.PickupMessage "$BIO_COMBATSTORMGUN_PKUP";
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;	
	}

	States
	{
		// ???
	}
}
