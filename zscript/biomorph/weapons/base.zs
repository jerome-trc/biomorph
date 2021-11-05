enum BIO_WeaponFlags : uint8
{
	BIO_WF_NONE = 0,
	BIO_WF_CORRUPTED = 1 << 0,
	BIO_WF_AFFIXESHIDDEN = 1 << 1, // Caused by corruption
	BIO_WF_PISTOL = 1 << 2,
	// The following 3 are applicable only to dual-wielded weapons
	BIO_WF_NOAUTOPRIMARY = 1 << 3,
	BIO_WF_NOAUTOSECONDARY = 1 << 4,
	BIO_WF_AKIMBORELOAD = 1 << 5
}

// Dictate what stats can be affected by affixes. If a bit is set,
// the affix should stop itself from altering that stat, or applying itself
// to a weapon which it can't even affect.
enum BIO_WeaponAffixMask : uint
{
	BIO_WAM_NONE = 0,
	BIO_WAM_ALL = uint.MAX,
	// The first 8 bits are reserved for `MiscAffixMask`, which is 8 bits wide.
	BIO_WAM_RAISESPEED = 1 << 0,
	BIO_WAM_LOWERSPEED = 1 << 1,
	BIO_WAM_SWITCHSPEED = BIO_WAM_RAISESPEED | BIO_WAM_LOWERSPEED,
	BIO_WAM_BIOFLAGS = 1 << 2,
	BIO_WAM_KICKBACK = 1 << 3,
	// The following bits should only be assigned to `AffixMask1` or `AffixMask2`.
	BIO_WAM_FIRETYPE = 1 << 9,
	BIO_WAM_FIRECOUNT = 1 << 10,
	BIO_WAM_FIREDATA = BIO_WAM_FIRETYPE | BIO_WAM_FIRECOUNT,
	BIO_WAM_MINDAMAGE = 1 << 11,
	BIO_WAM_MAXDAMAGE = 1 << 12,
	BIO_WAM_DAMAGE = BIO_WAM_MINDAMAGE | BIO_WAM_MAXDAMAGE,
	BIO_WAM_HSPREAD = 1 << 13,
	BIO_WAM_VSPREAD = 1 << 14,
	BIO_WAM_SPREAD = BIO_WAM_HSPREAD | BIO_WAM_VSPREAD,
	BIO_WAM_MAGSIZE = 1 << 15,
	BIO_WAM_FIRETIME = 1 << 16,
	BIO_WAM_RELOADTIME = 1 << 17,
	BIO_WAM_LIFESTEAL = 1 << 18,
	BIO_WAM_MELEERANGE = 1 << 19,
	BIO_WAM_MELEE = BIO_WAM_LIFESTEAL | BIO_WAM_MELEERANGE,
	BIO_WAM_ONPROJFIRED = 1 << 20,
	BIO_WAM_PROJTRAVELFUNCTORS = 1 << 21,
	BIO_WAM_PROJDAMAGEFUNCTORS = 1 << 22,
	BIO_WAM_PROJDEATHFUNCTORS = 1 << 23,
	BIO_WAM_PROJFUNCTORS = BIO_WAM_PROJTRAVELFUNCTORS |
		BIO_WAM_PROJDAMAGEFUNCTORS | BIO_WAM_PROJDEATHFUNCTORS,
	BIO_WAM_AFFIXMASK = 1 << 24
}

mixin class BIO_Magazine
{
	Default
	{
		+INVENTORY.IGNORESKILL
		Inventory.Icon '';
		Inventory.MaxAmount 32767;
	}
}

class BIO_Weapon : DoomWeapon abstract
{
	mixin BIO_Gear;

	const MAX_AFFIXES = 6;

	BIO_WeaponFlags BIOFlags; property Flags: BIOFlags;
	BIO_WeaponAffixMask AffixMask1, AffixMask2;
	uint8 MiscAffixMask;
	property AffixMasks: AffixMask1, AffixMask2, MiscAffixMask;

	Class<Actor> FireType1, FireType2;
	property FireType: FireType1;
	property FireType1: FireType1;
	property FireType2: FireType2;
	property FireTypes: FireType1, FireType2;

	int FireCount1, FireCount2;
	property FireCount: FireCount1;
	property FireCount1: FireCount1;
	property FireCount2: FireCount2;
	property FireCounts: FireCount1, FireCount2;

	int MinDamage1, MinDamage2;
	property MinDamage: MinDamage1;
	property MinDamage1: MinDamage1;
	property MinDamage2: MinDamage2;
	property MinDamages: MinDamage1, MinDamage2;

	int MaxDamage1, MaxDamage2;
	property MaxDamage: MaxDamage1;
	property MaxDamage1: MaxDamage1;
	property MaxDamage2: MaxDamage2;
	property MaxDamages: MaxDamage1, MaxDamage2;

	property DamageRange: MinDamage1, MaxDamage1;
	property DamageRange1: MinDamage1, MaxDamage1;
	property DamageRange2: MinDamage2, MaxDamage2;
	property DamageRanges: MinDamage1, MaxDamage1, MinDamage2, MaxDamage2;

