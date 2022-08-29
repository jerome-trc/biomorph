struct BIO_DamageOutput
{
	int Current, Minimum, Maximum;
}

struct BIO_ShotData
{
	uint Pipeline;
	uint Number; // Which shot out of `Count` is this?
	uint Count; // Loaded with `BIO_WeaponPipeline::ShotCount`.
	class<Actor> Payload;
	int Damage;
	float HSpread, VSpread, Angle, Pitch;
}

struct BIO_PayloadFunctorTuple
{
	// Not applicable to puffs and `FastProjectile`s.
	Array<BIO_ProjTravelFunctor> Travel;
	Array<BIO_HitDamageFunctor> HitDamage;
	Array<BIO_PayloadDeathFunctor> OnDeath;
}

enum BIO_WeaponPipelineFlags
{
	BIO_WPF_NONE = 0,
	BIO_WPF_PRIMARYAMMO = 1 << 0,
	BIO_WPF_SECONDARYAMMO = 1 << 1
}

class BIO_WeaponPipeline play
{
	string Tag;

	BIO_WeaponPipelineFlags Flags;
	uint AmmoUseMulti;

	BIO_FireFunctor FireFunctor;
	class<Actor> Payload;
	uint ShotCount;
	BIO_DamageBaseFunctor DamageBase;
	Array<BIO_DamageEffect> DamageEffects;
	float HSpread, VSpread, Angle, Pitch;

	int AlertFlags;
	double MaxAlertDistance;
	sound FireSound;

	BIO_PayloadFunctorTuple PayloadFunctors;

	void Invoke(BIO_Weapon weap, uint pipelineIndex)
	{
		BIO_ShotData shotData;
		shotData.Pipeline = pipelineIndex;
		shotData.Count = ShotCount;

		for (uint i = 0; i < weap.Affixes.Size(); i++)
			weap.Affixes[i].BeforeAllShots(weap, shotData);

		for (uint i = 0; i < ShotCount; i++)
		{
			shotData.Number = i;
			shotData.Payload = Payload;
			shotData.Damage = ComputeDamage(true);
			shotData.HSpread = HSpread;
			shotData.VSpread = VSpread;
			shotData.Angle = Angle;
			shotData.Pitch = Pitch;

			for (uint i = 0; i < weap.Affixes.Size(); i++)
				weap.Affixes[i].BeforeEachShot(weap, shotData);

			Actor output = FireFunctor.Invoke(weap, shotData);

			if (output is 'BIO_Puff') // Might be of `Payload`, might be `FakePuff`
			{
				let puff = BIO_Puff(output);

				for (uint i = 0; i < PayloadFunctors.HitDamage.Size(); i++)
					PayloadFunctors.HitDamage[i].InvokePuff(puff);
				for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
					PayloadFunctors.OnDeath[i].InvokePuff(puff);

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnPuffFired(weap, puff);
			}
			else if (output is 'BIO_Projectile')
			{
				let sProj = BIO_Projectile(output);
				sProj.SetDamage(shotData.Damage);
				sProj.Pipeline = self;

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnSlowProjectileFired(weap, sProj);
			}
			else if (output is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(output);
				fProj.SetDamage(shotData.Damage);
				fProj.Pipeline = self;

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnFastProjectileFired(weap, fProj);
			}
		}

		weap.Owner.A_AlertMonsters(MaxAlertDistance, AlertFlags);
	}

	BIO_WeaponPipeline Copy() const
	{
		let ret = new('BIO_WeaponPipeline');
	
		ret.Flags = Flags;

		ret.FireFunctor = FireFunctor.Copy();
		ret.Payload = Payload;
		ret.DamageBase = DamageBase.Copy();

		for (uint i = 0; i < DamageEffects.Size(); i++)
			ret.DamageEffects.Push(DamageEffects[i].Copy());

		ret.HSpread = HSpread;
		ret.VSpread = VSpread;
		ret.Angle = Angle;
		ret.Pitch = Pitch;

		ret.AlertFlags = AlertFlags;
		ret.MaxAlertDistance = MaxAlertDistance;

		ret.FireSound = FireSound;

		for (uint i = 0; i < PayloadFunctors.Travel.Size(); i++)
			ret.PayloadFunctors.Travel.Push(PayloadFunctors.Travel[i].Copy());
		for (uint i = 0; i < PayloadFunctors.HitDamage.Size(); i++)
			ret.PayloadFunctors.HitDamage.Push(PayloadFunctors.HitDamage[i].Copy());
		for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
			ret.PayloadFunctors.OnDeath.Push(PayloadFunctors.OnDeath[i].Copy());

		return ret;
	}

	bool CanFireProjectiles() const
	{
		return FireFunctor != null && (FireFunctor.Capabilities() & BIO_FFC_PROJECTILE);
	}

	bool CanFirePuffs() const
	{
		return FireFunctor != null && (FireFunctor.Capabilities() & BIO_FFC_PUFF);
	}

	bool CanFireRails() const
	{
		return FireFunctor != null && (FireFunctor.Capabilities() & BIO_FFC_RAIL);
	}

	bool IsMelee() const
	{
		return FireFunctor is 'BIO_FireFunc_Melee';
	}

	int, int, int BaseDamage() const
	{
		int ret1 = -1, ret2 = -1, ret3 = -1;
		[ret1, ret2, ret3] = DamageBase.Invoke();
		return ret1, ret2, ret3;
	}

