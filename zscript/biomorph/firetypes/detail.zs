// Projectile/puff information that can't be expressed any other way.
enum BIO_FiredThingMetaFlags : uint8
{
	BIO_FTMF_NONE = 0,
	BIO_FTMF_BALLISTIC = 1 << 0,
	BIO_FTMF_ENERGY = 1 << 1,
	BIO_FTMF_ALL = uint8.MAX
}

// Mixins ======================================================================

mixin class BIO_FireTypeCommon
{
	meta string PluralTag; property PluralTag: PluralTag;
	meta BIO_FiredThingMetaFlags MetaFlags; property MetaFlags: MetaFlags;

	Default
	{
		+BLOODSPLATTER
		+THRUSPECIES
		+THRUGHOST

		Damage -1;
		Species 'Player';
	}
}

mixin class BIO_ProjectileCommon
{
	int SplashDamage, SplashRadius; property Splash: SplashDamage, SplashRadius;
	int Shrapnel; property Shrapnel: Shrapnel;

	// These are set by the firing weapon to point to that 
	// weapon's own counterparts of these arrays.
	Array<BIO_HitDamageFunctor> HitDamageFunctors;
	Array<BIO_FTDeathFunctor> FTDeathFunctors;

	Default
	{
		+FORCEXYBILLBOARD
		Gravity 0.3;
	}
}

// Abstract classes ============================================================

class BIO_Projectile : Actor abstract
{
	mixin BIO_FireTypeCommon;
	mixin BIO_ProjectileCommon;

	float Acceleration; property Acceleration: Acceleration;
	bool Seek; property Seek: Seek;

	// Set by the firing weapon to point to that 
	// weapon's own counterpart of this arrays.
	Array<BIO_ProjTravelFunctor> ProjTravelFunctors;

	Default
	{
		Projectile;

		Tag "$BIO_ROUND_TAG";
		
		BIO_Projectile.MetaFlags BIO_FTMF_NONE;
		BIO_Projectile.Acceleration 1.0;
		BIO_Projectile.PluralTag "$BIO_ROUND_TAGS";
		BIO_Projectile.Splash 0, 0;
		BIO_Projectile.Shrapnel 0;
		BIO_Projectile.Seek false;
	}

	// Overriden so projectiles live long enough to receive their data from the
	// weapon which fired them. If `Damage` is still at the default of -1,
	// don't expire quite yet.
	override int SpecialMissileHit(Actor victim)
	{
		// (a.k.a. the part which keeps half this mod from toppling over)
		if (Damage <= -1)
			return 1; // Ignored for now
		else
			return super.SpecialMissileHit(victim);
	}

	// Don't multiply damage by `Random(1, 8)`.
	final override int DoSpecialDamage(Actor target, int dmg, name dmgType)
	{
		int ret = Damage;

		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			HitDamageFunctors[i].InvokeTrue(BIO_Projectile(self),
				target, ret, dmgType);

		return ret;
	}

	action void A_Travel()
	{
		for (uint i = 0; i < invoker.ProjTravelFunctors.Size(); i++)
			invoker.ProjTravelFunctors[i].Invoke(BIO_Projectile(self));

		A_ScaleVelocity(invoker.Acceleration);

		if (invoker.Seek) A_SeekerMissile(4.0, 4.0, SMF_LOOK);
	}

	// Invoked before `A_ProjectileDeath()` does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();

		for (uint i = 0; i < invoker.FTDeathFunctors.Size(); i++)
			invoker.FTDeathFunctors[i].InvokeTrue(BIO_Projectile(self));

		// TODO: Subtle sound if Shrapnel is >0
		if (invoker.Shrapnel > 0)
		{
			A_Explode(invoker.SplashDamage, invoker.SplashRadius,
				nails: invoker.Shrapnel,
				nailDamage: Max(((invoker.Damage * 3) / invoker.Shrapnel), 0),
				puffType: 'BIO_Shrapnel');
		}
		else
		{
			A_Explode(invoker.SplashDamage, invoker.SplashRadius);
		}
	}
}

class BIO_FastProjectile : FastProjectile abstract
{
	mixin BIO_FireTypeCommon;
	mixin BIO_ProjectileCommon;

