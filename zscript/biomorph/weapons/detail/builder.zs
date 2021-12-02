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
		int fireCount, int minDamage, int maxDamage, float hSpread, float vSpread)
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

		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder BasicBulletPipeline(Class<Actor> fireType,
		int fireCount, int minDamage, int maxDamage, float hSpread, float vSpread,
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
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();
		CheckDamageFunctorRestricted();

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
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();
		CheckDamageFunctorRestricted();

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
		CheckFireFunctorRestricted();
		CheckFireTypeRestricted();
		CheckFireCountRestricted();
		CheckDamageFunctorRestricted();
		CheckSpreadRestricted();

		let fireFunc = new('BIO_FireFunc_Projectile');
		Pipeline.SetFireFunctor(fireFunc);
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		let sprayFunctor = new('BIO_FTDF_BFGSpray');
		sprayFunctor.RayCount = rayCount;
		sprayFunctor.MinDamage = minRayDmg;
		sprayFunctor.MaxDamage = maxRayDmg;
		Pipeline.PushFiredThingDeathFunctor(sprayFunctor);

		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder Projectile(Class<Actor> fireType, int fireCount)
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
		int fireCount = 1,
		int accuracyType = BULLET_ALWAYS_SPREAD)
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
		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDmg, maxDmg);
		Pipeline.SetDamageFunctor(dmgFunc);
		return self;
	}

	BIO_WeaponPipelineBuilder X1D3Damage(int baseline)
	{
		CheckDamageFunctorRestricted();
		let dmgFunc = new('BIO_DmgFunc_1DX');
		dmgFunc.CustomSet(baseline, 3);
		Pipeline.SetDamageFunctor(dmgFunc);
		return self;
	}

	BIO_WeaponPipelineBuilder X1D8Damage(int baseline)
	{
		CheckDamageFunctorRestricted();
		let dmgFunc = new('BIO_DmgFunc_1Dx');
		dmgFunc.CustomSet(baseline, 8);
		Pipeline.SetDamageFunctor(dmgFunc);
		return self;
	}

	BIO_WeaponPipelineBuilder SingleDamage(int dmg)
	{
		CheckDamageFunctorRestricted();
		let dmgFunc = new('BIO_DmgFunc_Single');
		dmgFunc.CustomSet(dmg);
		Pipeline.SetDamageFunctor(dmgFunc);
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

	BIO_WeaponPipelineBuilder Splash(int damage, int radius)
	{
		CheckSplashRestricted();
		Pipeline.SetSplash(damage, radius);
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
		Pipeline.SetSound(fireSound);
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
