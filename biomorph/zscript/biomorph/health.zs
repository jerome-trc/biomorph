mixin class BIO_Health
{
	private void OnFirstBerserkPickup(in out Actor other)
	{
		other.GiveInventory('PowerStrength', 1);
		self.PrintPickupMessage(other.CheckLocalView(), "$BIO_BERSERK_PKUPFIRST");

		let pawn = BIO_Player(other);

		if (pawn != null)
		{
			let bsks = BIO_CVar.BerserkSwitch(pawn.Player);
			bool prev = pawn.FindInventory('PowerStrength', true) != null;
			bool select = bsks == BIO_CV_BSKS_MELEE;
			select |= (bsks == BIO_CV_BSKS_ONLYFIRST && !prev);

			if (select)
				pawn.A_SelectWeapon('BIO_Melee');
		}
	}

	final override bool TryPickup(in out Actor other)
	{
		if (self is 'BIO_Berserk' && self.bCountItem)
			self.OnFirstBerserkPickup(other);

		int amt = 0;

		if (other.Player != null)
		{
			self.prevHealth = other.Player.Health;
			let cap = other.GetMaxHealth() - other.Player.Health;

			if (self is 'BIO_HealthBonus' || self is 'BIO_SuperHealth')
				cap += 100;

			cap = Max(cap, 0);
			amt = Min(self.amount, cap);
			other.GiveBody(amt, self.maxAmount);
			self.amount -= amt;
		}
		else
		{
			self.prevHealth = other.Health;
			let cap = other.GetMaxHealth() - other.Health;
			cap = Max(cap, 0);

			if (self is 'BIO_HealthBonus' || self is 'BIO_SuperHealth')
				cap += 100;

			amt = Min(self.amount, cap);
			other.GiveBody(amt, self.maxAmount);
			self.amount -= amt;
		}

		if (self.amount <= 0)
		{
			self.GoAwayAndDie();
			return true;
		}

		if (amt > 0)
			self.OnPartialPickup(other);

		if (bCountItem)
			self.MarkAsCollected(other);

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

class BIO_SmallHealth : Stimpack replaces Stimpack
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		Tag "$BIO_SMALLHEALTH_TAG";
		Inventory.PickupMessage "$BIO_SMALLHEALTH_PKUP";
		BIO_SmallHealth.PartialPickupMessage "$BIO_SMALLHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIO_SMALLHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		PILS A -1;
		Stop;
	}
}

class BIO_BigHealth : Medikit replaces Medikit
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		Tag "$BIO_BIGHEALTH_TAG";
		Inventory.PickupMessage "$BIO_BIGHEALTH_PKUP";
		BIO_BigHealth.PartialPickupMessage "$BIO_BIGHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIO_BIGHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		TRAU A -1;
		Stop;
	}
}

class BIO_SuperHealth : Soulsphere replaces Soulsphere
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		-INVENTORY.AUTOACTIVATE;
		-INVENTORY.ALWAYSPICKUP;

		Tag "$BIO_SUPERHEALTH_TAG";
		Inventory.PickupMessage "$BIO_SUPERHEALTH_PKUP";
		Health.LowMessage 25, "$BIO_SUPERHEALTH_PKUPLOW";
		BIO_SuperHealth.PartialPickupMessage "$BIO_SUPERHEALTH_PARTIAL";
		BIO_SuperHealth.CollectedMessage "$BIO_SUPERHEALTH_COLLECTED";
	}
}
