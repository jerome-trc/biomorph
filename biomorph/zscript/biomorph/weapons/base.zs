class BIO_Weapon : DoomWeapon abstract
{
	// `SelectionOrder` is for when ammo runs out; lower number, higher priority

	const SELORDER_PLASRIFLE = 100;
	const SELORDER_SSG = 400;
	const SELORDER_CHAINGUN = 700;
	const SELORDER_SHOTGUN = 1300;
	const SELORDER_PISTOL = 1900;
	const SELORDER_CHAINSAW = 2200;
	const SELORDER_RLAUNCHER = 2500;
	const SELORDER_BFG = 2800;
	const SELORDER_FIST = 3700;

	// `SlotPriority` is for manual selection; higher number, higher priority

	const SLOTPRIO_MAX = 1.0;
	const SLOTPRIO_HIGH = 0.6;
	const SLOTPRIO_LOW = 0.3;
	const SLOTPRIO_MIN = 0.0;

	/// If this weapon has this set to `false`, it will
	/// be destroyed if both of its `ammoGive` values are drained.
	meta bool ScavengePersist;
	property ScavengePersist: ScavengePersist;

	Default
	{
		-SPECIAL
		+DONTGIB
		+NOBLOCKMONST
		+THRUACTORS
		+WEAPON.ALT_AMMO_OPTIONAL
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT

		Height 8;
		Radius 16;

		Inventory.PickupMessage "";
		Inventory.RestrictedTo 'BIO_Player';

		Weapon.BobStyle 'InverseSmooth';
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobSpeed 2.0;

		BIO_Weapon.ScavengePersist true;
	}

	final override bool HandlePickup(Inventory item)
	{
		let weap = BIO_Weapon(item);

		if (weap == null || item.GetClass() != self.GetClass())
			return false;

		if (self.maxAmount > 1)
			return Inventory.HandlePickup(item);

		if (self.ammoType1 != null || self.ammoType2 != null)
		{
			int
				amt1 = self.owner.CountInv(self.ammoType1),
				amt2 = self.owner.CountInv(self.ammoType2);
			weap.bPickupGood = weap.PickupForAmmo(self);
			int given1 = self.owner.CountInv(self.ammoType1) - amt1,
				given2 = self.owner.CountInv(self.ammoType2) - amt2;
			weap.ammoGive1 -= given1;
			weap.ammoGive2 -= given2;
			weap.bPickupGood &= weap.ScavengingDestroys();

			if (!self.bQuiet && (given1 > 0 || given2 > 0))
			{
				weap.PrintPickupMessage(self.owner.CheckLocalView(), weap.PickupMessage());
				weap.PlayPickupSound(self.owner.player.mo);
			}
		}

		return true;
	}

	final override bool TryPickupRestricted(in out Actor toucher)
	{
		if (self.ammoType1 == null && self.ammoType2 == null)
			return false;

		// Weapon has ammo types but default ammogives are both 0
		if (self.default.ammoGive1 <= 0 && self.default.ammoGive1 <= 0)
			return false;

		int given1 = 0, given2 = 0;

		if (self.ammoType1 != null && self.ammoGive1 > 0)
		{
			let ammoItem = toucher.FindInventory(self.ammoType1);
			int amt = toucher.CountInv(self.ammoType1),
				toGive = self.ammoGive1 * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);
			ammoItem.Amount = Min(ammoItem.Amount + toGive, ammoItem.MaxAmount);
			given1 = ammoItem.Amount - amt;
			self.ammoGive1 -= given1;
		}

		if (self.ammoType2 != null && self.ammoGive2 > 0)
		{
			let ammoItem = toucher.FindInventory(self.ammoType2);
			int amt = toucher.CountInv(self.ammoType2),
				toGive = self.ammoGive2 * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);
			ammoItem.Amount = Min(ammoItem.Amount + toGive, ammoItem.MaxAmount);
			given2 = ammoItem.Amount - amt;
			self.ammoGive2 -= given2;
		}

		if (ScavengingDestroys())
		{
			GoAwayAndDie();
			return true;
		}

		return given1 > 0 || given2 > 0;
	}

	override void AttachToOwner(Actor newOwner)
	{
		int
			prevAmmo1 = newOwner.CountInv(self.ammoType1),
			prevAmmo2 = newOwner.CountInv(self.ammoType2);

		super.AttachToOwner(newOwner);
		self.ammoGive1 -= (newOwner.CountInv(self.ammoType1) - prevAmmo1);
		self.ammoGive2 -= (newOwner.CountInv(self.ammoType2) - prevAmmo2);
	}

	/// The parent variant of this function clears both `AmmoGive` fields to
	/// prevent exploitation; Biomorph solves this problem differently.
	/// This override fixes dropped weapons being impossible to scavenge as such.
	final override Inventory CreateTossable(int amt)
	{
		int ag1 = self.ammoGive1, ag2 = self.ammoGive2;
		let ret = Weapon(super.CreateTossable(amt));
		ret.ammoGive1 = ag1;
		ret.ammoGive2 = ag2;
		return ret;
	}

	private bool ScavengingDestroys() const
	{
		return
			(self.ammoType1 != null || self.ammoType2 != null) &&
			self.ammoGive1 <= 0 && self.ammoGive2 <= 0 &&
			!self.scavengePersist;
	}
}
