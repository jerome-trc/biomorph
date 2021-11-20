enum BIO_WeaponPipelineMask : uint8
{
	BIO_WPM_NONE = 0,
	BIO_WPM_FIREFUNCTOR = 1 << 0,
	BIO_WPM_FIRETYPE = 1 << 1,
	BIO_WPM_FIRECOUNT = 1 << 2,
	BIO_WPM_DAMAGE = 1 << 3,
	BIO_WPM_HSPREAD = 1 << 4,
	BIO_WPM_VSPREAD = 1 << 5,
	BIO_WPM_FIRETIME = 1 << 6,
	BIO_WPM_RELOADTIME = 1 << 7,
	BIO_WPM_ALL = uint8.MAX
}

class BIO_NewWeapon : DoomWeapon abstract
{
	mixin BIO_Gear;

	const MAX_AFFIXES = 6;

	// SelectionOrder is for when ammo runs out; lower number, higher priority

	const SELORDER_PLASMARIFLE = 100;
	const SELORDER_SSG = 400;
	const SELORDER_CHAINGUN = 700;
	const SELORDER_SHOTGUN = 1300;
	const SELORDER_PISTOL = 1900;
	const SELORDER_CHAINSAW = 2200;
	const SELORDER_RLAUNCHER = 2500;
	const SELORDER_BFG = 2800;
	const SELORDER_FIST = 3700;

	// SlotPriority is for manual selection; higher number, higher priority

	const SLOTPRIO_MAX = 1.0;	
	const SLOTPRIO_CLASSIFIED = 0.8;
	const SLOTPRIO_SPECIALTY = 0.6;
	const SLOTPRIO_STANDARD = 0.4;
	const SLOTPRIO_SURPLUS = 0.2;
	const SLOTPRIO_MIN = 0.0;

	// (RAT: Who designed those two properties to be so counter-intuitive?)

	meta Class<BIO_NewWeapon> UniqueBase; property UniqueBase: UniqueBase;
	BIO_WeaponFlags BIOFlags; property Flags: BIOFlags;
	uint AffixMask; property AffixMask: AffixMask;
	int RaiseSpeed, LowerSpeed;
	property SwitchSpeeds: RaiseSpeed, LowerSpeed;

	private uint LastPipeline;
	Array<BIO_WeaponPipeline> Pipelines;

	Array<BIO_WeaponAffix> ImplicitAffixes, Affixes;
	Array<string> StatReadout, AffixReadout;

	Default
	{
		-SPECIAL
		+DONTGIB
		+NOBLOCKMONST
		+THRUACTORS
		+USESPECIAL
		+WEAPON.ALT_AMMO_OPTIONAL
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT

		Activation
			THINGSPEC_ThingActs | THINGSPEC_ThingTargets | THINGSPEC_Switch;
		Height 8;
		Radius 16;

		Inventory.PickupMessage "";

		Weapon.BobRangeX 0.5;
        Weapon.BobRangeY 0.5;
        Weapon.BobSpeed 1.2;
        Weapon.BobStyle 'Alpha';

		BIO_NewWeapon.AffixMask BIO_WAM_NONE;
		BIO_NewWeapon.Flags BIO_WF_NONE;
		BIO_NewWeapon.Grade BIO_GRADE_NONE;
		BIO_NewWeapon.Rarity BIO_RARITY_COMMON;
		BIO_NewWeapon.SwitchSpeeds 6, 6;
		BIO_NewWeapon.UniqueBase '';
	}

