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

// Implementors ////////////////////////////////////////////////////////////////

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
				crEsc_dmg = crEsc_rad = Biomorph.CRESC_STATMODIFIED;

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
				crEsc_count = crEsc_dmg = Biomorph.CRESC_STATMODIFIED;

			readout.Push(String.Format(
				StringTable.Localize("$BIO_PLDF_EXPLODE_SHRAPNEL"),
				crEsc_count, ShrapnelCount, crEsc_dmg, ShrapnelDamage));
		}
	}
}

class BIO_PLDF_BFGSpray : BIO_PayloadDeathFunctor
{
	private readOnly<BIO_PLDF_BFGSpray> Defaults;

	int RayCount, MinDamage, MaxDamage;

	static BIO_PLDF_BFGSpray Create(int rayCount, int minDmg, int maxDmg)
	{
		let ret = new('BIO_PLDF_BFGSpray'), defs = new('BIO_PLDF_BFGSpray');

		ret.RayCount = defs.RayCount = rayCount;
		ret.MinDamage = defs.MinDamage = minDmg;
		ret.MaxDamage = defs.MaxDamage = maxDmg;
		ret.Defaults = BIO_PLDF_BFGSpray(defs.AsConst());

		return ret;
	}

	final override void InvokeSlow(BIO_Projectile proj) const
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

	final override BIO_PayloadDeathFunctor Copy() const
	{
		let ret = new('BIO_PLDF_BFGSpray');
		ret.RayCount = RayCount;
		ret.MinDamage = MinDamage;
		ret.MaxDamage = MaxDamage;
		return ret;
	}

	final override void Summary(in out Array<string> readout) const
	{
		string crEsc_rc = "", crEsc_min = "", crEsc_max = "";

		if (Defaults != null)
		{
			crEsc_rc = BIO_Utils.StatFontColor(RayCount, Defaults.RayCount);
			crEsc_min = BIO_Utils.StatFontColor(MinDamage, Defaults.MinDamage);
			crEsc_max = BIO_Utils.StatFontColor(MaxDamage, Defaults.MaxDamage);
		}
		else
			crEsc_rc = crEsc_min = crEsc_max = Biomorph.CRESC_STATMODIFIED;
		
		readout.Push(String.Format(
			StringTable.Localize("$BIO_PLDF_BFGSPRAY"),
			crEsc_rc, RayCount, crEsc_min, MinDamage, crEsc_max, MaxDamage));
	}
}
