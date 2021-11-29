enum BIO_WeaponPipelineMask : uint16
{
	BIO_WPM_NONE = 0,
	BIO_WPM_FIREFUNCTOR = 1 << 0,
	BIO_WPM_FIRETYPE = 1 << 1,
	BIO_WPM_FIRECOUNT = 1 << 2,
	BIO_WPM_DAMAGEFUNCTOR = 1 << 3,
	BIO_WPM_DAMAGEVALS = 1 << 4,
	BIO_WPM_SPLASH = 1 << 5,
	BIO_WPM_HSPREAD = 1 << 6,
	BIO_WPM_VSPREAD = 1 << 7,
	BIO_WPM_ANGLE = 1 << 8,
	BIO_WPM_PITCH = 1 << 9,
	BIO_WPM_AMMOUSE = 1 << 10,
	BIO_WPM_PROJTRAVELFUNCS = 1 << 11,
	BIO_WPM_PROJDAMAGEFUNCS = 1 << 12,
	BIO_WPM_PROJDEATHFUNCS = 1 << 13,
	BIO_WPM_PROJFUNCTORS =
		BIO_WPM_PROJTRAVELFUNCS |
		BIO_WPM_PROJDAMAGEFUNCS |
		BIO_WPM_PROJDEATHFUNCS,
	BIO_WPM_ALERT = 1 << 15,
	BIO_WPM_ALL = uint16.MAX
}

struct BIO_FireData
{
	uint Number;
	Class<Actor> FireType;
	int Damage;
	float HSpread, VSpread, Angle, Pitch;
}

class BIO_WeaponPipeline play
{
	enum ToStringExtraIndex : uint
	{
		TOSTREX_FIREFUNC,
		TOSTREX_COUNT
	}

	readOnly<BIO_Weapon> WeapDefault;
	uint Index;
	private BIO_WeaponPipelineMask Mask;

	private bool SecondaryMagazine;

	private BIO_FireFunctor FireFunctor;
	private Class<Actor> FireType;
	private int FireCount;
	private BIO_DamageFunctor Damage;
	private int SplashDamage, SplashRadius;
	private float HSpread, VSpread, Angle, Pitch;

	private int AlertFlags;
	private double MaxAlertDistance;

	private Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	private Array<BIO_ProjDamageFunctor> ProjDamageFunctors;
	private Array<BIO_ProjDeathFunctor> ProjDeathFunctors;

	private sound FireSound;
	private double FireSoundVolume, FireSoundAttenuation;

	private string Obituary;
	private Array<string> ReadoutExtra;
	private string[TOSTREX_COUNT] ToStringAppends, ToStringPrepends;

	void Invoke(BIO_Weapon weap, uint fireFactor = 1, float spreadFactor = 1.0)
	{
		for (uint i = 0; i < FireCount * fireFactor; i++)
		{
			BIO_FireData fireData;
			fireData.Number = i;
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
				tProj.SplashDamage = SplashDamage;
				tProj.SplashRadius = SplashRadius;
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
				fProj.SplashDamage = SplashDamage;
				fProj.SplashRadius = SplashRadius;
				fProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				fProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnFastProjectileFired(weap, fProj);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnFastProjectileFired(weap, fProj);
			}
		}

		weap.Owner.A_AlertMonsters(MaxAlertDistance, AlertFlags);
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

	bool FireTypeIsDefault() const
	{
		readOnly<BIO_WeaponPipeline> defs;

		{
			Array<BIO_WeaponPipeline> ppls;
			WeapDefault.InitPipelines(ppls);
			defs = ppls[Index].AsConst();
		}

		return FireType == defs.FireType;
	}
	
	/*	Checks that the fire type hasn't already been changed, isn't masked 
		against modification, and is currently set to a given class. If
		`subclass` is false, the check will only pass if the argument class
		exactly matches the fire type.
	*/
	bool FireTypeMutableFrom(Class<Actor> curFT, bool subClass = false) const
	{
		if (FireFunctor is 'BIO_FireFunc_Melee') return false;

		bool sameType;

		if (subClass)
			sameType = FireType is curFT;
		else
			sameType = FireType != curFT;

		return FireTypeIsDefault() && !(Mask & BIO_WPM_FIRETYPE) && sameType;
	}

	/* 	Checks that the fire type hasn't already been changed, isn't masked
		against modification, and isn't currently set to a given class. If
		`subclass` is false, the check will only fail if the argument class
		exactly matches the fire type.
	*/
	bool FireTypeMutableTo(Class<Actor> newFT, bool subClass = false) const
	{
		if (FireFunctor is 'BIO_FireFunc_Melee') return false;

		bool sameType;

		if (subClass)
			sameType = FireType is newFT;
		else
			sameType = FireType != newFT;

		return FireTypeIsDefault() && !(Mask & BIO_WPM_FIRETYPE) && !sameType;
	}

