struct BIO_ShotData
{
	uint Pipeline;
	uint Number; // Which shot out of `Count` is this?
	uint Count; // Loaded with `BIO_WeaponPipeline::ShotCount`.
	class<Actor> Payload;
	int Damage;
	float HSpread, VSpread, Angle, Pitch;
}

class BIO_PayloadFunctorTuple
{
	// Not applicable to puffs and `FastProjectile`s.
	Array<BIO_ProjTravelFunctor> Travel;
	Array<BIO_HitDamageFunctor> HitDamage;
	Array<BIO_PayloadDeathFunctor> OnDeath;
}

class BIO_WeaponPipeline play
{
	string Tag;

	bool SecondaryAmmo;

	BIO_FireFunctor FireFunctor;
	class<Actor> Payload;
	uint ShotCount;
	BIO_DamageFunctor Damage;
	float HSpread, VSpread, Angle, Pitch;

	int AlertFlags;
	double MaxAlertDistance;
	sound FireSound;

	BIO_PayloadFunctorTuple PayloadFunctors; // Should never be null.

	void Invoke(BIO_Weapon weap, uint pipelineIndex,
		uint fireFactor = 1, float spreadFactor = 1.0)
	{
		uint sc = ShotCount * fireFactor;

		BIO_ShotData shotData;
		shotData.Pipeline = pipelineIndex;
		shotData.Count = sc;

		for (uint i = 0; i < weap.Affixes.Size(); i++)
			weap.Affixes[i].BeforeAllShots(weap, shotData);

		for (uint i = 0; i < sc; i++)
		{
			shotData.Number = i;
			shotData.Payload = Payload;
			shotData.Damage = Damage.Invoke();
			shotData.HSpread = HSpread * spreadFactor;
			shotData.VSpread = VSpread * spreadFactor;
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
				sProj.Functors = PayloadFunctors;

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnSlowProjectileFired(weap, sProj);
			}
			else if (output is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(output);
				fProj.SetDamage(shotData.Damage);
				fProj.Functors = PayloadFunctors;

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnFastProjectileFired(weap, fProj);
			}
		}

		weap.Owner.A_AlertMonsters(MaxAlertDistance, AlertFlags);
	}

	BIO_WeaponPipeline Copy() const
	{
		let ret = new('BIO_WeaponPipeline');
	
		ret.SecondaryAmmo = SecondaryAmmo;

		ret.FireFunctor = FireFunctor.Copy();
		ret.Payload = Payload;
		ret.Damage = Damage.Copy();
		ret.HSpread = HSpread;
		ret.VSpread = VSpread;
		ret.Angle = Angle;
		ret.Pitch = Pitch;

		ret.AlertFlags = AlertFlags;
		ret.MaxAlertDistance = MaxAlertDistance;

		ret.FireSound = FireSound;
		ret.PayloadFunctors = new('BIO_PayloadFunctorTuple');

		for (uint i = 0; i < PayloadFunctors.Travel.Size(); i++)
		{
			ret.PayloadFunctors.Travel.Push(PayloadFunctors.Travel[i].Copy());
		}

		for (uint i = 0; i < PayloadFunctors.HitDamage.Size(); i++)
		{
			ret.PayloadFunctors.HitDamage.Push(PayloadFunctors.HitDamage[i].Copy());
		}

		for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
		{
			ret.PayloadFunctors.OnDeath.Push(PayloadFunctors.OnDeath[i].Copy());
		}

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

	bool DealsAnyDamage() const
	{
		if (Damage == null)
			return false;

		return GetMinDamage() > 0;
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
		
		for (uint i = 0; i < PayloadFunctors.Travel.Size(); i++)
			PayloadFunctors.Travel[i].GetDamageValues(damages);
		for (uint i = 0; i < PayloadFunctors.HitDamage.Size(); i++)
			PayloadFunctors.HitDamage[i].GetDamageValues(damages);
		for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
			PayloadFunctors.OnDeath[i].GetDamageValues(damages);
	}

	int GetMinDamage() const { return Damage.MinOutput(); }
	int GetMaxDamage() const { return Damage.MaxOutput(); }
	int GetAverageDamage(uint sampleSize = 200) const
	{
		return Damage.AverageOutput(sampleSize);
	}

	void SetDamageValues(in out Array<int> damages)
	{
		Damage.SetValues(damages);
		damages.Delete(0, Damage.ValueCount());

		FireFunctor.SetDamageValues(damages);
		damages.Delete(0, FireFunctor.DamageValueCount());

		for (uint i = 0; i < PayloadFunctors.Travel.Size(); i++)
		{
			PayloadFunctors.Travel[i].SetDamageValues(damages);
			damages.Delete(0, PayloadFunctors.Travel[i].DamageValueCount());
		}

		for (uint i = 0; i < PayloadFunctors.HitDamage.Size(); i++)
		{
			PayloadFunctors.HitDamage[i].SetDamageValues(damages);
			damages.Delete(0, PayloadFunctors.HitDamage[i].DamageValueCount());
		}

		for (uint i = 0; i < PayloadFunctors.OnDeath.Size(); i++)
		{
			PayloadFunctors.OnDeath[i].SetDamageValues(damages);
			damages.Delete(0, PayloadFunctors.OnDeath[i].DamageValueCount());
		}
	}

	void AddToAllDamageValues(int dmg)
	{
		Array<int> vals;
		GetDamageValues(vals);

		for (uint i = 0; i < vals.Size(); i++)
			vals[i] += dmg;

		SetDamageValues(vals);
	}

	void MultiplyAllDamage(float multi)
	{
		Array<int> vals;
		GetDamageValues(vals);

		for (uint i = 0; i < vals.Size(); i++)
		{
			vals[i] = Max(float(vals[i]) * multi, 1.0);
		}

		SetDamageValues(vals);
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

	bool DealsAnySplashDamage() const
	{
		let func = GetSplashFunctor();
		return func != null && func.Damage > 0 && func.Radius > 0;
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

	string GetTagAsQualifier(string parenthClr = "\c[White]") const
	{
		if (Tag.Length() < 1)
			return "";
		else
			return String.Format("%s(\c[Yellow]%s%s)", parenthClr, Tag, parenthClr);
	}

	readOnly<BIO_WeaponPipeline> AsConst() const { return self; }
}