	float HSpread1, HSpread2;
	property HSpread: HSpread1;
	property HSpread1: HSpread1;
	property HSpread2: HSpread2;
	property HSpreads: HSpread1, HSpread2;
	
	float VSpread1, VSpread2;
	property VSpread: VSpread1;
	property VSpread1: VSpread1;
	property VSpread2: VSpread2;
	property VSpreads: VSpread1, VSpread2;

	property Spread: HSpread1, VSpread1;
	property Spread1: HSpread1, VSpread2;
	property Spread2: HSpread2, VSpread2;
	property Spreads: HSpread1, VSpread1, HSpread2, VSpread2;

	int RaiseSpeed, LowerSpeed;
	property SwitchSpeeds: RaiseSpeed, LowerSpeed;

	meta Class<Ammo> MagazineType1, MagazineType2;
	property MagazineType: MagazineType1;
	property MagazineType1: MagazineType1;
	property MagazineType2: MagazineType2;
	property MagazineTypes: MagazineType1, MagazineType2;

	// Reloading 1 round costs ReloadFactor rounds in reserve.
	int ReloadFactor1, ReloadFactor2;
	property ReloadFactor: ReloadFactor1;
	property ReloadFactor1: ReloadFactor1;
	property ReloadFactor2: ReloadFactor2;
	property ReloadFactors: ReloadFactor1, ReloadFactor2;

	int MagazineSize1, MagazineSize2;
	property MagazineSize: MagazineSize1;
	property MagazineSize1: MagazineSize1;
	property MagazineSize2: MagazineSize2;
	property MagazineSizes: MagazineSize1, MagazineSize2;

	int MinAmmoReserve1, MinAmmoReserve2;
	property MinAmmoReserve: MinAmmoReserve1;
	property MinAmmoReserve1: MinAmmoReserve1;
	property MinAmmoReserve2: MinAmmoReserve2;
	property MinAmmoReserves: MinAmmoReserve1, MinAmmoReserve2;

	protected Ammo Magazine1, Magazine2;

	Array<BIO_WeaponAffix> ImplicitAffixes, Affixes;
	Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	Array<BIO_ProjDamageFunctor> ProjDamageFunctors;
	Array<BIO_ProjDeathFunctor> ProjDeathFunctors;

	// If the weapon carries special data that can't be known without knowing the
	// exact class type in advance (e.g. from a mixin), store it in here.
	protected transient Dictionary Dict;

	const DICTKEY_PELLETCOUNT_1 = "PelletCount1";
	const DICTKEY_PELLETCOUNT_2 = "PelletCount2";
	const DICTKEY_MELEERANGE = "MeleeRange";
	const DICTKEY_LIFESTEAL = "LifeSteal";
	
	Array<string> StatReadout, AffixReadout;

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

