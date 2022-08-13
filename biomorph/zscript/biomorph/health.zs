mixin class BIO_Health
{
	private void OnFirstBerserkPickup(in out Actor other)
	{
		other.GiveInventory('PowerStrength', 1);
		PrintPickupMessage(other.CheckLocalView(), "$BIO_BERSERK_PKUPFIRST");

		let pawn = BIO_Player(other);

		if (pawn != null)
		{
			let bsks = BIO_CVar.BerserkSwitch(pawn.Player);
			bool prev = pawn.FindInventory('PowerStrength', true) != null;
			bool select = bsks == BIO_CV_BSKS_MELEE;
			select |= (bsks == BIO_CV_BSKS_ONLYFIRST && !prev);

			if (select)
				pawn.A_SelectWeapon('BIO_Unarmed');
		}
	}

	final override bool TryPickup(in out Actor other)
	{
		if (self is 'BIO_Berserk' && bCountItem)
			OnFirstBerserkPickup(other);

		int amt = 0;

		if (other.Player != null)
		{
			PrevHealth = other.Player.Health;
			let cap = other.GetMaxHealth() - other.Player.Health;

			if (self is 'BIO_HealthBonus' || self is 'BIO_Soulsphere')
				cap += 100;

			cap = Max(cap, 0);
			amt = Min(Amount, cap);
			other.GiveBody(amt, MaxAmount);
			Amount -= amt;
		}
		else
		{
			PrevHealth = other.Health;
			let cap = other.GetMaxHealth() - other.Health;
			cap = Max(cap, 0);

			if (self is 'BIO_HealthBonus' || self is 'BIO_Soulsphere')
				cap += 100;

			amt = Min(Amount, cap);
			other.GiveBody(amt, MaxAmount);
			Amount -= amt;
		}

		if (Amount <= 0)
		{
			GoAwayAndDie();
			return true;
		}

		if (amt > 0)
			OnPartialPickup(other);

		if (bCountItem)
			MarkAsCollected(other);

		return false;
	}
}

class BIO_HealthBonus : HealthBonus replaces HealthBonus
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		Tag "$BIO_HEALTHBONUS_TAG";
		-INVENTORY.ALWAYSPICKUP
		Inventory.PickupMessage "$BIO_HEALTHBONUS_PKUP";
		BIO_HealthBonus.CollectedMessage "$BIO_HEALTHBONUS_COLLECTED";
	}
}

class BIO_Stimpack : Stimpack replaces Stimpack
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		Tag "$BIO_STIMPACK_TAG";
		Inventory.PickupMessage "$BIO_STIMPACK_PKUP";
		BIO_Stimpack.PartialPickupMessage "$BIO_STIMPACK_PARTIAL";
		Health.LowMessage 25, "$BIO_STIMPACK_PKUPLOW";
	}
}

class BIO_Medikit : Medikit replaces Medikit
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		Tag "$BIO_MEDIKIT_TAG";
		Inventory.PickupMessage "$BIO_MEDIKIT_PKUP";
		BIO_Medikit.PartialPickupMessage "$BIO_MEDIKIT_PARTIAL";
		Health.LowMessage 25, "$BIO_MEDIKIT_PKUPLOW";
	}
}

class BIO_Soulsphere : Soulsphere replaces Soulsphere
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		-INVENTORY.AUTOACTIVATE;
		-INVENTORY.ALWAYSPICKUP;

		Tag "$BIO_SOULSPHERE_TAG";
		Inventory.PickupMessage "$BIO_SOULSPHERE_PKUP";
		Health.LowMessage 25, "$BIO_SOULSPHERE_PKUPLOW";
		BIO_Soulsphere.PartialPickupMessage "$BIO_SOULSPHERE_PARTIAL";
		BIO_Soulsphere.CollectedMessage "$BIO_SOULSPHERE_COLLECTED";
	}
}
