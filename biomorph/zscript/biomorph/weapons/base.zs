// Note to reader: classes are defined using `extend` blocks for code folding.

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

	// (Rat) Who designed those two properties to be so counter-intuitive?

	const SWITCHSPEED_MAX = 96;

	// If this weapon is unmodified and this field is false, it will
	// be destroyed if both of its `AmmoGive` values are drained.
	meta bool ScavengePersist;
	property ScavengePersist: ScavengePersist;

	meta string ScavengeMsg;
	property PickupMessages: PickupMsg, ScavengeMsg;

	meta bool Unique;
	property Unique: Unique;

	meta BIO_WeaponFamily Family;
	property Family: Family;

	meta BIO_WeaponSpawnCategory SpawnCategory;
	property SpawnCategory: SpawnCategory;

	meta uint GraphQuality;
	property GraphQuality: GraphQuality;

	meta string Summary;
	property Summary: Summary;

	int RaiseSpeed, LowerSpeed;
	property SwitchSpeeds: RaiseSpeed, LowerSpeed;

	meta sound GroundHitSound; property GroundHitSound: GroundHitSound;

	// For dual-wield weapons, ammo and magazine types 2 are for the left weapon

	meta class<Ammo> MagazineType1, MagazineType2;
	property MagazineType: MagazineType1;
	property MagazineType1: MagazineType1;
	property MagazineType2: MagazineType2;
	property MagazineTypes: MagazineType1, MagazineType2;

	meta class<BIO_MagazineETM> MagazineTypeETM1, MagazineTypeETM2;
	property MagazineTypeETM: MagazineTypeETM1;
	property MagazineTypeETM1: MagazineTypeETM1;
	property MagazineTypeETM2: MagazineTypeETM2;
	property MagazineTypeETMs: MagazineTypeETM1, MagazineTypeETM2;

	uint MagazineSize1, MagazineSize2;
	property MagazineSize: MagazineSize1;
	property MagazineSize1: MagazineSize1;
	property MagazineSize2: MagazineSize2;
	property MagazineSizes: MagazineSize1, MagazineSize2;

	// To reload a round, `ReloadCost` gets taken from reserve and `ReloadOutput`
	// gets added to the magazine. Has no effect on magazineless weapons.
	uint8 ReloadCost1, ReloadCost2, ReloadOutput1, ReloadOutput2;

	property ReloadCost: ReloadCost1;
	property ReloadCost1: ReloadCost1;
	property ReloadCost2: ReloadCost2;
	property ReloadCosts: ReloadCost1, ReloadCost2;

	property ReloadOutput: ReloadOutput1;
	property ReloadOutput1: ReloadOutput1;
	property ReloadOutput2: ReloadOutput2;
	property ReloadOutputs: ReloadOutput1, ReloadOutput2;

	property ReloadRatio: ReloadCost1, ReloadOutput1;
	property ReloadRatio1: ReloadCost1, ReloadOutput1;
	property ReloadRatio2: ReloadCost2, ReloadOutput2;

	// Reloading is only possible if `MinAmmoReserve * ReloadCost` rounds
	// are held in reserve. Has no effect on magazineless weapons.
	uint16 MinAmmoReserve1, MinAmmoReserve2;
	property MinAmmoReserve: MinAmmoReserve1;
	property MinAmmoReserve1: MinAmmoReserve1;
	property MinAmmoReserve2: MinAmmoReserve2;
	property MinAmmoReserves: MinAmmoReserve1, MinAmmoReserve2;

	protected uint DynFlags;
	flagdef HitGround: DynFlags, 0;
	flagdef PreviouslyPickedUp: DynFlags, 1;
	flagdef Spooling: DynFlags, 2;
	// The last 4 flags (28 to 31) are reserved for derived classes.

	Array<BIO_WeaponPipeline> Pipelines;
	Array<BIO_StateTimeGroup> FireTimeGroups, ReloadTimeGroups;
	Array<BIO_WeaponAffix> Affixes;
	BIO_WeaponModGraph ModGraph;
	BIO_WeaponSpecialFunctor SpecialFunc; // Invoked via the `Zoom` input.

	protected Ammo Magazine1, Magazine2;
	protected bool Zoomed;

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

		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobStyle 'InverseSmooth';
		Weapon.BobSpeed 2.0;

		BIO_Weapon.GroundHitSound "bio/weap/groundhit/0";
		BIO_Weapon.MinAmmoReserves 1, 1;
		BIO_Weapon.ReloadRatio1 1, 1;
		BIO_Weapon.ReloadRatio2 1, 1;
		BIO_Weapon.ScavengePersist true;
		BIO_Weapon.SwitchSpeeds 6, 6;
		BIO_Weapon.SpawnCategory __BIO_WSCAT_COUNT__;
	}

	States
	{
	Select.Loop:
		#### # 1 A_BIO_Raise;
		Loop;
	Deselect.Loop:
		#### # 1 A_BIO_Lower;
		Loop;
	Spawn.Normal:
		#### # 10; // Prevent player instantly picking weapon back up
		#### # 1 A_BIO_GroundHit;
		Goto Spawn.Normal + 1;
	Spawn.Mutated:
		#### # 10; // Prevent player instantly picking weapon back up
		#### # 1
		{
			A_BIO_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_BIO_GroundHit;
		#### # 1 Bright Light("BIO_MutatedLoot")
		{
			A_BIO_GroundHit();
			A_SetTranslation('BIO_Mutated');
		}
		#### ##### 1 Bright Light("BIO_MutatedLoot") A_BIO_GroundHit;
		Goto Spawn.Mutated + 1;
	Spawn.Unique:
		#### # 10; // Prevent player instantly picking weapon back up
		#### # 1
		{
			A_BIO_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_BIO_GroundHit;
		#### # 1 Bright Light("BIO_UniqueLoot")
		{
			A_BIO_GroundHit();
			A_SetTranslation('BIO_Unique');
		}
		#### ##### 1 Bright Light("BIO_UniqueLoot") A_BIO_GroundHit;
		Goto Spawn.Unique + 1;
	Zoom:
		TNT1 A 0 A_BIO_WeaponSpecial;
		TNT1 A 0 A_Jump(256, 'Ready');
		TNT1 A 0 {
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Reached an illegal state through `BIO_Weapon::Zoom`. (%s)",
				invoker.GetClassName()
			);
		}
		Stop;
	}

	// Virtuals/abstracts //////////////////////////////////////////////////////

	// Build pipelines, define state time groups.
	// Called immediately after the weapon is spawned.
	abstract void SetDefaults();

	/*	Intrinsic mod graphs can't be created in `SetDefaults()`, since that
		function gets called during the weapon mod simulation process (causing
		infinite recursion and stack overflow). Do it here instead.

		If `onMutate` is false, the call is being made during `LazyInit()`.
		Otherwise it's being made during application of a general mutagen.

		If your intent is for the unique weapon to have a pre-filled mod graph,
		act upon the former.
		If your intent is for a weapon to start un-mutated but gain certain
		properties implicitly upon mutation, act upon the latter.
	*/
	virtual void IntrinsicModGraph(bool onMutate) {}

	// Each is called once before starting its respective loop.
	virtual void OnDeselect()
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnDeselect(self);
	}

	virtual void OnSelect()
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnSelect(self);
	}

	// When calculating the cost to modify or morph a weapon, each gene has a base
	// value of 1, and the sum of those gene values is passed into this.
	virtual uint ModCost(uint base) const { return base; }

	virtual ui void RenderOverlay(BIO_RenderContext context) const
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].RenderOverlay(context);
	}
}

