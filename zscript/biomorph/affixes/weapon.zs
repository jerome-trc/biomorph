// Damage ======================================================================

class BIO_WeaponAffix_Damage : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	override void Init(BIO_Weapon weap)
	{
		Modifier1 = Random(weap.MinDamage1, weap.MaxDamage1) * 0.4;
		Modifier2 = Random(weap.MinDamage2, weap.MaxDamage2) * 0.4;
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return !weap.AllDamageAffixMasked();
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask & BIO_WAM_MINDAMAGE_1))
			weap.MinDamage1 += Modifier1;
		if (!(weap.AffixMask & BIO_WAM_MAXDAMAGE_1))
			weap.MaxDamage1 += Modifier1;

		if (!(weap.AffixMask & BIO_WAM_MINDAMAGE_2))
			weap.MinDamage2 += Modifier2;
		if (!(weap.AffixMask & BIO_WAM_MAXDAMAGE_2))
			weap.MaxDamage2 += Modifier2;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (weap.AffixMask & BIO_WAM_DAMAGE_2)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG1"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "-", Modifier1));
		}
		else if (weap.AffixMask & BIO_WAM_DAMAGE_1)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG2"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "-", Modifier2));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "-", Modifier1,
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "-", Modifier2));
		}
	}
}

class BIO_WeaponAffix_DamagePercent : BIO_WeaponAffix
{
	float Multi1, Multi2;

	override void Init(BIO_Weapon weap)
	{
		Multi1 = FRandom(0.25, 0.75);
		Multi2 = FRandom(0.25, 0.75);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return !weap.AllDamageAffixMasked() && weap.DealsAnyDamage();
	}

	override void Apply(BIO_Weapon weap)
	{
		if (!(weap.AffixMask & BIO_WAM_MINDAMAGE_1))
			weap.MinDamage1 *= (1.0 + Multi1);
		if (!(weap.AffixMask & BIO_WAM_MAXDAMAGE_1))
			weap.MaxDamage1 *= (1.0 + Multi1);

		if (!(weap.AffixMask & BIO_WAM_MINDAMAGE_2))
			weap.MinDamage2 *= (1.0 + Multi2);
		if (!(weap.AffixMask & BIO_WAM_MAXDAMAGE_2))
			weap.MaxDamage2 *= (1.0 + Multi2);
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (weap.AffixMask & BIO_WAM_DAMAGE_2)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMGPERCENT1"),
				Multi1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi1 >= 0 ? "+" : "-", int(Multi1 * 100)));
		}
		else if (weap.AffixMask & BIO_WAM_DAMAGE_1)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMGPERCENT2"),
				Multi2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi2 >= 0 ? "+" : "-", int(Multi2 * 100)));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMGPERCENT"),
				Multi1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi1 >= 0 ? "+" : "-", int(Multi1 * 100),
				Multi2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi2 >= 0 ? "+" : "-", int(Multi2 * 100)));
		}
	}
}

// Fire type ===================================================================

class BIO_WeaponAffix_Plasma : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo("BIO_PlasmaBall", false) ||
			weap.FireTypeMutableTo("BIO_PlasmaBall", true);
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (weap.FireTypeMutableTo("BIO_PlasmaBall", false))
			weap.FireType1 = "BIO_PlasmaBall";
		
		if (weap.FireTypeMutableTo("BIO_PlasmaBall", true))
			weap.FireType2 = "BIO_PlasmaBall";
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_PLASMA"));
	}
}

class BIO_WeaponAffix_Slug : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	// Weapon must be firing shot pellets for this affix to be applicable.
	override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.FireTypeMutableFrom("BIO_ShotPellet", false) &&
			!(weap.AffixMask & BIO_WAM_SPREAD_1) &&
			!(weap.AffixMask & BIO_WAM_DAMAGE_1))
			return true;
		else if (weap.FireTypeMutableFrom("BIO_ShotPellet", true) &&
			!(weap.AffixMask & BIO_WAM_SPREAD_2) &&
			!(weap.AffixMask & BIO_WAM_DAMAGE_2))
			return true;
		else
			return false;
	}

	override void Apply(BIO_Weapon weap) const
	{
		weap.UpdateDictionary();

		if (weap.FireTypeMutableFrom("BIO_ShotPellet", false) &&
			!(weap.AffixMask & BIO_WAM_SPREAD_1) &&
			!(weap.AffixMask & BIO_WAM_DAMAGE_1))
		{
			bool valid = false;
			string val = "";
			[val, valid] = weap.TryGetDictValue("PelletCount1");

			if (!valid)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"%s is a shotgun with no PelletCount1 dictionary value.");
			}
			else
			{
				int pc1 = val.ToInt();
				weap.FireType1 = "BIO_Slug";
				weap.FireCount1 /= pc1;
				weap.MinDamage1 *= pc1;
				weap.MaxDamage1 *= pc1;
				weap.HSpread1 = 0.1;
				weap.VSpread1 = 0.1;
			}
		}
		
		if (weap.FireTypeMutableFrom("BIO_ShotPellet", true) &&
			!(weap.AffixMask & BIO_WAM_SPREAD_2) &&
			!(weap.AffixMask & BIO_WAM_DAMAGE_2))
		{
			bool valid = false;
			string val = "";
			[val, valid] = weap.TryGetDictValue("PelletCount2");

			if (!valid)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"%s is a shotgun with no PelletCount1 dictionary value.");
			}
			else
			{
				int pc2 = val.ToInt();
				weap.FireType2 = "BIO_Slug";
				weap.FireCount2 /= pc2;
				weap.MinDamage2 *= pc2;
				weap.MaxDamage2 *= pc2;
				weap.HSpread2 = 0.1;
				weap.VSpread2 = 0.1;
			}
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_SLUG"));
	}
}

