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

	BIO_WeaponPipelineBuilder BasicProjectilePipeline(Class<Actor> fireType,
		uint fireCount, int minDamage, int maxDamage, float hSpread, float vSpread)
	{
		if (fireType is 'BIO_Puff')
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Fire type class %s is a puff, but was passed to "
				"`BasicProjectilePipeline()`. (%s)",
				fireType.GetClassName(), WeaponType.GetClassName());

		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();
		CheckDamageFunctorRestricted();
		CheckSpreadRestricted();

		Pipeline.SetFireFunctor(new('BIO_FireFunc_Projectile'));
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_Rand')
			.CustomSet(minDamage, maxDamage));

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder BasicBulletPipeline(Class<Actor> fireType,
		uint fireCount, int minDamage, int maxDamage, float hSpread, float vSpread,
		int accuracyType = BULLET_ALWAYS_SPREAD)
	{
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();
		CheckDamageFunctorRestricted();
		CheckSpreadRestricted();

		let fireFunc = new('BIO_FireFunc_Bullet');
		fireFunc.AlwaysSpread();

		Pipeline.SetFireFunctor(fireFunc);
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_Rand')
			.CustomSet(minDamage, maxDamage));

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
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

	BIO_WeaponPipelineBuilder Projectile(Class<Actor> fireType, int fireCount = 1)
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

	BIO_WeaponPipelineBuilder X1D3Damage(int baseline)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_1DX').CustomSet(baseline, 3));
		return self;
	}

	BIO_WeaponPipelineBuilder X1D8Damage(int baseline)
	{
		CheckDamageFunctorRestricted();
		Pipeline.SetDamageFunctor(new('BIO_DmgFunc_1Dx').CustomSet(baseline, 8));
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
		EExplodeFlags flags = XF_NONE)
	{
		CheckSplashRestricted();
		Pipeline.SetSplash(damage, radius);
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
