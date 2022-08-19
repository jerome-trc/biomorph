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

	abstract string Description(
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

	override string Description(
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

class BIO_FireFunc_Bullet : BIO_FireFunctor
{
	double Range;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		return weap.BIO_FireBullet(
			shotData.Payload,
			shotData.Damage,
			shotData.Angle + FRandom(-shotData.HSpread, shotData.HSpread),
			shotData.Pitch + FRandom(-shotData.VSpread, shotData.VSpread),
			Range
		);
	}

	override string Description(
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
		return Create(Range);
	}

	override BIO_FireFunctorCapabilities Capabilities() const
	{
		return BIO_FFC_PUFF;
	}

	static BIO_FireFunc_Bullet Create(double range = PLAYERMISSILERANGE) // 8192.0
	{
		let ret = new('BIO_FireFunc_Bullet');
		ret.Range = range;
		return ret;
	}
}

class BIO_FireFunc_Rail : BIO_FireFunctor
{
	ERailFlags Flags;
	int PierceLimit;
	double Range;
	// Aesthetic
	color Color1, Color2;
	int ParticleDuration, SpiralOffset;
	double MaxDiff, ParticleSparsity, ParticleDriftSpeed;

	override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		class<Actor> puff_t = null, spawn_t = null;

		if (shotData.Payload is 'BIO_RailPuff')
		{
			puff_t = shotData.Payload;

			spawn_t = GetDefaultByType(
				(class<BIO_RailPuff>)(shotData.Payload)
			).SpawnClass;
		}
		else if (shotData.Payload is 'BIO_RailSpawn')
		{
			spawn_t = shotData.Payload;

			puff_t = GetDefaultByType(
				(class<BIO_RailSpawn>)(shotData.Payload)
			).PuffType;
		}

		return weap.BIO_RailAttack(
			puff_t,
			spawn_t,
			shotData.Damage,
			0.0,
			0.0,
			Range,
			shotData.Angle + FRandom(-shotData.HSpread, shotData.HSpread),
			shotData.Pitch + FRandom(-shotData.VSpread, shotData.VSpread),
			Flags,
			0,
			Color1,
			Color2,
			MaxDiff,
			ParticleDuration,
			ParticleSparsity,
			ParticleDriftSpeed,
			SpiralOffset
		);
	}

	override string Description(
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

	override string Description(
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

	override string Description(
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

// Notes:
// - Given horizontal spread is used for the cone (vanilla is 90.0 degrees).
// - Given pitch is used as a vertical auto-aim range (vanilla is 32.0).
class BIO_FireFunc_BFGSpray : BIO_FireFunctor
{
	double Range;
	bool HurtSource;

	final override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		double angle =
			weap.Owner.Angle -
			shotData.HSpread / 2 +
			shotData.HSpread /
			shotData.Count *
			shotData.Number;

		return weap.BIO_BFGSpray(
			shotData.Payload,
			shotData.Damage,
			angle + shotData.Angle,
			Range,
			shotData.Pitch,
			HurtSource
		);
	}

	final override string Description(
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