// Parent overrides.
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
		if (!bPreviouslyPickedUp && Unique)
			BIO_Utils.DRLMDangerLevel(1);

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

		if (TryEnergyToMatterFeed(altFire))
			return true;

		if (checkEnough && !CheckAmmo(altFire ? AltFire : PrimaryFire, false, false, ammoUse))
			return false;

		if (!altFire)
		{
			if (ammoUse < 0) ammoUse = AmmoUse1;

			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].BeforeAmmoDeplete(self, ammoUse, altFire);

			if (Magazine1 != null)
				Magazine1.Amount = Max(Magazine1.Amount - ammoUse, 0);

			if (bPRIMARY_USES_BOTH && Magazine2 != null)
				Magazine2.Amount = Max(Magazine2.Amount - AmmoUse2, 0);
		}
		else
		{
			if (ammoUse < 0) ammoUse = AmmoUse2;

			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].BeforeAmmoDeplete(self, ammoUse, altFire);

			if (Magazine2 != null)
				Magazine2.Amount = Max(Magazine2.Amount - ammoUse, 0);

			if (bALT_USES_BOTH && Magazine1 != null)
				Magazine1.Amount = Max(Magazine1.Amount - AmmoUse1, 0);
		}

		return true;
	}
}

// Accessor member functions.
extend class BIO_Weapon
{
	bool Uninitialised() const
	{
		return
			Pipelines.Size() < 1 &&
			Affixes.Size() < 1 &&
			FireTimeGroups.Size() < 1 &&
			ReloadTimeGroups.Size() < 1 &&
			ModGraph == null;
	}

	// Doesn't do much, but will ease refactoring if the condition needs to change.
	bool IsMutated() const
	{
		return ModGraph != null;
	}

	// Graph quality inherited over successive downgrades/sidegrades.
	uint InheritedGraphQuality() const
	{
		if (ModGraph == null)
			return 0;

		return (ModGraph.Nodes.Size() - 1) - Default.GraphQuality;
	}

	bool CanReload(bool secondary = false) const
	{
		Ammo magItem = null, reserveAmmo = null;
		int cost = -1, magSize = -1, minReserve = -1;

		if (!secondary)
		{
			magItem = Magazine1;
			magSize = MagazineSize1;

			if (AmmoType1 == null && MagazineType1 != null &&
				magItem != null && magItem.Amount < magSize)
				return true;

			if (magItem is 'BIO_MagazineETM')
				return false;

			reserveAmmo = Ammo(Owner.FindInventory(AmmoType1));
			cost = ReloadCost1;
			minReserve = MinAmmoReserve1;
		}
		else
		{
			magItem = Magazine2;
			magSize = MagazineSize2;

			if (AmmoType2 == null && MagazineType2 != null &&
				magItem != null && magItem.Amount < magSize)
				return true;

			if (magItem is 'BIO_MagazineETM')
				return false;

			reserveAmmo = Ammo(Owner.FindInventory(AmmoType2));
			cost = ReloadCost2;
			minReserve = MinAmmoReserve2;
		}

		int minAmt = minReserve * cost;

		// Insufficient reserves
		if (reserveAmmo == null || reserveAmmo.Amount < minAmt)
			return false;

		// Magazine's already full
		if (magItem.Amount >= magSize)
			return false;

		return true;
	}

	bool HasAffixOfType(class<BIO_WeaponAffix> type) const
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			if (Affixes[i].GetClass() == type)
				return true;

		return false;
	}

	BIO_WeaponAffix GetAffixByType(class<BIO_WeaponAffix> type) const
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			if (Affixes[i].GetClass() == type)
				return Affixes[i];

		return null;
	}

	BIO_StateTimeGroup GetFireTimeGroupByDesignation(
		BIO_StateTimeGroupDesignation designation) const
	{
		for (uint i = 0; i < FireTimeGroups.Size(); i++)
			if (FireTimeGroups[i].Designation == designation)
				return FireTimeGroups[i];

		return null;
	}

	Ammo, Ammo GetMagazines() const { return Magazine1, Magazine2; }

	// Returns a valid result even if the weapon feeds from reserves.
	uint ShotsPerMagazine(bool secondary = false) const
	{
		float dividend = 0.0, divisor = 0.0;

		if (!secondary)
		{
			if (AmmoUse1 == 0)
				return 0;

			divisor = float(AmmoUse1);

			if (Magazine1 != null)
			{
				if (Magazine1 is 'BIO_Magazine')
					dividend = float(MagazineSize1);
				else // Reserve
					dividend = float(Magazine1.MaxAmount);
			}
			else if (MagazineType1 != null)
			{
				if (MagazineType1 is 'BIO_Magazine')
					dividend = float(MagazineSize1);
				else // Reserve
					dividend = GetDefaultByType(MagazineType1).MaxAmount;
			}
			else if (Ammo1 != null)
			{
				dividend = float(Ammo1.MaxAmount);
			}
		}
		else
		{
			if (AmmoUse2 == 0)
				return 0;

			divisor = float(AmmoUse2);

			if (Magazine2 != null)
			{
				if (Magazine2 is 'BIO_Magazine')
					dividend = float(MagazineSize2);
				else // Reserve
					dividend = float(Magazine2.MaxAmount);
			}
			else if (MagazineType2 != null)
			{
				if (MagazineType2 is 'BIO_Magazine')
					dividend = float(MagazineSize2);
				else // Reserve
					dividend = GetDefaultByType(MagazineType2).MaxAmount;
			}
			else if (Ammo2 != null)
			{
				dividend = float(Ammo2.MaxAmount);
			}
		}

		return Floor(dividend / divisor);
	}

	uint RealAmmoConsumption(bool secondary = false) const
	{
		if (!secondary)
		{
			if (Magazine1 != null ||
				(MagazineType1 != null && MagazineType1 != AmmoType1))
				return AmmoUse1 * uint(Ceil(
					double(ReloadCost1) / double(ReloadOutput1)
				));
			else
				return AmmoUse1;
		}
		else
		{
			if (Magazine2 != null ||
				(MagazineType2 != null && MagazineType2 != AmmoType2))
				return AmmoUse2 * uint(Ceil(
					double(ReloadCost2) / double(ReloadOutput2)
				));
			else
				return AmmoUse2;
		}
	}

	bool Magazineless(bool secondary = false) const
	{
		return !(Magazine1 is 'BIO_Magazine') && !(Magazine2 is 'BIO_Magazine');
	}

	bool SufficientAmmo(bool secondary = false, int multi = 1) const
	{
		if (CheckInfiniteAmmo())
			return true;

		if (CanFeedEnergyToMatter(secondary, multi) ||
			CanFireEnergyToMatter(secondary, multi))
			return true;

		if (!secondary)
		{
			if (Magazine1.Amount < (AmmoUse1 * multi))
				return false;

			return true;
		}
		else
		{
			if (Magazine2.Amount < (AmmoUse2 * multi))
				return false;

			return true;
		}
	}

	bool MagazineEmpty(bool secondary = false) const
	{
		return !secondary ? Magazine1.Amount <= 0 : Magazine2.Amount <= 0;
	}

	bool MagazineFull(bool secondary = false) const
	{
		return !secondary ?
			Magazine1.Amount >= MagazineSize1 :
			Magazine2.Amount >= MagazineSize2;
	}

	bool CheckInfiniteAmmo() const
	{
		return
			sv_infiniteammo ||
			Owner.FindInventory('PowerInfiniteAmmo', true) != null;
	}

	bool CanFeedEnergyToMatter(bool secondary = false, int multi = 1) const
	{
		if (!secondary)
		{
			if (!(Magazine1 is 'BIO_MagazineETM'))
				return false;

			// Can't feed if the user's ETMF charge is already active
			if (Owner.FindInventory(BIO_MagazineETM(Magazine1).PowerupType))
				return false;

			if (CountInv('Cell') < AmmoUse1 * multi)
				return false;

			return true;
		}
		else
		{
			if (!(Magazine2 is 'BIO_MagazineETM'))
				return false;

			// Can't feed if the user's ETMF charge is already active
			if (Owner.FindInventory(BIO_MagazineETM(Magazine2).PowerupType))
				return false;

			if (CountInv('Cell') < AmmoUse2 * multi)
				return false;

			return true;
		}
	}

	bool CanFireEnergyToMatter(bool secondary = false, int multi = 1) const
	{
		if (!secondary)
		{
			if (!(Magazine1 is 'BIO_MagazineETM'))
				return false;

			if (Owner.FindInventory(BIO_MagazineETM(Magazine1).PowerupType))
				return true;
		}
		else
		{
			if (!(Magazine2 is 'BIO_MagazineETM'))
				return false;

			if (Owner.FindInventory(BIO_MagazineETM(Magazine2).PowerupType))
				return true;
		}

		return false;
	}

	bool Ammoless() const
	{
		return
			AmmoType1 == null && AmmoType2 == null &&
			AmmoUse1 <= 0 && AmmoUse2 <= 0 &&
			MagazineType1 == null && MagazineType2 == null;
	}

	bool DealsAnyDamage() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DealsAnyDamage())
				return true;

		return false;
	}

	bool DealsAnySplashDamage() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DealsAnySplashDamage())
				return true;

		return false;
	}

	bool MagazineSizeMutable(bool secondary = false) const
	{
		if (!secondary)
		{
			if (MagazineType1 == null || MagazineType1 == AmmoType1)
				return false;

			if (MagazineSize1 <= 0)
				return false;
		}
		else
		{
			if (MagazineType2 == null || MagazineType2 == AmmoType2)
				return false;

			if (MagazineSize2 <= 0)
				return false;
		}

		return true;
	}

	bool FireTimesReducible() const
	{
		// State sequences can't have all of their tic times reduced to 0.
		// Fire rate-affecting affixes must know in advance if
		// they can even have any effect, given this caveat.
		for (uint i = 0; i < FireTimeGroups.Size(); i++)
			if (FireTimeGroups[i].PossibleReduction() > 1)
				return true;

		return false;
	}

	bool FireTimesMutable() const
	{
		return FireTimeGroups.Size() > 0 && FireTimesReducible();
	}

	bool ReloadTimesReducible() const
	{
		// State sequences can't have all of their tic times reduced to 0.
		// Reload speed-affecting affixes must know in advance if
		// they can even have any effect, given this caveat.
		for (uint i = 0; i < ReloadTimeGroups.Size(); i++)
			if (ReloadTimeGroups[i].PossibleReduction() > 1)
				return true;

		return false;
	}

	bool ReloadTimesMutable() const
	{
		return ReloadTimeGroups.Size() > 0 && ReloadTimesReducible();
	}

	private bool ScavengingDestroys() const
	{
		return
			(AmmoType1 != null || AmmoType2 != null) &&
			AmmoGive1 <= 0 && AmmoGive2 <= 0 && !ScavengePersist &&
			!IsMutated();
	}

	string ColoredTag() const
	{
		string crEsc = "\c[White]";

		if (Unique)
			crEsc = "\c[Orange]";
		else if (IsMutated())
			crEsc = "\c[Cyan]";

		return String.Format("%s%s\c-", crEsc, Default.GetTag());
	}

	readOnly<BIO_Weapon> AsConst() const { return self; }
}