	int ComputeDamage(bool directHit) const
	{
		BIO_DamageOutput dmg;
		[dmg.Current, dmg.Minimum, dmg.Maximum] = DamageBase.Invoke();

		for (uint i = 0; i < DamageEffects.Size(); i++)
		{
			if (!DamageEffects[i].HitOnly && !directHit)
				continue;

			DamageEffects[i].Invoke(dmg);
		}

		return dmg.Current;
	}

	int, int, int ComputeDamageTuple(bool directHit) const
	{
		BIO_DamageOutput dmg;
		[dmg.Current, dmg.Minimum, dmg.Maximum] = DamageBase.Invoke();

		for (uint i = 0; i < DamageEffects.Size(); i++)
		{
			if (!DamageEffects[i].HitOnly && !directHit)
				continue;

			DamageEffects[i].Invoke(dmg);
		}

		return dmg.Current, dmg.Minimum, dmg.Maximum;
	}

	int ApplyDamageEffects(
		int baseDamage, int minDamage, int maxDamage,
		bool directHit
	) const
	{
		BIO_DamageOutput dmg;
		dmg.Current = baseDamage;
		dmg.Minimum = minDamage;
		dmg.Maximum = maxDamage;

		for (uint i = 0; i < DamageEffects.Size(); i++)
		{
			if (!DamageEffects[i].HitOnly && !directHit)
				continue;

			DamageEffects[i].Invoke(dmg);
		}

		return dmg.Current;
	}

	int GetMinDamage(bool directHit) const
	{
		int c = -1, mn = -1, mx = -1;
		[c, mn, mx] = ComputeDamageTuple(directHit);
		return mn;
	}

	int GetMaxDamage(bool directHit) const
	{
		int c = -1, mn = -1, mx = -1;
		[c, mn, mx] = ComputeDamageTuple(directHit);
		return mx;
	}

	bool DealsAnyHitDamage() const
	{
		return GetMinDamage(true) > 0;
	}

	BIO_PLDF_Explode GetSplashFunctor() const
	{
		return BIO_PLDF_Explode(GetPayloadDeathFunctor('BIO_PLDF_Explode'));
	}

	BIO_ProjTravelFunctor GetProjTravelFunctor(class<BIO_ProjTravelFunctor> type)
	{
		for (uint i = 0; i < PayloadFunctors.Travel.Size(); i++)
			if (PayloadFunctors.Travel[i].GetClass() == type)
				return PayloadFunctors.Travel[i];

		return null;
	}

	BIO_HitDamageFunctor GetHitDamageFunctor(class<BIO_HitDamageFunctor> type)
	{
		for (uint i = 0; i < PayloadFunctors.HitDamage.Size(); i++)
			if (PayloadFunctors.HitDamage[i].GetClass() == type)
				return PayloadFunctors.HitDamage[i];

		return null;
	}

	BIO_PayloadDeathFunctor GetPayloadDeathFunctor(class<BIO_PayloadDeathFunctor> type) const
	{
		for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
			if (PayloadFunctors.OnDeath[i].GetClass() == type)
				return PayloadFunctors.OnDeath[i];

		return null;
	}

	void DeletePayloadDeathFunctors(
		class<BIO_PayloadDeathFunctor> type,
		bool subclass = false
	)
	{
		for (uint i = PayloadFunctors.OnDeath.Size() - 1; i >= 0; i--)
		{
			if (subclass)
			{
				if (PayloadFunctors.OnDeath[i] is type)
					PayloadFunctors.OnDeath.Delete(i);
			}
			else
			{
				if (PayloadFunctors.OnDeath[i].GetClass() == type)
					PayloadFunctors.OnDeath.Delete(i);
			}
		}
	}

	bool DealsAnySplashDamage() const
	{
		let func = GetSplashFunctor();
		return func != null && func.Damage > 0 && func.Radius > 0;
	}

	int CombinedSplashDamage() const
	{
		int ret = 0;

		for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
		{
			let expl = BIO_PLDF_Explode(PayloadFunctors.OnDeath[i]);

			if (expl == null)
				continue;

			ret += expl.Damage;
		}

		return ret;
	}

	void SetSplash(int damage, int radius,
		EExplodeFlags flags = XF_HURTSOURCE, int fullDmgDistance = 0)
	{
		let func = GetSplashFunctor();

		if (func == null)
		{
			func = BIO_PLDF_Explode.Create(damage, radius, flags, fullDmgDistance);
			PayloadFunctors.OnDeath.Push(func);
		}
		else
		{
			func.Damage = damage;
			func.Radius = radius;
			func.Flags = flags;
			func.FullDamageDistance = fullDmgDistance;
		}
	}

	float CombinedSpread() const { return HSpread + VSpread; }

	bool IsScattering() const
	{
		return ShotCount > 3 && CombinedSpread() >= 5.5;
	}

	bool UsesPrimaryAmmo() const { return Flags & BIO_WPF_PRIMARYAMMO; }
	bool UsesSecondaryAmmo() const { return Flags & BIO_WPF_SECONDARYAMMO; }

	string GetTagAsQualifier(string parenthClr = "\c[White]") const
	{
		if (Tag.Length() < 1)
			return "";
		else
			return String.Format("%s(\c[Yellow]%s%s)", parenthClr, Tag, parenthClr);
	}

	readOnly<BIO_WeaponPipeline> AsConst() const { return self; }
}
