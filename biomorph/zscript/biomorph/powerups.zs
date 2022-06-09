// This subclass only exists so that `TakeInventory()` is guaranteed to only
// remove items of exactly this class and no other `PowerupGiver` items.
class BIO_PowerupGiver : PowerupGiver {}

class BIO_Berserk : Berserk replaces Berserk
{
	Default
	{
		+DONTGIB
	}

	States
	{
	Pickup:
		TNT1 A 0;
		Stop;
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		toucher.GiveBody(100, toucher.GetMaxHealth());

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		let bsks = BIO_CVar.BerserkSwitch(bioPlayer.Player);

		if (bsks == BIO_CV_BSKS_MELEE ||
			(bsks == BIO_CV_BSKS_ONLYFIRST &&
			!bioPlayer.FindInventory('PowerStrength', true)))
		{
			bioPlayer.A_SelectWeapon('Fist');
		}

		bioPlayer.GiveInventory('PowerStrength', 1);
	}
}