// Non-const member functions.
extend class BIO_Weapon
{
	// Prepare this weapon for another call to `SetDefaults()`.
	// Has no effect whatsoever on the mod graph, or `AmmoGive` values.
	virtual void Reset()
	{
		Pipelines.Clear();
		FireTimeGroups.Clear();
		ReloadTimeGroups.Clear();
		Affixes.Clear();
		SpecialFunc = null;

		bNoAutoFire = Default.bNoAutoFire;
		bNoAlert = Default.bNoAlert;
		bNoAutoAim = Default.bNoAutoAim;
		bMeleeWeapon = Default.bMeleeWeapon;

		bSpooling = Default.bSpooling;

		AmmoType1 = Default.AmmoType1;
		AmmoType2 = Default.AmmoType2;
		AmmoUse1 = Default.AmmoUse1;
		AmmoUse2 = Default.AmmoUse2;

		BobRangeX = Default.BobRangeX;
		BobRangeY = Default.BobRangeY;
		BobSpeed = Default.BobSpeed;
		BobStyle = Default.BobStyle;
		KickBack = Default.KickBack;

		RaiseSpeed = Default.RaiseSpeed;
		LowerSpeed = Default.LowerSpeed;

		MagazineSize1 = Default.MagazineSize1;
		MagazineSize2 = Default.MagazineSize2;

		ReloadCost1 = Default.ReloadCost1;
		ReloadOutput1 = Default.ReloadOutput1;
		ReloadCost2 = Default.ReloadCost2;
		ReloadOutput2 = Default.ReloadOutput2;

		MinAmmoReserve1 = Default.MinAmmoReserve1;
		MinAmmoReserve2 = Default.MinAmmoReserve2;

		ClearMagazines();
	}

	void LazyInit()
	{
		if (Uninitialised())
		{
			SetDefaults();
			IntrinsicModGraph(false);

			if (ModGraph != null)
				SetTag(ColoredTag());
		}
	}

	void SetupAmmo()
	{
		if (Owner == null)
			return;

		Ammo1 = AddAmmo(Owner, AmmoType1, 0);
		Ammo2 = AddAmmo(Owner, AmmoType2, 0);
	}

	void SetupMagazines(class<Ammo> override1 = null, class<Ammo> override2 = null)
	{
		if (Owner == null)
			return;

		if (override1 != null)
		{
			Magazine1 = Ammo(Owner.FindInventory(override1));

			if (Magazine1 == null)
			{
				Magazine1 = Ammo(Actor.Spawn(override1));
				Magazine1.AttachToOwner(Owner);
			}
		}
		// Get a pointer to primary ammo (which is either `AmmoType1` or
		// `MagazineType1`). If it isn't found, generate and attach it
		else if (Magazine1 == null && (MagazineType1 != null || AmmoType1 != null))
		{
			bool previouslyOwned = true;

			Magazine1 = MagazineType1 != null ?
				Ammo(Owner.FindInventory(MagazineType1)) :
				Ammo(Owner.FindInventory(AmmoType1));

			if (Magazine1 == null)
			{
				previouslyOwned = false;
				Magazine1 = Ammo(Actor.Spawn(MagazineType1));
				Magazine1.AttachToOwner(Owner);
			}

			if (!previouslyOwned && Default.MagazineSize1 != 0)
				Magazine1.Amount = Max(Default.MagazineSize1, 0);
		}

		if (override2 != null)
		{
			Magazine2 = Ammo(Owner.FindInventory(override2));

			if (Magazine2 == null)
			{
				Magazine2 = Ammo(Actor.Spawn(override2));
				Magazine2.AttachToOwner(Owner);
			}
		}
		// Same for secondary:
		else if (Magazine2 == null && (MagazineType2 != null || AmmoType2 != null))
		{
			bool previouslyOwned = true;

			Magazine2 = MagazineType2 != null ?
				Ammo(Owner.FindInventory(MagazineType2)) :
				Ammo(Owner.FindInventory(AmmoType2));

			if (Magazine2 == null)
			{
				previouslyOwned = false;
				Magazine2 = Ammo(Actor.Spawn(MagazineType2));
				Magazine2.AttachToOwner(Owner);
			}

			if (!previouslyOwned && Default.MagazineSize2 != 0)
				Magazine2.Amount = Max(Default.MagazineSize2, 0);
		}

		if (MagazineType1 == MagazineType2)
			Magazine2 = Magazine1;
	}

	void ClearMagazines(bool secondary = false)
	{
		if (!secondary)
			Magazine1 = null;
		else
			Magazine2 = null;
	}

	// Empty the magazine and return rounds in it to the reserve, with
	// consideration given to the relevant reload ratio.
	void DrainMagazine(bool secondary = false, int toDrain = 0)
	{
		Ammo mag = null, reserve = null;
		int cost = -1, output = -1;

		if (!secondary)
		{
			mag = Magazine1;
			reserve = Ammo1;
			cost = ReloadCost1;
			output = ReloadOutput1;
		}
		else
		{
			mag = Magazine2;
			reserve = Ammo2;
			cost = ReloadCost2;
			output = ReloadOutput2;
		}

		if (mag == null || reserve == null || !(mag is 'BIO_Magazine'))
			return;

		if (toDrain <= 0)
		{
			if (mag.Amount <= 0)
				return;

			toDrain = mag.Amount;
		}

		mag.Amount -= toDrain;
		let toGive = (toDrain / output) * cost;
		reserve.Amount = Clamp(reserve.Amount + toGive, 0, reserve.MaxAmount);
	}

	void DrainMagazineExcess(bool secondary = false)
	{
		Ammo mag = !secondary ? Magazine1 : Magazine2;
		int msize = !secondary ? MagazineSize1 : MagazineSize2;
		DrainMagazine(secondary, msize - mag.Amount);
	}

	void Mutate()
	{
		ModGraph = BIO_WeaponModGraph.Create(GraphQuality);
		IntrinsicModGraph(true);
		SetTag(ColoredTag());
	}

	// Used for supply box weapons and Legendary drops.
	void SpecialLootMutate(
		uint extraNodes = 0,
		uint geneCount = 1,
		bool noDuplicateGenes = false,
		bool raritySound = true
	)
	{
		if (Unique)
			return;

		LazyInit();

		if (ModGraph == null)
			Mutate();

		ModGraph.TryGenerateNodes(extraNodes);
		let sim = BIO_WeaponModSimulator.Create(self);

		sim.InsertNewGenesAtRandom(
			Min(ModGraph.Nodes.Size() - 1, geneCount),
			noDuplication: noDuplicateGenes
		);

		if (raritySound)
			BIO_Gene.PlayRaritySound(sim.LowestGeneLootWeight());

		sim.CommitAndClose();
		SetState(FindState('Spawn'));
	}

	bool TryEnergyToMatterFeed(bool secondary = false, int multi = 1)
	{
		if (CanFireEnergyToMatter(secondary, multi))
			return true;

		if (!CanFeedEnergyToMatter(secondary, multi))
			return false;

		if (!secondary)
		{
			Owner.A_TakeInventory('Cell', AmmoUse1 * multi, TIF_NOTAKEINFINITE);
			BIO_Utils.GivePowerup(
				Owner, BIO_MagazineETM(Magazine1).PowerupType,
				MagazineSize1 * multi
			);
		}
		else
		{
			Owner.A_TakeInventory('Cell', AmmoUse2 * multi, TIF_NOTAKEINFINITE);
			BIO_Utils.GivePowerup(
				Owner, BIO_MagazineETM(Magazine2).PowerupType,
				MagazineSize2 * multi
			);
		}

		Owner.A_StartSound("bio/weap/etmf", CHAN_AUTO);
		return true;
	}

	void ApplyLifeSteal(float percent, int dmg)
	{
		let lsp = Min(percent, 1.0);
		let given = int(float(dmg) * lsp);
		Owner.GiveBody(given, Owner.GetMaxHealth(true) + 100);
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnKill(self, killed, inflictor);
	}
}