// Miscellaneous ===============================================================

class BIO_WeaponAffix_FireCount : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	override void Init(BIO_Weapon weap)
	{
		if (weap.FireCount1 <= 1)
			Modifier1 = Random(1, 2);
		else
			Modifier1 = Random(1, weap.FireCount1);

		if (weap.FireCount2 <= 1)
			Modifier2 = Random(1, 2);
		else
			Modifier2 = Random(1, weap.FireCount2);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.bMeleeWeapon) return false;

		bool ret = false;

		if (weap.FireCount1 != 0 && !(weap.AffixMask & BIO_WAM_FIRECOUNT_1))
			ret = true;
		if (weap.FireCount2 != 0 && !(weap.AffixMask & BIO_WAM_FIRECOUNT_2))
			ret = true;

		return ret;
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask & BIO_WAM_FIRECOUNT_1))
		{
			if (weap.FireCount1 == -1) weap.FireCount1 = 1;
			weap.FireCount1 += Modifier1;
		}
		
		if (!(weap.AffixMask & BIO_WAM_FIRECOUNT_2))
		{
			if (weap.FireCount2 == -1) weap.FireCount2 = 1;
			weap.FireCount2 += Modifier2;
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (weap.AffixMask & BIO_WAM_FIRECOUNT_2)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_FIRECOUNT1"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "-", Modifier1,
				GetDefaultByType(weap.FireType1).GetTag()));
		}
		else if (weap.AffixMask & BIO_WAM_FIRECOUNT_1)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_FIRECOUNT2"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "-", Modifier2,
				GetDefaultByType(weap.FireType2).GetTag()));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_FIRECOUNT"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "-", Modifier1,
				GetDefaultByType(weap.FireType1).GetTag(),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "-", Modifier2,
				GetDefaultByType(weap.FireType2).GetTag()));
		}
	}
}

class BIO_WeaponAffix_FireRate : BIO_WeaponAffix
{
	int Modifier;

	override void Init(BIO_Weapon weap)
	{
		int rft = weap.ReducibleFireTime();

		if (rft == 1)
			Modifier = -1;
		else if (rft > 1)
			Modifier = -Random(1, rft);
		else
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegally initialized %s against reducible fire time of %d.",
				GetClassName(), rft);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.AffixMask & BIO_WAM_FIRETIME) &&
			weap.ReducibleFireTime() > 0;
	}

	override void Apply(BIO_Weapon weap)
	{
		weap.ModifyFireTime(Modifier);
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_FIRERATE"),
			Modifier >= 0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			Modifier >= 0 ? "+" : "", float(Modifier) / 35.0));
	}
}

class BIO_WeaponAffix_ProjSeek : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
	{
		if (!weap.PrimaryAffixMasked() && weap.FiresTrueProjectile(false))
			return true;
		else if (!weap.SecondaryAffixMasked() && weap.FiresTrueProjectile(true))
			return true;
		else
			return false;
	}

	override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.MaxSeekAngle = 4.0;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_PROJSEEK"));
	}
}

class BIO_WeaponAffix_MeleeRange : BIO_WeaponAffix
{
	float Modifier;

	override void Init(BIO_Weapon weap) { Modifier = FRandom(16.0, 32.0); }

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.bMeleeWeapon && !(weap.AffixMask & BIO_WAM_MELEERANGE);
	}

	override void ModifyMeleeRange(BIO_Weapon weap, in out float range) const
	{
		range += Modifier;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_MELEERANGE"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "", Modifier));
	}
}

class BIO_WeaponAffix_LifeSteal : BIO_WeaponAffix
{
	float AddPercent;
	
	override void Init(BIO_Weapon weap) { AddPercent = FRandom(0.2, 0.8); }

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.bMeleeWeapon && !(weap.AffixMask & BIO_WAM_LIFESTEAL);
	}

	override void ModifyLifesteal(BIO_Weapon weap, in out float lifeSteal) const
	{
		lifeSteal += AddPercent;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(CRESC_POSITIVE .. String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_LIFESTEAL"),
			int(AddPercent * 100.0)));
	}
}
