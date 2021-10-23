class BIO_WeaponAffix_Damage : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	override void Init(BIO_Weapon weap)
	{
		Modifier1 = Random(weap.MinDamage1, weap.MaxDamage1) * 0.2;
		Modifier2 = Random(weap.MinDamage2, weap.MaxDamage2) * 0.2;
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return (weap.AffixMask & BIO_WAM_DAMAGE) != BIO_WAM_DAMAGE;
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

	override string ToString(BIO_Weapon weap) const
	{
		if (weap.AffixMask & BIO_WAM_DAMAGE_2)
		{
			return String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG1"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "-", Modifier1);
		}
		else if (weap.AffixMask & BIO_WAM_DAMAGE_1)
		{
			return String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG2"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "-", Modifier2);
		}
		else
		{
			return String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "-", Modifier1,
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "-", Modifier2);
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
		else
			Modifier = -Random(1, rft);
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

	override string ToString(BIO_Weapon weap) const
	{
		return String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_FIRERATE"),
			Modifier >= 0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			Modifier >= 0 ? "+" : "", float(Modifier) / 35.0);
	}
}