// Weapon-building helpers.
extend class BIO_Weapon
{
	BIO_StateTimeGroup StateTimeGroupFrom(
		statelabel label,
		string tag = "",
		BIO_StateTimeGroupDesignation designation = BIO_STGD_NONE,
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	) const
	{
		state s = FindState(label);

		if (s == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"`BIO_Weapon::StateTimeGroupFrom()` "
				"failed to find a state by label. (%s)",
				GetClassName()
			);
			return null;
		}

		return BIO_StateTimeGroup.FromState(s, tag, designation, flags);
	}

	BIO_StateTimeGroup StateTimeGroupFromRange(
		statelabel start,
		statelabel end,
		string tag = "",
		BIO_StateTimeGroupDesignation designation = BIO_STGD_NONE,
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	) const
	{
		state s = FindState(start);

		if (s == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"`BIO_Weapon::StateTimeGroupFromRange()` "
				"failed to find a state given a `start` label. (%s)",
				GetClassName()
			);
			return null;
		}

		state e = FindState(end);

		if (e == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"`BIO_Weapon::StateTimeGroupFromRange()` "
				"failed to find a state given an `end` label. (%s)",
				GetClassName()
			);
			return null;
		}

		return BIO_StateTimeGroup.FromStateRange(s, e, tag, designation, flags);
	}

	BIO_StateTimeGroup StateTimeGroupFromArray(
		Array<statelabel> labels,
		string tag = "",
		BIO_StateTimeGroupDesignation designation = BIO_STGD_NONE,
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	) const
	{
		Array<state> stateptrs;

		for (uint i = 0; i < labels.Size(); i++)
		{
			state s = FindState(labels[i]);

			if (s == null)
			{
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"`BIO_Weapon::StateTimeGroupFromArray()` "
					"failed to find state at index %d. (%s)",
					i, GetClassName()
				);
			}
			else
			{
				stateptrs.Push(s);
			}
		}

		return BIO_StateTimeGroup.FromStates(stateptrs, tag, designation, flags);
	}
}

