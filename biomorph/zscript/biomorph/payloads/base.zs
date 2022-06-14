// Mixins //////////////////////////////////////////////////////////////////////

mixin class BIO_PayloadCommon
{
	meta string PluralTag;
	property PluralTag: PluralTag;

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
	// These are filled with copies of the contents of the
	// corresponding arrays in the pipeline firing this projectile.
	Array<BIO_HitDamageFunctor> HitDamageFunctors;
	Array<BIO_PayloadDeathFunctor> PayloadDeathFunctors;

	Default
	{
		+FORCEXYBILLBOARD
		Gravity 0.25;
	}

	protected int, int GetSplashData() const
	{
		for (uint i = 0; i < PayloadDeathFunctors.Size(); i++)
		{
			let expl = BIO_PLDF_Explode(PayloadDeathFunctors[i]);
			if (expl == null) continue;
			return expl.Damage, expl.Radius;
		}

		return 0, 0;
	}
}

// Abstract classes ////////////////////////////////////////////////////////////

class BIO_Projectile : Actor abstract
{
	mixin BIO_PayloadCommon;
	mixin BIO_ProjectileCommon;

	float Acceleration; property Acceleration: Acceleration;
	int SeekAngle; property SeekAngle: SeekAngle;

	// Set by the firing weapon to point to that 
	// weapon's own counterpart of this arrays.
	Array<BIO_ProjTravelFunctor> ProjTravelFunctors;

	Default
	{
		Projectile;

		Tag "$BIO_ROUND_TAG";
		BounceCount 4;

		BIO_Projectile.Acceleration 1.0;
		BIO_Projectile.PluralTag "$BIO_ROUND_TAGS";
		BIO_Projectile.SeekAngle 0;
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
			HitDamageFunctors[i].InvokeSlow(BIO_Projectile(self),
				target, ret, dmgType);

		return ret;
	}

	virtual void Summary(in out Array<string> weapReadout) {}

	action void A_Travel()
	{
		for (uint i = 0; i < invoker.ProjTravelFunctors.Size(); i++)
			invoker.ProjTravelFunctors[i].Invoke(BIO_Projectile(self));

		A_ScaleVelocity(invoker.Acceleration);
		if (invoker.SeekAngle > 0)
			A_SeekerMissile(invoker.SeekAngle, invoker.SeekAngle * 1.6, SMF_LOOK);
	}

	// Invoked before `A_ProjectileDeath()` does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();

		bNoGravity = true;

		for (uint i = 0; i < invoker.PayloadDeathFunctors.Size(); i++)
			invoker.PayloadDeathFunctors[i].InvokeSlow(BIO_Projectile(self));
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

		for (uint i = 0; i < HitDamageFunctors.Size(); i++)
			HitDamageFunctors[i].InvokeFast(BIO_FastProjectile(self),
				target, ret, dmgType);

		return ret;
	}

	virtual void Summary(in out Array<string> weapReadout) {}

	// Invoked before the A_ProjectileDeath does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();

		for (uint i = 0; i < invoker.PayloadDeathFunctors.Size(); i++)
			invoker.PayloadDeathFunctors[i].InvokeFast(BIO_FastProjectile(self));
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

	virtual void Summary(in out Array<string> weapReadout) {}
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
	meta string PluralTag; property PluralTag: PluralTag;
	meta class<Actor> PuffType; property PuffType: PuffType;

	virtual void Summary(in out Array<string> weapReadout) {}
}

// Functor base types //////////////////////////////////////////////////////////

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

	abstract BIO_ProjTravelFunctor Copy() const;

	abstract void Summary(in out Array<string> readout) const;

	readOnly<BIO_ProjTravelFunctor> AsConst() const { return self; }
}

class BIO_HitDamageFunctor play abstract
{
	virtual void InvokeSlow(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const {}
	virtual void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const {}
	virtual void InvokePuff(BIO_Puff puff) const {}

	virtual void GetDamageValues(in out Array<int> damages) const {}
	virtual void SetDamageValues(in out Array<int> damages) {}

	uint DamageValueCount() const
	{
		Array<int> dmgVals;
		GetDamageValues(dmgVals);
		return dmgVals.Size();
	}

	abstract BIO_HitDamageFunctor Copy() const;

	abstract void Summary(in out Array<string> readout) const;

	readOnly<BIO_HitDamageFunctor> AsConst() const { return self; }
}

class BIO_PayloadDeathFunctor play abstract
{
	virtual void InvokeSlow(BIO_Projectile proj) const {}
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