	bool FiresTrueProjectile() const { return FireType is 'BIO_Projectile'; }
	bool FiresFastProjectile() const { return FireType is 'BIO_FastProjectile'; }
	bool FiresProjectile() const { return FiresTrueProjectile() || FiresFastProjectile(); }

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
		return !(Mask & BIO_WPM_DAMAGEFUNCTOR);
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
		return !(Mask & BIO_WPM_DAMAGEVALS);
	}

	bool ExportsDamageValues() const
	{
		Array<int> vals;
		GetDamageValues(vals);
		return vals.Size() > 0;
	}

	void GetDamageValues(in out Array<int> damages) const
	{
		Damage.GetValues(damages);
		FireFunctor.GetDamageValues(damages);
		
		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
			ProjTravelFunctors[i].GetDamageValues(damages);
		for (uint i = 0; i < ProjDamageFunctors.Size(); i++)
			ProjDamageFunctors[i].GetDamageValues(damages);
		for (uint i = 0; i < ProjDeathFunctors.Size(); i++)
			ProjDeathFunctors[i].GetDamageValues(damages);
	}

	void SetDamageValues(in out Array<int> damages)
	{
		if (Mask & BIO_WPM_DAMAGEVALS) return;

		Damage.SetValues(damages);
		damages.Delete(0, Damage.ValueCount());

		FireFunctor.SetDamageValues(damages);
		damages.Delete(0, FireFunctor.DamageValueCount());

		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
		{
			ProjTravelFunctors[i].SetDamageValues(damages);
			damages.Delete(0, ProjTravelFunctors[i].DamageValueCount());
		}

		for (uint i = 0; i < ProjDamageFunctors.Size(); i++)
		{
			ProjDamageFunctors[i].SetDamageValues(damages);
			damages.Delete(0, ProjDamageFunctors[i].DamageValueCount());
		}

		for (uint i = 0; i < ProjDeathFunctors.Size(); i++)
		{
			ProjDeathFunctors[i].SetDamageValues(damages);
			damages.Delete(0, ProjDeathFunctors[i].DamageValueCount());
		}
	}

	bool DealsAnyDamage() const
	{
		Array<int> vals;
		GetDamageValues(vals);
		
		for (uint i = 0; i < vals.Size(); i++)
			if (vals[i] > 0)
				return true;

		return false;
	}

	void PushProjTravelFunctor(BIO_ProjTravelFunctor func)
	{
		if (Mask & BIO_WPM_PROJTRAVELFUNCS) return;
		ProjTravelFunctors.Push(func);
	}

	void PushProjDamageFunctor(BIO_ProjDamageFunctor func)
	{
		if (Mask & BIO_WPM_PROJDAMAGEFUNCS) return;
		ProjDamageFunctors.Push(func);
	}

	void PushProjDeathFunctor(BIO_ProjDeathFunctor func)
	{
		if (Mask & BIO_WPM_PROJDEATHFUNCS) return;
		ProjDeathFunctors.Push(func);
	}

	bool Splashes() const { return SplashDamage > 0; }
	int GetSplashDamage() const { return SplashDamage; }
	int GetSplashRadius() const { return SplashRadius; }

	void SetSplash(int damage, int radius)
	{
		if (Mask & BIO_WPM_SPLASH) return;
		SplashDamage = damage;
		SplashRadius = radius;
	}

	float, float GetSpread() const { return HSpread, VSpread; }
	float GetHSpread() const { return HSpread; }
	float GetVSpread() const { return VSpread; }
	bool HasAnySpread() const { return HSpread > 0.0 || VSpread > 0.0; }

	void SetSpread(float hSpr, float vSpr)
	{
		if (!(Mask & BIO_WPM_HSPREAD))
			hSpread = hSpr;
		if (!(Mask & BIO_WPM_VSPREAD))
			vSpread = vSpr;
	}

	void SetAngleAndPitch(float ang, float ptch)
	{
		if (!(Mask & BIO_WPM_ANGLE))
			Angle = ang;
		if (!(Mask & BIO_WPM_PITCH))
			Pitch = ptch;
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

	void AppendStringTo(ToStringExtraIndex index, string str)
	{
		if (index > TOSTREX_COUNT)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to illegally append a string to index: %d",
				index);
			return;
		}

		ToStringAppends[index] = str;
	}

	void PrependStringTo(ToStringExtraIndex index, string str)
	{
		if (index > TOSTREX_COUNT)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to illegally prepend a string to index: %d",
				index);
			return;
		}

		ToStringPrepends[index] = str;
	}

	void SetObituary(string obit)
	{
		Obituary = obit;
	}

	BIO_WeaponPipelineMask GetRestrictions() const { return Mask; }
	void SetRestrictions(BIO_WeaponPipelineMask msk) { Mask = msk; }
	void AddRestriction(BIO_WeaponPipelineMask msk) { Mask |= msk; }

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
			WeapDefault.InitPipelines(ppls);
			defs = ppls[Index].AsConst();
		}

		FireFunctor.ToString(readout, AsConst(), defs);
		readout[readout.Size() - 1].AppendFormat(ToStringAppends[TOSTREX_FIREFUNC]);
		readout.Push(Damage.ToString(defs.Damage));

		if (SplashDamage > 0)
		{
			readout.Push(String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_SPLASH"),
				BIO_Utils.StatFontColor(SplashDamage, defs.SplashDamage),
				SplashDamage,
				BIO_Utils.StatFontColor(SplashRadius, defs.SplashRadius),
				SplashRadius));
		}

		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
			ProjTravelFunctors[i].ToString(readout);
		for (uint i = 0; i < ProjDamageFunctors.Size(); i++)
			ProjDamageFunctors[i].ToString(readout);
		for (uint i = 0; i < ProjDeathFunctors.Size(); i++)
			ProjDeathFunctors[i].ToString(readout);

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

	static BIO_WeaponPipeline Create(Class<BIO_Weapon> weap_t)
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

	static BIO_WeaponPipelineBuilder Create(Class<BIO_Weapon> weap_t)
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

	BIO_WeaponPipelineBuilder PunchPipeline(Class<Actor> fireType = 'BIO_MeleeHit',
		int hitCount = 1, int minDamage = 2, int maxDamage = 20,
		float range = DEFMELEERANGE)
	{
		let fireFunc = new('BIO_FireFunc_Fist');
		Pipeline.SetFireFunctor(fireFunc);
		fireFunc.Range = range;
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(hitCount);
		
		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		return self;
	}

	BIO_WeaponPipelineBuilder SawPipeline(Class<Actor> fireType = 'BIO_MeleeHit',
		int hitCount = 1, int minDamage = 2, int maxDamage = 20,
		float range = SAWRANGE)
	{
		let fireFunc = new('BIO_FireFunc_Chainsaw');
		Pipeline.SetFireFunctor(fireFunc);
		fireFunc.Range = range;
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(hitCount);
		
		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		return self;
	}

	BIO_WeaponPipelineBuilder BFGPipeline(Class<Actor> fireType = 'BIO_BFGBall',
		int fireCount = 1, int rayCount = 40, int minDamage = 100, int maxDamage = 800,
		int minRayDmg = 49, int maxRayDmg = 87, float hSpread = 0.4, float vSpread = 0.4)
	{
		let fireFunc = new('BIO_FireFunc_Default');
		Pipeline.SetFireFunctor(fireFunc);
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		let sprayFunctor = new('BIO_PDTF_BFGSpray');
		sprayFunctor.RayCount = rayCount;
		sprayFunctor.MinDamage = minRayDmg;
		sprayFunctor.MaxDamage = maxRayDmg;
		Pipeline.PushProjDeathFunctor(sprayFunctor);

		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder FireFunctor(BIO_FireFunctor func)
	{
		Pipeline.SetFireFunctor(func);
		return self;
	}

	BIO_WeaponPipelineBuilder FireType(Class<Actor> fireType)
	{
		Pipeline.SetFireType(fireType);
		return self;
	}

	BIO_WeaponPipelineBuilder FireCount(int fireCount)
	{
		Pipeline.SetFireCount(fireCount);
		return self;
	}

	BIO_WeaponPipelineBuilder DamageFunctor(BIO_DamageFunctor func)
	{
		Pipeline.SetDamageFunctor(func);
		return self;
	}

	BIO_WeaponPipelineBuilder BasicDamage(int minDmg, int maxDmg)
	{
		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDmg, maxDmg);
		Pipeline.SetDamageFunctor(dmgFunc);
		return self;
	}

	BIO_WeaponPipelineBuilder SingleDamage(int dmg)
	{
		let dmgFunc = new('BIO_DmgFunc_Single');
		dmgFunc.CustomSet(dmg);
		Pipeline.SetDamageFunctor(dmgFunc);
		return self;
	}

	BIO_WeaponPipelineBuilder Spread(float horiz, float vert)
	{
		Pipeline.SetSpread(horiz, vert);
		return self;
	}

	BIO_WeaponPipelineBuilder AngleAndPitch(float angle, float pitch)
	{
		Pipeline.SetAngleAndPitch(angle, pitch);
		return self;
	}

	BIO_WeaponPipelineBuilder Splash(int damage, int radius)
	{
		Pipeline.SetSplash(damage, radius);
		return self;
	}

	BIO_WeaponPipelineBuilder Alert(double maxDist, int flags = 0)
	{
		Pipeline.SetAlertStats(maxDist, flags);
		return self;
	}

	BIO_WeaponPipelineBuilder FireSound(sound fireSound, double volume = 1.0,
		double attenuation = ATTN_NORM)
	{
		Pipeline.SetSound(fireSound, volume, attenuation);
		return self;
	}

	// Argument should be fully localized.
	BIO_WeaponPipelineBuilder AppendToFireFunctorString(string str)
	{
		Pipeline.AppendStringTo(BIO_WeaponPipeline.TOSTREX_FIREFUNC, str);
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

	BIO_WeaponPipelineBuilder AddRestriction(BIO_WeaponPipelineMask mask)
	{
		Pipeline.AddRestriction(mask);
		return self;
	}

	BIO_WeaponPipelineBuilder SetRestrictions(BIO_WeaponPipelineMask mask)
	{
		Pipeline.SetRestrictions(mask);
		return self;
	}

	BIO_WeaponPipeline Build() const
	{
		return Pipeline;
	}
}
