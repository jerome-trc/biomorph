class BIO_WAfx_ForcePain : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const { return true; }

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForcePain = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForcePain = true;
	}

	final override void OnPuffFired(BIO_Weapon weap, BIO_Puff puff) const
	{
		if (puff.Tracer != null)
			puff.Tracer.TriggerPainChance(puff.DamageType, true);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_FORCEPAIN_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FORCEPAIN_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override bool ImplicitExplicitExclusive() const { return true; }
	
	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_ForceRadiusDmg : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresProjectile() && weap.DealsAnySplashDamage();
	}

	final override void OnTrueProjectileFired(
		BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForceRadiusDmg = true;
	}

	final override void OnFastProjectileFired(
		BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForceRadiusDmg = true;
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_FORCERADIUSDMG_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FORCERADIUSDMG_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override bool ImplicitExplicitExclusive() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_ProjSeek : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresTrueProjectile();
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bSeekerMissile = true;
		proj.SeekAngle = 4;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PROJSEEK_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJSEEK_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override bool ImplicitExplicitExclusive() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ADDSSEEKING;
	}
}

class BIO_WAfx_ProjGravity : BIO_WeaponAffix
{
	float Multi;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Multi = FRandom[BIO_Afx](0.5, 1.0);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		if (weap.AnyAffixesAddGravity())
			return false;

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FiresTrueProjectile())
				continue;

			if (weap.Pipelines[i].AffectedByGravity())
				continue;
			
			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].FiresTrueProjectile() &&
				!weap.Pipelines[i].AffectedByGravity())
				weap.Pipelines[i].MultiplyAllDamage(1.0 + Multi);
		}
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bNoGravity = false;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(StringTable.Localize("$BIO_WAFX_PROJGRAVITY_TOSTR"),
			Multi >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Multi >= 0 ? "+" : "", int(Multi * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJGRAVITY_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }
	final override bool ImplicitExplicitExclusive() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ADDSGRAVITY | BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_ProjBounce : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresTrueProjectile();
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bBounceOnWalls = true;
		proj.bBounceOnFloors = true;
		proj.bBounceOnCeilings = true;
		proj.bAllowBounceOnActors = true;
		proj.bBounceAutoOff = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bBounceOnWalls = true;
		proj.bBounceOnFloors = true;
		proj.bBounceOnCeilings = true;
		proj.bAllowBounceOnActors = true;
		proj.bBounceAutoOff = true;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PROJBOUNCE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJBOUNCE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override bool ImplicitExplicitExclusive() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ADDSBOUNCE;
	}
}
