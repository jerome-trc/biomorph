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

	/* 	This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/
	Actor BIO_FireBullet(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, class<Actor> puff_t, EFireBulletsFlags flags = FBF_NONE,
		double range = 0.0, class<Actor> missile = null,
		double spawnHeight = 32.0, double spawnOfs_xy = 0.0)
	{
		int i = 0;
		double bAngle = 0.0, bSlope = 0.0;
		int laFlags = (flags & FBF_NORANDOMPUFFZ) ? LAF_NORANDOMPUFFZ : 0;
		FTranslatedLineTarget t;

		if (range ~== 0.0) range = PLAYERMISSILERANGE;

		if (!(flags & FBF_NOFLASH)) BIO_Player(Owner).PlayAttacking2();
		if (!(flags & FBF_NOPITCH)) bSlope = Owner.BulletSlope();

		bAngle = Owner.Angle;

		if ((numBullets == 1 && !Owner.Player.Refire) || numBullets == 0)
		{
			int damage = bulletDmg;

			Actor puff = null; int realDmg = -1;
			[puff, realDmg] = Owner.LineAttack(bAngle, range,
				bSlope, damage, 'Hitscan', puff_t, laFlags, t);
			
			if (puff == null)
			{
				FLineTraceData ltd;
				LineTrace(bAngle, range, bSlope, TRF_NONE, data: ltd);
				puff = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
				puff.DamageType = GetDefaultByType(puff_t).DamageType;
				puff.Tracer = t.LineTarget;
			}

			puff.SetDamage(realDmg);

			if (missile != null)
			{
				bool temp = false;
				double ang = Owner.Angle - 90;
				Vector2 ofs = Owner.AngleToVector(ang, spawnOfs_xy);
				Actor proj = Owner.SpawnPlayerMissile(missile, bAngle,
					ofs.X, ofs.Y, spawnHeight);

				if (proj)
				{
					if (!puff)
					{
						temp = true;
						puff = Owner.LineAttack(bAngle, range, bSlope, 0,
							'Hitscan', puff_t, laFlags | LAF_NOINTERACT, t);
					}
					Owner.AimBulletMissile(proj, puff, flags, temp, false);
					if (t.Unlinked)
					{
						// Arbitary portals will make angle and pitch calculations 
						// unreliable. So use the angle and pitch we passed instead.
						proj.Angle = bAngle;
						proj.Pitch = bSlope;
						proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
					}
				}
			}

			return puff;
		}
		else // `numBullets` -1; all bullets spread
		{
			double pAngle = bAngle;
			double slope = bSlope;

			if (flags & FBF_EXPLICITANGLE)
			{
				pAngle += spread_xy;
				slope += spread_z;
			}
			else
			{
				pAngle += spread_xy * Random2[cabullet]() / 255.;
				slope += spread_z * Random2[cabullet]() / 255.;
			}

			int damage = bulletDmg;

			Actor puff = null; int realDmg = -1;
			[puff, realDmg] = Owner.LineAttack(pAngle, range, 
				slope, damage, 'Hitscan', puff_t, laflags, t);

			if (puff == null)
			{
				FLineTraceData ltd;
				LineTrace(pAngle, range, slope, TRF_NONE, data: ltd);
				puff = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
				puff.DamageType = GetDefaultByType(puff_t).DamageType;
				puff.Tracer = t.LineTarget;
			}

			puff.SetDamage(realDmg);
			if (missile == null) return puff;

			bool temp = false;
			double ang = Owner.Angle - 90;
			Vector2 ofs = Owner.AngleToVector(ang, spawnOfs_xy);
			Actor proj = Owner.SpawnPlayerMissile(missile, bAngle, ofs.X, ofs.Y, spawnHeight);
			
			if (proj)
			{
				if (!puff)
				{
					temp = true;
					puff = Owner.LineAttack(
						bAngle, range, bSlope, 0, 'Hitscan', puff_t,
						laFlags | LAF_NOINTERACT, t);
				}
				Owner.AimBulletMissile(proj, puff, flags, temp, false);
				if (t.Unlinked)
				{
					// Arbitary portals will make angle and pitch calculations 
					// unreliable. So use the angle and pitch we passed instead.
					proj.Angle = bAngle;
					proj.Pitch = bSlope;
					proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
				}
			}

			return puff;
		}
	}

	void BIO_RailAttack(int damage, int spawnOffs_xy = 0, color color1 = 0,
		color color2 = 0, int flags = 0, double maxDiff = 0,
		class<Actor> puff_t = 'BulletPuff', double spread_xy = 0,
		double spread_z = 0, double range = 0, int duration = 0,
		double sparsity = 1.0, double driftSpeed = 1.0,
		class<Actor> spawnClass = 'None', double spawnOffs_z = 0,
		int spiraloffset = 270, int limit = 0)
	{
		if (range == 0) range = 8192;
		if (sparsity == 0) sparsity = 1.0;

		if (!(flags & RGF_EXPLICITANGLE))
		{
			spread_xy = spread_xy * Random2[CRailgun]() / 255.0;
			spread_z = spread_z * Random2[CRailgun]() / 255.0;
		}

		FRailParams p;
		p.Damage = damage;
		p.Offset_xy = spawnOffs_xy;
		p.Offset_z = spawnOffs_z;
		p.Color1 = color1;
		p.Color2 = color2;
		p.MaxDiff = maxDiff;
		p.Flags = flags | RGF_SILENT;
		p.Puff = puff_t;
		p.AngleOffset = spread_xy;
		p.PitchOffset = spread_z;
		p.Distance = range;
		p.Duration = duration;
		p.Sparsity = sparsity;
		p.Drift = driftSpeed;
		p.SpawnClass = spawnClass;
		p.SpiralOffset = spiralOffset;
		p.Limit = limit;
		Owner.RailAttack(p);
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
