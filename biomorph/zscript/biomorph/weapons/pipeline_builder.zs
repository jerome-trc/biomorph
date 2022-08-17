class BIO_WeaponPipelineBuilder play
{
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create(BIO_WeaponPipeline existing = null)
	{
		let ret = new('BIO_WeaponPipelineBuilder');

		if (existing == null)
		{
			ret.Pipeline = new('BIO_WeaponPipeline');
			ret.Pipeline.PayloadFunctors = new('BIO_PayloadFunctorTuple');
			ret.Pipeline.Flags = BIO_WPF_PRIMARYAMMO;
		}
		else
		{
			ret.Pipeline = existing;
		}

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

	BIO_WeaponPipelineBuilder Projectile(
		class<Actor> payload, uint shotCount = 1,
		double spawnOffs_xy = 0.0, int spawnHeight = 0
	)
	{
		Pipeline.FireFunctor = new('BIO_FireFunc_Projectile').Init(
			spawnOffs_xy, spawnHeight
		);
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
		ECustomPunchFlags flags = CPF_NONE, sound hitSound = "bio/punch/hit/0",
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

	BIO_WeaponPipelineBuilder FireFunctor(BIO_FireFunctor func)
	{
		Pipeline.FireFunctor = func;
		return self;
	}

	BIO_WeaponPipelineBuilder Payload(class<Actor> type)
	{
		Pipeline.Payload = type;
		return self;
	}

	BIO_WeaponPipelineBuilder ShotCount(uint count)
	{
		if (count <= 0)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Attempted to a set a shot count below 1 to a weapon pipeline."
			);
		}
		else
		{
			Pipeline.ShotCount = count;
		}

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
		Pipeline.PayloadFunctors.OnDeath.Push(
			BIO_PLDF_BFGSpray.Create(rayCount, minRayDmg, maxRayDmg)
		);

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

	BIO_WeaponPipelineBuilder UsePrimaryAndSecondaryAmmo()
	{
		Pipeline.Flags |= (BIO_WPF_PRIMARYAMMO | BIO_WPF_SECONDARYAMMO);
		return self;
	}

	BIO_WeaponPipelineBuilder UsePrimaryAmmo()
	{
		Pipeline.Flags |= BIO_WPF_PRIMARYAMMO;
		Pipeline.Flags &= ~BIO_WPF_SECONDARYAMMO;
		return self;
	}

	BIO_WeaponPipelineBuilder UseSecondaryAmmo()
	{
		Pipeline.Flags |= BIO_WPF_SECONDARYAMMO;
		Pipeline.Flags &= ~BIO_WPF_PRIMARYAMMO;
		return self;
	}

	BIO_WeaponPipelineBuilder UseNoAmmo()
	{
		Pipeline.Flags &= ~(BIO_WPF_PRIMARYAMMO | BIO_WPF_SECONDARYAMMO);
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