	States
	{
	Select.Loop:
		#### # 1 A_BIO_Raise;
		Loop;
	Deselect.Loop:
		#### # 1 A_BIO_Lower;
		Loop;
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
		Construct();
		SetTag(GetColoredTag());

		if (Abs(Vel.Z) <= 0.01)
		{
			bSpecial = true;
			bThruActors = false;
			HitGround = true;
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

		return true;
	}

	// Prevents picking up a weapon if one weapon of that class is already held.
	override bool HandlePickup(Inventory item)
	{
		if (item.GetClass() == self.GetClass()) return true;
		return super.HandlePickup(item);
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

	override void Activate(Actor activator)
	{
		super.Activate(activator);
		
		let bioPlayer = BIO_Player(activator);
		if (bioPlayer == null) return;

		string output = GetTag() .. "\n\n";

		for (uint i = 0; i < StatReadout.Size(); i++)
			output.AppendFormat("%s\n", StatReadout[i]);

		if (AffixReadout.Size() > 0)
		{
			output = output .. "\n";

			for (uint i = 0; i < AffixReadout.Size(); i++)
				output.AppendFormat("\cj%s\n", AffixReadout[i]);
		}

		output.DeleteLastCharacter();
		bioPlayer.A_Print(output, 5.0);
	}

	override string GetObituary(Actor victim, Actor inflictor, Name mod, bool playerAtk)
	{
		return Pipelines[LastPipeline].GetObituary();
	}

	// Virtuals and abstracts ==================================================

	// Build this weapon's default firing pipelines.
	abstract void Construct();

	virtual void OnDeselect() {}
	virtual void OnSelect() {}

	/*	The first return value indicates if the mutagen should reset the weapon's
		stats, set the corrupted flag, and try for a generic corruption effect.
		The second return value indicates if the mutagen should be consumed.
	*/
	virtual bool, bool OnCorrupt() { return true, true; }

	// Called after all other weapon details have been drawn.
	virtual ui void DrawToHUD(BIO_StatusBar sbar) const {}

	// Actions =================================================================

	protected action bool A_BIO_Fire(uint pipeline = 0)
	{
		if (!invoker.Pipelines[pipeline].DepleteAmmo()) return false;

		return true;
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
			A_StartSound("bio/weap/gundrop_0");
			A_ScaleVelocity(0.5);
			bSpecial = true;
			bThruActors = false;
			invoker.HitGround = true;
		}
	}

	action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }
}

class BIO_WeaponPipeline play
{
	// Acts like `Actor::Default`.
	readOnly<BIO_WeaponPipeline> Prototype;
	private BIO_WeaponPipelineMask Mask;

	private string Obituary;

	private Ammo Magazine;
	private int AmmoUse, AmmoUseFactor, ReloadFactor;

	private BIO_FireFunctor FireFunctor;
	private Class<Actor> FireType;
	private int FireCount;
	private BIO_DamageFunctor Damage;
	private float HSpread, VSpread, Angle, Pitch;

	private Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	private Array<BIO_ProjDamageFunctor> ProjDamageFunctors;
	private Array<BIO_ProjDeathFunctor> ProjDeathFunctors;

	void Invoke(BIO_Weapon weap, int fireFactor = 1, float spreadFactor = 1.0) const
	{
		for (uint i = 0; i < FireCount * fireFactor; i++)
		{
			int dmg = Damage.Invoke();

			for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
				weap.ImplicitAffixes[i].ModifyDamage(weap, dmg);
			for (uint i = 0; i < weap.Affixes.Size(); i++)
				weap.Affixes[i].ModifyDamage(weap, dmg);

			Actor proj = FireFunctor.Invoke(weap, FireType, dmg,
				Angle + (FRandom(-HSpread, HSpread) * spreadFactor),
				Pitch + (FRandom(-VSpread, VSpread) * spreadFactor));

			if (proj == null) continue;
			proj.SetDamage(dmg);
			
			if (proj is 'BIO_Projectile')
			{
				let tProj = BIO_Projectile(proj);
				tProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				tProj.ProjTravelFunctors.Copy(ProjTravelFunctors);
				tProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
				{
					weap.ImplicitAffixes[i].ModifySplash(weap,
						tProj.SplashDamage, tProj.SplashRadius, dmg);
					weap.ImplicitAffixes[i].OnTrueProjectileFired(weap, tProj);
				}

				for (uint i = 0; i < weap.Affixes.Size(); i++)
				{
					weap.Affixes[i].ModifySplash(weap,
						tProj.SplashDamage, tProj.SplashRadius, dmg);
					weap.Affixes[i].OnTrueProjectileFired(weap, tProj);
				}
			}
			else if (proj is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(proj);
				fProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				fProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
				{
					weap.ImplicitAffixes[i].ModifySplash(weap,
						fProj.SplashDamage, fProj.SplashRadius, dmg);
					weap.ImplicitAffixes[i].OnFastProjectileFired(weap, fProj);
				}

				for (uint i = 0; i < weap.Affixes.Size(); i++)
				{
					weap.Affixes[i].ModifySplash(weap,
						fProj.SplashDamage, fProj.SplashRadius, dmg);
					weap.Affixes[i].OnFastProjectileFired(weap, fProj);
				}
			}
		}
	}

