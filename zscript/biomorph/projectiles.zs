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

	// Don't multiply damage by Random(1, 8).
	override int DoSpecialDamage(Actor target, int dmg, name dmgType)
	{
		return Damage;
	}

	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();
		// TODO: Subtle sound if Shrapnel is >0
		if (invoker.Shrapnel > 0)
		{
			A_Explode(invoker.SplashDamage, invoker.SplashRadius,
				nails: invoker.Shrapnel,
				nailDamage: Max(((invoker.Damage * 3) / invoker.Shrapnel), 0),
				puffType: "BIO_Shrapnel");
		}
		else
		{
			A_Explode(invoker.SplashDamage, invoker.SplashRadius);
		}
	}
}

class BIO_Projectile : Actor abstract
{
	mixin BIO_ProjectileCommon;

	bool Seek; property Seek: Seek;

	Default
	{
		Projectile;
		
		BIO_Projectile.MetaFlags BIO_PMF_NONE;
		BIO_Projectile.BFGRays 0;
		BIO_Projectile.Splash 0, 0;
		BIO_Projectile.Shrapnel 0;
		BIO_Projectile.Seek false;
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

	action void A_Travel()
	{
		if (invoker.Seek) A_SeekerMissile(4.0, 4.0, SMF_LOOK);
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

class BIO_Slug : BIO_Bullet
{
	Default
	{
		Tag "$BIO_PROJ_TAG_SLUG";
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
		MISL A 1 Bright A_Travel;
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

class BIO_MiniMissile : BIO_Rocket
{
	Default
	{
		Tag "$BIO_PROJ_TAG_MINIMISSILE";

		Height 2;
		Radius 3;
		Scale 0.3;
		Speed 50;

		BIO_Projectile.Splash 32, 32;
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
		PLSS A 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		PLSS B 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
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
		BFS1 A 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		BFS1 B 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
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

class BIO_Shrapnel : BulletPuff
{
	Default
	{
		+ALLOWTHRUFLAGS
		+MTHRUSPECIES
		+THRUGHOST
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		if (Deathmatch) bMTHRUSPECIES = false;
	}
}

class BIO_BFGExtra : BFGExtra
{
	Default
	{
		Tag "$BIO_PROJEXTRA_TAG_BFGRAY";
	}
}