// Newly-defined actions.
extend class BIO_Weapon
{
	// `fireFactor` multiplies fired count and ammo usage.
	protected action bool A_BIO_Fire(uint pipeline = 0,
		int fireFactor = 1, float spreadFactor = 1.0)
	{
		bool secAmmo = invoker.Pipelines[pipeline].SecondaryAmmo;
		let usage = !secAmmo ? invoker.AmmoUse1 : invoker.AmmoUse2;

		if (!invoker.DepleteAmmo(secAmmo, true, usage * fireFactor))
			return false;

		invoker.Pipelines[pipeline].Invoke(
			invoker, pipeline, fireFactor, spreadFactor
		);
		return true;
	}

	protected action void A_BIO_FireSound(int channel = CHAN_WEAPON,
		int flags = CHANF_DEFAULT, double volume = 1.0,
		double attenuation = ATTN_NORM, uint pipeline = 0)
	{
		A_StartSound(invoker.Pipelines[pipeline].FireSound,
			channel, flags, volume, attenuation);
	}

	// If no argument is given, try to reload as much of the magazine as 
	// possible. Otherwise, try to reload the given amount of rounds.
	action void A_BIO_LoadMag(uint amt = 0, bool secondary = false)
	{
		class<Ammo> res_t = null;

		Ammo mag = null;
		int cost = -1, output = -1, magsize = -1, reserve = -1;

		if (!secondary)
		{
			res_t = invoker.AmmoType1;
			mag = invoker.Magazine1;
			magsize = invoker.MagazineSize1;
			cost = invoker.ReloadCost1;
			output = invoker.ReloadOutput1;
		}
		else
		{
			res_t = invoker.AmmoType2;
			mag = invoker.Magazine2;
			magsize = invoker.MagazineSize2;
			cost = invoker.ReloadCost2;
			output = invoker.ReloadOutput2;
		}

		if (mag == null)
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"%s tried to illegally load a null magazine.",
				invoker.GetClassName());
			return;
		}

		if (mag.Amount >= magsize)
			return;

		// e.g., pistols
		if (res_t == null)
		{
			mag.Amount = magsize;
			return;
		}
		else
		{
			reserve = CountInv(res_t);
		}

		int toLoad = -1, toDraw = -1;

		if (amt > 0)
			toLoad = amt;
		else
			toLoad = magsize - mag.Amount;

		toLoad = int(Floor(float(toLoad) / float(output)));
		toDraw = Min(toLoad * cost, reserve);
		toLoad = Min(toLoad, toDraw) * output;

		for (uint i = 0; i < invoker.Affixes.Size(); i++)
			invoker.Affixes[i].OnMagLoad(invoker, secondary, toDraw, toLoad);

		TakeInventory(res_t, toDraw);
		mag.Amount += toLoad;
	}

	// Conventionally called on a `TNT1 A 0` state at the
	// very beginning of a fire/altfire state.
	protected action state A_BIO_CheckAmmo(bool secondary = false,
		statelabel fallback = 'Ready', statelabel reload = 'Reload',
		statelabel dryfire = 'Dryfire', int multi = 1, bool single = false)
	{
		if (invoker.SufficientAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
		{
			state dfs = ResolveState(dryfire);
			
			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}

		let cv = BIO_CVar.AutoReloadPre(Player);
		bool s = single || invoker.ShotsPerMagazine(secondary) == 1;

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && s))
			return ResolveState(reload);
		else
		{
			state dfs = ResolveState(dryfire);
			
			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}
	}

	// To be called at the end of a fire/altfire state.
	protected action state A_BIO_AutoReload(bool secondary = false,
		statelabel reload = 'Reload', int multi = 1, bool single = false)
	{
		if (invoker.SufficientAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
			return state(null);

		let cv = BIO_CVar.AutoReloadPost(Player);
		bool s = single || invoker.ShotsPerMagazine(secondary) == 1;

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && s))
			return ResolveState(reload);
		else
			return state(null);
	}

	// Call on a `TNT1 A 0` state before a `Reload` state sequence begins.
	protected action state A_BIO_CheckReload(
		bool secondary = false, statelabel fallback = 'Ready')
	{
		if (invoker.CanReload(secondary))
			return state(null);
		else
			return ResolveState(fallback);
	}

	/*	Call from the weapon's `Spawn` state, after two frames of the weapon's 
		pickup sprite (each 0 tics long). Puts the weapon into a new loop with
		appropriate behaviour for its status (e.g., blinking cyan if mutated).
	*/
	protected action state A_BIO_Spawn()
	{
		if (invoker.Unique)
			return ResolveState('Spawn.Unique');
		else if (invoker.IsMutated())
			return ResolveState('Spawn.Mutated');
		else
			return ResolveState('Spawn.Normal');
	}

	/*	Call from the weapon's Deselect state, during one frame of the weapon's
		ready sprite (0 tics long). Runs a callback and puts the weapon in a 
		lowering loop.
	*/
	protected action state A_BIO_Deselect()
	{
		invoker.OnDeselect();
		return ResolveState('Deselect.Loop');
	}

	/*	Call from the weapon's Select state, during one frame of the weapon's
		ready sprite (0 tics long). Runs a callback and puts the weapon in a 
		raising loop.
	*/
	protected action state A_BIO_Select()
	{
		invoker.OnSelect();
		return ResolveState('Select.Loop');
	}

	protected action void A_BIO_GroundHit()
	{
		if (Abs(Vel.Z) <= 0.01 && !invoker.bHitGround)
		{
			A_StartSound(invoker.GroundHitSound);
			A_ScaleVelocity(0.5);
			bSpecial = true;
			bThruActors = false;
			invoker.bHitGround = true;
		}
	}

	protected action void A_BIO_SetFireTime(
		uint index, uint group = 0, int modifier = 0)
	{
		A_SetTics(Max(modifier + invoker.FireTimeGroups[group].Times[index], 0));
	}

	protected action void A_BIO_SetReloadTime(
		uint index, uint group = 0, int modifier = 0)
	{
		A_SetTics(Max(modifier + invoker.ReloadTimeGroups[group].Times[index], 0));
	}

	protected action void A_BIO_Recoil(class<BIO_RecoilThinker> recoil_t,
		float scale = 1.0, bool invert = false)
	{
		BIO_RecoilThinker.Create(recoil_t, BIO_Weapon(invoker), scale, invert);
	}

	// Shunt the wielder in the opposite direction from the one they're facing.
	protected action void A_BIO_Pushback(float xVelMult, float zVelMult)
	{
		// Don't apply any if the wielding player isn't on the ground
		if (invoker.Owner.Pos.Z > invoker.Owner.FloorZ) return;

		A_ChangeVelocity(
			Cos(invoker.Pitch) * -xVelMult, 0.0,
			Sin(invoker.Pitch) * zVelMult, CVF_RELATIVE);
	}

	protected action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	protected action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }

	protected action state A_BIO_WeaponSpecial()
	{
		if (invoker.SpecialFunc == null ||
			invoker.Owner.FindInventory('BIO_WeaponSpecialCooldown') != null)
			return state(null);

		invoker.Owner.GiveInventory('BIO_WeaponSpecialCooldown', 1);
		return invoker.SpecialFunc.Invoke(invoker);
	}
}

