extend class BIO_Weapon
{
	Actor BIO_FireProjectile(class<Actor> proj_t, double angle = 0,
		double spawnOfs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle - 90.0;
		Vector2 ofs = AngleToVector(ang, spawnOfs_xy);
		double shootangle = Owner.Angle;

		if (flags & FPF_AIMATANGLE) shootangle += angle;

		// Temporarily adjusts the pitch
		double playerPitch = Owner.Pitch;
		Owner.Pitch += pitch;
		let misl = Owner.SpawnPlayerMissile(proj_t, shootangle, ofs.X, ofs.Y,
			spawnHeight, t, false, (flags & FPF_NOAUTOAIM) != 0);
		Owner.Pitch = playerPitch;

		// Automatic handling of seeker missiles
		if (misl != null)
		{
			if (flags & FPF_TRANSFERTRANSLATION)
				misl.Translation = Translation;
			if (t.LineTarget && !t.Unlinked && misl.bSeekerMissile)
				misl.Tracer = t.LineTarget;

			if (!(flags & FPF_AIMATANGLE))
			{
				// This original implementation is to aim straight ahead and then offset
				// the angle from the resulting direction. 
				misl.Angle += angle;
				misl.VelFromAngle(misl.Vel.XY.Length());
			}
		}
		return misl;
	}

	/* `angle` and `pitch` are added to the weapon owner's angle and pitch.	
		This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/
	Actor BIO_FireBullet(
		class<Actor> puff_t,
		int damage,
		double angle,
		double pitch,
		double range = PLAYERMISSILERANGE // 8192.0
	) const
	{
		Actor ret = null; int realDmg = -1;
		double bAngle = Owner.Angle + angle;
		double bSlope = Owner.BulletSlope() + pitch;
		FTranslatedLineTarget t;

		[ret, realDmg] = Owner.LineAttack(
			bAngle,
			range,
			bSlope,
			damage,
			'Hitscan', // TODO: Use `puff_t`'s default damage type?
			puff_t,
			LAF_NONE,
			t
		);

		if (ret == null)
		{
			FLineTraceData ltd;
			Owner.LineTrace(bAngle, range, bSlope, TRF_NONE, data: ltd);
			ret = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
			ret.DamageType = GetDefaultByType(puff_t).DamageType;
			ret.Tracer = t.LineTarget;
		}

		ret.SetDamage(realDmg);
		return ret;
	}

	// `angle` and `pitch` are added to the weapon owner's angle and pitch.
	Actor BIO_RailAttack(
		class<Actor> puff_t,
		class<Actor> spawn_t,
		int damage,
		int offset_xy,
		int offset_z,
		double range = PLAYERMISSILERANGE, // 8192.0
		double angle = 0.0,
		double pitch = 0.0,
		ERailFlags flags = RGF_NONE,
		int pierceLimit = 0,
		// Purely aesthetic parameters
		color color1 = 0,
		color color2 = 0,
		double maxDiff = 0.0,
		int duration = 0,
		double sparsity = 1.0,
		double driftSpeed = 1.0,
		int spiralOffset = 270
	) const
	{
		FRailParams p;
		p.Puff = puff_t;
		p.SpawnClass = spawn_t;
		p.Damage = damage;
		p.Offset_XY = offset_xy;
		p.Offset_Z = offset_z;
		p.Distance = range;
		p.AngleOffset = angle;
		p.PitchOffset = pitch;
		p.Flags = flags | RGF_SILENT;
		p.Limit = pierceLimit;
		p.Color1 = color1;
		p.Color2 = color2;
		p.MaxDiff = maxDiff;
		p.Duration = duration;
		p.Sparsity = sparsity;
		p.Drift = driftSpeed;
		Owner.RailAttack(p);

		FLineTraceData ltd;

		Owner.LineTrace(
			Owner.Angle + angle,
			range,
			Owner.BulletSlope() + pitch,
			p.Limit == 0 ? TRF_THRUACTORS : TRF_NONE,
			offset_z,
			offsetside: offset_xy,
			data: ltd
		);

		ltd.HitLocation.Z += 32.0; // (Rat): ???
		let ret = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
		ret.Tracer = ltd.HitActor;
		ret.SetDamage(damage);
		return ret;
	}

	/* 	This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/ 
	Actor BIO_Punch(in out BIO_ShotData shotData, double range = DEFMELEERANGE,
		float lifesteal = 0.0, sound hitSound = 0, sound missSound = "",
		ECustomPunchFlags flags = CPF_NONE)
	{
		FTranslatedLineTarget t;

		shotData.Angle = Owner.Angle + Random2[CWPunch]() * (5.625 / 256);
		shotData.Pitch = Owner.AimLineAttack(shotData.Angle, range, t, 0.0, ALF_CHECK3D);
		
		Actor ret = null;
		int actualDmg = -1;

		ELineAttackFlags puffFlags = LAF_ISMELEEATTACK |
			((flags & CPF_NORANDOMPUFFZ) ? LAF_NORANDOMPUFFZ : 0);

		[ret, actualDmg] = Owner.LineAttack(shotData.Angle, range, shotData.Pitch,
			shotData.Damage, 'Melee', shotData.Payload, puffFlags, t);

		if (t.LineTarget == null)
		{
			Owner.A_StartSound(missSound, CHAN_AUTO);
			return null;
		}

		Owner.A_StartSound(hitSound, CHAN_AUTO);

		if (!(flags & CPF_NOTURN))
		{
			// Turn to face target
			Owner.Angle = t.AngleFromSource;
		}

		if (flags & CPF_PULLIN) Owner.bJustAttacked = true;

		if (!t.LineTarget.bDontDrain)
			ApplyLifeSteal(lifesteal, actualDmg);

		if (ret == null)
		{
			ret = Spawn('BIO_FakePuff', t.LineTarget.Pos);
			ret.SetDamage(actualDmg);
			ret.DamageType = 'Melee';
			ret.Tracer = t.LineTarget;
		}

		return ret;
	}

	void BIO_Saw(sound fullSound, sound hitSound, int dmg, class<Actor> puff_t,
		ESawFlags flags, float range, float lifestealPercent)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle + 2.8125 * (Random2[Saw]() / 255.0);
		double slope = Owner.AimLineAttack(ang, range, t) *
			(Random2[Saw]() / 255.0);

		Actor puff = null;
		int actualDmg = 0;
		[puff, actualDmg] = Owner.LineAttack(ang, range, slope, dmg,
			'Melee', puff_t, 0, t);

		if (!t.LineTarget)
		{
			if ((flags & SF_RANDOMLIGHTMISS) && (Random[Saw]() > 64))
				Player.ExtraLight = !Player.ExtraLight;
			
			Owner.A_StartSound(fullSound, CHAN_WEAPON);
			return;
		}

		if (flags & SF_RANDOMLIGHTHIT)
		{
			int randVal = Random[Saw]();

			if (randVal < 64)
				Player.ExtraLight = 0;
			else if (randVal < 160)
				Player.ExtraLight = 1;
			else
				Player.ExtraLight = 2;
		}

		if (!t.LineTarget.bDontDrain)
			ApplyLifeSteal(lifestealPercent, actualDmg);

		Owner.A_StartSound(hitSound, CHAN_WEAPON);

		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double angleDiff = DeltaAngle(Owner.Angle, t.AngleFromSource);

			if (angleDiff < 0.0)
			{
				if (angleDiff < -4.5)
					Owner.Angle = t.AngleFromSource + 90.0 / 21;
				else
					Owner.Angle -= 4.5;
			}
			else
			{
				if (angleDiff > 4.5)
					Owner.Angle = t.AngleFromSource - 90.0 / 21;
				else
					Owner.Angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			bJustAttacked = true;
	}

	// A specialized variation on `A_BFGSpray()`, for use by
	// `BIO_FireFunc_BFGSpray()`. Shoots only one ray and returns a fake puff.
	Actor BIO_BFGSpray(in out BIO_ShotData shotData, double distance = 16.0 * 64.0,
		double vrange = 32.0, EBFGSprayFlags flags = BFGF_NONE)
	{
		FTranslatedLineTarget t;
		double an = Owner.Angle - shotData.Angle / 2 + shotData.Angle /
			shotData.Count * shotData.Number;

		Owner.AimLineAttack(an, distance, t, vrange);

		if (t.LineTarget == null) return null;

		Actor
			spray = Spawn(shotData.Payload, t.LineTarget.Pos +
			(0, 0, t.LineTarget.Height / 4), ALLOW_REPLACE),
			ret = Spawn('BIO_FakePuff', t.LineTarget.Pos);

		int dmgFlags = 0;
		name dmgType = 'BFGSplash';

		if (spray != null)
		{
			// [XA] Don't hit oneself unless we say so.
			if ((spray.bMThruSpecies &&
				Owner.GetSpecies() == t.LineTarget.GetSpecies()) || 
				(!(flags & BFGF_HURTSOURCE) && Owner == t.LineTarget)) 
			{
				// [MC] Remove it because technically, the spray isn't trying to "hit" them.
				spray.Destroy(); 
				return null;
			}

			if (spray.bPuffGetsOwner) spray.Target = Owner;
			if (spray.bFoilInvul) dmgFlags |= DMG_FOILINVUL;
			if (spray.bFoilBuddha) dmgFlags |= DMG_FOILBUDDHA;
			dmgType = spray.DamageType;
		}

		int newdam = t.LineTarget.DamageMObj(
			ret, Owner, shotData.Damage, dmgType,
			dmgFlags | DMG_USEANGLE, t.AngleFromSource);
		ret.SetDamage(newDam);
		ret.DamageType = 'BFGSplash';
		ret.Tracer = t.LineTarget;
		t.TraceBleed(newdam > 0 ? newdam : shotData.Damage, Owner);
		return ret;
	}
}
