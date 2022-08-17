extend class BIO_Weapon
{
	override void BeginPlay()
	{
		super.BeginPlay();

		// So that pre-placed weapons don't make a cacophony at level start
		if (Abs(Vel.Z) <= 0.01)
		{
			bSpecial = true;
			bThruActors = false;
			bHitGround = true;
		}
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		SetTag(ColoredTag());
	}

	override void Tick()
	{
		super.Tick();

		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnTick(self);
	}

	final override bool Used(Actor user)
	{
		let pawn = BIO_Player(user);

		if (pawn == null)
			return false;

		pawn.ExamineWeapon(self);

		// Don't consume the interaction so players can open doors and so on
		return false;
	}

	// The player can't pick up a weapon if they're full on them,
	// or already have one of this class.
	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher))
			return false;

		let pawn = BIO_Player(toucher);

		// Gearbox calls this function on every weapon prototype when changing
		// levels; if one of those checks returns false (i.e. when player
		// is at weapon capacity) then that weapon can't be displayed
		if (Level == null)
			return true;

		if (pawn.HeldWeaponCount() >= pawn.MaxWeaponsHeld)
			return pawn.FindInventory(GetClass());

		return true;
	}

	final override bool HandlePickup(Inventory item)
	{
		let weap = BIO_Weapon(item);
		
		if (weap == null || item.GetClass() != self.GetClass())
			return false;

		if (MaxAmount > 1)
			return Inventory.HandlePickup(item);

		if (AmmoType1 != null || AmmoType2 != null)
		{
			int amt1 = Owner.CountInv(AmmoType1), amt2 = Owner.CountInv(AmmoType2);
			weap.bPickupGood = weap.PickupForAmmo(self);
			int given1 = Owner.CountInv(AmmoType1) - amt1,
				given2 = Owner.CountInv(AmmoType2) - amt2;
			weap.AmmoGive1 -= given1;
			weap.AmmoGive2 -= given2;
			weap.bPickupGood &= weap.ScavengingDestroys();

			if (!bQuiet && (given1 > 0 || given2 > 0))
			{
				weap.PrintPickupMessage(Owner.CheckLocalView(), weap.PickupMessage());
				weap.PlayPickupSound(Owner.Player.MO);
			}
		}

		return true;
	}

	final override bool TryPickupRestricted(in out Actor toucher)
	{
		if (AmmoType1 == null && AmmoType2 == null)
			return false;
		
		// Weapon has ammo types but default ammogives are both 0
		if (Default.AmmoGive1 <= 0 && Default.AmmoGive1 <= 0)
			return false;

		int given1 = 0, given2 = 0;

		if (AmmoType1 != null && AmmoGive1 > 0)
		{
			let ammoItem = toucher.FindInventory(AmmoType1);
			int amt = toucher.CountInv(AmmoType1),
				toGive = AmmoGive1 * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);
			ammoItem.Amount = Min(ammoItem.Amount + toGive, ammoItem.MaxAmount);
			given1 = ammoItem.Amount - amt;
			AmmoGive1 -= given1;
		}

		if (AmmoType2 != null && AmmoGive2 > 0)
		{
			let ammoItem = toucher.FindInventory(AmmoType2);
			int amt = toucher.CountInv(AmmoType2),
				toGive = AmmoGive2 * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);
			ammoItem.Amount = Min(ammoItem.Amount + toGive, ammoItem.MaxAmount);
			given2 = ammoItem.Amount - amt;
			AmmoGive2 -= given2;
		}

		if (ScavengingDestroys())
		{
			GoAwayAndDie();
			return true;
		}

		return given1 > 0 || given2 > 0;
	}

	override string PickupMessage()
	{
		// Is this weapon being scavenged for ammo?
		if (InStateSequence(CurState, FindState('HoldAndDestroy')) || Owner == null)
			return String.Format(StringTable.Localize(ScavengeMsg), GetTag());

		string ret = String.Format(StringTable.Localize(PickupMsg), GetTag());
		ret = ret .. " [\c[LightBlue]" .. SlotNumber .. "\c-]";
		return ret;
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnPickup(self);
	}

	override void AttachToOwner(Actor newOwner)
	{
		if (!bPreviouslyPickedUp)
		{
			BIO_EventHandler.BroadcastFirstPickup(GetClassName());
		}

		bPreviouslyPickedUp = true;

		int 
			prevAmmo1 = newOwner.CountInv(AmmoType1),
			prevAmmo2 = newOwner.CountInv(AmmoType2);

		super.AttachToOwner(newOwner);
		AmmoGive1 -= (newOwner.CountInv(AmmoType1) - prevAmmo1);
		AmmoGive2 -= (newOwner.CountInv(AmmoType2) - prevAmmo2);

		LazyInit();
		SetupMagazines();
	}

	// The parent variant of this function clears both `AmmoGive` fields to
	// prevent exploitation; Biomorph solves this problem differently.
	// This override fixes dropped weapons being impossible to scavenge as such.
	final override Inventory CreateTossable(int amt)
	{
		int ag1 = AmmoGive1, ag2 = AmmoGive2;
		let ret = Weapon(super.CreateTossable(amt));
		ret.AmmoGive1 = ag1;
		ret.AmmoGive2 = ag2;
		return ret;
	}

	override void OnDrop(Actor dropper)
	{
		super.OnDrop(dropper);

		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnDrop(self, BIO_Player(dropper));

		Magazine1 = Magazine2 = null;
		bHitGround = false;
	}

	final override bool DepleteAmmo(bool altFire, bool checkEnough, int ammoUse)
	{
		if (CheckInfiniteAmmo())
			return true;

		if (checkEnough && !CheckAmmo(altFire ? AltFire : PrimaryFire, false, false, ammoUse))
			return false;

		if (!altFire)
		{
			if (ammoUse < 0) ammoUse = AmmoUse1;

			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].BeforeAmmoDeplete(self, ammoUse, altFire);

			if (Magazine1 != null)
				Magazine1.Deplete(self, ammoUse);
			else if (Ammo1 != null)
				Ammo1.Amount = Max(Ammo1.Amount - ammoUse, 0);

			if (bPRIMARY_USES_BOTH)
			{
				if (Magazine2 != null)
					Magazine2.Deplete(self, AmmoUse2);
				else if (Ammo2 != null)
					Ammo2.Amount = Max(Ammo2.Amount - AmmoUse2, 0);
			}
		}
		else
		{
			if (ammoUse < 0) ammoUse = AmmoUse2;

			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].BeforeAmmoDeplete(self, ammoUse, altFire);

			if (Magazine2 != null)
				Magazine2.Deplete(self, ammoUse);
			else if (Ammo2 != null)
				Ammo2.Amount = Max(Ammo2.Amount - ammoUse, 0);

			if (bALT_USES_BOTH)
			{
				if (Magazine1 != null)
					Magazine1.Deplete(self, AmmoUse1);
				else if (Ammo1 != null)
					Ammo1.Amount = Max(Ammo1.Amount - AmmoUse1, 0);
			}
		}

		return true;
	}
}