		Weapon.BobRangeX 0.5;
        Weapon.BobRangeY 0.5;
        Weapon.BobSpeed 1.2;
        Weapon.BobStyle 'Alpha';

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_NONE, BIO_WAM_NONE;
		BIO_Weapon.DamageRanges -2, -2, -2, -2;
		BIO_Weapon.FireCounts 1, 1;
		BIO_Weapon.FireTypes '', '';
		BIO_Weapon.Flags BIO_WF_NONE;
		BIO_Weapon.Grade BIO_GRADE_NONE;
		BIO_Weapon.MagazineSizes 0, 0;
		BIO_Weapon.MagazineTypes '', '';
		BIO_Weapon.MinAmmoReserves 1, 1;
		BIO_Weapon.Rarity BIO_RARITY_COMMON;
		BIO_Weapon.ReloadFactors 1, 1;
		BIO_Weapon.Spreads 0.0, 0.0, 0.0, 0.0;
		BIO_Weapon.SwitchSpeeds 6, 6;
	}

	States
	{
	Select.Loop:
		#### # 1 A_BIO_Raise;
		Loop;
	Deselect.Loop:
		#### # 1 A_BIO_Lower;
		Loop;
	Spawn:
		TNT1 A 0;
		Stop;
	Spawn.Common:
		#### # 4;
		#### # 1 A_GroundHit;
		Goto Spawn.Common + 1;
	Spawn.Mutated:
		#### # 4;
		#### # 1
		{
			A_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_GroundHit;
		#### # 1 Bright
		{
			A_GroundHit();
			A_SetTranslation('BIO_Mutated');
		}
		#### ##### 1 Bright A_GroundHit;
		Goto Spawn.Mutated + 1;
	Spawn.Unique:
		#### # 4;
		#### # 1
		{
			A_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_GroundHit;
		#### # 1 Bright
		{
			A_GroundHit();
			A_SetTranslation('BIO_Unique');
		}
		#### ##### 1 Bright A_GroundHit;
		Goto Spawn.Unique + 1;
	}

	// Parent overrides ========================================================

	override void BeginPlay()
	{
		super.BeginPlay();
		SetTag(GetColoredTag());
		RewriteAffixReadout();
		RewriteStatReadout();

		if (Abs(Vel.Z) <= 0.01)
		{
			bSpecial = true;
			bThruActors = false;
			HitGround = true;
		}
	}

	override void AttachToOwner(Actor newOwner)
	{
		if (!PreviouslyPickedUp) RLMDangerLevel();
		PreviouslyPickedUp = true;
		
		// Weapon::AttachToOwner() calls AddAmmo() for both types, which we
		// don't want. This next bit is silly, but beats re-implementing
		// that function (and having to watch if it changes upstream)
		AmmoGive1 = AmmoGive2 = 0;
		super.AttachToOwner(newOwner);
		AmmoGive1 = Default.AmmoGive1;
		AmmoGive2 = Default.AmmoGive2;

		BIO_GlobalData.Get().OnWeaponAcquired(Grade);

		// Get a pointer to primary ammo (which is either AmmoType1 or MagazineType1):
		if (Magazine1 == null && AmmoType1 != null)
		{
			Magazine1 =
				MagazineType1 != null ?
				Ammo(FindInventory(MagazineType1)) :
				Ammo(FindInventory(AmmoType1));

			if (Magazine1 == null)
			{
				Magazine1 = Ammo(Actor.Spawn(MagazineType1));
				Magazine1.AttachToOwner(newOwner);
			}
		}

		// Same for secondary:
		if (Magazine2 == null && AmmoType2 != null)
		{
			Magazine2 =
				MagazineType2 != null ?
				Ammo(FindInventory(MagazineType2)) :
				Ammo(FindInventory(AmmoType2));

			if (Magazine2 == null)
			{
				Magazine2 = Ammo(Actor.Spawn(MagazineType2));
				Magazine2.AttachToOwner(newOwner);
			}
		}
	}

	// The player can't pick up a weapon if they're full on them,
	// or already have one of this class.
	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher)) return false;

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return false;

		if (bioPlayer.IsFullOnWeapons()) return false;
		if (bioPlayer.CountInv(GetClass()) >= MaxAmount) return false;

		return true;
	}

	// For now, weapons cannot be cannibalised for ammunition.
	override bool TryPickupRestricted(in out Actor toucher) { return false; }

	override string PickupMessage()
	{
		string ret = String.Format(StringTable.Localize(PickupMsg), GetTag());
		ret = ret .. " [\cn" .. SlotNumber .. "\c-]";
		return ret;
	}

	override void OnDrop(Actor dropper)
	{
		super.OnDrop(dropper);
		HitGround = false;
	}

	// Virtuals/abstracts ======================================================

	virtual void OnDeselect() {}
	virtual void OnSelect() {}

	// If the weapon carries special data that can't be known without knowing the
	// exact class type in advance (e.g. from a mixin), store it in `Dict`.
	virtual void UpdateDictionary() {}

	// Always gets called before affixes get their version of this invoked.
	virtual void OnTrueProjectileFired(BIO_Projectile proj) const {}
	virtual void OnFastProjectileFired(BIO_FastProjectile proj) const {}

	// Only for getting mutable fire times; ignore any fixed state frame times.
	virtual void GetFireTimes(in out Array<int> fireTimes,
		bool secondary = false) const {}
	protected virtual void SetFireTimes(Array<int> fireTimes,
		bool secondary = false) {}

	// Only for getting mutable reload times; ignore any fixed state frame times.
	virtual void GetReloadTimes(in out Array<int> reloadTimes,
		bool secondary = false) const {}
	protected virtual void SetReloadTimes(Array<int> reloadTimes,
		bool secondary = false) {}

	// Ensure that overrides include fixed state frame times.
	abstract int TrueFireTime() const;
	virtual int TrueReloadTime() const { return 0; }

	// Getters =================================================================

	protected abstract void StatsToString(in out Array<string> stats) const;

	string GetFireTypeTag(bool secondary = false) const
	{
		Class<Actor> fireType = !secondary ? FireType1 : FireType2;
		int count = !secondary ? FireCount1 : FireCount2;
		
		if (fireType is 'BIO_Projectile')
		{
			let defs = GetDefaultByType((Class<BIO_Projectile>)(fireType));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (fireType is 'BIO_FastProjectile')
		{
			let defs = GetDefaultByType((Class<BIO_FastProjectile>)(fireType));
		
			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else
			return StringTable.Localize(GetDefaultByType(fireType).GetTag());
	}

	string, bool TryGetDictValue(string key)
	{
		string ret = Dict.At(key);
		return ret, ret.Length() > 0;
	}

	Ammo, Ammo GetMagazines() const { return Magazine1, Magazine2; }

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

	bool CanReload(bool secondary = false) const
	{
		let magAmmo = !secondary ? Magazine1 : Magazine2;
		let reserveAmmo = Owner.FindInventory(
			!secondary ? AmmoType1 : AmmoType2);
		let minReserve = !secondary ? MinAmmoReserve1 : MinAmmoReserve2;
		let factor = !secondary ? ReloadFactor1 : ReloadFactor2;
		let magSize = !secondary ? MagazineSize1 : MagazineSize2;
		
		int minAmt = minReserve * factor;

		// Insufficient reserves
		if (reserveAmmo == null || reserveAmmo.Amount < minAmt)
			return false;

		// Magazine's already full
		if (magAmmo.Amount >= magSize)
			return false;

		return true;
	}

	bool HasAffixOfType(Class<BIO_WeaponAffix> t, bool implicit = false) const
	{
		if (!implicit)
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				if (Affixes[i].GetClass() == t)
					return true;

			return false;
		}
		else
		{
			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
				if (ImplicitAffixes[i].GetClass() == t)
					return true;

			return false;
		}
	}

	bool NoImplicitAffixes() const { return ImplicitAffixes.Size() < 1; }
	bool NoExplicitAffixes() const { return Affixes.Size() < 1; }
	bool NoAffixes() const { return NoImplicitAffixes() && NoExplicitAffixes(); }

	bool DealsAnyDamage() const { return (MaxDamage1 + MaxDamage2) > 0; }

	bool FireTypeMutableFrom(Class<Actor> curFT, bool secondary = false) const
	{
		if (bMeleeWeapon) return false;

		if (!secondary)
		{
			return
				FireTypeIsDefault(false) &&
				!(AffixMask1 & BIO_WAM_FIRETYPE) &&
				FireType1 == curFT;
		}
		else
		{
			return
				FireTypeIsDefault(true) &&
				!(AffixMask2 & BIO_WAM_FIRETYPE) &&
				FireType2 == curFT;
		}
	}

	bool FireTypeMutableTo(Class<Actor> newFT, bool secondary = false) const
	{
		if (bMeleeWeapon) return false;

		if (!secondary)
		{
			return
				FireTypeIsDefault(false) &&
				!(AffixMask1 & BIO_WAM_FIRETYPE) &&
				FireType1 != newFT;
		}
		else
		{
			return
				FireTypeIsDefault(true) &&
				!(AffixMask2 & BIO_WAM_FIRETYPE) &&
				FireType2 != newFT;
		}
	}

	bool FireTypeIsDefault(bool secondary = false) const
	{
		if (!secondary)
			return FireType1 == Default.FireType1;
		else
			return FireType2 == Default.FireType2;
	}

	bool FiresTrueProjectile(bool secondary = false) const
	{
		if (!secondary)
			return FireType1 is 'BIO_Projectile';
		else
			return FireType2 is 'BIO_Projectile';
	}

	// Only accounts for the `SplashDamage` field of the fired actor (if it's present).
	bool Splashes(bool secondary = false) const
	{
		if (!secondary)
		{
			if (FireType1 is 'BIO_Projectile')
			{
				let defs = GetDefaultByType((Class<BIO_Projectile>)(FireType1));
				return defs.SplashDamage > 0;
			}
			else if (FireType1 is 'BIO_FastProjectile')
			{
				let defs = GetDefaultByType((Class<BIO_FastProjectile>)(FireType1));
				return defs.SplashDamage > 0;
			}
			else return false; // Impossible to tell for certain
		}
		else
		{
			if (FireType2 is 'BIO_Projectile')
			{
				let defs = GetDefaultByType((Class<BIO_Projectile>)(FireType2));
				return defs.SplashDamage > 0;
			}
			else if (FireType2 is 'BIO_FastProjectile')
			{
				let defs = GetDefaultByType((Class<BIO_FastProjectile>)(FireType2));
				return defs.SplashDamage > 0;
			}
			else return false; // Impossible to tell for certain
		}
	}

	// No fire state can have a tic time below 1. Fire rate-affecting affixes need
	// to know in advance if they can even have any effect, given this caveat.
	int ReducibleFireTime() const
	{
		int ret = 0;
		Array<int> fireTimes;
		GetFireTimes(fireTimes);
		
		for (uint i = 0; i < fireTimes.Size(); i++)
			ret += Max(fireTimes[i] - 1, 0);

		return ret;
	}

	// See the above.
	int ReducibleReloadTime() const
	{
		int ret = 0;
		Array<int> reloadTimes;
		GetReloadTimes(reloadTimes);

		for (uint i = 0; i < reloadTimes.Size(); i++)
			ret += Max(reloadTimes[i] - 1, 0);

		return ret;
	}

	bool AfxMask_AllDamage() const
	{
		return
			((AffixMask1 & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE) &&
			((AffixMask2 & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE);
	}

	// Setters =================================================================

	override bool DepleteAmmo(bool altFire, bool checkEnough, int ammoUse)
	{
		if (sv_infiniteammo || (Owner.FindInventory('PowerInfiniteAmmo', true) != null))
			return false;

		if (checkEnough && !CheckAmmo(altFire ? AltFire : PrimaryFire, false, false, ammoUse))
			return false;

		if (!altFire)
		{
			if (Magazine1 != null)
			{
				if (ammoUse >= 0)
					Magazine1.Amount -= ammoUse;
				else
					Magazine1.Amount -= AmmoUse1;
			}

			if (bPRIMARY_USES_BOTH && Magazine2 != null)
				Magazine2.Amount -= AmmoUse2;
		}
		else
		{
			if (Magazine2 != null)
				Magazine2.Amount -= AmmoUse2;
			if (bALT_USES_BOTH && Magazine1 != null)
				Magazine1.Amount -= AmmoUse1;
		}

		if (Magazine1 != null && Magazine1.Amount < 0)
			Magazine1.Amount = 0;

		if (Magazine2 != null && Magazine2.Amount < 0)
			Magazine2.Amount = 0;
		
		return true;
	}

	// This function's base form does not affect any affixes
	// or the dictionary, and neither should any overrides.
	virtual void ResetStats()
	{
		Kickback = Default.Kickback;

		BIOFlags = Default.BIOFlags;
		AffixMask1 = Default.AffixMask1;
		AffixMask2 = Default.AffixMask2;
		MiscAffixMask = Default.MiscAffixMask;

		FireType1 = Default.FireType1;
		FireType2 = Default.FireType2;
		FireCount1 = Default.FireCount1;
		FireCount2 = Default.FireCount2;

		MinDamage1 = Default.MinDamage1;
		MinDamage2 = Default.MinDamage2;
		MaxDamage1 = Default.MaxDamage1;
		MaxDamage2 = Default.MaxDamage2;

		HSpread1 = Default.HSpread1;
		HSpread2 = Default.HSpread2;
		VSpread1 = Default.VSpread1;
		VSpread2 = Default.VSpread2;

		RaiseSpeed = Default.RaiseSpeed;
		LowerSpeed = Default.LowerSpeed;

		MagazineSize1 = Default.MagazineSize1;
		MagazineSize2 = Default.MagazineSize2;
		MinAmmoReserve1 = Default.MinAmmoReserve1;
		MinAmmoReserve2 = Default.MinAmmoReserve2;
		ReloadFactor1 = Default.ReloadFactor1;
		ReloadFactor2 = Default.ReloadFactor2;

		ProjTravelFunctors.Clear();
		ProjDamageFunctors.Clear();
		ProjDeathFunctors.Clear();
	}

	void ApplyImplicitAffixes()
	{
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].Apply(self);

		RewriteAffixReadout();
		RewriteStatReadout();
	}

	void ApplyAllAffixes()
	{
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].Apply(self);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].Apply(self);

		RewriteAffixReadout();
		RewriteStatReadout();
	}

	// Does not alter stats, and does not apply the newly-added affixes.
	// Returns `false` if there are no compatible affixes to add.
	bool AddRandomAffix()
	{
		Array<BIO_WeaponAffix> eligibles;

		if (!BIO_GlobalData.Get().AllEligibleWeaponAffixes(eligibles, self))
			return false;

		if (Rarity == BIO_RARITY_COMMON)
		{
			Rarity = BIO_RARITY_MUTATED;
			SetTag(Default.GetTag());
			SetTag(GetColoredTag());
		}

		uint e = Affixes.Push(eligibles[Random(0, eligibles.Size() - 1)]);
		Affixes[e].Init(self);
		return true;
	}

	// Affects explicits only.
	void RandomizeAffixes()
	{
		ResetStats();
		Affixes.Clear();
		ApplyImplicitAffixes();

		uint c = Random(2, MAX_AFFIXES);

		for (uint i = 0; i < c; i++)
		{
			if (AddRandomAffix())
				Affixes[Affixes.Size() - 1].Apply(self);
		}

		RewriteAffixReadout();
		RewriteStatReadout();
	}

	void ClearAffixes(bool implicitsToo = false)
	{
		if (implicitsToo) ImplicitAffixes.Clear();
		Affixes.Clear();
		
		Rarity = BIO_RARITY_COMMON;
		SetTag(Default.GetTag());
		SetTag(GetColoredTag());

		RewriteAffixReadout();
		RewriteStatReadout();
	}

	void ModifyFireTime(int modifier)
	{
		if (modifier == 0)
		{
			Console.Printf(
				"Illegal fire time modifier of 0 given to %s.",
				GetClassName());
			return;
		}

		Array<int> fireTimes;
		GetFireTimes(fireTimes);

		if (fireTimes.Size() < 1)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"%s attempted to illegally modify fire times.",
				GetClassName());
		}

		uint e = Abs(modifier);
		for (uint i = 0; i < e; i++)
		{
			uint idx = 0, minOrMax = 0;

			if (modifier > 0)
				[idx, minOrMax] = BIO_Utils.IntArrayMin(fireTimes);
			else
				[idx, minOrMax] = BIO_Utils.IntArrayMax(fireTimes);

			fireTimes[idx] = modifier > 0 ? fireTimes[idx] + 1 : fireTimes[idx] - 1;
		}

		SetFireTimes(fireTimes);
	}

	void ModifyReloadTime(int modifier)
	{
		if (modifier == 0)
		{
			Console.Printf(
				"Illegal reload time modifier of 0 given to %s.",
				GetClassName());
			return;
		}

		Array<int> reloadTimes;
		GetReloadTimes(reloadTimes);

		if (reloadTimes.Size() < 1)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"%s attempted to illegally modify reload times.",
				GetClassName());
		}

		uint e = Abs(modifier);
		for (uint i = 0; i < e; i++)
		{
			uint idx = 0, minOrMax = 0;

			if (modifier > 0)
				[idx, minOrMax] = BIO_Utils.IntArrayMin(reloadTimes);
			else
				[idx, minOrMax] = BIO_Utils.IntArrayMax(reloadTimes);

			reloadTimes[idx] = modifier > 0 ? reloadTimes[idx] + 1 : reloadTimes[idx] - 1;
		}

		SetReloadTimes(reloadTimes);
	}

	// Actions =================================================================

	action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }

	action bool A_BIO_Fire(int fireFactor = 1, float spreadFactor = 1.0,
		float angle = 0.0, float pitch = 0.0)
	{
		if (!invoker.DepleteAmmo(invoker.bAltFire, true, invoker.AmmoUse1 * fireFactor))
			return false;
		
		for (int i = 0; i < (invoker.FireCount1 * fireFactor); i++)
		{
			Actor proj = A_FireProjectile(invoker.FireType1,
				angle: angle + FRandom(-invoker.HSpread1, invoker.HSpread1) * spreadFactor,
				useAmmo: false,
				pitch: pitch + FRandom(-invoker.VSpread1, invoker.VSpread1) * spreadFactor);
			
			if (proj == null) continue;
			invoker.OnProjectileFired(proj);
		}

		A_BIO_AlertMonsters();
		return true;
	}

	action bool A_BIO_FireSecondary(int fireFactor = 1, float spreadFactor = 1.0,
		float angle = 0.0, float pitch = 0.0)
	{
		if (!invoker.DepleteAmmo(invoker.bAltFire, true, invoker.AmmoUse2 * fireFactor))
			return false;
		
		for (int i = 0; i < (invoker.FireCount2 * fireFactor); i++)
		{
			Actor proj = A_FireProjectile(invoker.FireType2,
				angle: angle + FRandom(-invoker.HSpread2, invoker.HSpread2) * spreadFactor,
				useAmmo: false,
				pitch: pitch + FRandom(-invoker.VSpread2, invoker.VSpread2) * spreadFactor);
			
			if (proj == null) continue;
			int dmg = Random(invoker.MinDamage2, invoker.MaxDamage2);

			for (uint i = 0; i < invoker.ImplicitAffixes.Size(); i++)
				invoker.ImplicitAffixes[i].ModifyDamage(invoker, dmg);
			for (uint i = 0; i < invoker.Affixes.Size(); i++)
				invoker.Affixes[i].ModifyDamage(invoker, dmg);

			proj.SetDamage(dmg);
			invoker.OnProjectileFired(proj);
		}

		A_BIO_AlertMonsters();
		return true;
	}

	protected action state A_AutoReload(bool secondary = false,	
		bool single = false, int min = -1)
	{
		if (!invoker.MagazineEmpty(secondary))
			return state(null);
		
		if (min == -1) min = 1;
		
		if ((!secondary ? invoker.Magazine1 : invoker.Magazine2).Amount >= min)
			return state(null);
		
		let cv = BIO_CVar.AutoReload(Player);

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && single))
			return ResolveState('Reload');
		else
			return ResolveState('Ready');
	}

	// If no argument is given, try to reload as much of the magazine as possible.
	// Otherwise, try to reload the given amount of rounds.
	action void A_LoadMag(uint amt = 0, bool secondary = false)
	{
		let magAmmo = !secondary ? invoker.Magazine1 : invoker.Magazine2;
		let reserveAmmo = invoker.Owner.FindInventory(
			!secondary ? invoker.AmmoType1 : invoker.AmmoType2);
		let factor = !secondary ? invoker.ReloadFactor1 : invoker.ReloadFactor2;
		int magSize = !secondary ? invoker.MagazineSize1 : invoker.MagazineSize2;
		int reserve = reserveAmmo.Amount / factor;

		let diff = Min(reserve, amt > 0 ? amt : magSize - magAmmo.Amount);
		magAmmo.Amount += diff;

		int subtract = diff * factor;
		reserveAmmo.Amount -= subtract;
	}

	action void A_EmptyMagazine(bool secondary = false)
	{
		let magAmmo = !secondary ? invoker.Magazine1 : invoker.Magazine2;
		let reserveAmmo = invoker.Owner.FindInventory(
			!secondary ? invoker.AmmoType1 : invoker.AmmoType2);
		let factor = !secondary ? invoker.ReloadFactor1 : invoker.ReloadFactor2;
		// reserveAmmo.MaxAmount intentionally not factored into this
		reserveAmmo.Amount += magAmmo.Amount * factor;
		magAmmo.Amount -= magAmmo.Amount;
	}

	protected action void A_BIO_AlertMonsters()
	{
		double maxDist = 0;
		int flags = 0;

		for (uint i = 0; i < invoker.ImplicitAffixes.Size(); i++)
			invoker.ImplicitAffixes[i].PreAlertMonsters(invoker, maxDist, flags);

		for (uint i = 0; i < invoker.Affixes.Size(); i++)
			invoker.Affixes[i].PreAlertMonsters(invoker, maxDist, flags);

		A_AlertMonsters(maxDist, flags);
	}

	protected action void A_Kickback(float xVelMult, float zVelMult)
	{
		// Don't apply any if the wielding player isn't on the ground
		if (invoker.Owner.Pos.Z > invoker.Owner.FloorZ) return;

		A_ChangeVelocity(
			Cos(invoker.Pitch) * -xVelMult, 0.0,
			Sin(invoker.Pitch) * zVelMult, CVF_RELATIVE);
	}

	protected action void A_LightRecoil()
	{
		A_Recoil(0.1);
		A_SetPitch(Pitch - 0.65);
		A_Quake(1, 1, 0, 10);
	}

	protected action void A_MediumRecoil()
	{
		A_Recoil(0.15);
		A_SetPitch(Pitch - 1.5);	
		A_Quake(2, 2, 0, 20);
	}

	protected action void A_HeavyRecoil()
	{
		A_Recoil(0.4);
		A_SetPitch(Pitch - 3.0);	
		A_Quake(3, 3, 0, 20);
	}

	// Call from the weapon's Spawn state, after two frames of the weapon's 
	// pickup sprite (each 0 tics long). Puts the weapon into a new loop with
	// appropriate behaviour for its rarity (e.g., blinking cyan if mutated).
	protected action state A_BIO_Spawn()
	{
		if (invoker.Rarity == BIO_RARITY_UNIQUE)
			return ResolveState('Spawn.Unique');
		else if (invoker.Affixes.Size() > 0)
			return ResolveState('Spawn.Mutated');
		else
			return ResolveState('Spawn.Common');
	}

	// Call from the weapon's Deselect state, during one frame of the weapon's
	// ready sprite (0 tics long). Runs a callback and puts the weapon in a 
	// lowering loop.
	protected action state A_BIO_Deselect()
	{
		invoker.OnDeselect();
		return ResolveState('Deselect.Loop');
	}

	// Call from the weapon's Select state, during one frame of the weapon's
	// ready sprite (0 tics long). Runs a callback and puts the weapon in a 
	// raising loop.
	protected action state A_BIO_Select()
	{
		invoker.OnSelect();
		return ResolveState('Select.Loop');
	}

	protected action void A_GroundHit()
	{
		if (Abs(Vel.Z) <= 0.01 && !invoker.HitGround)
		{
			A_StartSound("weapons/gundrop0");
			A_ScaleVelocity(0.5);
			bSpecial = true;
			bThruActors = false;
			invoker.HitGround = true;
		}
	}

	// Utility functions =======================================================

	private void OnProjectileFired(Actor proj)
	{
		int dmg = Random(MinDamage1, MaxDamage1);

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ModifyDamage(self, dmg);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].ModifyDamage(self, dmg);

		if (proj is 'BIO_Projectile')
		{
			let tProj = BIO_Projectile(proj);
			tProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
			tProj.ProjTravelFunctors.Copy(ProjTravelFunctors);
			tProj.ProjDeathFunctors.Copy(ProjDeathFunctors);
			OnTrueProjectileFired(tProj);

			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			{
				ImplicitAffixes[i].ModifySplash(self,
					tProj.SplashDamage, tProj.SplashRadius, dmg);
				ImplicitAffixes[i].OnTrueProjectileFired(self, tProj);
			}

			for (uint i = 0; i < Affixes.Size(); i++)
			{
				Affixes[i].ModifySplash(self,
					tProj.SplashDamage, tProj.SplashRadius, dmg);
				Affixes[i].OnTrueProjectileFired(self, tProj);
			}
		}
		else if (proj is 'BIO_FastProjectile')
		{
			let fProj = BIO_FastProjectile(proj);
			OnFastProjectileFired(fProj);
			fProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
			fProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			{
				ImplicitAffixes[i].ModifySplash(self,
					fProj.SplashDamage, fProj.SplashRadius, dmg);
				ImplicitAffixes[i].OnFastProjectileFired(self, fProj);
			}

			for (uint i = 0; i < Affixes.Size(); i++)
			{
				Affixes[i].ModifySplash(self,
					fProj.SplashDamage, fProj.SplashRadius, dmg);
				Affixes[i].OnFastProjectileFired(self, fProj);
			}
		}

		proj.SetDamage(dmg);
	}

	void RewriteStatReadout()
	{
		StatReadout.Clear();
		StatsToString(StatReadout);
	}

	void RewriteAffixReadout()
	{
		AffixReadout.Clear();

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ToString(AffixReadout, self);

		// Blank line between implicit and explicit affixes
		if (ImplicitAffixes.Size() > 0)
			AffixReadout.Push("");

		if (BIOFlags & BIO_WF_AFFIXESHIDDEN)
			AffixReadout.Push("\cg" .. StringTable.Localize("$BIO_AFFIXESUNKNOWN"));
		else
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].ToString(AffixReadout, self);
		}
	}

	// The following 3 functions serve to color stats differently if those stats
	// have been modified from their defaults by an affix.

	protected string FireTypeFontColor(bool secondary = false) const
	{
		if (!secondary)
			return FireType1 != Default.FireType1 ?
				CRESC_STATMODIFIED : CRESC_STATDEFAULT;
		else
			return FireType2 != Default.FireType2 ?
				CRESC_STATMODIFIED : CRESC_STATDEFAULT;
	}

	protected string FireCountFontColor(bool secondary = false) const
	{
		if (!secondary)
		{
			if (FireCount1 > Default.FireCount1)
				return CRESC_STATBETTER;
			else if (FireCount1 < Default.FireCount1)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (FireCount2 > Default.FireCount2)
				return CRESC_STATBETTER;
			else if (FireCount2 < Default.FireCount2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
	}

	protected string MinDamageFontColor(bool secondary = false) const
	{
		if (!secondary)
		{
			if (MinDamage1 > Default.MinDamage1)
				return CRESC_STATBETTER;
			else if (MinDamage1 < Default.MinDamage1)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (MinDamage2 > Default.MinDamage2)
				return CRESC_STATBETTER;
			else if (MinDamage2 < Default.MinDamage2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
	}

	protected string MaxDamageFontColor(bool secondary = false) const
	{
		if (!secondary)
		{
			if (MaxDamage1 > Default.MaxDamage1)
				return CRESC_STATBETTER;
			else if (MaxDamage1 < Default.MaxDamage1)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (MaxDamage2 > Default.MaxDamage2)
				return CRESC_STATBETTER;
			else if (MaxDamage2 < Default.MaxDamage2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
	}

	protected string HorizSpreadFontColor(bool secondary = false) const
	{
		if (!secondary)
		{
			if (HSpread1 > Default.HSpread1)
				return CRESC_STATWORSE;
			else if (HSpread1 < Default.HSpread1)
				return CRESC_STATBETTER;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (HSpread2 > Default.HSpread2)
				return CRESC_STATWORSE;
			else if (HSpread2 < Default.HSpread2)
				return CRESC_STATBETTER;
			else
				return CRESC_STATDEFAULT;
		}
	}

	protected string VertSpreadFontColor(bool secondary = false) const
	{
		if (!secondary)
		{
			if (VSpread1 > Default.VSpread1)
				return CRESC_STATWORSE;
			else if (VSpread1 < Default.VSpread1)
				return CRESC_STATBETTER;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (VSpread2 > Default.VSpread2)
				return CRESC_STATWORSE;
			else if (VSpread2 < Default.VSpread2)
				return CRESC_STATBETTER;
			else
				return CRESC_STATDEFAULT;
		}
	}

	protected string GenericFireDataReadout(bool secondary = false,
		string fireTypeTag = "") const
	{
		string tag = "";

		if (!secondary)
		{
			if (fireTypeTag.Length() < 1)
				tag = GetFireTypeTag(false);
			else
				tag = StringTable.Localize(fireTypeTag);

			return String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
				MinDamageFontColor(false), MinDamage1,
				MaxDamageFontColor(false), MaxDamage1,
				FireCountFontColor(false),
				FireCount1 == -1 ? 1 : FireCount1,
				FireTypeFontColor(false), tag);
		}
		else
		{
			if (fireTypeTag.Length() < 1)
				tag = GetFireTypeTag(true);
			else
				tag = StringTable.Localize(fireTypeTag);

			return String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
				MinDamageFontColor(false), MinDamage2,
				MaxDamageFontColor(false), MaxDamage2,
				FireCountFontColor(true),
				FireCount2 == -1 ? 1 : FireCount2,
				FireTypeFontColor(true), tag);
		}
	}

	protected string GenericSpreadReadout(bool secondary = false) const
	{
		if (!secondary)
		{
			return String.Format(StringTable.Localize("$BIO_WEAPSTAT_SPREAD"),
				HorizSpreadFontColor(false), HSpread1,
				VertSpreadFontColor(false), VSpread1);
		}
		else
		{
			return String.Format(StringTable.Localize("$BIO_WEAPSTAT_SPREAD"),
				HorizSpreadFontColor(true), HSpread2,
				VertSpreadFontColor(true), VSpread2);
		}
	}

	protected string GenericFireTimeReadout(int totalFireTime,
		string template = "$BIO_WEAPSTAT_FIRETIME",
		int defaultArg = -1) const
	{
		string crEsc = "";
		int defFT = defaultArg == -1 ? Default.TrueFireTime() : defaultArg;

		if (totalFireTime > defFT)
			crEsc = CRESC_STATWORSE;
		else if (totalFireTime < defFT)
			crEsc = CRESC_STATBETTER;
		else
			crEsc = CRESC_STATDEFAULT;

		return String.Format(StringTable.Localize(template),
			crEsc, float(totalFireTime) / 35.0);
	}

	protected string GenericReloadTimeReadout(int totalReloadTime) const
	{
		string crEsc = "";
		int defRT = Default.TrueReloadTime();

		if (totalReloadTime > defRT)
			crEsc = CRESC_STATWORSE;
		else if (totalReloadTime < defRT)
			crEsc = CRESC_STATBETTER;
		else
			crEsc = CRESC_STATDEFAULT;

		return String.Format(StringTable.Localize("$BIO_WEAPSTAT_RELOADTIME"),
			crEsc, float(totalReloadTime) / 35.0);
	}
}

mixin class BIO_MeleeWeapon
{
	float MeleeRange, LifeSteal;
	property MeleeRange: MeleeRange;
	property LifeSteal: LifeSteal;

	float CalcMeleeRange()
	{
		float ret = MeleeRange;
		
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ModifyMeleeRange(self, ret);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].ModifyMeleeRange(self, ret);

		return ret;
	}

	void ApplyLifeSteal(int dmg)
	{
		let fDmg = float(dmg);
		float lsp = LifeSteal;

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ModifyLifesteal(self, lsp);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].ModifyLifesteal(self, lsp);

		Owner.GiveBody(int(fDmg * Min(lsp, 1.0)), Owner.GetMaxHealth(true) + 100);
	}
}
