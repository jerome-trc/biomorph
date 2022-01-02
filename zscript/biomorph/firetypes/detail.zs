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
	// These are filled with copies of the contents of the
	// corresponding arrays in the pipeline firing this projectile.
	Array<BIO_HitDamageFunctor> HitDamageFunctors;
	Array<BIO_FTDeathFunctor> FTDeathFunctors;

	Default
	{
		+FORCEXYBILLBOARD
		Gravity 0.3;
	}

	protected int, int GetSplashData() const
	{
		for (uint i = 0; i < FTDeathFunctors.Size(); i++)
		{
			let expl = BIO_FTDF_Explode(FTDeathFunctors[i]);
			if (expl == null) continue;
			return expl.Damage, expl.Radius;
		}

		return 0, 0;
	}
}

// Abstract classes ============================================================

class BIO_Projectile : Actor abstract
{
	mixin BIO_FireTypeCommon;
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
		
		BIO_Projectile.MetaFlags BIO_FTMF_NONE;
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
			HitDamageFunctors[i].InvokeTrue(BIO_Projectile(self),
				target, ret, dmgType);

		return ret;
	}

	virtual void ToString(in out Array<string> weapReadout) {}

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

		for (uint i = 0; i < invoker.FTDeathFunctors.Size(); i++)
			invoker.FTDeathFunctors[i].InvokeTrue(BIO_Projectile(self));
	}
}

class BIO_FastProjectile : FastProjectile abstract
{
	mixin BIO_FireTypeCommon;
	mixin BIO_ProjectileCommon;

	meta Class<BIO_Puff> PuffCounterpart;
	property PuffCounterpart: PuffCounterpart;

	Default
	{
		Tag "$BIO_ROUND_TAG";

		BIO_FastProjectile.MetaFlags BIO_FTMF_NONE;
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

	virtual void ToString(in out Array<string> weapReadout) {}

	// Invoked before the A_ProjectileDeath does anything else.
	// Note that you never need to call `super.OnProjectileDeath()`.
	virtual void OnProjectileDeath() {}

	action void A_ProjectileDeath()
	{
		invoker.OnProjectileDeath();

		for (uint i = 0; i < invoker.FTDeathFunctors.Size(); i++)
			invoker.FTDeathFunctors[i].InvokeFast(BIO_FastProjectile(self));
	}
}

class BIO_Puff : BulletPuff abstract
{
	mixin BIO_FireTypeCommon;

	meta Class<BIO_FastProjectile> ProjCounterpart;
	property ProjCounterpart: ProjCounterpart;

	Default
	{
		+BLOODSPLATTER
		+HITTRACER
		+PUFFGETSOWNER
		+THRUSPECIES
		+THRUGHOST

		Tag "$BIO_ROUND_TAG";
		BIO_Puff.PluralTag "$BIO_ROUND_TAGS";
		BIO_Puff.MetaFlags BIO_FTMF_NONE;
	}

	States
	{
	Melee:
		PUFF CD 4;
		Stop;
	}

	virtual void ToString(in out Array<string> weapReadout) {}
}

class BIO_RailPuff : BIO_Puff abstract
{
	meta Class<Actor> SpawnClass; property SpawnClass: SpawnClass;
}

class BIO_RailSpawn : Actor abstract
{
	meta string PluralTag; property PluralTag: PluralTag;
	meta Class<Actor> PuffType; property PuffType: PuffType;

	virtual void ToString(in out Array<string> weapReadout) {}
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

	readOnly<BIO_ProjTravelFunctor> AsConst() const { return self; }
}

class BIO_HitDamageFunctor play abstract
{
	virtual void InvokeTrue(BIO_Projectile proj,
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

	abstract void ToString(in out Array<string> readout) const;

	readOnly<BIO_HitDamageFunctor> AsConst() const { return self; }
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
	
	readOnly<BIO_FTDeathFunctor> AsConst() const { return self; }
}

class BIO_FTDF_Explode : BIO_FTDeathFunctor
{
	private readOnly<BIO_FTDF_Explode> Defaults;

	int Damage, Radius, ShrapnelCount, ShrapnelDamage, FullDamageDistance;
	EExplodeFlags Flags;

	static BIO_FTDF_Explode Create(int damage, int radius,
		EExplodeFlags flags = XF_HURTSOURCE, int fullDmgDistance = 0,
		int shrapnel = 0, int shrapnelDmg = 0)
	{
		let ret = new('BIO_FTDF_Explode'), defs = new('BIO_FTDF_Explode');

		ret.Damage = defs.Damage = damage;
		ret.Radius = defs.Radius = radius;
		ret.Flags = defs.Flags = flags;
		ret.FullDamageDistance = defs.FullDamageDistance = fullDmgDistance;
		ret.ShrapnelCount = defs.ShrapnelCount = shrapnel;
		ret.ShrapnelDamage = defs.ShrapnelDamage = shrapnelDmg;
		ret.Defaults = BIO_FTDF_Explode(defs.AsConst());

		return ret;
	}

	final override void InvokeTrue(BIO_Projectile proj) const
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

	final override void ToString(in out Array<string> readout) const
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
				StringTable.Localize("$BIO_FTDF_EXPLODE_SPLASH"),
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
				StringTable.Localize("$BIO_FTDF_EXPLODE_SHRAPNEL"),
				crEsc_count, ShrapnelCount, crEsc_dmg, ShrapnelDamage));
		}
	}
}
