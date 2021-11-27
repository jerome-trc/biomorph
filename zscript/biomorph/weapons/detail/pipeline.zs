enum BIO_WeaponPipelineMask : uint16
{
	BIO_WPM_NONE = 0,
	BIO_WPM_FIREFUNCTOR = 1 << 0,
	BIO_WPM_FIRETYPE = 1 << 1,
	BIO_WPM_FIRECOUNT = 1 << 2,
	BIO_WPM_DAMAGEFUNCTOR = 1 << 3,
	BIO_WPM_DAMAGEVALS = 1 << 4,
	BIO_WPM_HSPREAD = 1 << 5,
	BIO_WPM_VSPREAD = 1 << 6,
	BIO_WPM_FIRETIME = 1 << 7,
	BIO_WPM_AMMOUSE = 1 << 8,
	BIO_WPM_PROJTRAVELFUNCS = 1 << 12,
	BIO_WPM_PROJDAMAGEFUNCS = 1 << 13,
	BIO_WPM_PROJDEATHFUNCS = 1 << 14,
	BIO_WPM_PROJFUNCTORS =
		BIO_WPM_PROJTRAVELFUNCS |
		BIO_WPM_PROJDAMAGEFUNCS |
		BIO_WPM_PROJDEATHFUNCS,
	BIO_WPM_ALERT = 1 << 15,
	BIO_WPM_ALL = uint16.MAX
}

struct BIO_FireData
{
	Class<Actor> FireType;
	int Damage;
	float HSpread, VSpread, Angle, Pitch;
}

class BIO_WeaponPipeline play
{
	// Acts like `Actor::Default`.
	readOnly<BIO_WeaponPipeline> Prototype;
	private BIO_WeaponPipelineMask Mask;

	private bool SecondaryMagazine;
	private int AmmoUse;

	private BIO_FireFunctor FireFunctor;
	private Class<Actor> FireType;
	private int FireCount;
	private BIO_DamageFunctor Damage;
	private float HSpread, VSpread, Angle, Pitch;

	private int AlertFlags;
	private double MaxAlertDistance;

	private Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	private Array<BIO_ProjDamageFunctor> ProjDamageFunctors;
	private Array<BIO_ProjDeathFunctor> ProjDeathFunctors;

	private Array<int> FireTimes, FireTimeMinimums;

	private sound FireSound;
	private double FireSoundVolume, FireSoundAttenuation;

	private string Obituary;
	private Array<string> ReadoutExtra;

	void Invoke(BIO_NewWeapon weap, uint fireFactor = 1, float spreadFactor = 1.0)
	{
		for (uint i = 0; i < FireCount * fireFactor; i++)
		{
			BIO_FireData fireData;
			fireData.FireType = FireType;
			fireData.Damage = Damage.Invoke();
			fireData.HSpread = HSpread * spreadFactor;
			fireData.VSpread = VSpread * spreadFactor;
			fireData.Angle = Angle;
			fireData.Pitch = Pitch;

			Actor proj = FireFunctor.Invoke(weap, fireData);

			if (proj == null) continue;
			proj.SetDamage(fireData.Damage);
			
			if (proj is 'BIO_Projectile')
			{
				let tProj = BIO_Projectile(proj);
				tProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				tProj.ProjTravelFunctors.Copy(ProjTravelFunctors);
				tProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnTrueProjectileFired(weap, tProj);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnTrueProjectileFired(weap, tProj);
			}
			else if (proj is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(proj);
				fProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				fProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnFastProjectileFired(weap, fProj);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnFastProjectileFired(weap, fProj);
			}
		}

		weap.Owner.A_AlertMonsters(MaxAlertDistance, AlertFlags);
		weap.Owner.A_StartSound(FireSound, CHAN_WEAPON, CHANF_DEFAULT,
			FireSoundVolume, FireSoundAttenuation);
	}

	string GetObituary() const
	{
		return StringTable.Localize(Obituary);
	}

