mixin class BIOM_Health
{
	private void OnFirstBerserkPickup(in out Actor other)
	{
		other.GiveInventory('PowerStrength', 1);
		self.PrintPickupMessage(other.CheckLocalView(), "$BIOM_BERSERK_PKUPFIRST");

		let pawn = BIOM_Player(other);

		if (pawn != null)
		{
			let bsks = BIOM_CVar.BerserkSwitch(pawn.Player);
			bool prev = pawn.FindInventory('PowerStrength', true) != null;
			bool select = bsks == BIOM_CV_BSKS_MELEE;
			select |= (bsks == BIOM_CV_BSKS_ONLYFIRST && !prev);

			if (select)
				pawn.A_SelectWeapon('BIOM_Melee');
		}
	}

	final override bool TryPickup(in out Actor other)
	{
		if (self is 'BIOM_Berserk' && self.bCountItem)
			self.OnFirstBerserkPickup(other);

		int amt = 0;

		if (other.Player != null)
		{
			self.prevHealth = other.Player.Health;
			let cap = other.GetMaxHealth() - other.Player.Health;

			if (self is 'BIOM_HealthBonus' || self is 'BIOM_SuperHealth')
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

			if (self is 'BIOM_HealthBonus' || self is 'BIOM_SuperHealth')
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

class BIOM_HealthBonus : HealthBonus replaces HealthBonus
{
	mixin BIOM_Pickup;
	mixin BIOM_Health;

	Default
	{
		Tag "$BIOM_HEALTHBONUS_TAG";
		-INVENTORY.ALWAYSPICKUP
		Inventory.PickupMessage "$BIOM_HEALTHBONUS_PKUP";
		BIOM_HealthBonus.CollectedMessage "$BIOM_HEALTHBONUS_COLLECTED";
	}
}

class BIOM_SmallHealth : Stimpack replaces Stimpack
{
	mixin BIOM_Pickup;
	mixin BIOM_Health;

	Default
	{
		Tag "$BIOM_SMALLHEALTH_TAG";
		Inventory.PickupMessage "$BIOM_SMALLHEALTH_PKUP";
		BIOM_SmallHealth.PartialPickupMessage "$BIOM_SMALLHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIOM_SMALLHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		PILS A -1;
		Stop;
	}
}

class BIOM_BigHealth : Medikit replaces Medikit
{
	mixin BIOM_Pickup;
	mixin BIOM_Health;

	Default
	{
		Tag "$BIOM_BIGHEALTH_TAG";
		Inventory.PickupMessage "$BIOM_BIGHEALTH_PKUP";
		BIOM_BigHealth.PartialPickupMessage "$BIOM_BIGHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIOM_BIGHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		TRAU A -1;
		Stop;
	}
}

class BIOM_SuperHealth : Soulsphere replaces Soulsphere
{
	mixin BIOM_Pickup;
	mixin BIOM_Health;

	Default
	{
		-INVENTORY.AUTOACTIVATE;
		-INVENTORY.ALWAYSPICKUP;

		Tag "$BIOM_SUPERHEALTH_TAG";
		Inventory.PickupMessage "$BIOM_SUPERHEALTH_PKUP";
		Health.LowMessage 25, "$BIOM_SUPERHEALTH_PKUPLOW";
		BIOM_SuperHealth.PartialPickupMessage "$BIOM_SUPERHEALTH_PARTIAL";
		BIOM_SuperHealth.CollectedMessage "$BIOM_SUPERHEALTH_COLLECTED";
	}
}