	bool DepleteAmmo() const
	{
		return true;
	}

	string GetObituary() const
	{
		return StringTable.Localize(Obituary);
	}

	void SetFireFunctor(BIO_FireFunctor fireFunc)
	{
		if (Mask & BIO_WPM_FIREFUNCTOR) return;
		FireFunctor = fireFunc;
	}

	void SetFireType(Class<Actor> fType)
	{
		if (Mask & BIO_WPM_FIRETYPE) return;
		FireType = fType;
	}

	void SetFireCount(int fCount)
	{
		if (Mask & BIO_WPM_FIRECOUNT) return;
		FireCount = fCount;
	}

	void SetDamageFunctor(BIO_DamageFunctor dmgFunc)
	{
		if (mask & BIO_WPM_DAMAGE) return;
		Damage = dmgFunc;
	}

	void GetDamageValues(in out Array<int> damages) const
	{
		Damage.GetValues(damages);
	}

	void SetDamageValues(in out Array<int> damages)
	{
		if (mask & BIO_WPM_DAMAGE) return;
		Damage.SetValues(damages);
	}

	void SetSpread(float hSpr, float vSpr)
	{
		if (!(Mask & BIO_WPM_HSPREAD))
			hSpread = hSpr;
		if (!(Mask & BIO_WPM_VSPREAD))
			vSpread = vSpr;
	}

	void Restrict(BIO_WeaponPipelineMask msk)
	{
		Mask = msk;
	}

	// void Reset()
	// {
	// 	AmmoUse = Prototype.AmmoUse;
	// 	FireType = Prototype.FireType;
	// 	FireCount = Prototype.FireCount;
	// 	Damage = BIO_DamageFunctor(new(Prototype.Damage.GetClass()));
	// 	FireFunctor = BIO_FireFunctor(new(Prototype.FireFunctor.GetClass()));

	// 	ProjTravelFunctors.Clear();
	// 	ProjTravelFunctors.Copy(Prototype.ProjTravelFunctors);

	// 	ProjDamageFunctors.Clear();
	// 	ProjDamageFunctors.Copy(Prototype.ProjDamageFunctors);

	// 	ProjDeathFunctors.Clear();
	// 	ProjDeathFunctors.Copy(Prototype.ProjDeathFunctors);
	// }

	void ToString(in out Array<string> readout, uint ndx, bool alone) const
	{
		// If this is the weapon's only pipeline, the header is unnecessary
		// Otherwise tell the user which fire mode this is
		if (!alone)
		{
			string header = "";
			
			switch (ndx)
			{
			case 0:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_0");
				break;
			case 1:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_1");
				break;
			case 2:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_2");
				break;
			case 3:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_3");
				break;
			default:
				header = String.Format(
					StringTable.Localize("$BIO_WEAP_STAT_HEADER_DEFAULT"), ndx);
				break;
			}

			readout.Push(header);
		}

		readout.Push(FireFunctor.ToString(
			Prototype.FireFunctor.AsConst(), fireType, fireCount));
		readout.Push(Damage.ToString(
			Prototype.Damage.AsConst()));

		// Don't report spread unless it's non-trivial (weapons with true
		// projectiles are likely to have little to no spread)
		if (HSpread > 0.5)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				HSpread, Prototype.HSpread, invert: true);

