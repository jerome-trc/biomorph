// Damage ======================================================================

// All splash damage on the fired projectile is converted into direct hit damage.
class BIO_WAFX_SplashForDamage : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return PrimaryCompatible(weap) || SecondaryCompatible(weap);
	}

	protected bool PrimaryCompatible(BIO_Weapon weap) const
	{
		return weap.Splashes(false);
	}

	protected bool SecondaryCompatible(BIO_Weapon weap) const
	{
		return weap.Splashes(true);
	}

	final override void ModifySplash(BIO_Weapon weap, in out int dmg, in out int radius,
		in out int baseDmg) const
	{
		baseDmg += Max(dmg, 0);
		dmg = 0;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(CRESC_MIXED .. StringTable.Localize(
			"$BIO_WAFX_SPLASHFORDAMAGE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPLASHFORDAMAGE_TAG");
	}
}

// Miscellaneous ===============================================================

class BIO_WAFX_FireCount : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	final override void Init(BIO_Weapon weap)
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

	final override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.bMeleeWeapon) return false;

		bool ret = false;

		if (weap.FireCount1 != 0 && !(weap.AffixMask1 & BIO_WAM_FIRECOUNT))
			ret = true;
		if (weap.FireCount2 != 0 && !(weap.AffixMask2 & BIO_WAM_FIRECOUNT))
			ret = true;

		return ret;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_FIRECOUNT))
		{
			if (weap.FireCount1 == -1) weap.FireCount1 = 1;
			weap.FireCount1 += Modifier1;
		}
		
		if (!(weap.AffixMask2 & BIO_WAM_FIRECOUNT))
		{
			if (weap.FireCount2 == -1) weap.FireCount2 = 1;
			weap.FireCount2 += Modifier2;
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (weap.AffixMask2 & BIO_WAM_FIRECOUNT)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRECOUNT1_TOSTR"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1, weap.GetFireTypeTag(false)));
		}
		else if (weap.AffixMask1 & BIO_WAM_FIRECOUNT)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRECOUNT2_TOSTR"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2, weap.GetFireTypeTag(true)));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRECOUNT_TOSTR"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1, weap.GetFireTypeTag(false),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2, weap.GetFireTypeTag(true)));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FIRECOUNT_TAG");
	}
}
