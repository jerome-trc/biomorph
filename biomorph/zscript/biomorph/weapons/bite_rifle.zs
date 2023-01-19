/// A Plasma Rifle counterpart.
class BIO_BiteRifle : BIO_Weapon
{
	Default
	{
		Tag "$BIO_BITERIFLE_TAG";
		Obituary "$BIO_BITERIFLE_OB";
		// Inventory.Icon 'BNRPZ0';
		Inventory.PickupMessage "$BIO_BITERIFLE_PKUP";
		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;
	}

	States
	{
		// ???
	}
}
