mixin class biom_Health
{
	private void OnFirstBerserkPickup(in out Actor other)
	{
		other.GiveInventory('PowerStrength', 1);
		self.PrintPickupMessage(other.CheckLocalView(), "$BIOM_BERSERK_PKUPFIRST");

		let pawn = biom_Player(other);

		if (pawn != null)
		{
			let bsks = biom_CVar.BerserkSwitch(pawn.Player);
			bool prev = pawn.FindInventory('PowerStrength', true) != null;
			bool select = bsks == BIOM_CV_BSKS_MELEE;
			select |= (bsks == BIOM_CV_BSKS_ONLYFIRST && !prev);

			if (select)
				pawn.A_SelectWeapon('biom_Melee');
		}
	}

	final override bool TryPickup(in out Actor other)
	{
		if (self is 'biom_Berserk' && self.bCountItem)
			self.OnFirstBerserkPickup(other);

		int amt = 0;

		if (other.Player != null)
		{
			self.prevHealth = other.Player.Health;
			let cap = other.GetMaxHealth() - other.Player.Health;

			if (self is 'biom_HealthBonus' || self is 'biom_SuperHealth')
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

			if (self is 'biom_HealthBonus' || self is 'biom_SuperHealth')
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

class biom_HealthBonus : HealthBonus replaces HealthBonus
{
	mixin biom_Pickup;
	mixin biom_Health;

	Default
	{
		Tag "$BIOM_HEALTHBONUS_TAG";
		-INVENTORY.ALWAYSPICKUP
		Inventory.PickupMessage "$BIOM_HEALTHBONUS_PKUP";
		biom_HealthBonus.CollectedMessage "$BIOM_HEALTHBONUS_COLLECTED";
	}

	States
	{
	Spawn:
		MEPI A -1;
		stop;
	}
}

class biom_SmallHealth : Stimpack replaces Stimpack
{
	mixin biom_Pickup;
	mixin biom_Health;

	Default
	{
		Tag "$BIOM_SMALLHEALTH_TAG";
		Inventory.PickupMessage "$BIOM_SMALLHEALTH_PKUP";
		biom_SmallHealth.PartialPickupMessage "$BIOM_SMALLHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIOM_SMALLHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		PILS A -1;
		stop;
	}
}

class biom_BigHealth : Medikit replaces Medikit
{
	mixin biom_Pickup;
	mixin biom_Health;

	Default
	{
		Tag "$BIOM_BIGHEALTH_TAG";
		Inventory.PickupMessage "$BIOM_BIGHEALTH_PKUP";
		biom_BigHealth.PartialPickupMessage "$BIOM_BIGHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIOM_BIGHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		TRAU A -1;
		stop;
	}
}

class biom_SuperHealth : Soulsphere replaces Soulsphere
{
	mixin biom_Pickup;
	mixin biom_Health;

	Default
	{
		-INVENTORY.AUTOACTIVATE;
		-INVENTORY.ALWAYSPICKUP;

		Tag "$BIOM_SUPERHEALTH_TAG";
		Inventory.PickupMessage "$BIOM_SUPERHEALTH_PKUP";
		Health.LowMessage 25, "$BIOM_SUPERHEALTH_PKUPLOW";
		biom_SuperHealth.PartialPickupMessage "$BIOM_SUPERHEALTH_PARTIAL";
		biom_SuperHealth.CollectedMessage "$BIOM_SUPERHEALTH_COLLECTED";
	}

	States
	{
	Spawn:
		PANA ABCD 6 bright;
		loop;
	}
}
