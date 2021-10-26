enum BIO_WeaponFlags : uint8
{
	BIO_WEAPF_NONE = 0,
	BIO_WEAPF_CORRUPTED = 1 << 0,
	BIO_WEAPF_AFFIXESHIDDEN = 1 << 1, // Caused by corruption
	// The following 3 are applicable only to dual-wielded weapons
	BIO_WEAPF_NOAUTOPRIMARY = 1 << 2,
	BIO_WEAPF_NOAUTOSECONDARY = 1 << 3,
	BIO_WEAPF_AKIMBORELOAD = 1 << 4
}

// Dictate what stats can be affected by affixes. If a bit is set,
// the affix should stop itself from altering that stat, or applying itself
// to a weapon which it can't even affect.
enum BIO_WeaponAffixMask : uint
{
	BIO_WAM_NONE = 0,
	// Fire data: bits
	BIO_WAM_FIRETYPE_1 = 1 << 0,
	BIO_WAM_FIRETYPE_2 = 1 << 1,
	BIO_WAM_FIRECOUNT_1 = 1 << 2,
	BIO_WAM_FIRECOUNT_2 = 1 << 3,
	// Fire data: combinations
	BIO_WAM_FIRETYPE = BIO_WAM_FIRETYPE_1 | BIO_WAM_FIRETYPE_2,
	BIO_WAM_FIRECOUNT = BIO_WAM_FIRECOUNT_1 | BIO_WAM_FIRECOUNT_2,
	BIO_WAM_FIREDATA_1 = BIO_WAM_FIRETYPE_1 | BIO_WAM_FIRECOUNT_1,
	BIO_WAM_FIREDATA_2 = BIO_WAM_FIRETYPE_2 | BIO_WAM_FIRECOUNT_2,
	BIO_WAM_FIREDATA = BIO_WAM_FIRETYPE | BIO_WAM_FIRECOUNT,
	// Damage: bits
	BIO_WAM_MINDAMAGE_1 = 1 << 4,
	BIO_WAM_MINDAMAGE_2 = 1 << 5,
	BIO_WAM_MAXDAMAGE_1 = 1 << 6,
	BIO_WAM_MAXDAMAGE_2 = 1 << 7,
	// Damage: combinations
	BIO_WAM_MINDAMAGE = BIO_WAM_MINDAMAGE_1 | BIO_WAM_MINDAMAGE_2,
	BIO_WAM_MAXDAMAGE = BIO_WAM_MAXDAMAGE_1 | BIO_WAM_MAXDAMAGE_2,
	BIO_WAM_DAMAGE_1 = BIO_WAM_MINDAMAGE_1 | BIO_WAM_MAXDAMAGE_1,
	BIO_WAM_DAMAGE_2 = BIO_WAM_MINDAMAGE_2 | BIO_WAM_MAXDAMAGE_2,
	BIO_WAM_DAMAGE = BIO_WAM_MINDAMAGE | BIO_WAM_MAXDAMAGE,
	// Spread: bits
	BIO_WAM_HSPREAD_1 = 1 << 8,
	BIO_WAM_HSPREAD_2 = 1 << 9,
	BIO_WAM_VSPREAD_1 = 1 << 10,
	BIO_WAM_VSPREAD_2 = 1 << 11,
	// Spread: combinations
	BIO_WAM_HSPREAD = BIO_WAM_HSPREAD_1 | BIO_WAM_HSPREAD_2,
	BIO_WAM_VSPREAD = BIO_WAM_VSPREAD_1 | BIO_WAM_VSPREAD_2,
	BIO_WAM_SPREAD_1 = BIO_WAM_HSPREAD_1 | BIO_WAM_VSPREAD_1,
	BIO_WAM_SPREAD_2 = BIO_WAM_HSPREAD_2 | BIO_WAM_VSPREAD_2,
	BIO_WAM_SPREAD = BIO_WAM_HSPREAD | BIO_WAM_VSPREAD,
	// Magazine
	BIO_WAM_MAGSIZE_1 = 1 << 12,
	BIO_WAM_MAGSIZE_2 = 1 << 13,
	BIO_WAM_MAGSIZE = BIO_WAM_MAGSIZE_1 | BIO_WAM_MAGSIZE_2,
	// Switch speeds
	BIO_WAM_RAISESPEED = 1 << 14,
	BIO_WAM_LOWERSPEED = 1 << 15,
	BIO_WAM_SWITCHSPEED = BIO_WAM_RAISESPEED | BIO_WAM_LOWERSPEED,
	// Fire and reload times
	BIO_WAM_FIRETIME = 1 << 16,
	BIO_WAM_RELOADTIME = 1 << 17,
	// Callbacks
	BIO_WAM_ONPROJFIRED_1 = 1 << 18,
	BIO_WAM_ONPROJFIRED_2 = 1 << 19,
	BIO_WAM_ONPROJFIRED_TRUE = 1 << 20,
	BIO_WAM_ONPROJFIRED_FAST = 1 << 21,
	BIO_WAM_ONPROJFIRED =
		BIO_WAM_ONPROJFIRED_1 | BIO_WAM_ONPROJFIRED_2 |
		BIO_WAM_ONPROJFIRED_TRUE | BIO_WAM_ONPROJFIRED_FAST,
	BIO_WAM_PREALERT = 1 << 22,
	// Melee-weapon only
	BIO_WAM_LIFESTEAL = 1 << 23,
	BIO_WAM_MELEERANGE = 1 << 24,
	// Completely lock off the primary or secondary side of the weapon
	BIO_WAM_PRIMARY =
		BIO_WAM_FIREDATA_1 | BIO_WAM_DAMAGE_1 |
		BIO_WAM_SPREAD_1 | BIO_WAM_MAGSIZE_1 | BIO_WAM_ONPROJFIRED_1,
	BIO_WAM_SECONDARY =
		BIO_WAM_FIREDATA_2 | BIO_WAM_DAMAGE_2 |
		BIO_WAM_SPREAD_2 | BIO_WAM_MAGSIZE_2 | BIO_WAM_ONPROJFIRED_2,
	BIO_WAM_ALL = uint.MAX
}

