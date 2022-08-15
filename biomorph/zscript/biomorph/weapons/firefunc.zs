enum BIO_FireFunctorCapabilities : uint8
{
	BIO_FFC_NONE = 0,
	BIO_FFC_PUFF = 1 << 0,
	BIO_FFC_PROJECTILE = 1 << 1,
	BIO_FFC_RAIL = 1 << 2,
	BIO_FFC_ALL = uint8.MAX
}

class BIO_FireFunctor play abstract
{
	abstract Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const;

	virtual void GetDamageValues(in out Array<int> vals) const {}
	virtual void SetDamageValues(in out Array<int> vals) {}

	uint DamageValueCount() const
	{
		Array<int> dmgVals;
		GetDamageValues(dmgVals);
		return dmgVals.Size();
	}

	abstract string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
	) const;

	// If a category of payload can be handled by this functor, include its bit.
	// Used to determine from the outside if a new payload may be compatible.
	abstract BIO_FireFunctorCapabilities Capabilities() const;

	abstract BIO_FireFunctor Copy() const;

	readOnly<BIO_FireFunctor> AsConst() const { return self; }
}

class BIO_FireFunc_Projectile : BIO_FireFunctor
{
	double SpawnOffsXY;
	int SpawnHeight;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		return weap.BIO_FireProjectile(
			shotData.Payload,
			angle: shotData.Angle + FRandom(-shotData.HSpread, shotData.HSpread),
			spawnOfs_xy: SpawnOffsXY, spawnHeight: SpawnHeight,
			pitch: shotData.Pitch + FRandom(-shotData.VSpread, shotData.VSpread)
		);
	}

	BIO_FireFunc_Projectile Init(double spawnOffs_xy = 0.0, int spawnH = 0)
	{
		SpawnOffsXY = spawnOffs_xy;
		SpawnHeight = spawnH;
		return self;
	}

	override string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
	) const
	{
		uint sc = pipeline.ShotCount;
		class<Actor> pl = pipeline.Payload;

		return String.Format(
			StringTable.Localize("$BIO_FIREFUNC_GENERAL"),
			BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc,
			pl != pipelineDef.Payload ? Biomorph.CRESC_STATMODIFIED : Biomorph.CRESC_STATDEFAULT,
			BIO_Utils.PayloadTag(pl, sc)
		);
	}

	override BIO_FireFunctor Copy() const
	{
		let ret = new('BIO_FireFunc_Projectile');
		ret.SpawnOffsXY = SpawnOffsXY;
		ret.SpawnHeight = SpawnHeight;
		return ret;
	}

	override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_PROJECTILE;
	}
}

const BULLET_ALWAYS_SPREAD = -1;
const BULLET_ALWAYS_ACCURATE = 0;
const BULLET_FIRST_ACCURATE = 1;

class BIO_FireFunc_Bullet : BIO_FireFunctor
{
	private int AccuracyType, Flags;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		return weap.BIO_FireBullet(shotData.HSpread, shotData.VSpread,
			AccuracyType, shotData.Damage, shotData.Payload, Flags);
	}

	void AlwaysSpread() { AccuracyType = BULLET_ALWAYS_SPREAD; }
	void AlwaysAccurate() { AccuracyType = BULLET_ALWAYS_ACCURATE; }
	void FirstAccurate() { AccuracyType = BULLET_FIRST_ACCURATE; }

	BIO_FireFunc_Bullet Setup(int accType = BULLET_ALWAYS_SPREAD, int flagArg = 0)
	{
		AccuracyType = accType;
		Flags = flagArg;
		return self;
	}

	override string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
		) const
	{
		uint sc = pipeline.ShotCount;
		class<Actor> pl = pipeline.Payload;

		return String.Format(
			StringTable.Localize("$BIO_FIREFUNC_PROJECTILE"),
			BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc,
			pl != pipelineDef.Payload ?
				Biomorph.CRESC_STATMODIFIED :
				Biomorph.CRESC_STATDEFAULT,
			BIO_Utils.PayloadTag(pl, sc)
		);
	}

	override BIO_FireFunctor Copy() const
	{
		let ret = new('BIO_FireFunc_Bullet');
		ret.AccuracyType = AccuracyType;
		ret.Flags = Flags;
		return ret;
	}

	override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_PUFF;
	}
}

