/// A Pistol counterpart.
/// Infinite ammo, 7-round magazine, highly damaging.
class BIOM_Pistol : BIOM_Weapon
{
	Default
	{
		Tag "$BIOM_PISTOL_TAG";
		Obituary "$BIOM_PISTOL_OB";
		// Inventory.Icon 'HGUNZ0';
		Inventory.PickupMessage "$BIOM_PISTOL_PKUP";
		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 2;
	}

	States
	{
		// ???
	}
}
