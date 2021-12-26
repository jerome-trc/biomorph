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
	BIO_WPM_HITDAMAGEFUNCS = 1 << 12,
	BIO_WPM_FTDEATHFUNCS = 1 << 13,
	BIO_WPM_PROJFUNCTORS =
		BIO_WPM_PROJTRAVELFUNCS |
		BIO_WPM_HITDAMAGEFUNCS |
		BIO_WPM_FTDEATHFUNCS,
	BIO_WPM_ALERT = 1 << 15,
	BIO_WPM_ALL = uint16.MAX
}

const TRIVIAL_WEAPON_SPREAD = 0.48;

struct BIO_FireData
{
	uint Number, Count;
	Class<Actor> FireType;
	int Damage;
	float HSpread, VSpread, Angle, Pitch;
	bool Critical;
}

class BIO_WeaponPipeline play
{
	enum ToStringExtraIndex : uint
	{
		TOSTREX_FIREFUNC,
		TOSTREX_COUNT
	}

	readOnly<BIO_WeaponPipeline> Defaults;

	private BIO_WeaponPipelineMask Mask;

	private bool SecondaryAmmo;

	private BIO_FireFunctor FireFunctor;
	private Class<Actor> FireType;
	private uint FireCount;
	private BIO_DamageFunctor Damage;
	private float HSpread, VSpread, Angle, Pitch;

	private int AlertFlags;
	private double MaxAlertDistance;

	private Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	private Array<BIO_HitDamageFunctor> HitDamageFunctors;
	private Array<BIO_FTDeathFunctor> FTDeathFunctors;

	private sound FireSound;

	string Tag, Obituary;
	private Array<string> ReadoutExtra;
	private string[TOSTREX_COUNT] ToStringAppends, ToStringPrepends;

