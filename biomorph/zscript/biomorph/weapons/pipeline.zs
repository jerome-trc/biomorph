struct BIO_ShotData
{
	uint Pipeline;
	uint Number; // Which shot out of `Count` is this?
	uint Count; // Loaded with `BIO_WeaponPipeline::ShotCount`.
	class<Actor> Payload;
	int Damage;
	float HSpread, VSpread, Angle, Pitch;
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

	Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	Array<BIO_HitDamageFunctor> HitDamageFunctors;
	Array<BIO_PayloadDeathFunctor> PayloadDeathFunctors;

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

				for (uint i = 0; i < HitDamageFunctors.Size(); i++)
					HitDamageFunctors[i].InvokePuff(puff);
				for (uint i = 0; i < PayloadDeathFunctors.Size(); i++)
					PayloadDeathFunctors[i].InvokePuff(puff);

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnPuffFired(weap, puff);
			}
			else if (output is 'BIO_Projectile')
			{
				let sProj = BIO_Projectile(output);
				sProj.SetDamage(shotData.Damage);
				sProj.HitDamageFunctors.Copy(HitDamageFunctors);
				sProj.ProjTravelFunctors.Copy(ProjTravelFunctors);
				sProj.PayloadDeathFunctors.Copy(PayloadDeathFunctors);

				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnSlowProjectileFired(weap, sProj);
			}
			else if (output is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(output);
				fProj.SetDamage(shotData.Damage);
				fProj.HitDamageFunctors.Copy(HitDamageFunctors);
				fProj.PayloadDeathFunctors.Copy(PayloadDeathFunctors);

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

		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
		{
			ret.ProjTravelFunctors.Push(ProjTravelFunctors[i].Copy());
		}

		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
		{
			ret.HitDamageFunctors.Push(HitDamageFunctors[i].Copy());
		}

		for (uint i = 0; i < PayloadDeathFunctors.Size(); i++)
		{
			ret.PayloadDeathFunctors.Push(PayloadDeathFunctors[i].Copy());
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
		
		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
			ProjTravelFunctors[i].GetDamageValues(damages);
		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			HitDamageFunctors[i].GetDamageValues(damages);
		for (uint i = 0; i < PayloadDeathFunctors.Size(); i++)
			PayloadDeathFunctors[i].GetDamageValues(damages);
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

		for (uint i = 0; i < PayloadDeathFunctors.Size(); i++)
		{
			PayloadDeathFunctors[i].SetDamageValues(damages);
			damages.Delete(0, PayloadDeathFunctors[i].DamageValueCount());
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
		for (uint i = 0; i < ProjTravelFunctors.Size(); i++)
			if (ProjTravelFunctors[i].GetClass() == type)
				return ProjTravelFunctors[i];

		return null;
	}

	BIO_HitDamageFunctor GetHitDamageFunctor(class<BIO_HitDamageFunctor> type)
	{
		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			if (HitDamageFunctors[i].GetClass() == type)
				return HitDamageFunctors[i];

		return null;
	}

	BIO_PayloadDeathFunctor GetPayloadDeathFunctor(class<BIO_PayloadDeathFunctor> type) const
	{
		for (uint i = 0; i < PayloadDeathFunctors.Size(); i++)
			if (PayloadDeathFunctors[i].GetClass() == type)
				return PayloadDeathFunctors[i];

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
			PayloadDeathFunctors.Push(func);
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

class BIO_WeaponPipelineBuilder play
{
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create()
	{
		let ret = new('BIO_WeaponPipelineBuilder');
		ret.Pipeline = new('BIO_WeaponPipeline');
		return ret;
	}

	BIO_WeaponPipelineBuilder Bullet(class<Actor> payload = 'BIO_Bullet',
		uint shotCount = 1, int accuracyType = BULLET_ALWAYS_SPREAD)
	{
		let fireFunc = new('BIO_FireFunc_Bullet');
		Pipeline.FireFunctor = fireFunc;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = shotCount;

		switch (accuracyType)
		{
		case BULLET_ALWAYS_SPREAD:
			fireFunc.AlwaysSpread();
			break;
		case BULLET_ALWAYS_ACCURATE:
			fireFunc.AlwaysAccurate();
			break;
		case BULLET_FIRST_ACCURATE:
			fireFunc.FirstAccurate();
			break;
		default:
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Invalid bullet accuracy type given: %d"
				"(defaulting to always spread)");
			fireFunc.AlwaysSpread();
			break;
		}
		
		return self;
	}

	BIO_WeaponPipelineBuilder Projectile(class<Actor> payload, uint shotCount = 1)
	{
		Pipeline.FireFunctor = new('BIO_FireFunc_Projectile');
		Pipeline.Payload = payload;
		Pipeline.ShotCount = shotCount;
		return self;
	}

	BIO_WeaponPipelineBuilder Rail(class<Actor> payload, uint shotCount = 1,
		color color1 = 0, color color2 = 0, ERailFlags flags = RGF_NONE,
		double maxDiff = 0.0, double range = 0.0, int duration = 0,
		double sparsity = 1.0, double driftSpeed = 1.0, int spiralOffset = 270)
	{
		Pipeline.FireFunctor = new('BIO_FireFunc_Rail').Setup(
			color1, color2, flags, maxDiff, range,
			duration, sparsity, driftSpeed, spiralOffset);

		Pipeline.Payload = payload;
		Pipeline.ShotCount = shotCount;

		return self;
	}

	BIO_WeaponPipelineBuilder Saw(class<Actor> payload = 'BIO_MeleeHit',
		uint hitCount = 1, float range = SAWRANGE, ESawFlags flags = 0,
		sound fullSound = "weapons/sawfull", sound hitSound = "weapons/sawhit")
	{
		let fireFunc = new('BIO_FireFunc_Saw');
		fireFunc.Range = range;
		fireFunc.FullSound = fullSound;
		fireFunc.HitSound = hitSound;
		fireFunc.Flags = flags;
		Pipeline.FireFunctor = fireFunc;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = hitCount;
		return self;
	}

	BIO_WeaponPipelineBuilder Punch(class<Actor> payload = 'BIO_MeleeHit',
		uint hitCount = 1, float range = DEFMELEERANGE,
		ECustomPunchFlags flags = CPF_NONE, sound hitSound = "*fist",
		sound missSound = "")
	{
		let fireFunc = new('BIO_FireFunc_Punch');
		Pipeline.FireFunctor = fireFunc;
		fireFunc.Range = range;
		fireFunc.HitSound = hitSound;
		fireFunc.MissSound = missSound;
		fireFunc.Flags = flags;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = hitCount;

		return self;
	}

	BIO_WeaponPipelineBuilder BFGSpray(int rayCount = 40,
		int minRayDmg = 49, int maxRayDmg = 87)
	{
		Pipeline.FireFunctor = new('BIO_FireFunc_BFGSpray');
		Pipeline.Payload = 'BIO_BFGExtra';
		Pipeline.ShotCount = rayCount;
		return self;
	}

	BIO_WeaponPipelineBuilder X1D3Damage(int multi)
	{
		Pipeline.Damage = new('BIO_DmgFunc_XTimesRand').Init(multi, 1, 3);
		return self;
	}

	BIO_WeaponPipelineBuilder X1D8Damage(int multi)
	{
		Pipeline.Damage = new('BIO_DmgFunc_XTimesRand').Init(multi, 1, 8);
		return self;
	}

	BIO_WeaponPipelineBuilder RandomDamage(int min, int max)
	{
		Pipeline.Damage = new('BIO_DmgFunc_Rand').Init(min, max);
		return self;
	}

	BIO_WeaponPipelineBuilder XPlusRandDamage(int base, int minRand, int maxRand)
	{
		Pipeline.Damage = new('BIO_DmgFunc_XPlusRand').Init(base, minRand, maxRand);
		return self;
	}

	BIO_WeaponPipelineBuilder XTimesRandomDamage(int multi, int minRand, int maxRand)
	{
		Pipeline.Damage = new('BIO_DmgFunc_XTimesRand').Init(multi, minRand, maxRand);
		return self;
	}

	BIO_WeaponPipelineBuilder SingleDamage(int dmg)
	{
		Pipeline.Damage = new('BIO_DmgFunc_Single').Init(dmg);
		return self;
	}

	BIO_WeaponPipelineBuilder NoDamage()
	{
		Pipeline.Damage = new('BIO_DmgFunc_Noop');
		return self;
	}

	BIO_WeaponPipelineBuilder Spread(float horiz, float vert)
	{
		Pipeline.HSpread = horiz;
		Pipeline.VSpread = vert;
		return self;
	}

	BIO_WeaponPipelineBuilder AngleAndPitch(float angle, float pitch)
	{
		Pipeline.Angle = angle;
		Pipeline.Pitch = pitch;
		return self;
	}

	BIO_WeaponPipelineBuilder Splash(int damage, int radius,	
		EExplodeFlags flags = XF_HURTSOURCE, int fullDmgDistance = 0)
	{
		Pipeline.SetSplash(damage, radius, flags, fullDmgDistance);
		return self;
	}

	BIO_WeaponPipelineBuilder AddBFGSpray(int rayCount = 40,
		int minRayDmg = 49, int maxRayDmg = 87)
	{
		Pipeline.PayloadDeathFunctors.Push(
			BIO_PLDF_BFGSpray.Create(rayCount, minRayDmg, maxRayDmg));
		return self;
	}

	BIO_WeaponPipelineBuilder FireSound(sound fireSound)
	{
		Pipeline.FireSound = fireSound;
		return self;
	}

	BIO_WeaponPipelineBuilder Alert(double maxDist, int flags = 0)
	{
		Pipeline.MaxAlertDistance = maxDist;
		Pipeline.AlertFlags = flags;
		return self;
	}

	BIO_WeaponPipelineBuilder SecondaryAmmo(bool secondary)
	{
		Pipeline.SecondaryAmmo = secondary;
		return self;
	}

	BIO_WeaponPipelineBuilder Tag(string tag)
	{
		Pipeline.Tag = tag;
		return self;
	}

	BIO_WeaponPipeline Build() const
	{
		if (Pipeline.FireFunctor == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed without a fire functor.");
		}

		if (Pipeline.Damage == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed without a damage functor.");
		}

		if (Pipeline.Payload == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"A weapon pipeline was constructed without a payload.");
		}

		if (Pipeline.ShotCount == 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed with a shot count of 0.");
		}

		return Pipeline;
	}
}