	Default
	{
		Tag "$BIO_ROUND_TAG";

		BIO_FastProjectile.MetaFlags BIO_FTMF_NONE;
		BIO_FastProjectile.PluralTag "$BIO_ROUND_TAGS";
		BIO_FastProjectile.Splash 0, 0;
		BIO_FastProjectile.Shrapnel 0;
	}

	// Don't multiply damage by `Random(1, 8)`.
	final override int DoSpecialDamage(Actor target, int dmg, name dmgType)
	{
		int ret = Damage;

		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			HitDamageFunctors[i].InvokeFast(BIO_FastProjectile(self),
				target, ret, dmgType);

		return ret;
	}

	// Invoked before the A_ProjectileDeath does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();

		for (uint i = 0; i < invoker.FTDeathFunctors.Size(); i++)
			invoker.FTDeathFunctors[i].InvokeFast(BIO_FastProjectile(self));

		// TODO: Subtle sound if `Shrapnel` is >0
		if (invoker.Shrapnel > 0)
		{
			A_Explode(invoker.SplashDamage, invoker.SplashRadius,
				nails: invoker.Shrapnel,
				nailDamage: Max(((invoker.Damage * 3) / invoker.Shrapnel), 0),
				puffType: 'BIO_Shrapnel');
		}
		else
		{
			A_Explode(invoker.SplashDamage, invoker.SplashRadius);
		}
	}
}

class BIO_Puff : BulletPuff abstract
{
	mixin BIO_FireTypeCommon;

	Default
	{
		+BLOODSPLATTER
		+THRUSPECIES
		+THRUGHOST

		Tag "$BIO_ROUND_TAG";
		BIO_Puff.PluralTag "$BIO_ROUND_TAGS";
		BIO_Puff.MetaFlags BIO_FTMF_NONE;
	}

	States
	{
	Melee:
		TNT1 A 0 { invoker.OnPuffDeath(); }
		PUFF CD 4;
		Stop;
	}

	// Note that you never need to call `super.OnPuffDeath()`.
	virtual void OnPuffDeath() {}
}

class BIO_RailPuff : BIO_Puff abstract
{
	meta Class<Actor> SpawnClass; property SpawnClass: SpawnClass;
}

class BIO_RailSpawn : Actor abstract
{
	meta string PluralTag; property PluralTag: PluralTag;
	meta Class<Actor> PuffType; property PuffType: PuffType;
}

// Functor base types ==========================================================

class BIO_ProjTravelFunctor play abstract
{
	abstract void Invoke(BIO_Projectile proj);

	virtual void GetDamageValues(in out Array<int> damages) const {}
	virtual void SetDamageValues(in out Array<int> damages) {}

	uint DamageValueCount() const
	{
		Array<int> dmgVals;
		GetDamageValues(dmgVals);
		return dmgVals.Size();
	}

	abstract void ToString(in out Array<string> readout) const;
}

class BIO_HitDamageFunctor play abstract
{
	virtual void InvokeTrue(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const {}
	virtual void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const {}
	virtual void InvokePuff(BIO_Puff puff,
		Actor target, int damage, name dmgType) const {}

	virtual void GetDamageValues(in out Array<int> damages) const {}
	virtual void SetDamageValues(in out Array<int> damages) {}

	uint DamageValueCount() const
	{
		Array<int> dmgVals;
		GetDamageValues(dmgVals);
		return dmgVals.Size();
	}

	abstract void ToString(in out Array<string> readout) const;
}

class BIO_FTDeathFunctor play abstract
{
	virtual void InvokeTrue(BIO_Projectile proj) const {}
	virtual void InvokeFast(BIO_FastProjectile proj) const {}
	virtual void InvokePuff(BIO_Puff puff) const {}

	virtual void GetDamageValues(in out Array<int> damages) const {}
	virtual void SetDamageValues(in out Array<int> damages) {}

	uint DamageValueCount() const
	{
		Array<int> dmgVals;
		GetDamageValues(dmgVals);
		return dmgVals.Size();
	}

	abstract void ToString(in out Array<string> readout) const;
}