			string hSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_HSPREAD"),
				fontColor, HSpread);

			readout.Push(hSpreadStr);
		}

		if (VSpread > 0.5)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				HSpread, Prototype.VSpread, invert: true);

			string vSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_VSPREAD"),
				fontColor, VSpread);

			readout.Push(vSpreadStr);
		}
	}
}

class BIO_DamageFunctor play abstract
{
	abstract int Invoke() const;
	abstract void Reset(readOnly<BIO_DamageFunctor> def);

	virtual void GetValues(in out Array<int> vals) const {}
	virtual void SetValues(in out Array<int> vals) {}

	// Output should be full localized.
	abstract string ToString(readOnly<BIO_DamageFunctor> def) const;

	readOnly<BIO_DamageFunctor> AsConst() const { return self; }
}

// Emits a random number between a minimum and a maximum.
class BIO_DmgFunc_Default : BIO_DamageFunctor
{
	private int Minimum, Maximum;

	override int Invoke() const { return Random(Minimum, Maximum); }

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDef = BIO_DmgFunc_Default(def);
		Minimum = myDef.Minimum;
		Maximum = myDef.Maximum;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Minimum, Maximum);
	}

	override void SetValues(in out Array<int> vals)
	{
		Minimum = vals[0];
		Maximum = vals[1];
	}

	void CustomSet(int minDmg, int maxDmg)
	{
		Minimum = minDmg;
		Maximum = maxDmg;
	}

	override string ToString(readOnly<BIO_DamageFunctor> def) const
	{
		let myDefs = BIO_DmgFunc_Default(def);

		string
			minClr = BIO_Utils.StatFontColor(Maximum, myDefs.Maximum),
			maxClr = BIO_Utils.StatFontColor(Minimum, myDefs.Minimum);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_DEFAULT"),
			minClr, Minimum, maxClr, Maximum);
	}
}

// Imitates the vanilla behaviour of multiplying bullet puff damage by 1D3.
class BIO_DmgFunc_1D3 : BIO_DamageFunctor
{
	private int Baseline;

	override int Invoke() const
	{
		return Baseline * Random(1, 3);
	}

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDefs = BIO_DmgFunc_1D3(def);
		Baseline = myDefs.Baseline;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	override string ToString(readOnly<BIO_DamageFunctor> def) const
	{
		let myDefs = BIO_DmgFunc_1D3(def);

		string fontColor = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			fontColor, Baseline);
	}
}

// Imitates the vanilla behaviour of multiplying projectile damage by 1D8.
class BIO_DmgFunc_1D8 : BIO_DamageFunctor
{
	private int Baseline;

	override int Invoke() const
	{
		return Baseline * Random(1, 8);
	}

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDefs = BIO_DmgFunc_1D8(def);
		Baseline = myDefs.Baseline;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	override string ToString(readOnly<BIO_DamageFunctor> def) const
	{
		let myDefs = BIO_DmgFunc_1D8(def);

		string fontColor = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			fontColor, Baseline);
	}
}

class BIO_FireFunctor play abstract
{
	abstract Actor Invoke(BIO_Weapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const;

	// Output is fully localized.
	protected static string FireTypeTag(Class<Actor> fireType, int count)
	{
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

	abstract string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const;

	readOnly<BIO_FireFunctor> AsConst() const { return self; }
}

class BIO_FireFunc_Default : BIO_FireFunctor
{
	override Actor Invoke(BIO_Weapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		return weap.A_FireProjectile(fireType, angle, useAmmo: false, pitch);
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WEAP_FIREFUNC_DEFAULT"),
			fireCount, FireTypeTag(fireType, fireCount));
	}
}

class BIO_FireFunc_Melee : BIO_FireFunctor abstract
{
	float Range, Lifesteal;

	protected void ApplyLifeSteal(BIO_Weapon weap, int dmg)
	{
		let lsp = Min(Lifesteal, 1.0);
		let given = int(float(dmg) * lsp);
		weap.Owner.GiveBody(given, weap.Owner.GetMaxHealth(true) + 100);
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WEAP_FIREFUNC_MELEE"),
			fireCount);
	}
}