// Customised variations on gzdoom.pk3 attack actions.
extend class BIO_Weapon
{
	Actor BIO_FireProjectile(class<Actor> proj_t, double angle = 0,
		double spawnOfs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle - 90.0;
		Vector2 ofs = AngleToVector(ang, spawnOfs_xy);
		double shootangle = Owner.Angle;

		if (flags & FPF_AIMATANGLE) shootangle += angle;

		// Temporarily adjusts the pitch
		double playerPitch = Owner.Pitch;
		Owner.Pitch += pitch;
		let misl = Owner.SpawnPlayerMissile(proj_t, shootangle, ofs.X, ofs.Y,
			spawnHeight, t, false, (flags & FPF_NOAUTOAIM) != 0);
		Owner.Pitch = playerPitch;

		// Automatic handling of seeker missiles
		if (misl != null)
		{
			if (flags & FPF_TRANSFERTRANSLATION)
				misl.Translation = Translation;
			if (t.LineTarget && !t.Unlinked && misl.bSeekerMissile)
				misl.Tracer = t.LineTarget;

			if (!(flags & FPF_AIMATANGLE))
			{
				// This original implementation is to aim straight ahead and then offset
				// the angle from the resulting direction. 
				misl.Angle += angle;
				misl.VelFromAngle(misl.Vel.XY.Length());
			}
		}
		return misl;
	}

	/* 	This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/
	Actor BIO_FireBullet(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, class<Actor> puff_t, EFireBulletsFlags flags = FBF_NONE,
		double range = 0.0, class<Actor> missile = null,
		double spawnHeight = 32.0, double spawnOfs_xy = 0.0)
	{
		int i = 0;
		double bAngle = 0.0, bSlope = 0.0;
		int laFlags = (flags & FBF_NORANDOMPUFFZ) ? LAF_NORANDOMPUFFZ : 0;
		FTranslatedLineTarget t;

		if (range ~== 0.0) range = PLAYERMISSILERANGE;

		if (!(flags & FBF_NOFLASH)) BIO_Player(Owner).PlayAttacking2();
		if (!(flags & FBF_NOPITCH)) bSlope = Owner.BulletSlope();

		bAngle = Owner.Angle;

		if ((numBullets == 1 && !Owner.Player.Refire) || numBullets == 0)
		{
			int damage = bulletDmg;

			Actor puff = null; int realDmg = -1;
			[puff, realDmg] = Owner.LineAttack(bAngle, range,
				bSlope, damage, 'Hitscan', puff_t, laFlags, t);
			
			if (puff == null)
			{
				FLineTraceData ltd;
				LineTrace(bAngle, range, bSlope, TRF_NONE, data: ltd);
				puff = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
				puff.DamageType = GetDefaultByType(puff_t).DamageType;
				puff.Tracer = t.LineTarget;
			}

			puff.SetDamage(realDmg);

			if (missile != null)
			{
				bool temp = false;
				double ang = Owner.Angle - 90;
				Vector2 ofs = Owner.AngleToVector(ang, spawnOfs_xy);
				Actor proj = Owner.SpawnPlayerMissile(missile, bAngle,
					ofs.X, ofs.Y, spawnHeight);

				if (proj)
				{
					if (!puff)
					{
						temp = true;
						puff = Owner.LineAttack(bAngle, range, bSlope, 0,
							'Hitscan', puff_t, laFlags | LAF_NOINTERACT, t);
					}
					Owner.AimBulletMissile(proj, puff, flags, temp, false);
					if (t.Unlinked)
					{
						// Arbitary portals will make angle and pitch calculations 
						// unreliable. So use the angle and pitch we passed instead.
						proj.Angle = bAngle;
						proj.Pitch = bSlope;
						proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
					}
				}
			}

			return puff;
		}
		else // `numBullets` -1; all bullets spread
		{
			double pAngle = bAngle;
			double slope = bSlope;

			if (flags & FBF_EXPLICITANGLE)
			{
				pAngle += spread_xy;
				slope += spread_z;
			}
			else
			{
				pAngle += spread_xy * Random2[cabullet]() / 255.;
				slope += spread_z * Random2[cabullet]() / 255.;
			}

			int damage = bulletDmg;

			Actor puff = null; int realDmg = -1;
			[puff, realDmg] = Owner.LineAttack(pAngle, range, 
				slope, damage, 'Hitscan', puff_t, laflags, t);

			if (puff == null)
			{
				FLineTraceData ltd;
				LineTrace(pAngle, range, slope, TRF_NONE, data: ltd);
				puff = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
				puff.DamageType = GetDefaultByType(puff_t).DamageType;
				puff.Tracer = t.LineTarget;
			}

			puff.SetDamage(realDmg);
			if (missile == null) return puff;

			bool temp = false;
			double ang = Owner.Angle - 90;
			Vector2 ofs = Owner.AngleToVector(ang, spawnOfs_xy);
			Actor proj = Owner.SpawnPlayerMissile(missile, bAngle, ofs.X, ofs.Y, spawnHeight);
			
			if (proj)
			{
				if (!puff)
				{
					temp = true;
					puff = Owner.LineAttack(
						bAngle, range, bSlope, 0, 'Hitscan', puff_t,
						laFlags | LAF_NOINTERACT, t);
				}
				Owner.AimBulletMissile(proj, puff, flags, temp, false);
				if (t.Unlinked)
				{
					// Arbitary portals will make angle and pitch calculations 
					// unreliable. So use the angle and pitch we passed instead.
					proj.Angle = bAngle;
					proj.Pitch = bSlope;
					proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
				}
			}

			return puff;
		}
	}

	void BIO_RailAttack(int damage, int spawnOffs_xy = 0, color color1 = 0,
		color color2 = 0, int flags = 0, double maxDiff = 0,
		class<Actor> puff_t = 'BulletPuff', double spread_xy = 0,
		double spread_z = 0, double range = 0, int duration = 0,
		double sparsity = 1.0, double driftSpeed = 1.0,
		class<Actor> spawnClass = 'None', double spawnOffs_z = 0,
		int spiraloffset = 270, int limit = 0)
	{
		if (range == 0) range = 8192;
		if (sparsity == 0) sparsity = 1.0;

		if (!(flags & RGF_EXPLICITANGLE))
		{
			spread_xy = spread_xy * Random2[CRailgun]() / 255.0;
			spread_z = spread_z * Random2[CRailgun]() / 255.0;
		}

		FRailParams p;
		p.Damage = damage;
		p.Offset_xy = spawnOffs_xy;
		p.Offset_z = spawnOffs_z;
		p.Color1 = color1;
		p.Color2 = color2;
		p.MaxDiff = maxDiff;
		p.Flags = flags | RGF_SILENT;
		p.Puff = puff_t;
		p.AngleOffset = spread_xy;
		p.PitchOffset = spread_z;
		p.Distance = range;
		p.Duration = duration;
		p.Sparsity = sparsity;
		p.Drift = driftSpeed;
		p.SpawnClass = spawnClass;
		p.SpiralOffset = spiralOffset;
		p.Limit = limit;
		Owner.RailAttack(p);
	}

	/* 	This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/ 
	Actor BIO_Punch(in out BIO_ShotData shotData, double range = DEFMELEERANGE,
		float lifesteal = 0.0, sound hitSound = 0, sound missSound = "",
		ECustomPunchFlags flags = CPF_NONE)
	{
		FTranslatedLineTarget t;

		shotData.Angle = Owner.Angle + Random2[CWPunch]() * (5.625 / 256);
		shotData.Pitch = Owner.AimLineAttack(shotData.Angle, range, t, 0.0, ALF_CHECK3D);
		
		Actor ret = null;
		int actualDmg = -1;

		ELineAttackFlags puffFlags = LAF_ISMELEEATTACK |
			((flags & CPF_NORANDOMPUFFZ) ? LAF_NORANDOMPUFFZ : 0);

		[ret, actualDmg] = Owner.LineAttack(shotData.Angle, range, shotData.Pitch,
			shotData.Damage, 'Melee', shotData.Payload, puffFlags, t);

		if (t.LineTarget == null)
		{
			Owner.A_StartSound(missSound, CHAN_AUTO);
			return null;
		}

		Owner.A_StartSound(hitSound, CHAN_AUTO);

		if (!(flags & CPF_NOTURN))
		{
			// Turn to face target
			Owner.Angle = t.AngleFromSource;
		}

		if (flags & CPF_PULLIN) Owner.bJustAttacked = true;

		if (!t.LineTarget.bDontDrain)
			ApplyLifeSteal(lifesteal, actualDmg);

		if (ret == null)
		{
			ret = Spawn('BIO_FakePuff', t.LineTarget.Pos);
			ret.SetDamage(actualDmg);
			ret.DamageType = 'Melee';
			ret.Tracer = t.LineTarget;
		}

		return ret;
	}

	void BIO_Saw(sound fullSound, sound hitSound, int dmg, class<Actor> puff_t,
		ESawFlags flags, float range, float lifestealPercent)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle + 2.8125 * (Random2[Saw]() / 255.0);
		double slope = Owner.AimLineAttack(ang, range, t) *
			(Random2[Saw]() / 255.0);

		Actor puff = null;
		int actualDmg = 0;
		[puff, actualDmg] = Owner.LineAttack(ang, range, slope, dmg,
			'Melee', puff_t, 0, t);

		if (!t.LineTarget)
		{
			if ((flags & SF_RANDOMLIGHTMISS) && (Random[Saw]() > 64))
				Player.ExtraLight = !Player.ExtraLight;
			
			Owner.A_StartSound(fullSound, CHAN_WEAPON);
			return;
		}

		if (flags & SF_RANDOMLIGHTHIT)
		{
			int randVal = Random[Saw]();

			if (randVal < 64)
				Player.ExtraLight = 0;
			else if (randVal < 160)
				Player.ExtraLight = 1;
			else
				Player.ExtraLight = 2;
		}

		if (!t.LineTarget.bDontDrain)
			ApplyLifeSteal(lifestealPercent, actualDmg);

		Owner.A_StartSound(hitSound, CHAN_WEAPON);

		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double angleDiff = DeltaAngle(Owner.Angle, t.AngleFromSource);

			if (angleDiff < 0.0)
			{
				if (angleDiff < -4.5)
					Owner.Angle = t.AngleFromSource + 90.0 / 21;
				else
					Owner.Angle -= 4.5;
			}
			else
			{
				if (angleDiff > 4.5)
					Owner.Angle = t.AngleFromSource - 90.0 / 21;
				else
					Owner.Angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			bJustAttacked = true;
	}

	// A specialized variation on `A_BFGSpray()`, for use by
	// `BIO_FireFunc_BFGSpray()`. Shoots only one ray and returns a fake puff.
	Actor BIO_BFGSpray(in out BIO_ShotData shotData, double distance = 16.0 * 64.0,
		double vrange = 32.0, EBFGSprayFlags flags = BFGF_NONE)
	{
		FTranslatedLineTarget t;
		double an = Owner.Angle - shotData.Angle / 2 + shotData.Angle /
			shotData.Count * shotData.Number;

		Owner.AimLineAttack(an, distance, t, vrange);

		if (t.LineTarget == null) return null;

		Actor
			spray = Spawn(shotData.Payload, t.LineTarget.Pos +
			(0, 0, t.LineTarget.Height / 4), ALLOW_REPLACE),
			ret = Spawn('BIO_FakePuff', t.LineTarget.Pos);

		int dmgFlags = 0;
		name dmgType = 'BFGSplash';

		if (spray != null)
		{
			// [XA] Don't hit oneself unless we say so.
			if ((spray.bMThruSpecies &&
				Owner.GetSpecies() == t.LineTarget.GetSpecies()) || 
				(!(flags & BFGF_HURTSOURCE) && Owner == t.LineTarget)) 
			{
				// [MC] Remove it because technically, the spray isn't trying to "hit" them.
				spray.Destroy(); 
				return null;
			}

			if (spray.bPuffGetsOwner) spray.Target = Owner;
			if (spray.bFoilInvul) dmgFlags |= DMG_FOILINVUL;
			if (spray.bFoilBuddha) dmgFlags |= DMG_FOILBUDDHA;
			dmgType = spray.DamageType;
		}

		int newdam = t.LineTarget.DamageMObj(
			ret, Owner, shotData.Damage, dmgType,
			dmgFlags | DMG_USEANGLE, t.AngleFromSource);
		ret.SetDamage(newDam);
		ret.DamageType = 'BFGSplash';
		ret.Tracer = t.LineTarget;
		t.TraceBleed(newdam > 0 ? newdam : shotData.Damage, Owner);
		return ret;
	}
}

// Serialization/deserialization.
extend class BIO_Weapon
{
	Dictionary Serialize() const
	{
		let ret = Dictionary.Create();
		
		ret.Insert("type", GetClassName());

		if (ModGraph != null)
		{
			ret.Insert("modgraph.size", String.Format("%d", ModGraph.Nodes.Size()));

			for (uint i = 0; i < ModGraph.Nodes.Size(); i++)
			{
				ModGraph.Nodes[i].Serialize(ret);
			}
		}

		return ret;
	}

	static BIO_Weapon Deserialize(string input, Vector3 pos)
	{
		let dict = Dictionary.FromString(input);

		let ret = BIO_Weapon(Actor.Spawn(dict.At("type"), pos));
		ret.LazyInit();

		let sz = dict.At("modgraph.size").ToInt();

		if (sz > 0 && ret.ModGraph == null)
			ret.ModGraph = BIO_WeaponModGraph.Create(0);

		ret.ModGraph.Nodes[0] = BIO_WMGNode.Deserialize(dict, 0);

		for (uint i = 1; i < sz; i++)
			ret.ModGraph.Nodes.Push(BIO_WMGNode.Deserialize(dict, i));

		ret.SetTag(ret.ColoredTag());
		return ret;
	}
}
