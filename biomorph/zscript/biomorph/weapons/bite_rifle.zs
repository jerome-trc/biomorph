/// A Plasma Rifle counterpart.
class BIOM_BiteRifle : BIOM_Weapon
{
	Default
	{
		Tag "$BIOM_BITERIFLE_TAG";
		Obituary "$BIOM_BITERIFLE_OB";
		// Inventory.Icon 'BNRPZ0';
		Inventory.PickupMessage "$BIOM_BITERIFLE_PKUP";
		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;
	}

	States
	{
		// ???
	}
}
