class BIO_WeaponPipelineBuilder play
{
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create(BIO_WeaponPipeline existing = null)
	{
		let ret = new('BIO_WeaponPipelineBuilder');

		if (existing == null)
		{
			ret.Pipeline = new('BIO_WeaponPipeline');
			ret.Pipeline.AmmoUseMulti = 1;
			ret.Pipeline.Flags = BIO_WPF_PRIMARYAMMO;
		}
		else
		{
			ret.Pipeline = existing;
		}

		return ret;
	}

	BIO_WeaponPipelineBuilder Bullet(
		class<Actor> payload = 'BIO_Bullet',
		uint shotCount = 1,
		double range = PLAYERMISSILERANGE, // 8192.0
		class<BIO_FireFunc_Bullet> subclass = 'BIO_FireFunc_Bullet'
	)
	{
		let func = BIO_FireFunc_Bullet(new(subclass));
		func.Range = range;

		Pipeline.FireFunctor = func;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = shotCount;

		return self;
	}

	BIO_WeaponPipelineBuilder Projectile(
		class<Actor> payload,
		uint shotCount = 1,
		double spawnOffs_xy = 0.0,
		int spawnHeight = 0,
		class<BIO_FireFunc_Projectile> subclass = 'BIO_FireFunc_Projectile'
	)
	{
		let func = BIO_FireFunc_Projectile(new(subclass));
		func.SpawnOffsXY = spawnOffs_xy;
		func.SpawnHeight = 0;

		Pipeline.FireFunctor = func;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = shotCount;

		return self;
	}

	BIO_WeaponPipelineBuilder Rail(
		class<Actor> payload,
		uint shotCount = 1,
		ERailFlags flags = RGF_NONE,
		int pierceLimit = 0,
		double range = PLAYERMISSILERANGE, // 8192.0
		int offsex_xy = 0,
		int offset_z = 0,
		// Purely aesthetic parameters
		color color1 = 0,
		color color2 = 0,
		double maxDiff = 0.0,
		int particleDuration = 0,
		double particleSparsity = 1.0,
		double particleDriftSpeed = 1.0,
		int spiralOffset = 270,
		class<BIO_FireFunc_Rail> subclass = 'BIO_FireFunc_Rail'
	)
	{
		let func = BIO_FireFunc_Rail(new(subclass));
		func.Flags = flags;
		func.PierceLimit = Max(0, pierceLimit);
		func.Range = range;

		func.Color1 = color1;
		func.Color2 = color2;
		func.ParticleDuration = particleDuration;
		func.SpiralOffset = spiralOffset;
		func.MaxDiff = maxDiff;
		func.ParticleSparsity = particleSparsity;
		func.ParticleDriftSpeed = particleDriftSpeed;
		func.SpiralOffset = spiralOffset;

		Pipeline.FireFunctor = func;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = shotCount;

		return self;
	}

	BIO_WeaponPipelineBuilder Saw(
		class<Actor> payload = 'BIO_MeleeHit',
		uint hitCount = 1,
		float range = SAWRANGE,
		ESawFlags flags = 0,
		sound fullSound = "weapons/sawfull",
		sound hitSound = "weapons/sawhit",
		class<BIO_FireFunc_Saw> subclass = 'BIO_FireFunc_Saw'
	)
	{
		let func = BIO_FireFunc_Saw(new(subclass));
		func.Range = range;
		func.FullSound = fullSound;
		func.HitSound = hitSound;
		func.Flags = flags;

		Pipeline.FireFunctor = func;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = hitCount;

		return self;
	}

	BIO_WeaponPipelineBuilder Punch(
		class<Actor> payload = 'BIO_MeleeHit',
		uint hitCount = 1,
		float range = DEFMELEERANGE,
		ECustomPunchFlags flags = CPF_NONE,
		sound hitSound = "bio/punch/hit/0",
		sound missSound = "",
		class<BIO_FireFunc_Punch> subclass = 'BIO_FireFunc_Punch'
	)
	{
		let fireFunc = BIO_FireFunc_Punch(new(subclass));
		Pipeline.FireFunctor = fireFunc;
		fireFunc.Range = range;
		fireFunc.HitSound = hitSound;
		fireFunc.MissSound = missSound;
		fireFunc.Flags = flags;
		Pipeline.Payload = payload;
		Pipeline.ShotCount = hitCount;

		return self;
	}

