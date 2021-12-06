// Damage ======================================================================

class BIO_WAfx_Damage : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DamageMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
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

	final override void Apply(BIO_Weapon weap) const
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

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_DAMAGE_TOSTR"),
				BIO_Utils.RankString(i, "$BIO_FIRE_MODE"),
				BIO_Utils.StatFontColor(Modifiers[i], 0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i]));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DAMAGE_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_DamageMulti : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0.0
	Array<float> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DamageMutable() && weap.DealsAnyDamage();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
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

	final override void Apply(BIO_Weapon weap) const
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

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_DMGMULTI_TOSTR"),
				BIO_Utils.RankString(i, "$BIO_FIRE_MODE"),
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i] * 100.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DMGMULTI_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// Modify fired thing ==========================================================

class BIO_WAfx_ForceRadiusDmg : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresProjectile();
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

	final override bool CanGenerate() const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED;
	}
}

// Timing ======================================================================

class BIO_WAfx_FireTime : BIO_WeaponAffix
{
	// One per state time group. Negative number = faster firing
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FireTimesMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.FireTimeGroups.Size(); i++)
		{
			int poss = weap.FireTimeGroups[i].PossibleReduction();

			if (poss < 1)
				Modifiers.Push(0);
			else
				Modifiers.Push(-Random(1, poss));
		}
	}

	final override void Apply(BIO_Weapon weap)
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;
			weap.ModifyFireTime(i, Modifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			let grpTag = StringTable.Localize(weap.FireTimeGroups[i].Tag);
			if (grpTag.Length() > 1)
				grpTag = " (" .. grpTag .. ") ";

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRETIME_TOSTR"), grpTag,
				BIO_Utils.StatFontColor(Modifiers[i], 0, true),
				Modifiers[i] >= 0 ? "+" : "", float(Modifiers[i]) / 35.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FIRETIME_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRETIME;
	}
}

class BIO_WAfx_ReloadTime : BIO_WeaponAffix
{
	// One per state time group. Negative number = faster reloading
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.ReloadTimesMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
		{
			int poss = weap.ReloadTimeGroups[i].PossibleReduction();

			if (poss < 1)
				Modifiers.Push(0);
			else
				Modifiers.Push(-Random(1, poss));
		}
	}

	final override void Apply(BIO_Weapon weap)
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;
			weap.ModifyReloadTime(i, Modifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			let grpTag = StringTable.Localize(weap.ReloadTimeGroups[i].Tag);
			if (grpTag.Length() > 1)
				grpTag = " (" .. grpTag .. ") ";

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_RELOADTIME_TOSTR"), grpTag,
				BIO_Utils.StatFontColor(Modifiers[i], 0, true),
				Modifiers[i] >= 0 ? "+" : "", float(Modifiers[i]) / 35.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_RELOADTIME_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_RELOADTIME;
	}
}

// On-kill effects =============================================================

// Melee-only ==================================================================

// Miscellaneous ===============================================================
