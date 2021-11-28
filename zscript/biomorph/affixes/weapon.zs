// Damage ======================================================================

class BIO_WAfx_Damage : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0
	Array<int> Modifiers;

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DamageMutable();
	}

	override void Init(BIO_Weapon weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DamageMutable())
			{
				Modifiers.Push(0);
				continue;
			}

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);
			
			if (vals.Size() < 1)
			{
				Modifiers.Push(0);
				continue;
			}

			Modifiers.Push(Random(vals[0] / 2, vals[0] * 2));
		}
	}

	override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				vals[j] += Modifiers[i];
			
			weap.Pipelines[i].SetDamageValues(vals);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_TOSTR_DAMAGE"),
				BIO_Utils.RankString(i, "$BIO_FIRE_MODE"),
				BIO_Utils.StatFontColor(Modifiers[i], 0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i]));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_TAG_DAMAGE");
	}

	override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_DamageMulti : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0.0
	Array<float> Modifiers;

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DamageMutable() && weap.DealsAnyDamage();
	}

	override void Init(BIO_Weapon weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DamageMutable())
			{
				Modifiers.Push(0.0);
				continue;
			}

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);
			if (!weap.Pipelines[i].ExportsDamageValues())
			{
				Modifiers.Push(0.0);
				continue;
			}

			Modifiers.Push(FRandom(0.25, 0.75));
		}
	}

	override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				vals[j] *= (1.0 + Modifiers[i]);
			
			weap.Pipelines[i].SetDamageValues(vals);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_TOSTR_DMGMULTI"),
				BIO_Utils.RankString(i, "$BIO_FIRE_MODE"),
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i] * 100.0));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_TAG_DMGMULTI");
	}

	override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// Modify fired thing ==========================================================

class BIO_WAfx_ForceRadiusDmg : BIO_WeaponAffix
{
	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.FiresProjectile();
	}

	override void OnTrueProjectileFired(
		BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForceRadiusDmg = true;
	}

	override void OnFastProjectileFired(
		BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForceRadiusDmg = true;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_TOSTR_FORCERADIUSDMG"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_TAG_FORCERADIUSDMG");
	}

	override bool CanGenerate() const { return false; }

	override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED;
	}
}
