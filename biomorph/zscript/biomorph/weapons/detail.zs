/// Vanilla weapons are replaced by generic pickups that give different weapons
/// depending on what mutators have been chosen by the player touching the pickup.
class BIO_WeaponPickup : Inventory abstract
{
	Default
	{
		+DONTGIB
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.NEVERRESPAWN
		+FORCEXYBILLBOARD

		Radius 16.0;
		Height 14.0;

		Inventory.Amount 0;
		Inventory.PickupMessage "";
	}
}
