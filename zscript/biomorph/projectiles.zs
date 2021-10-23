// Abstract and detail classes =================================================

mixin class BIO_ProjectileCommon
{
	protected bool Dead;

	int BFGRays; property BFGRays: BFGRays;

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

	action void A_ProjectileDeath() { invoker.OnProjectileDeath(); }
}

class BIO_Projectile : Actor abstract
{
	mixin BIO_ProjectileCommon;

	Default
	{
		Projectile;
		BIO_Projectile.BFGRays 0;
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
		BIO_FastProjectile.BFGRays 0;
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

// Real projectiles ============================================================

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