class BIO_FireFunc_Rail : BIO_FireFunctor
{
	color Color1, Color2;
	ERailFlags Flags;
	int ParticleDuration, SpiralOffset, PierceLimit;
	double MaxDiff, Range, ParticleSparsity, ParticleDriftSpeed;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		class<Actor> puff_t = null, spawnClass = null;

		if (shotData.Payload is 'BIO_RailPuff')
		{
			puff_t = shotData.Payload;
			spawnClass = GetDefaultByType(
				(class<BIO_RailPuff>)(shotData.Payload)).SpawnClass;
		}
		else if (shotData.Payload is 'BIO_RailSpawn')
		{
			spawnClass = shotData.Payload;
			puff_t = GetDefaultByType(
				(class<BIO_RailSpawn>)(shotData.Payload)).PuffType;
		}

		weap.BIO_RailAttack(shotData.Damage,
			spawnOffs_xy: shotData.Angle,
			color1: Color1,
			color2: Color2,
			flags: Flags,
			maxDiff: MaxDiff,
			puff_t: puff_t,
			spread_xy: shotData.HSpread,
			spread_z: shotData.VSpread,
			range: Range,
			duration: ParticleDuration,
			sparsity: ParticleSparsity,
			driftSpeed: ParticleDriftSpeed,
			spawnClass: spawnClass,
			spawnOffs_z: shotData.Pitch
		);

		return null;
	}

	BIO_FireFunc_Rail Setup(color color1 = 0, color color2 = 0,
		ERailFlags flags = RGF_NONE, double maxDiff = 0.0, double range = 0.0,
		int duration = 0, double sparsity = 1.0, double driftSpeed = 1.0,
		int spiralOffs = 270)
	{
		self.Color1 = color1;
		self.Color2 = color2;
		self.Flags = flags;
		self.MaxDiff = maxDiff;
		self.Range = range;
		self.ParticleDuration = duration;
		self.ParticleSparsity = sparsity;
		self.ParticleDriftSpeed = driftSpeed;
		self.SpiralOffset = spiralOffs;

		return self;
	}

	override string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
	) const
	{
		class<Actor> pl = pipeline.Payload, puff_t = null, spawnClass = null;
		bool defaultPuff = true, defaultSpawn = true;
		uint sc = pipeline.ShotCount;

		if (pl is 'BIO_RailPuff')
		{
			puff_t = pl;
			spawnClass = GetDefaultByType((class<BIO_RailPuff>)(pl)).SpawnClass;
			defaultPuff = puff_t == pipelineDef.Payload;
		}
		else if (pl is 'BIO_RailSpawn')
		{
			spawnClass = pl;
			puff_t = GetDefaultByType((class<BIO_RailSpawn>)(pl)).PuffType;
			defaultSpawn = spawnClass == pipelineDef.Payload;
		}

		string ret = "";

		if (puff_t != null && spawnClass != null)
		{
			ret = String.Format(
				StringTable.Localize("$BIO_FIREFUNC_RAIL"),
				BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc,
				defaultPuff ? Biomorph.CRESC_STATDEFAULT : Biomorph.CRESC_STATMODIFIED,
				BIO_Utils.PayloadTag(puff_t, sc),
				defaultSpawn ? Biomorph.CRESC_STATDEFAULT : Biomorph.CRESC_STATMODIFIED,
				BIO_Utils.PayloadTag(spawnClass, sc)
			);
		}
		else if (puff_t == null)
		{
			ret = String.Format(
				StringTable.Localize("$BIO_FIREFUNC_RAIL_NOPUFF"),
				BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc,
				defaultSpawn ? Biomorph.CRESC_STATDEFAULT : Biomorph.CRESC_STATMODIFIED,
				BIO_Utils.PayloadTag(spawnClass, sc)
			);
		}
		else if (spawnClass == null)
		{
			ret = String.Format(
				StringTable.Localize("$BIO_FIREFUNC_RAIL_NOSPAWN"),
				BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc,
				defaultPuff ? Biomorph.CRESC_STATDEFAULT : Biomorph.CRESC_STATMODIFIED,
				BIO_Utils.PayloadTag(puff_t, sc)
			);
		}
		else
		{
			ret = String.Format(
				StringTable.Localize("$BIO_FIREFUNC_RAIL_NOTHING"),
				BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc
			);
		}

		return ret;
	}

	override BIO_FireFunctor Copy() const
	{
		let ret = new('BIO_FireFunc_Rail');
		ret.Color1 = Color1;
		ret.Color2 = Color2;
		ret.Flags = Flags;
		ret.ParticleDuration = ParticleDuration;
		ret.SpiralOffset = SpiralOffset;
		ret.PierceLimit = PierceLimit;
		ret.MaxDiff = MaxDiff;
		ret.Range = Range;
		ret.ParticleSparsity = ParticleSparsity;
		ret.ParticleDriftSpeed = ParticleDriftSpeed;
		return ret;
	}

	override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_RAIL;
	}
}