class BIO_FireFunc_Fist : BIO_FireFunc_Melee
{
	override Actor Invoke(BIO_Weapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		FTranslatedLineTarget t;

		if (weap.Owner.FindInventory('PowerStrength', true)) dmg *= 10;
		
		double ang = Angle + Random2[Punch]() * (5.625 / 256);
		double ptch = weap.AimLineAttack(ang, Range, null, 0.0, ALF_CHECK3D);

		Actor puff = null;
		int actualDmg = -1;

		[puff, actualDmg] = weap.LineAttack(ang, Range, ptch, dmg,
			'Melee', fireType, LAF_ISMELEEATTACK, t);

		// Turn to face target
		if (t.LineTarget)
		{
			weap.A_StartSound("*fist", CHAN_WEAPON);
			Angle = t.AngleFromSource;
			if (!t.lineTarget.bDontDrain) ApplyLifeSteal(weap, actualDmg);
		}

		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return StringTable.Localize("$BIO_WEAP_FIREFUNC_FIST");
	}
}

class BIO_FireFunc_Chainsaw : BIO_FireFunc_Melee
{
	override Actor Invoke(BIO_Weapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		int flags = 0; // TODO: Sort this out
		FTranslatedLineTarget t;

		double ang = Angle + 2.8125 * (Random2[Saw]() / 255.0);
		double slope = weap.AimLineAttack(ang, Range, t) *
			(Random2[Saw]() / 255.0);

		Actor puff = null;
		int actualDmg = 0;
		[puff, actualDmg] = weap.LineAttack(ang, Range, slope, dmg,
			'Melee', fireType, 0, t);

		weap.A_BIO_AlertMonsters();

		if (!t.LineTarget)
		{
			if ((flags & SF_RANDOMLIGHTMISS) && (Random[Saw]() > 64))
				weap.Player.ExtraLight = !weap.Player.ExtraLight;
			
			weap.A_StartSound("weapons/sawfull", CHAN_WEAPON);
			return null;
		}

		if (flags & SF_RANDOMLIGHTHIT)
		{
			int randVal = Random[Saw]();

			if (randVal < 64)
				weap.Player.ExtraLight = 0;
			else if (randVal < 160)
				weap.Player.ExtraLight = 1;
			else
				weap.Player.ExtraLight = 2;
		}

		if (!t.LineTarget.bDontDrain) ApplyLifeSteal(weap, actualDmg);

		weap.A_StartSound("weapons/sawhit", CHAN_WEAPON);
			
		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double angleDiff = weap.DeltaAngle(angle, t.angleFromSource);

			if (angleDiff < 0.0)
			{
				if (angleDiff < -4.5)
					angle = t.angleFromSource + 90.0 / 21;
				else
					angle -= 4.5;
			}
			else
			{
				if (angleDiff > 4.5)
					angle = t.angleFromSource - 90.0 / 21;
				else
					angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			weap.bJustAttacked = true;

		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return StringTable.Localize("$BIO_WEAP_FIREFUNC_CHAINSAW");
	}
}

class BIO_WeaponPipelineBuilder play
{
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create()
	{
		let ret = new('BIO_WeaponPipelineBuilder');
		ret.Pipeline = new('BIO_WeaponPipeline');
		return ret;
	}

	BIO_WeaponPipelineBuilder BasicProjectilePipeline(Class<Actor> fireType,
		int fireCount, int minDamage, int maxDamage, float hSpread, float vSpread)
	{
		Pipeline.SetFireFunctor(new('BIO_FireFunc_Default'));
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder Ammo(Class<Ammo> ammo_t, Class<Ammo> magazine_t,
		int ammoUse = 1, int ammoUseFactor = 1, int reloadFactor = 1)
	{
		return self;
	}

	BIO_WeaponPipelineBuilder Restrictions(BIO_WeaponPipelineMask mask)
	{
		Pipeline.Restrict(mask);
		return self;
	}

	BIO_WeaponPipeline Build() const
	{
		return Pipeline;
	}
}
