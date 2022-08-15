enum BIO_PayloadSizeClass : uint8
{
	BIO_PLSC_NONE, // e.g. incorporeal
	BIO_PLSC_XSMALL, // e.g. 9mm up to 12G and 7.62
	BIO_PLSC_SMALL, // e.g. .338 up to .50 BMG
	BIO_PLSC_MEDIUM, // e.g. 20mm
	BIO_PLSC_LARGE, // e.g. 40mm
	BIO_PLSC_XLARGE, // e.g. BFG ball
}

// Mixins //////////////////////////////////////////////////////////////////////

mixin class BIO_PayloadCommon
{
	meta BIO_PayloadSizeClass SizeClass;
	property SizeClass: SizeClass;

	meta string PluralTag;
	property PluralTag: PluralTag;

	BIO_PayloadFunctorTuple Functors;

	Default
	{
		+BLOODSPLATTER
		+THRUSPECIES
		+THRUGHOST

		Damage -1;
		Species 'Player';
	}

	// Context-less, universally-applicable information
	// which the user may want/need to know about this payload.
	virtual string Summary() const { return ""; }
}

mixin class BIO_ProjectileCommon
{
	Default
	{
		+FORCEXYBILLBOARD
		Gravity 0.25;
	}

	protected int, int GetSplashData() const
	{
		int ret1 = 0, ret2 = 0;

		for (uint i = 0; i < Functors.OnDeath.Size(); i++)
		{
			let expl = BIO_PLDF_Explode(Functors.OnDeath[i]);

			if (expl == null)
				continue;

			ret1 += expl.Damage;
			ret2 += expl.Radius;
		}

		return 0, 0;
	}
}

// Abstract classes ////////////////////////////////////////////////////////////

class BIO_Projectile : Actor abstract
{
	mixin BIO_PayloadCommon;
	mixin BIO_ProjectileCommon;

	Default
	{
		Projectile;

		Tag "$BIO_ROUND_TAG";
		BounceCount 4;

		BIO_Projectile.PluralTag "$BIO_ROUND_TAGS";
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

		for (uint i = 0; i < Functors.HitDamage.Size(); i++)
			Functors.HitDamage[i].InvokeSlow(
				BIO_Projectile(self), target, ret, dmgType
			);

		return ret;
	}

	action void A_Travel()
	{
		// Got called before `Functors` could be assigned
		if (invoker.Functors == null)
			return;

		for (uint i = 0; i < invoker.Functors.Travel.Size(); i++)
			invoker.Functors.Travel[i].Invoke(BIO_Projectile(self));
	}

	// Invoked before `A_ProjectileDeath()` does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();
		bNoGravity = true;

		// May have hit a surface before `Functors` could be assigned
		if (invoker.Functors == null)
			return;

		for (uint i = 0; i < invoker.Functors.OnDeath.Size(); i++)
			invoker.Functors.OnDeath[i].InvokeSlow(BIO_Projectile(self));
	}
}

class BIO_FastProjectile : FastProjectile abstract
{
	mixin BIO_PayloadCommon;
	mixin BIO_ProjectileCommon;

	Default
	{
		Tag "$BIO_ROUND_TAG";

		BIO_FastProjectile.PluralTag "$BIO_ROUND_TAGS";
	}

	// Don't multiply damage by `Random(1, 8)`.
	final override int DoSpecialDamage(Actor target, int dmg, name dmgType)
	{
		int ret = Damage;

		for (uint i = 0; i < Functors.HitDamage.Size(); i++)
			Functors.HitDamage[i].InvokeFast(
				BIO_FastProjectile(self), target, ret, dmgType
			);

		return ret;
	}

	// Invoked before the A_ProjectileDeath does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();

		for (uint i = 0; i < invoker.Functors.OnDeath.Size(); i++)
			invoker.Functors.OnDeath[i].InvokeFast(BIO_FastProjectile(self));
	}
}

class BIO_Puff : BulletPuff abstract
{
	mixin BIO_PayloadCommon;

	Default
	{
		+ALLOWTHRUFLAGS
		+BLOODSPLATTER
		+HITTRACER
		+MTHRUSPECIES
		+PUFFGETSOWNER
		+THRUSPECIES
		+THRUGHOST

		Tag "$BIO_ROUND_TAG";
		BIO_Puff.PluralTag "$BIO_ROUND_TAGS";
	}

	States
	{
	Melee:
		PUFF CD 4;
		Stop;
	}
}

class BIO_FakePuff : BIO_Puff
{
	Default
	{
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOTIMEFREEZE
		+NOTONAUTOMAP

		Height 6.0;
		Radius 6.0;
	}

    States
    {
    Spawn:
	    TNT1 AA 1;
        Stop;
    }
}

class BIO_RailPuff : BIO_Puff abstract
{
	meta class<Actor> SpawnClass; property SpawnClass: SpawnClass;
}

class BIO_RailSpawn : Actor abstract
{
	mixin BIO_PayloadCommon;

	meta class<Actor> PuffType; property PuffType: PuffType;
}
