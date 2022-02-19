class BIO_WeaponPipelineBuilder play
{
	private Class<BIO_Weapon> WeaponType;
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create()
	{
		let ret = new('BIO_WeaponPipelineBuilder');
		ret.Pipeline = BIO_WeaponPipeline.Create();
		return ret;
	}

	BIO_WeaponPipelineBuilder Punch(Class<Actor> fireType = 'BIO_MeleeHit',
		uint hitCount = 1, float range = DEFMELEERANGE,
		ECustomPunchFlags flags = CPF_NONE, sound hitSound = "*fist",
		sound missSound = "")
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();

		let fireFunc = new('BIO_FireFunc_Punch');
		Pipeline.SetFireFunctor(fireFunc);
		fireFunc.Range = range;
		fireFunc.HitSound = hitSound;
		fireFunc.MissSound = missSound;
		fireFunc.Flags = flags;
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(hitCount);
		
		return self;
	}

	BIO_WeaponPipelineBuilder Saw(Class<Actor> fireType = 'BIO_MeleeHit',
		uint hitCount = 1, float range = SAWRANGE, ESawFlags flags = 0,
		sound fullSound = "weapons/sawfull", sound hitSound = "weapons/sawhit")
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();

		let fireFunc = new('BIO_FireFunc_Saw');
		fireFunc.Range = range;
		fireFunc.FullSound = fullSound;
		fireFunc.HitSound = hitSound;
		fireFunc.Flags = flags;
		Pipeline.SetFireFunctor(fireFunc);
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(hitCount);

		return self;
	}

	BIO_WeaponPipelineBuilder BFGPipeline(Class<Actor> fireType = 'BIO_BFGBall',
		uint fireCount = 1, int rayCount = 40, int minDamage = 100, int maxDamage = 800,
		int minRayDmg = 49, int maxRayDmg = 87, float hSpread = 0.4, float vSpread = 0.4)
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();
		CheckDamageFunctorRestricted();
		CheckSpreadRestricted();

		let fireFunc = new('BIO_FireFunc_Projectile');
		Pipeline.SetFireFunctor(fireFunc);
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		Pipeline.PushFiredThingDeathFunctor(
			BIO_FTDF_BFGSpray.Create(rayCount, minRayDmg, maxRayDmg));

		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_Rand')
			.CustomSet(minDamage, maxDamage));

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder Projectile(Class<Actor> fireType, uint fireCount = 1)
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();

		Pipeline.SetFireFunctor(new('BIO_FireFunc_Projectile'));
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);
		return self;
	}

	BIO_WeaponPipelineBuilder Bullet(Class<Actor> fireType = 'BIO_Bullet',
		uint fireCount = 1, int accuracyType = BULLET_ALWAYS_SPREAD)
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();

		let fireFunc = new('BIO_FireFunc_Bullet');

		Pipeline.SetFireFunctor(fireFunc);
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);
		
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

	BIO_WeaponPipelineBuilder Rail(Class<Actor> fireType, uint fireCount = 1,
		color color1 = 0, color color2 = 0, ERailFlags flags = RGF_NONE,
		double maxDiff = 0.0, double range = 0.0, int duration = 0,
		double sparsity = 1.0, double driftSpeed = 1.0, int spiralOffset = 270)
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();

		Pipeline.SetFireFunctor(new('BIO_FireFunc_Rail').Setup(
			color1, color2, flags, maxDiff, range,
			duration, sparsity, driftSpeed, spiralOffset));
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		return self;
	}

	BIO_WeaponPipelineBuilder FireFunctor(BIO_FireFunctor func)
	{
		CheckFireFunctorRestricted();
		Pipeline.SetFireFunctor(func);
		return self;
	}

	BIO_WeaponPipelineBuilder FireType(Class<Actor> fireType)
	{
		CheckFireTypeRestricted();
		Pipeline.SetFireType(fireType);
		return self;
	}

	BIO_WeaponPipelineBuilder FireCount(int fireCount)
	{
		CheckFireCountRestricted();
		Pipeline.SetFireCount(fireCount);
		return self;
	}

	BIO_WeaponPipelineBuilder DamageFunctor(BIO_DamageFunctor func)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(func);
		return self;
	}

	BIO_WeaponPipelineBuilder BasicDamage(int minDmg, int maxDmg)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_Rand')
			.CustomSet(minDmg, maxDmg));
		return self;
	}

	BIO_WeaponPipelineBuilder X1D3Damage(int multi)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(
			new('BIO_DmgFunc_XTimesRand').CustomSet(multi, 1, 3));
		return self;
	}

	BIO_WeaponPipelineBuilder X1D8Damage(int multi)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(
			new('BIO_DmgFunc_XTimesRand').CustomSet(multi, 1, 8));
		return self;
	}

	BIO_WeaponPipelineBuilder XTimesRandomDamage(int multi, int minRand, int maxRand)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(
			new('BIO_DmgFunc_XTimesRand').CustomSet(multi, minRand, maxRand));
		return self;
	}

	BIO_WeaponPipelineBuilder SingleDamage(int dmg)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_Single').CustomSet(dmg));
		return self;
	}

	BIO_WeaponPipelineBuilder NoDamage()
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_Noop'));
		return self;
	}

	BIO_WeaponPipelineBuilder Spread(float horiz, float vert)
	{
		CheckSpreadRestricted();
		Pipeline.SetSpread(horiz, vert);
		return self;
	}

	BIO_WeaponPipelineBuilder AngleAndPitch(float angle, float pitch)
	{
		Pipeline.SetAngleAndPitch(angle, pitch);
		return self;
	}

	BIO_WeaponPipelineBuilder Splash(int damage, int radius,	
		EExplodeFlags flags = XF_HURTSOURCE, int fullDmgDistance = 0)
	{
		CheckSplashRestricted();
		Pipeline.SetSplash(damage, radius, flags, fullDmgDistance);
		return self;
	}

	BIO_WeaponPipelineBuilder Shrapnel(int count, int damage)
	{
		CheckSplashRestricted();
		Pipeline.SetShrapnel(count, damage);
		return self;
	}

	BIO_WeaponPipelineBuilder Lifesteal(float lifesteal)
	{
		let ff = Pipeline.GetFireFunctor();

		if (!(ff.GetClass() is 'BIO_FireFunc_Melee'))
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to apply lifesteal to a non-melee fire functor (type: %s).",
				ff.GetClassName());
			return self;
		}

		BIO_FireFunc_Melee(ff).Lifesteal = lifesteal;
		return self;
	}

	BIO_WeaponPipelineBuilder UseSecondaryAmmo()
	{
		Pipeline.SetToSecondaryAmmo();
		return self;
	}

	BIO_WeaponPipelineBuilder Alert(double maxDist, int flags = 0)
	{
		Pipeline.SetAlertStats(maxDist, flags);
		return self;
	}

	BIO_WeaponPipelineBuilder FireSound(sound fireSound)
	{
		Pipeline.SetFireSound(fireSound);
		return self;
	}

	BIO_WeaponPipelineBuilder AssociateFirstFireTime()
	{
		Pipeline.AssociateFireTimes(1 << 0);
		return self;
	}

	BIO_WeaponPipelineBuilder AssociateFireTime(uint index)
	{
		if (index >= 8)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to associate invalid fire time %d with a pipeline.",
				index);
		}
		else
			Pipeline.AssociateFireTimes(1 << index);
		
		return self;
	}

	BIO_WeaponPipelineBuilder Associate2FireTimes(uint i1, uint i2)
	{
		if (i1 >= 8 || i2 >= 8)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to associate one or more invalid fire times "
				"with a pipeline: %d, %d", i1, i2);
		}
		else
			Pipeline.AssociateFireTimes(1 << i1 | 1 << i2);

		return self;
	}

	BIO_WeaponPipelineBuilder Associate3FireTimes(uint i1, uint i2, uint i3)
	{
		if (i1 >= 8 || i2 >= 8 || i3 >= 8)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to associate one or more invalid fire times "
				"with a pipeline: %d, %d, %d", i1, i2, i3);
		}
		else
			Pipeline.AssociateFireTimes(1 << i1 | 1 << i2 | 1 << i3);

		return self;
	}

	BIO_WeaponPipelineBuilder Associate4FireTimes(uint i1, uint i2, uint i3, uint i4)
	{
		if (i1 >= 8 || i2 >= 8 || i3 >= 8 || i4)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to associate one or more invalid fire times "
				"with a pipeline: %d, %d, %d, %d", i1, i2, i3, i4);
		}
		else
			Pipeline.AssociateFireTimes(1 << i1 | 1 << i2 | 1 << i3 | 1 << i4);

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

	BIO_WeaponPipelineBuilder Tag(string tag)
	{
		Pipeline.Tag = tag;
		return self;
	}

	BIO_WeaponPipelineBuilder TagAsPrimary()
	{
		Pipeline.Tag = BIO_Utils.Capitalize(
			StringTable.Localize("$BIO_PRIMARY"));
		return self;
	}

	BIO_WeaponPipelineBuilder TagAsSecondary()
	{
		Pipeline.Tag = BIO_Utils.Capitalize(
			StringTable.Localize("$BIO_SECONDARY"));
		return self;
	}

	BIO_WeaponPipelineBuilder TagAsTertiary()
	{
		Pipeline.Tag = BIO_Utils.Capitalize(
			StringTable.Localize("$BIO_TERTIARY"));
		return self;
	}

	BIO_WeaponPipelineBuilder TagAsQuaternary()
	{
		Pipeline.Tag = BIO_Utils.Capitalize(
			StringTable.Localize("$BIO_QUATERNARY"));
		return self;
	}

	// Argument can be non-localized.
	BIO_WeaponPipelineBuilder Obituary(string obit)
	{
		Pipeline.Obituary = obit;
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
		if (Pipeline.GetFireFunctorConst() == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed without a fire functor.");
		}

		if (Pipeline.GetDamageFunctorConst() == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed without a damage functor.");
		}

		if (Pipeline.GetFireType() == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"A weapon pipeline was constructed without a fire type.");
		}

		if (Pipeline.GetFireCount() == 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed with a fire count of 0.");
		}

		return Pipeline;
	}

	// Sanity checks and warnings ==============================================

	private void CheckFireFunctorRestricted() const
	{
		if (Pipeline.HasRestriction(BIO_WPM_FIREFUNCTOR))
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Failed to modify fire functor of `%s` due to a restriction.",
				WeaponType.GetClassName());
		}
	}

	private void CheckFireTypeRestricted() const
	{
		if (Pipeline.HasRestriction(BIO_WPM_FIRETYPE))
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Failed to modify fire type of `%s` due to a restriction.",
				WeaponType.GetClassName());
		}
	}

	private void CheckFireCountRestricted() const
	{
		if (Pipeline.HasRestriction(BIO_WPM_FIRECOUNT))
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Failed to modify fire count of `%s` due to a restriction.",
				WeaponType.GetClassName());
		}
	}

	private void CheckDamageFunctorRestricted() const
	{
		if (Pipeline.HasRestriction(BIO_WPM_DAMAGEFUNCTOR))
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Failed to modify damage functor of `%s` due to a restriction.",
				WeaponType.GetClassName());
		}
	}

	private void CheckSpreadRestricted() const
	{
		if (Pipeline.HasRestriction(BIO_WPM_HSPREAD) ||
			Pipeline.HasRestriction(BIO_WPM_VSPREAD))
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Failed to modify spread of `%s` due to a restriction.",
				WeaponType.GetClassName());
		}
	}

	private void CheckSplashRestricted() const
	{
		if (Pipeline.HasRestriction(BIO_WPM_SPLASH))
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Failed to modify splash data of `%s` due to a restriction.",
				WeaponType.GetClassName());
		}
	}
}
