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
	readOnly<BIO_NewWeapon> WeapDefault;
	uint Index;
	private BIO_WeaponPipelineMask Mask;

	private bool SecondaryMagazine;

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

	readOnly<BIO_FireFunctor> GetFireFunctorConst() const
	{
		return FireFunctor.AsConst();
	}

	BIO_FireFunctor GetFireFunctor()
	{
		if (Mask & BIO_WPM_FIREFUNCTOR) return null;
		return FireFunctor;
	}

	void SetFireFunctor(BIO_FireFunctor fireFunc)
	{
		if (Mask & BIO_WPM_FIREFUNCTOR) return;
		FireFunctor = fireFunc;
		FireFunctor.Init();
	}

	Class<Actor> GetFireType() const { return FireType; }

	void SetFireType(Class<Actor> fType)
	{
		if (Mask & BIO_WPM_FIRETYPE) return;
		FireType = fType;
	}

	int GetFireCount() const { return FireCount; }

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

	readOnly<BIO_DamageFunctor> GetDamageFunctorConst() const
	{
		return Damage.AsConst();
	}

	BIO_DamageFunctor GetDamageFunctor()
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

	bool UsesSecondaryMagazine() const { return SecondaryMagazine; }

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

	void ToString(in out Array<string> readout, bool alone) const
	{
		// If this is the weapon's only pipeline, the header is unnecessary
		// Otherwise tell the user which fire mode this is
		if (!alone)
		{
			string header = "";
			
			switch (Index)
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
					StringTable.Localize("$BIO_WEAP_STAT_HEADER_DEFAULT"), Index);
				break;
			}

			readout.Push(header);
		}

		readOnly<BIO_WeaponPipeline> defs;

		{
			Array<BIO_WeaponPipeline> ppls;
			WeapDefault.Construct(ppls);
			defs = ppls[Index].AsConst();
		}

		readout.Push(FireFunctor.ToString(AsConst(), defs));
		readout.Push(Damage.ToString(defs.Damage));

		// Don't report spread unless it's non-trivial (weapons with 
		// true projectiles are likely to have little to no spread)
		if (HSpread > 0.5)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				HSpread, defs.HSpread, invert: true);

			string hSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_HSPREAD"),
				fontColor, HSpread);

			readout.Push(hSpreadStr);
		}

		if (VSpread > 0.5)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				VSpread, defs.VSpread, invert: true);

			string vSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_VSPREAD"),
				fontColor, VSpread);

			readout.Push(vSpreadStr);
		}

		for (uint i = 0; i < ReadoutExtra.Size(); i++)
			readout.Push(ReadoutExtra[i]);
	}

	static BIO_WeaponPipeline Create(Class<BIO_NewWeapon> weap_t)
	{
		let ret = new('BIO_WeaponPipeline');
		ret.WeapDefault = GetDefaultByType(weap_t);
		ret.FireCount = 1;
		return ret;
	}

	readOnly<BIO_WeaponPipeline> AsConst() const { return self; }
}

class BIO_WeaponPipelineBuilder play
{
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create(Class<BIO_NewWeapon> weap_t)
	{
		let ret = new('BIO_WeaponPipelineBuilder');
		ret.Pipeline = BIO_WeaponPipeline.Create(weap_t);
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
