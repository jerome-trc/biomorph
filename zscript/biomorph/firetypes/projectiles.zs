// Fast projectiles (used like puffs) ==========================================

class BIO_BulletProj : BIO_FastProjectile
{
	Default
	{
		Alpha 1.0;
		Decal 'BulletChip';
		Height 1;
		Radius 1;
		Speed 400;
		Tag "$BIO_BULLET_TAG";

		BIO_FastProjectile.MetaFlags BIO_FTMF_BALLISTIC;
		BIO_FastProjectile.PluralTag "$BIO_BULLET_TAG_PLURAL";
		BIO_FastProjectile.PuffCounterpart 'BIO_Bullet';
	}

	States
	{
	Spawn:
		TNT1 A 1;
		Loop;
	Death:
		TNT1 A 1 A_ProjectileDeath;
		Stop;
	}

	override void OnProjectileDeath()
	{
		A_SpawnItemEx('BulletPuff', flags: SXF_NOCHECKPOSITION);
	}
}

class BIO_ShotPelletProj : BIO_BulletProj
{
	Default
	{
		Tag "$BIO_SHOTPELLET_TAG";
		BIO_FastProjectile.PluralTag "$BIO_SHOTPELLET_TAG_PLURAL";
		BIO_FastProjectile.PuffCounterpart 'BIO_ShotPellet';
	}
}

class BIO_SlugProj : BIO_BulletProj
{
	Default
	{
		Tag "$BIO_SLUG_TAG";
		BIO_FastProjectile.PluralTag "$BIO_SLUG_TAG_PLURAL";
		BIO_FastProjectile.PuffCounterpart 'BIO_Slug';
	}
}

// True projectiles ============================================================

class BIO_Rocket : BIO_Projectile
{
	Default
	{
		+DEHEXPLOSION
		+RANDOMIZE
		+ROCKETTRAIL
		+ZDOOMTRANS

		DeathSound "weapons/rocklx";
		Height 8;
		Obituary "$OB_MPROCKET";
		Radius 11;
		SeeSound "weapons/rocklf";
		Speed 20;
		Tag "$BIO_ROCKET_TAG";

		BIO_Projectile.PluralTag "$BIO_ROCKET_TAG_PLURAL";
	}

	States
	{
	Spawn:
		MISL A 1 Bright A_Travel;
		Loop;
	Death:
		MISL B 8 Bright A_ProjectileDeath;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	BrainExplode:
		MISL BC 10 Bright;
		MISL D 10 A_BrainExplode;
		Stop;
	}
}

class BIO_MiniMissile : BIO_Rocket
{
	Default
	{
		Tag "$BIO_MINIMISSILE_TAG";

		Height 2;
		Radius 3;
		Scale 0.3;
		Speed 50;

		BIO_Projectile.PluralTag "$BIO_MINIMISSILE_TAG_PLURAL";
	}
}

class BIO_PlasmaBall : BIO_Projectile
{
	Default
	{
		+RANDOMIZE
		+ZDOOMTRANS

		Alpha 0.75;
		DeathSound "weapons/plasmax";
		Height 8;
		Obituary "$OB_MPPLASMARIFLE";
		Radius 13;
		RenderStyle 'Add';
		SeeSound "weapons/plasmaf";
		Speed 25;
		Tag "$BIO_PLASMABALL_TAG";

		BIO_Projectile.PluralTag "$BIO_PLASMABALL_TAG_PLURAL";
		BIO_Projectile.MetaFlags BIO_FTMF_ENERGY;
	}