	void SetFireFunctor(BIO_FireFunctor fireFunc)
	{
		if (Mask & BIO_WPM_FIREFUNCTOR) return;
		FireFunctor = fireFunc;
		FireFunctor.Init();
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

	bool DamageFunctorMutable() const
	{
		return Mask & BIO_WPM_DAMAGEFUNCTOR;
	}

	void SetDamageFunctor(BIO_DamageFunctor dmgFunc)
	{
		if (Mask & BIO_WPM_DAMAGEFUNCTOR) return;
		Damage = dmgFunc;
	}

	BIO_DamageFunctor GetDamageFunctor() const
	{
		if (Mask & BIO_WPM_DAMAGEFUNCTOR) return null;
		return Damage;
	}

	bool DamageMutable() const
	{
		return Mask & BIO_WPM_DAMAGEVALS;
	}

	void GetDamageValues(in out Array<int> damages) const
	{
		Damage.GetValues(damages);
	}

	void SetDamageValues(in out Array<int> damages)
	{
		if (Mask & BIO_WPM_DAMAGEVALS) return;
		Damage.SetValues(damages);
	}

	void SetSpread(float hSpr, float vSpr)
	{
		if (!(Mask & BIO_WPM_HSPREAD))
			hSpread = hSpr;
		if (!(Mask & BIO_WPM_VSPREAD))
			vSpread = vSpr;
	}

	double, int GetAlertStats() const
	{
		return MaxAlertDistance, AlertFlags;
	}

	void SetAlertStats(double maxDist, int flags)
	{
		if (Mask & BIO_WPM_ALERT) return;
		MaxAlertDistance = maxDist;
		AlertFlags = flags;
	}

	int GetFireTime(uint ndx) const { return FireTimes[ndx]; }

	void PushFireTimes(state fireState)
	{
		if (Mask & BIO_WPM_FIRETIME) return;

		for (state s = fireState; s.InStateSequence(fireState); s = s.NextState)
		{
			if (s.Tics == 0) continue; // `TNT1 A 0` and the like
			if (s.bSlow) continue; // States marked `Slow` are kept immutable
			
			uint j = FireTimes.Push(s.Tics);
			// States marked `Fast` are allowed to have their tic time set to 0,
			// effectively eliminating them from the state sequence
			uint e = FireTimeMinimums.Push(s.bFast ? 0 : 1);
		}
	}

	int GetAmmoUse() const { return AmmoUse; }
	bool UsesSecondaryMagazine() const { return SecondaryMagazine; }

	void SetAmmoUse(int use)
	{
		if (Mask & BIO_WPM_AMMOUSE) return;
		AmmoUse = use;
	}

	void SetSound(sound fireSnd, double volume, double attenuation)
	{
		FireSound = fireSnd;
		FireSoundVolume = volume;
		FireSoundAttenuation = attenuation;
	}

	sound, double, double GetFireSoundData() const
	{
		return FireSound, FireSoundVolume, FireSoundAttenuation;
	}

	void PushReadoutString(string str)
	{
		ReadoutExtra.Push(str);
	}

	void SetObituary(string obit)
	{
		Obituary = obit;
	}

	void Restrict(BIO_WeaponPipelineMask msk)
	{
		Mask = msk;
	}

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

		for (uint i = 0; i < ReadoutExtra.Size(); i++)
			readout.Push(ReadoutExtra[i]);
	}

	static BIO_WeaponPipeline Create()
	{
		let ret = new('BIO_WeaponPipeline');
		ret.FireCount = 1;
		ret.AmmoUse = 1;
		return ret;
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
	virtual void Init() {} // Use only for setting defaults.

	abstract Actor Invoke(BIO_NewWeapon weap, in out BIO_FireData fireData) const;

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
		else if (fireType is 'BIO_RailPuff')
		{
			let defs = GetDefaultByType((Class<BIO_RailPuff>)(fireType));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (fireType is 'BIO_RailSpawn')
		{
			let defs = GetDefaultByType((Class<BIO_RailSpawn>)(fireType));

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
	override Actor Invoke(BIO_NewWeapon weap, in out BIO_FireData fireData) const
	{
		return weap.BIO_FireProjectile(fireData.FireType,
			angle: fireData.Angle + FRandom(-fireData.HSpread, fireData.HSpread),
			pitch: fireData.Pitch + FRandom(-fireData.VSpread, fireData.VSpread)
		);
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WEAP_FIREFUNC_DEFAULT"),
			fireCount, FireTypeTag(fireType, fireCount));
	}
}

class BIO_FireFunc_Bullet : BIO_FireFunctor
{
	int NumBullets, Flags;

	override void Init()
	{
		NumBullets = -1;
		Flags = FBF_NORANDOM | FBF_NOFLASH;
	}

	override Actor Invoke(BIO_NewWeapon weap, in out BIO_FireData fireData) const
	{
		weap.A_FireBullets(fireData.HSpread, fireData.VSpread,
			NumBullets, fireData.Damage, fireData.FireType, Flags);
		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WEAP_FIREFUNC_DEFAULT"),
			fireCount, FireTypeTag(fireType, fireCount));
	}
}

class BIO_FireFunc_Rail : BIO_FireFunctor
{
	int Flags;
	color Color1, Color2;