	void Invoke(BIO_Weapon weap, uint fireFactor = 1, float spreadFactor = 1.0)
	{
		uint fc = fireCount * fireFactor;

		BIO_FireData fireData;
		fireData.Count = fc;

		for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
			weap.ImplicitAffixes[i].BeforeAllFire(weap, fireData);
		for (uint i = 0; i < weap.Affixes.Size(); i++)
			weap.Affixes[i].BeforeAllFire(weap, fireData);

		for (uint i = 0; i < fc; i++)
		{
			fireData.Number = i;
			fireData.FireType = FireType;
			fireData.Damage = Damage.Invoke();
			fireData.HSpread = HSpread * spreadFactor;
			fireData.VSpread = VSpread * spreadFactor;
			fireData.Angle = Angle;
			fireData.Pitch = Pitch;

			for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
				weap.ImplicitAffixes[i].BeforeEachFire(weap, fireData);
			for (uint i = 0; i < weap.Affixes.Size(); i++)
				weap.Affixes[i].BeforeEachFire(weap, fireData);

			Actor output = FireFunctor.Invoke(weap, fireData);

			if (output is 'BIO_Puff') // Might be of `FireType`, might be `FakePuff`
			{
				let puff = BIO_Puff(output);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnPuffFired(weap, puff);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnPuffFired(weap, puff);

				for (uint i = 0; i < HitDamageFunctors.Size(); i++)
					HitDamageFunctors[i].InvokePuff(puff);
				for (uint i = 0; i < FTDeathFunctors.Size(); i++)
					FTDeathFunctors[i].InvokePuff(puff);
			}
			else if (output is 'BIO_Projectile')
			{
				let tProj = BIO_Projectile(output);
				tProj.SetDamage(fireData.Damage);
				tProj.HitDamageFunctors.Copy(HitDamageFunctors);
				tProj.ProjTravelFunctors.Copy(ProjTravelFunctors);
				tProj.FTDeathFunctors.Copy(FTDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnTrueProjectileFired(weap, tProj);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnTrueProjectileFired(weap, tProj);
			}
			else if (output is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(output);
				fProj.SetDamage(fireData.Damage);
				fProj.HitDamageFunctors.Copy(HitDamageFunctors);
				fProj.FTDeathFunctors.Copy(FTDeathFunctors);

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

	bool CanFireProjectiles() const
	{
		return FireFunctor != null && (FireFunctor.GetType() & BIO_FFT_PROJECTILE);
	}

	bool CanFirePuffs() const
	{
		return FireFunctor != null && (FireFunctor.GetType() & BIO_FFT_PUFF);
	}

	bool CanFireRails() const
	{
		return FireFunctor != null && (FireFunctor.GetType() & BIO_FFT_RAIL);
	}

	bool FireFunctorMutable() const
	{
		return !(Mask & BIO_WPM_FIREFUNCTOR);
	}

	bool IsMelee() const
	{
		return FireFunctor is 'BIO_FireFunc_Melee';
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
	bool FireTypeIsDefault() const { return FireType == Defaults.FireType; }
	
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
			sameType = FireType == curFT;

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
			sameType = FireType == newFT;

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

	bool FireCountMutable() const { return !(Mask & BIO_WPM_FIRECOUNT); }

	uint GetFireCount() const { return FireCount; }

	void SetFireCount(uint fCount)
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
		return !(Mask & BIO_WPM_DAMAGEVALS) && ExportsDamageValues();
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
		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			HitDamageFunctors[i].GetDamageValues(damages);
		for (uint i = 0; i < FTDeathFunctors.Size(); i++)
			FTDeathFunctors[i].GetDamageValues(damages);
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

		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
		{
			HitDamageFunctors[i].SetDamageValues(damages);
			damages.Delete(0, HitDamageFunctors[i].DamageValueCount());
		}

		for (uint i = 0; i < FTDeathFunctors.Size(); i++)
		{
			FTDeathFunctors[i].SetDamageValues(damages);
			damages.Delete(0, FTDeathFunctors[i].DamageValueCount());
		}
	}

	void AddToAllDamageValues(int dmg)
	{
		if (Mask & BIO_WPM_DAMAGEVALS) return;

		Array<int> vals;
		GetDamageValues(vals);

		for (uint i = 0; i < vals.Size(); i++)
			vals[i] += dmg;

		SetDamageValues(vals);
	}

	void MultiplyAllDamage(float multi)
	{
		if (Mask & BIO_WPM_DAMAGEVALS) return;

		Array<int> vals;
		GetDamageValues(vals);

		for (uint i = 0; i < vals.Size(); i++)
			vals[i] *= multi;

		SetDamageValues(vals);
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
	
	bool ProjTravelFunctorsMutable() const { return !(Mask & BIO_WPM_PROJTRAVELFUNCS); }
	bool HitDamageFunctorsMutable() const { return !(Mask & BIO_WPM_HITDAMAGEFUNCS); }
	bool FTDeathFunctorsMutable() const { return !(Mask & BIO_WPM_FTDEATHFUNCS); }

	void PushProjTravelFunctor(BIO_ProjTravelFunctor func)
	{
		if (Mask & BIO_WPM_PROJTRAVELFUNCS) return;
		ProjTravelFunctors.Push(func);
	}

	void PushHitDamageFunctor(BIO_HitDamageFunctor func)
	{
		if (Mask & BIO_WPM_HITDAMAGEFUNCS) return;
		HitDamageFunctors.Push(func);
	}

	void PushFiredThingDeathFunctor(BIO_FTDeathFunctor func)
	{
		if (Mask & BIO_WPM_FTDEATHFUNCS) return;
		FTDeathFunctors.Push(func);
	}

	BIO_FTDF_Explode GetSplashFunctor() const
	{
		if (Mask & BIO_WPM_SPLASH) return null;

		for (uint i = 0; i < FTDeathFunctors.Size(); i++)
			if (FTDeathFunctors[i].GetClass() == 'BIO_FTDF_Explode')
				return BIO_FTDF_Explode(FTDeathFunctors[i]);

		return null;
	}

	readOnly<BIO_FTDF_Explode> GetSplashFunctorConst() const
	{
		for (uint i = 0; i < FTDeathFunctors.Size(); i++)
			if (FTDeathFunctors[i].GetClass() == 'BIO_FTDF_Explode')
				return BIO_FTDF_Explode(FTDeathFunctors[i].AsConst());

		return null;
	}

	bool Splashes() const
	{
		let func = GetSplashFunctor();
		return func != null && func.Damage > 0 && func.Radius > 0;
	}

	bool SplashMutable() const { return Mask & BIO_WPM_SPLASH; }

	void SetSplash(int damage, int radius, EExplodeFlags flags = 0)
	{
		if (Mask & BIO_WPM_SPLASH) return;

		let func = GetSplashFunctor();

		if (func == null)
		{
			func = BIO_FTDF_Explode.Create(damage, radius, flags, 0, 0);
			func.Damage = damage;
			func.Radius = radius;
			func.Flags = flags;
		}

		FTDeathFunctors.Push(func);
	}

	void SetShrapnel(int count, int damage)
	{
		if (Mask & BIO_WPM_SPLASH) return;

		let func = GetSplashFunctor();

		if (func == null)
		{
			func = BIO_FTDF_Explode.Create(0, 0, XF_NONE, count, damage);
			func.ShrapnelCount = count;
			func.ShrapnelDamage = damage;
		}

		FTDeathFunctors.Push(func);
	}

	float, float GetSpread() const { return HSpread, VSpread; }
	float GetHSpread() const { return HSpread; }
	float GetVSpread() const { return VSpread; }
	bool HasAnySpread() const { return HSpread > 0.0 || VSpread > 0.0; }
	bool NonTrivialSpread() const
	{
		return HSpread > TRIVIAL_WEAPON_SPREAD || VSpread > TRIVIAL_WEAPON_SPREAD;
	}

	bool SpreadMutable() const
	{
		return !(Mask & BIO_WPM_HSPREAD) || !(Mask & BIO_WPM_VSPREAD);
	}

	void SetSpread(float hSpr, float vSpr)
	{
		if (!(Mask & BIO_WPM_HSPREAD))
			hSpread = hSpr;
		if (!(Mask & BIO_WPM_VSPREAD))
			vSpread = vSpr;
	}

	bool AngleMutable() const { return !(Mask & BIO_WPM_ANGLE); }
	bool PitchMutable() const { return !(Mask & BIO_WPM_PITCH); }

	void ModifyAngleAndPitch(float ang, float ptch)
	{
		if (!(Mask & BIO_WPM_ANGLE))
			Angle += ang;
		if (!(Mask & BIO_WPM_PITCH))
			Pitch += ptch;
	}

	void SetAngleAndPitch(float ang, float ptch)
	{
		if (!(Mask & BIO_WPM_ANGLE))
			Angle = ang;
		if (!(Mask & BIO_WPM_PITCH))
			Pitch = ptch;
	}

	bool UsesSecondaryAmmo() const { return SecondaryAmmo; }
	void SetToPrimaryAmmo() { SecondaryAmmo = false; }
	void SetToSecondaryAmmo() { SecondaryAmmo = true; }

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

	void SetFireSound(sound fireSnd) { FireSound = fireSnd; }
	sound GetFireSound() const { return FireSound; }

	string GetTagAsQualifier() const
	{
		return String.Format("(\c[Yellow]%s\c[White])", Tag);
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

	BIO_WeaponPipelineMask GetRestrictions() const { return Mask; }
	bool HasRestriction(BIO_WeaponPipelineMask m) const { return Mask & m; }
	void SetRestrictions(BIO_WeaponPipelineMask msk) { Mask = msk; }
	void AddRestriction(BIO_WeaponPipelineMask msk) { Mask |= msk; }

	void ToString(in out Array<string> readout, uint index, bool alone) const
	{
		if (Tag.Length() > 1)
			readout.Push("\c[Yellow]" .. Tag .. "\c[MidGrey]:");

		if (FireFunctor != null)
		{
			FireFunctor.ToString(readout, AsConst(), Defaults);
			readout[readout.Size() - 1].AppendFormat(ToStringAppends[TOSTREX_FIREFUNC]);
			if (FireType is 'BIO_Projectile')
				GetDefaultByType((Class<BIO_Projectile>)(FireType)).ToString(readout);
			else if (FireType is 'BIO_FastProjectile')
				GetDefaultByType((Class<BIO_FastProjectile>)(FireType)).ToString(readout);
			else if (FireType is 'BIO_Puff')
				GetDefaultByType((Class<BIO_Puff>)(FireType)).ToString(readout);
			else if (FireType is 'BIO_RailSpawn')
				GetDefaultByType((Class<BIO_RailSpawn>)(FireType)).ToString(readout);
		}

		if (Damage != null)
			readout.Push(Damage.ToString(Defaults.Damage));

		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
			ProjTravelFunctors[i].ToString(readout);
		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			HitDamageFunctors[i].ToString(readout);
		for (uint i = 0; i < FTDeathFunctors.Size(); i++)
			FTDeathFunctors[i].ToString(readout);

		// Don't report spread unless it's non-trivial (weapons with 
		// true projectiles are likely to have little to no spread)
		if (HSpread > TRIVIAL_WEAPON_SPREAD)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				HSpread, Defaults.HSpread, invert: true);

			string hSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAPTOSTR_HSPREAD"),
				fontColor, HSpread);

			readout.Push(hSpreadStr);
		}

		if (VSpread > TRIVIAL_WEAPON_SPREAD)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				VSpread, Defaults.VSpread, invert: true);

			string vSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAPTOSTR_VSPREAD"),
				fontColor, VSpread);

			readout.Push(vSpreadStr);
		}

		for (uint i = 0; i < ReadoutExtra.Size(); i++)
			readout.Push(ReadoutExtra[i]);
	}

	static BIO_WeaponPipeline Create()
	{
		let ret = new('BIO_WeaponPipeline');
		return ret;
	}

	readOnly<BIO_WeaponPipeline> AsConst() const { return self; }
}