	States
	{
	Spawn:
		PLSS A 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		PLSS B 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		Loop;
	Death:
		TNT1 A 0 A_ProjectileDeath;
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class BIO_BFGBall : BIO_Projectile
{
	Default
	{
		+RANDOMIZE
		+ZDOOMTRANS

		Alpha 0.75;
		DeathSound "weapons/bfgx";
		Height 8;
		Obituary "$OB_MPBFG_BOOM";
		Radius 13;
		RenderStyle 'Add';
		Speed 25;
		Tag "$BIO_BFGBALL_TAG";

		BIO_Projectile.PluralTag "$BIO_BFGBALL_TAG_PLURAL";
		BIO_Projectile.MetaFlags BIO_FTMF_ENERGY;
	}

	States
	{
	Spawn:
		BFS1 A 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		BFS1 B 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		Loop;
	Death:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_ProjectileDeath;
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class BIO_FTDF_BFGSpray : BIO_FTDeathFunctor
{
	private readOnly<BIO_FTDF_BFGSpray> Defaults;

	int RayCount, MinDamage, MaxDamage;

	static BIO_FTDF_BFGSpray Create(int rayCount, int minDmg, int maxDmg)
	{
		let ret = new('BIO_FTDF_BFGSpray'), defs = new('BIO_FTDF_BFGSpray');

		ret.RayCount = defs.RayCount = rayCount;
		ret.MinDamage = defs.MinDamage = minDmg;
		ret.MaxDamage = defs.MaxDamage = maxDmg;
		ret.Defaults = BIO_FTDF_BFGSpray(defs.AsConst());

		return ret;
	}

	final override void InvokeTrue(BIO_Projectile proj) const
	{
		proj.A_BFGSpray(numRays: RayCount,
			defDamage: Random(MinDamage, MaxDamage) * proj.DamageMultiply);
	}

	final override void InvokeFast(BIO_FastProjectile proj) const
	{
		proj.A_BFGSpray(numRays: RayCount,
			defDamage: Random(MinDamage, MaxDamage) * proj.DamageMultiply);
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		puff.A_BFGSpray(numRays: RayCount,
			defDamage: Random(MinDamage, MaxDamage) * puff.DamageMultiply);
	}

	final override void GetDamageValues(in out Array<int> damages) const
	{
		damages.Push(MinDamage);
		damages.Push(MaxDamage);
	}

	final override void SetDamageValues(in out Array<int> damages)
	{
		MinDamage = damages[0];
		MaxDamage = damages[1];
	}

	final override void ToString(in out Array<string> readout) const
	{
		string crEsc_rc = "", crEsc_min = "", crEsc_max = "";

		if (Defaults != null)
		{
			crEsc_rc = BIO_Utils.StatFontColor(RayCount, Defaults.RayCount);
			crEsc_min = BIO_Utils.StatFontColor(MinDamage, Defaults.MinDamage);
			crEsc_max = BIO_Utils.StatFontColor(MaxDamage, Defaults.MaxDamage);
		}
		else
			crEsc_rc = crEsc_min = crEsc_max = CRESC_STATMODIFIED;
		
		readout.Push(String.Format(
			StringTable.Localize("$BIO_FTDF_BFGSPRAY"),
			crEsc_rc, RayCount, crEsc_min, MinDamage, crEsc_max, MaxDamage));
	}
}

class BIO_ProxMineProj : BIO_Projectile
{
	Default
	{
		-NOGRAVITY
		-SLIDESONWALLS
		+CANBOUNCEWATER
		+NOTARGET

		BounceType 'Doom';
		BounceFactor BIO_ProxMine.BOUNCE_FACTOR;
		WallBounceFactor BIO_ProxMine.BOUNCE_FACTOR;

		Height 8;
		Radius 10;
		Scale 0.9;
		Speed 40;
		Tag "$BIO_PROXMINE_TAG";

		BIO_Projectile.PluralTag "$BIO_PROXMINE_TAG_PLURAL";
	}

	States
	{
	Spawn:
		PROX A 0;
		PROX A 1 A_CheckFloor('Planted');
		Loop;
	Planted:
		PROX A 1 A_StartSound("bio/proj/proximity/hit", CHAN_AUTO);
		PROX A 0
		{
			let mine = BIO_ProxMine(A_SpawnProjectile('BIO_ProxMine',
				flags: CMF_TRACKOWNER));

			if (mine != null)
				[mine.SplashDamage, mine.SplashRadius] = invoker.GetSplashData();
		}
		Stop;
	Death:
		PRXD A 2 Bright
		{
			A_Stop();
			bNoGravity = true;
			A_SetTranslucent(0.5, 1);
			A_ProjectileDeath();
			A_StartSound("weapons/rocklx", CHAN_AUTO, attenuation: 0.8);
		}
		PRXD BCDEFGHIJKLMNOPQRSTU 2 Bright;
		Stop;
	}
}

// TODO: Needs extra fanciness. Definitely a `DeathSound`, maybe a `SeeSound`.
class BIO_Nail : BIO_Projectile
{
	protected Actor Stickee;

	Default
	{
		Tag "$BIO_NAIL_TAG";

		DeathSound "";
		Height 8;
		Radius 11;
		Speed 60;

		BIO_Projectile.PluralTag "$BIO_NAIL_TAG_PLURAL";
	}

	States
	{
	Spawn:
		NAIL A 3 A_Travel;
		Loop;
	Death:
		TNT1 A 0 A_ProjectileDeath;
		TNT1 A 0 A_JumpIf(Tracer != null, 'Death.Stuck');
	Death.Loop:
		NAIL A 4 A_FadeTo(0.0, 0.01, true);
		Loop;
	XDeath:
		TNT1 A 0;
		TNT1 A 0 A_ProjectileDeath;
		Stop;
	}
}

class BIO_PlasmaGlobule : BIO_PlasmaBall
{
	Default
	{
		+RIPPER

		Tag "$BIO_PLASMAGLOBULE_TAG";
		Scale 0.4;

		BIO_Projectile.PluralTag "$BIO_PLASMAGLOBULE_TAG_PLURAL";
	}

	States
	{
	Spawn:
		GLOB A 3 Bright
		{
			A_Travel();
			A_SpawnItemEx('BIO_PlasmaGlobuleTrail');
		}
		Loop;
	Death:
		TNT1 A 0 A_ProjectileDeath;
		GLOB BCDE 4 Bright;
		Stop;
	}
}

// Projectile-adjacent actors ==================================================

class BIO_BFGExtra : BFGExtra
{
	Default
	{
		Tag "$BIO_PROJEXTRA_TAG_BFGRAY";
	}
}

class BIO_ProxMine : Actor
{
	const BOUNCE_FACTOR = 0.5;

	bool TouchOff;
	int SplashDamage, SplashRadius;

	Default
	{
		-NOGRAVITY
		-SLIDESONWALLS
		+CANBOUNCEWATER
		+MOVEWITHSECTOR
		+NOTARGET
		+THRUGHOST

		Projectile;

		BounceType 'Doom';
		BounceFactor BIO_ProxMine.BOUNCE_FACTOR;
		WallBounceFactor BIO_ProxMine.BOUNCE_FACTOR;

		Damage (0);
		Height 8;
		Radius 10;
		Scale 0.9;
		Speed 0;
	}

	final override void BeginPlay()
	{
		super.BeginPlay();
		SplashDamage = SplashRadius = 176;
	}

	States
	{
	Spawn:
		PROX A 0;
		PROX AA 5 A_JumpIf(invoker.TouchOff, 'Death');
		PROX A 5
		{
			if (invoker.TouchOff)
				return ResolveState('Death');

			// Die if owning player dies
			if (Target != null && Target.Health < 0)
				return ResolveState('Death');

			let bli = BlockThingsIterator.Create(invoker, 15.0);
			while (bli.Next())
			{
				if (bli.Thing.bIsMonster && bli.Thing.Species != 'Player')
					return ResolveState('Death');
			}

			return state(null);
		}
		Loop;
	Death:
		PROX A 2 A_StartSound("bio/proj/proximity/beep", CHAN_AUTO);
		PROX BC 4;
		PRXD A 2 Bright
		{
			A_Stop();
			bNoGravity = true;
			A_SetTranslucent(0.5, 1);
			A_Explode(invoker.SplashDamage, invoker.SplashRadius, XF_HURTSOURCE);
			A_StartSound("weapons/rocklx", CHAN_AUTO, attenuation: 0.8);
		}
		PRXD BCDEFGHIJKLMNOPQRSTU 2 Bright;
		Stop;
	}
}

// Visual effects ==============================================================

class BIO_PlasmaGlobuleTrail : Actor
{
	Default
	{
		+NOINTERACTION

		Alpha 0.6;
		RenderStyle 'Add';
		Scale 0.4;
	}

	States
	{
	Spawn:
		GLOT A 6 Bright;
		GLOT B 4 Bright;
		GLOT C 2 Bright;
		Stop;
	}
}
