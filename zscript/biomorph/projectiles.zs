/* 	All Biomorph weapons fire projectiles (achieving effective hitscan via
	FastProjectiles), and sets their data after they spawn but before they hit
	anything. This works by way of a hack, wherein the projectile by default
	lacks bMissile, and has it enabled after it's fired.

	If projectiles ever do something unexpected, now you know a probable cause.

	- Rat
*/

// Abstract and detail classes =================================================

mixin class BIO_ProjectileCommon
{
	Default
	{
		-MISSILE
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
		if (victim == Target || !victim.bShootable || victim.Health <= 0)
			return 1; // Ignored

		victim.DamageMobj(self, Target, Damage, self.DamageType);
		return 0; // Hit, do nothing
	}
}

class BIO_Projectile : Actor abstract
{
	Default
	{
		Projectile;
	}

	mixin BIO_ProjectileCommon;
}

class BIO_FastProjectile : FastProjectile abstract
{
	mixin BIO_ProjectileCommon;
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
		TNT1 A 1 A_SpawnItemEx("BulletPuff", flags: SXF_NOCHECKPOSITION);
		Stop;
	}
}
