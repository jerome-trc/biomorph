// This subclass only exists so that `TakeInventory()` is guaranteed to only
// remove items of exactly this class and no other `PowerupGiver` items.
class BIO_PowerupGiver : PowerupGiver {}

class BIO_Berserk : Health replaces Berserk
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		+COUNTITEM

		Inventory.Amount 100;
		Inventory.MaxAmount 100;
		Inventory.PickupMessage "$BIO_BERSERK_PKUP";
		Inventory.PickupSound "misc/p_pkup";
		Health.LowMessage 25, "$BIO_BERSERK_PKUPLOW";
		BIO_Berserk.CollectedMessage "$BIO_BERSERK_COLLECTED";
		BIO_Berserk.PartialPickupMessage "$BIO_BERSERK_PARTIAL";
	}

	States
	{
	Spawn:
		PSTR A -1 Bright;
		Stop;
	}
}
