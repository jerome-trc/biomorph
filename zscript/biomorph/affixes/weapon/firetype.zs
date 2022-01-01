class BIO_WAfx_Plasma : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_PlasmaBall'))
				continue;
			if (!weap.Pipelines[i].CanFireProjectiles() &&
				!weap.Pipelines[i].FireFunctorMutable())
				continue;

			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_PlasmaBall'))
				continue;

			bool cfp = weap.Pipelines[i].CanFireProjectiles();
			
			if (!cfp)
			{
				if (!weap.Pipelines[i].FireFunctorMutable())
					continue;
				else
					weap.Pipelines[i].SetFireFunctor(new('BIO_FireFunc_Projectile'));
			}

			weap.Pipelines[i].SetFireType('BIO_PlasmaBall');
			weap.Pipelines[i].MultiplyAllDamage(1.25);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PLASMA_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PLASMA_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_Slug : BIO_WeaponAffix
{
	// Weapon must be firing shot pellets for this affix to be applicable.	
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableFrom('BIO_ShotPellet'))
				continue;
			if (!weap.Pipelines[i].DamageMutable() ||
				!weap.Pipelines[i].SpreadMutable())
				continue;
			if (!weap.Pipelines[i].CanFirePuffs() &&
				!weap.Pipelines[i].FireFunctorMutable())
				continue;

			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableFrom('BIO_ShotPellet'))
				continue;

			bool cfp = weap.Pipelines[i].CanFirePuffs();
			
			if (!cfp)
			{
				if (!weap.Pipelines[i].FireFunctorMutable())
					continue;
				else
					weap.Pipelines[i].SetFireFunctor(new('BIO_FireFunc_Bullet').Setup());
			}

			weap.Pipelines[i].SetFireType('BIO_Slug');
			uint fc = weap.Pipelines[i].GetFireCount();
			weap.Pipelines[i].SetFireCount(fc / fc);
			weap.Pipelines[i].MultiplyAllDamage(float(fc));
			weap.Pipelines[i].SetSpread(0.5, 0.5);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_SLUG_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SLUG_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRECOUNT | BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_MiniMissile : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_MiniMissile'))
				continue;
			if (!weap.Pipelines[i].SplashMutable())
				continue;
			if (!weap.Pipelines[i].CanFireProjectiles() &&
				!weap.Pipelines[i].FireFunctorMutable())
				continue;
			
			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_MiniMissile') ||
				!weap.Pipelines[i].SplashMutable())
				continue;

			bool cfp = weap.Pipelines[i].CanFireProjectiles();
			
			if (!cfp)
			{
				if (!weap.Pipelines[i].FireFunctorMutable())
					continue;
				else
					weap.Pipelines[i].SetFireFunctor(new('BIO_FireFunc_Projectile'));
			}

			weap.Pipelines[i].SetFireType('BIO_MiniMissile');
			weap.Pipelines[i].SetSplash(48, 48);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_MINIMISSILE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MINIMISSILE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_BFGSpray : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;
		}

		return false;
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		return
			ppl.FireTypeMutableTo('BIO_BFGExtra') && ppl.FireFunctorMutable() &&
			ppl.FireCountMutable() && ppl.DamageMutable() && ppl.AngleMutable();
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			if (!CompatibleWithPipeline(ppl.AsConst()))
				continue;

			ppl.SetFireFunctor(new('BIO_FireFunc_BFGSpray'));
			ppl.SetFireType('BIO_BFGExtra');
			ppl.SetFireCount(ppl.GetFireCount() * 4);
			ppl.MultiplyAllDamage(0.5);
			ppl.SetFireSound("weapons/bfgx");
			ppl.ModifyAngleAndPitch(45.0, 0.0);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_BFGSPRAY_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_BFGSPRAY_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