	override Actor Invoke(BIO_NewWeapon weap, in out BIO_FireData fireData) const
	{
		Class<Actor> puff_t = null, spawnClass = null;

		if (fireData.FireType is 'BIO_RailPuff')
		{
			puff_t = fireData.FireType;
			spawnClass = GetDefaultByType(
				(Class<BIO_RailPuff>)(fireData.FireType)).SpawnClass;
		}
		else if (fireData.FireType is 'BIO_RailSpawn')
		{
			spawnClass = fireData.FireType;
			puff_t = GetDefaultByType(
				(Class<BIO_RailSpawn>)(fireData.FireType)).PuffType;
		}

		weap.A_RailAttack(fireData.Damage,
			spawnOfs_xy: fireData.Angle,
			useAmmo: false,
			color1: Color1,
			color2: Color2,
			flags: Flags,
			puffType: puff_t,
			spread_xy: fireData.HSpread,
			spread_z: fireData.VSpread,
			spawnClass: spawnClass,
			spawnOfs_z: fireData.Pitch
		);

		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		Class<Actor> puff_t = null, spawnClass = null;

		if (fireType is 'BIO_RailPuff')
		{
			puff_t = fireType;
			spawnClass = GetDefaultByType((Class<BIO_RailPuff>)(fireType)).SpawnClass;
		}
		else if (fireType is 'BIO_RailSpawn')
		{
			spawnClass = fireType;
			puff_t = GetDefaultByType((Class<BIO_RailSpawn>)(fireType)).PuffType;
		}

		if (puff_t != null && spawnClass != null)
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL"), fireCount,
				FireTypeTag(puff_t, fireCount), FireTypeTag(spawnClass, fireCount));
		}
		else if (puff_t == null)
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL_NOPUFF"),
				fireCount, FireTypeTag(spawnClass, fireCount));
		}
		else if (spawnClass == null)
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL_NOSPAWN"),
				fireCount, FireTypeTag(puff_t, fireCount));
		}
		else
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL_NOTHING"),
				fireCount);
		}
	}
}

class BIO_FireFunc_Melee : BIO_FireFunctor abstract
{
	float Range, Lifesteal;

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
	override Actor Invoke(BIO_NewWeapon weap, in out BIO_FireData fireData) const
	{
		FTranslatedLineTarget t;

		if (weap.Owner.FindInventory('PowerStrength', true))
			fireData.Damage *= 10;
		
		double ang = weap.Owner.Angle + Random2[Punch]() * (5.625 / 256);
		double ptch = weap.AimLineAttack(ang, Range, null, 0.0, ALF_CHECK3D);

		Actor puff = null;
		int actualDmg = -1;

		[puff, actualDmg] = weap.LineAttack(ang, Range, ptch, fireData.Damage,
			'Melee', fireData.FireType, LAF_ISMELEEATTACK, t);

		// Turn to face target
		if (t.LineTarget)
		{
			weap.Owner.A_StartSound("*fist", CHAN_WEAPON);
			weap.Owner.Angle = t.AngleFromSource;
			if (!t.lineTarget.bDontDrain)
				weap.ApplyLifeSteal(Lifesteal, actualDmg);
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
	override Actor Invoke(BIO_NewWeapon weap, in out BIO_FireData fireData) const
	{
		weap.BIO_Saw(fireData.FireType, fireData.Damage,
			Range, fireData.Angle, Lifesteal);

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
		ret.Pipeline = BIO_WeaponPipeline.Create();
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

	BIO_WeaponPipelineBuilder Alert(double maxDist, int flags)
	{
		Pipeline.SetAlertStats(maxDist, flags);
		return self;
	}

	BIO_WeaponPipelineBuilder FireTime(state fireState)
	{
		Pipeline.PushFireTimes(fireState);
		return self;
	}

	BIO_WeaponPipelineBuilder FireSound(sound fireSound, double volume = 1.0,
		double attenuation = ATTN_NORM)
	{
		Pipeline.SetSound(fireSound, volume, attenuation);
		return self;
	}

	// Argument should be fully localized.
	BIO_WeaponPipelineBuilder CustomReadout(string str)
	{
		Pipeline.PushReadoutString(str);
		return self;
	}

	// Argument should be non-localized.
	BIO_WeaponPipelineBuilder Obituary(string obit)
	{
		Pipeline.SetObituary(obit);
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
