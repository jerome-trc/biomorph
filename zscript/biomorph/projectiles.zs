// Abstract and detail classes =================================================

// For details about projectiles that can't be expressed any other way.
enum BIO_ProjectileMetaFlags : uint
{
	BIO_PMF_NONE = 0,
	BIO_PMF_BALLISTIC = 1 << 0,
	BIO_PMF_ENERGY = 1 << 1
}

mixin class BIO_ProjectileCommon
{
	protected bool Dead;

	meta BIO_ProjectileMetaFlags MetaFlags; property MetaFlags: MetaFlags;

	int BFGRays; property BFGRays: BFGRays;
	int SplashDamage, SplashRadius; property Splash: SplashDamage, SplashRadius;
	int Shrapnel; property Shrapnel: Shrapnel;

	Default
	{
		+BLOODSPLATTER
		+FORCEXYBILLBOARD
		+THRUSPECIES
		+THRUGHOST

		Damage -1;
		Species "Player";
	}

	// Overriden so projectiles deal damage without built-in randomisation.
	override int SpecialMissileHit(Actor victim)
	{
		if (Damage <= 0)
			return 1; // Ignored for now

		if (victim == Target || !victim.bShootable || victim.Health <= 0)
			return 1; // Ignored

		victim.DamageMobj(self, Target, Damage, self.DamageType);
		return 0; // Hit, do nothing
	}

	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();
		// TODO: Subtle sound if Shrapnel is >0
		A_Explode(invoker.SplashDamage, invoker.SplashRadius,
			nails: invoker.Shrapnel, nailDamage: invoker.Damage);
	}
}

class BIO_Projectile : Actor abstract
{
	mixin BIO_ProjectileCommon;

	Default
	{
		Projectile;
		
		BIO_Projectile.MetaFlags BIO_PMF_NONE;
		BIO_Projectile.BFGRays 0;
		BIO_Projectile.Splash 0, 0;
		BIO_Projectile.Shrapnel 0;
	}

	// The hacky part that makes it all work.
	States
	{
	// Let the projectile live for one more tic so it can have its data set.
	PreDeath:
		#### # 1;
		Goto Death;
	Death:
		#### # 0
		{
			if (!invoker.Dead)
			{
				invoker.Dead = true;
				return ResolveState("PreDeath");
			}
			return ResolveState("Death.Impl");
		}
	}
}

class BIO_FastProjectile : FastProjectile abstract
{
	mixin BIO_ProjectileCommon;

	Default
	{
		BIO_FastProjectile.MetaFlags BIO_PMF_NONE;
		BIO_FastProjectile.BFGRays 0;
		BIO_FastProjectile.Splash 0, 0;
		BIO_FastProjectile.Shrapnel 0;
	}
}

// Fast projectiles (used like puffs) ==========================================

class BIO_Bullet : BIO_FastProjectile
{
	Default
	{
		+NOEXTREMEDEATH

		Alpha 1.0;
		Decal "Bulletchip";
		Height 1;
		Radius 1;
		Speed 80;
		Tag "$BIO_PROJ_TAG_BULLET";

		BIO_FastProjectile.MetaFlags BIO_PMF_BALLISTIC;
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
		A_SpawnItemEx("BulletPuff", flags: SXF_NOCHECKPOSITION);
	}
}

class BIO_ShotPellet : BIO_Bullet
{
	Default
	{
		Tag "$BIO_PROJ_TAG_SHOTPELLET";
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
		Tag "$BIO_PROJ_TAG_ROCKET";

		BIO_Projectile.Splash 128, 128;
	}

	States
	{
	Spawn:
		MISL A 1 Bright;
		Loop;
	Death.Impl:
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
		RenderStyle "Add";
		SeeSound "weapons/plasmaf";
		Speed 25;
		Tag "$BIO_PROJ_TAG_PLASMABALL";

		BIO_Projectile.MetaFlags BIO_PMF_ENERGY;
	}

	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Loop;
	Death.Impl:
		PLSE ABCDE 4 Bright A_ProjectileDeath;
		Stop;
	}
}

class BIO_BFGBall : BIO_Projectile
{
	int MinRayDamage, MaxRayDamage;
	property RayDamageRange: MinRayDamage, MaxRayDamage;

	Default
	{
		+RANDOMIZE
		+ZDOOMTRANS

		Alpha 0.75;
		DeathSound "weapons/bfgx";
		Height 8;
		Obituary "$OB_MPBFG_BOOM";
		Radius 13;
		RenderStyle "Add";
		Speed 25;
		Tag "$BIO_PROJ_TAG_BFGBALL";

		BIO_Projectile.MetaFlags BIO_PMF_ENERGY;
		BIO_BFGBall.RayDamageRange 15, 120;
	}

	States
	{
	Spawn:
		BFS1 AB 6 Bright;
		Loop;
	Death.Impl:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_ProjectileDeath;
		BFE1 DEF 8 Bright;
		Stop;
	}

	override void OnProjectileDeath()
	{
		A_BFGSpray(numRays: BFGRays, defDamage: Random(MinRayDamage, MaxRayDamage));
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