class BIO_FireFunc_Melee : BIO_FireFunctor abstract
{
	float Range, Lifesteal;

	override BIO_FireFunctor Copy() const
	{
		let ret = BIO_FireFunc_Melee(new(GetClass()));
		ret.Range = Range;
		ret.Lifesteal = Lifesteal;
		return ret;
	}
}

class BIO_FireFunc_Punch : BIO_FireFunc_Melee
{
	ECustomPunchFlags Flags;
	sound HitSound, MissSound;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		return weap.BIO_Punch(shotData, Range, Lifesteal, HitSound, MissSound, Flags);
	}

	override string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
	) const
	{
		return StringTable.Localize("$BIO_FIREFUNC_PUNCH");
	}

	override BIO_FireFunctor Copy() const
	{
		let ret = BIO_FireFunc_Punch(super.Copy());
		ret.Flags = Flags;
		ret.HitSound = HitSound;
		ret.MissSound = MissSound;
		return ret;
	}

	override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_PUFF;
	}
}

class BIO_FireFunc_Saw : BIO_FireFunc_Melee
{
	ESawFlags Flags;
	sound FullSound, HitSound;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		weap.BIO_Saw(FullSound, HitSound, shotData.Damage,
			shotData.Payload, Flags, Range, Lifesteal);
		return null;
	}

	override string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
	) const
	{
		return StringTable.Localize("$BIO_FIREFUNC_SAW");
	}

	override BIO_FireFunctor Copy() const
	{
		let ret = BIO_FireFunc_Saw(super.Copy());
		ret.Flags = Flags;
		ret.FullSound = FullSound;
		ret.HitSound = HitSound;
		return ret;
	}

	override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_PUFF;
	}
}

class BIO_FireFunc_BFGSpray : BIO_FireFunctor
{
	final override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		return weap.BIO_BFGSpray(shotData);
	}

	final override string Summary(
		readOnly<BIO_WeaponPipeline> pipeline,
		readOnly<BIO_WeaponPipeline> pipelineDef
	) const
	{
		uint sc = pipeline.ShotCount;
		class<Actor> pl = pipeline.Payload;

		return String.Format(
			StringTable.Localize("$BIO_FIREFUNC_BFGSPRAY"),
			BIO_Utils.StatFontColor(sc, pipelineDef.ShotCount), sc
		);
	}

	override BIO_FireFunctor Copy() const { return new('BIO_FireFunc_BFGSpray'); }

	final override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_NONE;
	}
}
