/* 	Health pickups run relevant player pawn callbacks.

	If Zhs2's Intelligent Supplies is installed, these behaviors are only invoked
	after these items have been fully drained.
*/

class BIO_HealthBonus : HealthBonus replaces HealthBonus
{
	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bioPlayer.OnHealthPickup(self);
	}
}

class BIO_Stimpack : Stimpack replaces Stimpack
{
	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnHealthPickup(self);
	}
}

class BIO_Medikit : Medikit replaces Medikit
{
	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnHealthPickup(self);
	}
}