mixin class BIO_Magazine
{
	Default
	{
		+INVENTORY.IGNORESKILL
		Inventory.Icon "";
		Inventory.MaxAmount 32767;
	}
}

class BIO_Weapon : DoomWeapon abstract
{
	mixin BIO_Gear;

	const MAX_AFFIXES = 6;

	BIO_WeaponFlags BIOFlags; property Flags: BIOFlags;
	BIO_WeaponAffixMask AffixMask; property AffixMask: AffixMask;

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
		+DONTGIB
		+NOBLOCKMONST
		+WEAPON.ALT_AMMO_OPTIONAL
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT

		Height 8;
		Radius 16;

		Inventory.PickupMessage "";

		Weapon.BobRangeX 0.5;
        Weapon.BobRangeY 0.5;
        Weapon.BobSpeed 1.2;
        Weapon.BobStyle "Alpha";
		Weapon.Kickback 100;

		BIO_Weapon.AffixMask BIO_WAM_NONE;
		BIO_Weapon.DamageRanges -2, -2, -2, -2;
		BIO_Weapon.FireCounts 1, 1;
		BIO_Weapon.FireTypes "", "";
		BIO_Weapon.Flags BIO_WEAPF_NONE;
		BIO_Weapon.Grade BIO_GRADE_NONE;
		BIO_Weapon.MagazineSizes 0, 0;
		BIO_Weapon.MagazineTypes "", "";
		BIO_Weapon.MinAmmoReserves 1, 1;
		BIO_Weapon.Rarity BIO_RARITY_COMMON;
		BIO_Weapon.ReloadFactors 1, 1;
		BIO_Weapon.Spreads 0.0, 0.0, 0.0, 0.0;
		BIO_Weapon.SwitchSpeeds 6, 6;
	}

	States
	{
	Select:
		TNT1 A 0
		{
			invoker.OnSelect();
			return ResolveState("Select.Loop");
		}
	Deselect:
		TNT1 A 0
		{
			invoker.OnDeselect();
			return ResolveState("Deselect.Loop");
		}
	Spawn:
		TNT1 A 0;
		Stop;
	Spawn.Common:
		#### # -1;
		Stop;
	Spawn.Mutated:
		#### # 6 A_SetTranslation("");
		#### # 6 Bright A_SetTranslation("BIO_Mutated");
		Loop;
	Spawn.Unique:
		#### # 6 A_SetTranslation("");
		#### # 6 Bright A_SetTranslation("BIO_Unique");
		Loop;
	}

	// Parent overrides ========================================================

	override void BeginPlay()
	{
		super.BeginPlay();
		SetTag(GetColoredTag());
		RewriteAffixReadout();
		RewriteStatReadout();
	}

	override void AttachToOwner(Actor newOwner)
	{
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

	// Virtuals/abstracts ======================================================

	virtual void OnDeselect() {}
	virtual void OnSelect() {}

	// If the weapon carries special data that can't be known without knowing the
	// exact class type in advance (e.g. from a mixin), store it in `Dict`.
	virtual void UpdateDictionary() {}

	// Always gets called before affixes get their version of this invoked.
	virtual void OnTrueProjectileFired(BIO_Projectile proj) const {}
	virtual void OnFastProjectileFired(BIO_FastProjectile proj) const {}

	abstract void GetFireTimes(in out Array<int> fireTimes,
		bool secondary = false) const;
	protected abstract void SetFireTimes(Array<int> fireTimes,
		bool secondary = false);

	abstract void GetReloadTimes(in out Array<int> reloadTimes,
		bool secondary = false) const;
	protected abstract void SetReloadTimes(Array<int> reloadTimes,
		bool secondary = false);

	protected virtual int DefaultFireTime() const { return 0; }
	protected virtual int DefaultReloadTime() const { return 0; }

	// Getters =================================================================

	protected abstract void StatsToString(in out Array<string> stats) const;

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

	// Includes implicits.
	bool NoAffixes() const
	{
		return Affixes.Size() < 1 && ImplicitAffixes.Size() < 1;
	}

	bool PrimaryAffixMasked() const
	{
		return (AffixMask & BIO_WAM_PRIMARY) == BIO_WAM_PRIMARY;
	}

	bool SecondaryAffixMasked() const
	{
		return (AffixMask & BIO_WAM_SECONDARY) == BIO_WAM_SECONDARY;
	}

	bool AllDamageAffixMasked() const
	{
		return (AffixMask & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE;
	}

	bool PrimaryDamageAffixMasked() const
	{
		return (AffixMask & BIO_WAM_DAMAGE_1) == BIO_WAM_DAMAGE_1;
	}

	bool SecondaryDamageAffixMasked() const
	{
		return (AffixMask & BIO_WAM_DAMAGE_2) == BIO_WAM_DAMAGE_2;
	}

	bool DealsAnyDamage() const
	{
		return (MaxDamage1 + MaxDamage2) > 0;
	}

	bool FireTypeMutableFrom(Class<Actor> curFT, bool secondary = false) const
	{
		if (bMeleeWeapon) return false;

		if (!secondary)
		{
			return
				FireTypeIsDefault(false) &&
				!(AffixMask & BIO_WAM_FIRETYPE_1) &&
				FireType1 == curFT;
		}
		else
		{
			return
				FireTypeIsDefault(true) &&
				!(AffixMask & BIO_WAM_FIRETYPE_2) &&
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
				!(AffixMask & BIO_WAM_FIRETYPE_1) &&
				FireType1 != newFT;
		}
		else
		{
			return
				FireTypeIsDefault(true) &&
				!(AffixMask & BIO_WAM_FIRETYPE_2) &&
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
			return FireType1 is "BIO_Projectile";
		else
			return FireType2 is "BIO_Projectile";
	}

	bool SpreadAffixMasked() const
	{
		return (AffixMask & BIO_WAM_SPREAD) == BIO_WAM_SPREAD;
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

	// Does not affect affixes in any way.
	virtual void ResetStats()
	{
		BIOFlags = Default.BIOFlags;
		AffixMask = Default.AffixMask;

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

	action bool A_BIO_Fire(bool secondary = false, int factor = 1,
		float spreadFactor = 1.0)
	{
		Class<Actor> fireType = !secondary ? invoker.FireType1 : invoker.FireType2;
		
		int fireCount = !secondary ? invoker.FireCount1 : invoker.FireCount2;
		fireCount *= factor;

		float
			hSpread = !secondary ? invoker.HSpread1 : invoker.HSpread2,
			vSpread = !secondary ? invoker.VSpread1 : invoker.VSpread2;

		int minDmg = !secondary ? invoker.MinDamage1 : invoker.MinDamage2,
			maxDmg = !secondary ? invoker.MaxDamage1 : invoker.MaxDamage2;

		int ammoUse = !secondary ? invoker.AmmoUse1 : invoker.AmmoUse2;
		ammoUse *= factor;

		if (!invoker.DepleteAmmo(invoker.bAltFire, true, ammoUse))
			return false;
		
		for (int i = 0; i < fireCount; i++)
		{
			Actor proj = A_FireProjectile(fireType,
				angle: FRandom(-hSpread, hSpread) * spreadFactor,
				useAmmo: false,
				pitch: FRandom(-vSpread, vSpread) * spreadFactor);
			
			if (proj == null) continue;
			proj.SetDamage(Random(minDmg, maxDmg));
			invoker.OnProjectileFired(proj);
		}

		A_BIO_AlertMonsters();
		return true;
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

	protected action state A_BIO_Spawn()
	{
		if (invoker.Rarity == BIO_RARITY_UNIQUE)
			return ResolveState("Spawn.Unique");
		else if (invoker.Affixes.Size() > 0)
			return ResolveState("Spawn.Mutated");
		else
			return ResolveState("Spawn.Common");
	}

	// Utility functions =======================================================

	private void OnProjectileFired(Actor proj)
	{
		if (proj is "BIO_Projectile")
		{
			let tProj = BIO_Projectile(proj);
			OnTrueProjectileFired(tProj);

			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			{
				ImplicitAffixes[i].ModifySplash(self, tProj.SplashDamage, tProj.SplashRadius);
				ImplicitAffixes[i].OnTrueProjectileFired(self, tProj);
			}

			for (uint i = 0; i < Affixes.Size(); i++)
			{
				Affixes[i].ModifySplash(self, tProj.SplashDamage, tProj.SplashRadius);
				Affixes[i].OnTrueProjectileFired(self, tProj);
			}
		}
		else if (proj is "BIO_FastProjectile")
		{
			let fProj = BIO_FastProjectile(proj);
			OnFastProjectileFired(fProj);

			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			{
				ImplicitAffixes[i].ModifySplash(self, fProj.SplashDamage, fProj.SplashRadius);
				ImplicitAffixes[i].OnFastProjectileFired(self, fProj);
			}

			for (uint i = 0; i < Affixes.Size(); i++)
			{
				Affixes[i].ModifySplash(self, fProj.SplashDamage, fProj.SplashRadius);
				Affixes[i].OnFastProjectileFired(self, fProj);
			}
		}
	}

	private void RewriteStatReadout()
	{
		StatReadout.Clear();
		StatsToString(StatReadout);
	}

	private void RewriteAffixReadout()
	{
		AffixReadout.Clear();

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ToString(AffixReadout, self);

		// Blank line between implicit and explicit affixes
		if (ImplicitAffixes.Size() > 0)
			AffixReadout.Push("");

		if (BIOFlags & BIO_WEAPF_AFFIXESHIDDEN)
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
				tag = GetDefaultByType(FireType1).GetTag();
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
				tag = GetDefaultByType(FireType2).GetTag();
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

	protected string GenericFireTimeReadout(int totalFireTime) const
	{
		string crEsc = "";
		int defFT = DefaultFireTime();

		if (totalFireTime > defFT)
			crEsc = CRESC_STATWORSE;
		else if (totalFireTime < defFT)
			crEsc = CRESC_STATBETTER;
		else
			crEsc = CRESC_STATDEFAULT;

		return String.Format(
			StringTable.Localize("$BIO_WEAPSTAT_FIRETIME"),
			crEsc, float(totalFireTime) / 35.0);
	}

	// Analogous to GenericFireTimeReadout, but for melee weapons.
	protected string GenericAttackTimeReadout(int totalFireTime) const
	{
		string crEsc = "";
		int defFT = DefaultFireTime();

		if (totalFireTime > defFT)
			crEsc = CRESC_STATWORSE;
		else if (totalFireTime < defFT)
			crEsc = CRESC_STATBETTER;
		else
			crEsc = CRESC_STATDEFAULT;

		return String.Format(
			StringTable.Localize("$BIO_WEAPSTAT_ATKTIME"),
			crEsc, float(totalFireTime) / 35.0);
	}

	protected string GenericReloadTimeReadout(int totalReloadTime) const
	{
		string crEsc = "";
		int defRT = DefaultReloadTime();

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

/*  Adapted from the Easy Dual Wield library by Jekyll Grim Payne.
	Used under the MIT License (/zscript/LICENSE.edw).
	https://github.com/jekyllgrim/Easy-Dual-Wield
*/
class BIO_DualWieldWeapon : BIO_Weapon abstract
{
	// Aliases for gun overlays.
	enum FireLayers
	{
		PSP_RIGHTGUN = 5,
		PSP_LEFTGUN = 6,
		PSP_RIGHTFLASH = 100,
		PSP_LEFTFLASH = 101
	}

	enum SoundChannels
	{
		CHAN_RIGHTGUN	= 12,
		CHAN_LEFTGUN = 13
	}

	protected state s_Ready,
		s_ReadyRight, s_ReadyLeft,
		s_FireRight, s_FireLeft,
		s_HoldRight, s_HoldLeft,
		s_FlashRight, s_FlashLeft,
		s_ReloadRight, s_ReloadLeft,
		s_ReloadWaitRight, s_ReloadWaitLeft;

	protected bool ContinueReload;

	States
	{
	// Normally Ready can be left as is in weapons based on this one
	Ready:
		TNT1 A 1 A_DualWeaponReady();
		Loop;
	// Fire state is required for the weapon to function but isn't used directly.
	// Do not redefine.
	Fire:
		TNT1 A 1
		{
			return ResolveState("Ready");
		}
	// AltFire state is required for the weapon to function but isn't used directly.
	// Do not redefine.
	AltFire:
		TNT1 A 1
		{
			return ResolveState("Ready");
		}
	// Normally Select can be left as is in weapons based on this one.
	// Redefine only if you want to significantly change selection animation
	Select:
		TNT1 A 0
		{
			A_Overlay(PSP_RIGHTGUN, "Select.Right");
			A_Overlay(PSP_LEFTGUN, "Select.Left");
		}
		TNT1 A 1 A_Raise(invoker.RaiseSpeed);
		Wait;
	// Normally Deselect can be left as is in weapons based on this one.
	// Redefine if you want to significantly change deselection animation
	Deselect:
		TNT1 A 0
		{
			A_Overlay(PSP_RIGHTGUN, "Deselect.Right");
			A_Overlay(PSP_LEFTGUN, "Deselect.Left");
		}
		TNT1 A 1 A_Lower(invoker.LowerSpeed);
		Wait;
	}

	// Setup state pointers.
	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		s_Ready = FindState("Ready");
		s_ReadyRight = FindState("Ready.Right");
		s_ReadyLeft = FindState("Ready.Left");
		s_FireRight = FindState("Fire.Right");
		s_FireLeft = FindState("Fire.Left");
		s_HoldRight = FindState("Hold.Right");
		s_HoldLeft = FindState("Hold.Left");
		s_FlashRight = FindState("Flash.Right");
		s_FlashLeft = FindState("Flash.Left");
		s_ReloadRight = FindState("Reload.Right");
		s_ReloadLeft = FindState("Reload.Left");
		s_ReloadWaitRight = FindState("ReloadWait.Right");
		s_ReloadWaitLeft = FindState("ReloadWait.Left");
	}

	// Returns true if ammo should be infinite.
	action bool A_EDW_CheckInfiniteAmmo()
	{
		return (sv_infiniteammo || FindInventory("PowerInfiniteAmmo",true) );
	}
	
	/*	This is meant to be called instead of A_WeaponReady() in the main
		Ready state sequence (NOT in the left/right ready sequences).
		This doesn't actually make the weapon ready for firing directly, but 
		rather	makes sure everything is set up correctly and creates overlays
		if they haven't been created yet.
		It also initiates reloading.
	*/
	action void A_DualWeaponReady()
	{
		// Create gun overlays (once) if they're not drawn for some reason:
		A_Overlay(PSP_RIGHTGUN, "Ready.Right", nooverride:true);
		A_Overlay(PSP_LEFTGUN, "Ready.Left", nooverride:true);		
		
		bool readyRight = A_CheckReady_R();
		bool readyLeft = A_CheckReady_L();
		bool reloadReadyRight = A_CheckReadyForReload_R();
		bool reloadReadyLeft = A_CheckReadyForReload_L();
		
		// Disable "rage face" if neither weapon is firing:
		if (readyRight && readyLeft)
			Player.AttackDown = false;
		
		// Handle pressing Reload button
		if (Player.Cmd.Buttons & BT_RELOAD)
		{
			// Check if guns can be reloaded independently:
			if (invoker.BIOFlags & BIO_WEAPF_AKIMBORELOAD)
			{
				// Reload right gun
				if (reloadReadyRight) A_Reload_R();
				// At the same time reload left gun
				if (reloadReadyLeft) A_Reload_L();
			}

			// Otherwise both guns must be in their Ready states:
			else if (readyRight && readyLeft)
			{
				// Only reload right:
				if (reloadReadyRight)
					A_Reload_R();
				// Otherwise only reload left:
				else
					A_Reload_L();
			}
		}

		/*	If player isn't pressing Reload but this bool was set by the right gun,
			proceed to reload the left gun as well.
			This is done to reload both guns in succession without having to
			press the Reload button twice.
		*/
		else if (!invoker.BIOFlags & BIO_WEAPF_AKIMBORELOAD &&
			invoker.continueReload && reloadReadyLeft)
		{
			invoker.continueReload = false;
			A_Reload_L();
		}
		
		A_WeaponReady(WRF_NOFIRE); // Let the gun bob and be deselected
	}
	
	// Returns true if the gun is in its respective Ready state sequence
	action bool A_CheckReady_R(bool left = false)
	{
		let psp = left ? Player.FindPSprite(PSP_LEFTGUN) : Player.FindPSprite(PSP_RIGHTGUN);
		let checkstate = left ? invoker.s_Readyleft : invoker.s_ReadyRight;
		return (psp && InStateSequence(psp.CurState, checkstate));
	}

	// Left-weapon alias for A_CheckReady_L().
	action bool A_CheckReady_L()
	{
		return A_CheckReady_R(true);
	}
	
	/*  Returns true if:
		- The appropriate Reload sequence exists
		- Magazine isn't full
		- Reserve ammo isn't empty
	*/
	action bool A_CheckReadyForReload_R(bool left = false)
	{
		if (!left)
		{
			return invoker.s_reloadRight && A_CheckReady_R() &&
				invoker.Magazine1 != invoker.ammo1 &&
				(invoker.Magazine1.amount < invoker.Magazine1.maxamount) &&
				(invoker.ammo1.amount >= invoker.ammouse1);
		}
		else
		{
			return invoker.s_reloadLeft && A_CheckReady_L() &&
				invoker.Magazine2 != invoker.ammo2 &&
				(invoker.Magazine2.amount < invoker.Magazine2.maxamount) &&
				(invoker.ammo2.amount >= invoker.ammouse2);
		}
	}

	// Left-weapon alias for A_CheckReadyForReload_R().
	action bool A_CheckReadyForReload_L()
	{
		return A_CheckReadyForReload_R(true);
	}
	
	// Returns true if the gun has enough ammo to fire.
	action bool A_CheckAmmo_R(bool left = false)
	{
		let ammo2check = left ? invoker.Magazine2 : invoker.Magazine1;
		// Return true if the weapon doesn't define ammo (= doesn't need it)
		if (!ammo2check) return true;
		// Otherwise get the required amount
		int reqAmt = left ? invoker.AmmoUse2 : invoker.AmmoUse1;
		// Return true if infinite ammo is active or we have enough
		return A_EDW_CheckInfiniteAmmo() || ammo2check.Amount >= reqAmt;
	}
	
	// Left-weapon alias for A_CheckAmmo_R().
	action bool A_CheckAmmo_L()
	{
		return A_CheckAmmo_R(true);
	}
	
	/*  The actual raising is done via the regular A_Raise in the regular Select
		state sequence. All this function does is, it checks if the main layer
		is already in the Ready state, and if so, moves the calling layer from
		Select.Right/Select.Left to Ready.Right/Ready.Left.
	*/
	action void A_Raise_R(bool left = false)
	{
		if (!player)
			return;
		let psp = player.FindPSprite(PSP_WEAPON);
		if (!psp)
			return;
		let targetState = left ? invoker.s_readyLeft : invoker.s_readyRight;
		if (InStateSequence(psp.curstate,invoker.s_ready))
		{
			player.SetPsprite(OverlayID(),targetState);
		}
	}

	// Left-weapon alias for A_Raise_R().
	action void A_Raise_L()
	{
		A_Raise_R(true);
	}
	
	/*  Ready function for the right weapon. Will jump into the right Fire
		sequence or right Reload sequence based on buttons pressed and ammo available.
	*/
	action void A_WeaponReady_R()
	{
		if (!Player) return;
		// Enable bobbing:
		A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);
		state targetState = null;
		bool pressingFire = Player.Cmd.Buttons & BT_ATTACK;		
		if (pressingFire)
		{
			if (A_CheckAmmo_R())
			{
				targetState = invoker.s_fireRight;
				invoker.continueReload = false;
			}
			else if (invoker.MagazineType1 && invoker.Ammo1.amount > 0)
			{
				if (invoker.BIOFlags & BIO_WEAPF_AKIMBORELOAD || A_CheckReadyForReload_L())
				{
					A_Reload_R();
					return;
				}
			}			
		}

		// If we're going to fire/reload, disable bobbing:
		if (targetState) 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, false);
			Player.SetPSprite(OverlayID(),targetState);
		}
		// Otherwise re-enable bobbing:
		else 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);
		}
	}
	
	/*  Ready function for the left weapon. Will jump into the left Fire sequence or
		left Reload sequence based on buttons pressed and ammo available.
	*/
	action void A_WeaponReady_L()
	{
		if (!Player) return;			
		A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);

		state targetState = null;
		bool pressingFire = Player.Cmd.Buttons & BT_ALTATTACK;		
		if (pressingFire)
		{
			if (A_CheckAmmo_L())
			{
				targetState = invoker.s_FireLeft;
				invoker.continueReload = false;
			}
			else if (invoker.MagazineType2 && invoker.Ammo2.amount > 0)
			{
				if (invoker.BIOFlags & BIO_WEAPF_AKIMBORELOAD || A_CheckReadyForReload_R())
				{
					A_Reload_L();
					return;
				}					
			}			
		}	

		if (targetState) 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, false);
			Player.SetPsprite(OverlayID(), targetState);
		}
		else 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);
		}
	}
	
	/*  Right-gun analong of A_GunFlash. Does two things:
		- Draws Flash.Right/Flash.Left on PSP_RIGHTFLASH/PSP_LEFTFLASH layers
		- Makes sure the flash doesn't follow weapon bob and gets aligned
		with the gun layer the moment it's called (If you want to move the 
		flash around after that, you'll have to do it manually.)
	*/
	action void A_GunFlash_R(bool left = false)
	{
		if (!player)
			return;
		let psp = Player.FindPSprite(OverlayID());
		if (!psp)
			return;
		int layer = left ? PSP_LEFTFLASH : PSP_RIGHTFLASH;
		state flashstate = left ? invoker.s_flashLeft : invoker.s_flashRight;
		if (!flashstate)
			return;
		Player.SetPsprite(layer,flashstate);
		A_OverlayFlags(layer,PSPF_ADDBOB,false);
		A_OverlayOffset(layer,psp.x,psp.y);
		
	}

	// Left-weapon alias for A_GunFlash_R().
	action void A_GunFlash_L()
	{
		A_GunFlash_R(true);
	}
	
	/*  A_ReFire analog for the right gun. Increases player.Refire just like
		A_Refire(), and resets it to 0 as long as neither gun is refiring.
	*/
	action void A_ReFire_R(bool left = false)
	{
		// Double-check player and psp:
		if (!Player) return;
		
		let psp = Player.FindPSprite(OverlayID());
		if (!psp) return;
		
		let s_fire = left ? invoker.s_FireLeft : invoker.s_FireRight; // Pointer to Fire
		let s_hold = left ? invoker.s_HoldLeft : invoker.s_Holdright; // Pointer to Hold
		int atkbutton = left ? BT_ALTATTACK : BT_ATTACK; // Check attack button is being held
		state targetState = null;
		// Check if this is being called from Fire or Hold:
		if (s_fire && (InStateSequence(psp.CurState, s_fire) ||
			InStateSequence(psp.CurState, s_hold)))
		{
			//Check if we have enough ammo and the attack button is being held:
			if (A_CheckAmmo_R(left) &&
				Player.Cmd.Buttons & atkButton &&
				player.OldButtons & atkButton)
			{
				//if so, jump to Hold (if it exists) or to Fire
				targetState = s_hold ? s_hold : s_fire;
			}
		}

		// If target state was set, increase player.refire and set the state:
		if (targetState) 
		{
			player.refire++;
			player.SetPsprite(OverlayID(),targetState);
		}

		// If we're not refiring...
		else
		{
			// If the OTHER weapon is in its Ready sequence, reset player.Refire:
			if (A_CheckReady_R(left))
				player.Refire = 0;
		}
	}

	// Left-weapon alias for A_ReFire_R().
	action void A_ReFire_L()
	{
		A_ReFire_R(true);
	}
	
	/*	This jumps to the reload state provided magazine isn't full
		and reserve ammo isn't empty.
	*/
	action void A_Reload_R(bool left = false)
	{
		if (!A_CheckReadyForReload_R(left)) return;

		// If WMF_AKIMBORELOAD isn't set, set the other gun into ReloadWait state sequence:
		if (!invoker.BIOFlags & BIO_WEAPF_AKIMBORELOAD)
		{
			int otherGun = left ? PSP_RIGHTGUN : PSP_LEFTGUN;
			state waitState = left ? invoker.s_ReloadWaitRight : invoker.s_ReloadWaitLeft;
			
			if (waitState)
			{
				player.SetPSprite(otherGun,waitState);
				invoker.continueReload = true;
			}
		}

		// Set the current layer to the Reload state sequence:
		let targetState = left ? invoker.s_ReloadLeft : invoker.s_ReloadRight;
		int gunLayer = left ? PSP_LEFTGUN : PSP_RIGHTGUN;
		player.SetPSprite(gunLayer, targetState);
	}

	action void A_Reload_L()
	{
		A_Reload_R(true);
	}
	
	action void A_LoadMag_R(uint amt = 0)
	{
		A_LoadMag(amt, false);
	}

	action void A_LoadMag_L(uint amt = 0)
	{
		A_LoadMag(amt, true);
	}

	// Attacks =================================================================

	/*  To make sure the correct ammo is consumed for each attack,
		we need to manually set invoker.bAltFire to false to consume
		primary ammo, and to true to consume secondary ammo.
		I made a bunch of simple wrappers for the generic attack
		functions.
		If you need to use a custom attack function, you'll have to set
		bAltFire manually. A_SetFireMode below can be used for that.
	*/
	
	// Call this before custom attack functions to define which gun is firing
	action void A_SetFireMode(bool secondary = false) 
	{
		invoker.bAltFire = secondary;
	}
	
	/*
		These are very simple wrappers that set bAltFire to false for 
		right gun and true for left gun to make sure the correct ammo 
		is consumed.
	*/

	// Wraps A_FireBullets.
	action void A_FireBullets_R(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, Class<Actor> puff_t = "BulletPuff", int flags = 1,
		double range = 0, Class<Actor> missile = null, double spawnHeight = 32,
		double spawnOffs_xy = 0)
	{
		invoker.bAltFire = false;
		A_FireBullets(spread_xy, spread_z, numBullets, bulletDmg, puff_t, flags, range ,missile, spawnHeight, spawnOffs_xy);
	}	

	action void A_FireBullets_L(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, Class<Actor> puff_t = "BulletPuff", int flags = 1,
		double range = 0, Class<Actor> missile = null, double spawnHeight = 32,
		double spawnOffs_xy = 0)
	{
		invoker.bAltFire = true;
		A_FireBullets(spread_xy, spread_z, numBullets, bulletDmg, puff_t, flags, range ,missile, spawnHeight, spawnOffs_xy);
	}

	// Wraps A_FireProjectile.
	action Actor A_FireProjectile_R(Class<Actor> missiletype, double angle = 0,
		bool useAmmo = true, double spawnOffs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		invoker.bAltFire = false;
		return A_FireProjectile(missiletype, angle, useAmmo, spawnOffs_xy, spawnHeight, flags, pitch);
	}

	action Actor A_FireProjectile_L(Class<Actor> missiletype, double angle = 0,
		bool useAmmo = true, double spawnOffs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		invoker.bAltFire = true;
		return A_FireProjectile(missiletype, angle, useAmmo, spawnOffs_xy, spawnHeight, flags, pitch);
	}

	// Wraps A_CustomPunch.
	action void A_CustomPunch_R(int damage, bool noRandom = false,
		int flags = CPF_USEAMMO, Class<Actor> puff_t = "BulletPuff",
		double range = 0, double lifesteal = 0, int lifestealMax = 0,
		Class<BasicArmorBonus> armorBonus_t = "ArmorBonus", sound meleeSound = 0,
		sound MissSound = "")
	{
		invoker.bAltFire = false;
		A_CustomPunch(damage, noRandom, flags, puff_t, range, lifesteal, lifestealMax, armorBonus_t, meleeSound, MissSound);
	}

	action void A_CustomPunch_L(int damage, bool noRandom = false,
		int flags = CPF_USEAMMO, Class<Actor> puff_t = "BulletPuff",
		double range = 0, double lifesteal = 0, int lifestealMax = 0,
		Class<BasicArmorBonus> armorBonus_t = "ArmorBonus", sound meleeSound = 0,
		sound MissSound = "")
	{
		invoker.bAltFire = true;
		A_CustomPunch(damage, noRandom, flags, puff_t, range, lifesteal, lifestealMax, armorBonus_t, meleeSound, MissSound);
	}

	// Wraps A_RailAttack.
	action void A_RailAttack_R(int damage, int spawnOffs_xy = 0,
		bool useAmmo = true, Color color1 = 0, Color color2 = 0, int flags = 0,
		double maxDiff = 0, Class<Actor> puff_t = "BulletPuff",
		double spread_xy = 0, double spread_z = 0, double range = 0,
		int duration = 0, double sparsity = 1.0, double driftSpeed = 1.0,
		Class<Actor> spawn_t = "none", double spawnOffs_z = 0,
		int spiralOffs = 270, int limit = 0)
	{
		invoker.bAltFire = false;
		A_RailAttack(damage, spawnOffs_xy, useAmmo, color1, color2, flags, maxDiff,
			puff_t, spread_xy, spread_z, range, duration, sparsity, driftSpeed,
			spawn_t, spawnOffs_z, spiralOffs, limit);
	}

	action void A_RailAttack_L(int damage, int spawnOffs_xy = 0,
		bool useAmmo = true, Color color1 = 0, Color color2 = 0, int flags = 0,
		double maxDiff = 0, Class<Actor> puff_t = "BulletPuff",
		double spread_xy = 0, double spread_z = 0, double range = 0,
		int duration = 0, double sparsity = 1.0, double driftSpeed = 1.0,
		Class<Actor> spawn_t = "none", double spawnOffs_z = 0,
		int spiralOffs = 270, int limit = 0)
	{
		invoker.bAltFire = true;
		A_RailAttack(damage, spawnOffs_xy, useAmmo, color1, color2, flags, maxDiff,
			puff_t, spread_xy, spread_z, range, duration, sparsity, driftSpeed,
			spawn_t, spawnOffs_z, spiralOffs, limit);
	}
}