	BIO_WeaponPipelineBuilder BFGSpray(
		int rayCount = 40,
		double cone = 90.0,
		double vertAutoaimRange = 32.0,
		double range = 16.0 * 64.0,
		bool hurtSource = false,
		class<BIO_FireFunc_BFGSpray> subclass = 'BIO_FireFunc_BFGSpray'
	)
	{
		let func = BIO_FireFunc_BFGSpray(new(subclass));
		func.Range = range;
		func.HurtSource = hurtSource;

		Pipeline.FireFunctor = func;
		Pipeline.Payload = 'BIO_BFGExtra';
		Pipeline.ShotCount = rayCount;
		Pipeline.HSpread = cone;
		Pipeline.Pitch = vertAutoaimRange;

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
		let func = new('BIO_DmgBase_XTimesRand');
		func.Multiplier = multi;
		func.MinRandom = 1;
		func.MaxRandom = 3;
		Pipeline.DamageBase = func;
		return self;
	}

	BIO_WeaponPipelineBuilder X1D8Damage(int multi)
	{
		let func = new('BIO_DmgBase_XTimesRand');
		func.Multiplier = multi;
		func.MinRandom = 1;
		func.MaxRandom = 8;
		Pipeline.DamageBase = func;
		return self;
	}

	BIO_WeaponPipelineBuilder RandomDamage(int min, int max)
	{
		let func = new('BIO_DmgBase_Range');
		func.Minimum = min;
		func.Maximum = max;
		Pipeline.DamageBase = func;
		return self;
	}

	BIO_WeaponPipelineBuilder XPlusRandDamage(int base, int minRand, int maxRand)
	{
		let func = new('BIO_DmgBase_XPlusRand');
		func.Baseline = base;
		func.MinRandom = minRand;
		func.MaxRandom = maxRand;
		Pipeline.DamageBase = func;
		return self;
	}

	BIO_WeaponPipelineBuilder XTimesRandomDamage(int multi, int minRand, int maxRand)
	{
		let func = new('BIO_DmgBase_XTimesRand');
		func.Multiplier = multi;
		func.MinRandom = minRand;
		func.MaxRandom = maxRand;
		Pipeline.DamageBase = func;
		return self;
	}

	BIO_WeaponPipelineBuilder SingleDamage(int dmg)
	{
		let func = new('BIO_DmgBase_Single');
		func.Value = dmg;
		Pipeline.DamageBase = func;
		return self;
	}

	BIO_WeaponPipelineBuilder NoDamage()
	{
		Pipeline.DamageBase = new('BIO_DmgBase_Noop');
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

	BIO_WeaponPipelineBuilder Splash(
		int damage,
		int radius,	
		EExplodeFlags flags = XF_HURTSOURCE,
		int fullDmgDistance = 0
	)
	{
		Pipeline.SetSplash(damage, radius, flags, fullDmgDistance);
		return self;
	}

	BIO_WeaponPipelineBuilder AddBFGSpray(
		int rayCount = 40,
		int minRayDmg = 49,
		int maxRayDmg = 87
	)
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

	BIO_WeaponPipelineBuilder AmmoUseMulti(uint multi)
	{
		Pipeline.AmmoUseMulti = Clamp(multi, 0, 255);
		return self;
	}

	BIO_WeaponPipelineBuilder UseNoAmmo()
	{
		Pipeline.Flags &= ~(BIO_WPF_PRIMARYAMMO | BIO_WPF_SECONDARYAMMO);
		return self;
	}

	BIO_WeaponPipelineBuilder AddFlag(BIO_WeaponPipelineFlags flag)
	{
		Pipeline.Flags |= flag;
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

		if (Pipeline.DamageBase == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"A weapon pipeline was constructed without a damage base functor.");
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