	abstract BIO_PayloadDeathFunctor Copy() const;

	abstract void Summary(in out Array<string> readout) const;
	
	readOnly<BIO_PayloadDeathFunctor> AsConst() const { return self; }
}

class BIO_PLDF_Explode : BIO_PayloadDeathFunctor
{
	private readOnly<BIO_PLDF_Explode> Defaults;

	int Damage, Radius, ShrapnelCount, ShrapnelDamage, FullDamageDistance;
	EExplodeFlags Flags;

	static BIO_PLDF_Explode Create(int damage, int radius,
		EExplodeFlags flags = XF_HURTSOURCE, int fullDmgDistance = 0,
		int shrapnel = 0, int shrapnelDmg = 0)
	{
		let ret = new('BIO_PLDF_Explode'), defs = new('BIO_PLDF_Explode');

		ret.Damage = defs.Damage = damage;
		ret.Radius = defs.Radius = radius;
		ret.Flags = defs.Flags = flags;
		ret.FullDamageDistance = defs.FullDamageDistance = fullDmgDistance;
		ret.ShrapnelCount = defs.ShrapnelCount = shrapnel;
		ret.ShrapnelDamage = defs.ShrapnelDamage = shrapnelDmg;
		ret.Defaults = BIO_PLDF_Explode(defs.AsConst());

		return ret;
	}

	final override void InvokeSlow(BIO_Projectile proj) const
	{
		// Temporarily bypass `DoSpecialDamage()`
		int d = proj.Damage;
		proj.SetDamage(Damage);
		proj.A_Explode(Damage, Radius, Flags, true, FullDamageDistance,
			ShrapnelCount, ShrapnelDamage, 'BIO_Shrapnel');
		proj.SetDamage(d);
	}

	final override void InvokeFast(BIO_FastProjectile proj) const
	{
		// Temporarily bypass `DoSpecialDamage()`
		int d = proj.Damage;
		proj.SetDamage(Damage);
		proj.A_Explode(Damage, Radius, Flags, true, FullDamageDistance,
			ShrapnelCount, ShrapnelDamage, 'BIO_Shrapnel');
		proj.SetDamage(d);
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		puff.A_Explode(Damage, Radius, Flags, true, FullDamageDistance,
			ShrapnelCount, ShrapnelDamage, 'BIO_Shrapnel');
	}

	final override void GetDamageValues(in out Array<int> damages) const
	{
		damages.Push(ShrapnelDamage);
	}

	final override void SetDamageValues(in out Array<int> damages)
	{
		ShrapnelDamage = damages[0];
	}

	final override BIO_PayloadDeathFunctor Copy() const
	{
		let ret = new('BIO_PLDF_Explode');
		ret.Damage = Damage;
		ret.Radius = Radius;
		ret.ShrapnelCount = ShrapnelCount;
		ret.ShrapnelDamage = ShrapnelDamage;
		ret.FullDamageDistance = FullDamageDistance;
		ret.Flags = Flags;
		return ret;
	}

	final override void Summary(in out Array<string> readout) const
	{
		if (Damage > 0 && Radius > 0)
		{
			string crEsc_dmg = "", crEsc_rad = "";

			if (Defaults != null)
			{
				crEsc_dmg = BIO_Utils.StatFontColor(Damage, Defaults.Damage);
				crEsc_rad = BIO_Utils.StatFontColor(Radius, Defaults.Radius);
			}
			else
				crEsc_dmg = crEsc_rad = CRESC_STATMODIFIED;

			readout.Push(String.Format(
				StringTable.Localize("$BIO_PLDF_EXPLODE_SPLASH"),
				crEsc_dmg, Damage, crEsc_rad, Radius));
		}

		if (ShrapnelCount > 0 && ShrapnelDamage > 0)
		{
			string crEsc_count = "", crEsc_dmg = "";

			if (Defaults != null)
			{
				crEsc_count = BIO_Utils.StatFontColor(
					ShrapnelCount, Defaults.ShrapnelCount);
				crEsc_dmg = BIO_Utils.StatFontColor(
					ShrapnelDamage, Defaults.ShrapnelDamage);
			}
			else
				crEsc_count = crEsc_dmg = CRESC_STATMODIFIED;

			readout.Push(String.Format(
				StringTable.Localize("$BIO_PLDF_EXPLODE_SHRAPNEL"),
				crEsc_count, ShrapnelCount, crEsc_dmg, ShrapnelDamage));
		}
	}
}
