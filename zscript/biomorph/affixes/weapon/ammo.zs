class BIO_WAfx_MagSize : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	override void Init(readOnly<BIO_Weapon> weap)
	{
		if (weap.MagazineSizeMutable(false))
		{
			switch (weap.MagazineSize1)
			{
			case 1:
			case 2:
				Modifier1 = 1;
				break;
			case 3:
			case 4:
				Modifier1 = Random[BIO_Afx](1, 2);
				break;
			default:
				Modifier1 = Ceil(float(weap.MagazineSize1) * FRandom[BIO_Afx](0.33, 0.55));
				break;
			}
		}

		if (weap.MagazineSizeMutable(true))
		{
			switch (weap.MagazineSize2)
			{
			case 1:
			case 2:
				Modifier2 = 1;
				break;
			case 3:
			case 4:
				Modifier2 = Random[BIO_Afx](1, 2);
				break;
			default:
				Modifier2 = Ceil(float(weap.MagazineSize2) * FRandom[BIO_Afx](0.33, 0.55));
				break;
			}
		}
	}

	override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.MagazineSizeMutable(false) || weap.MagazineSizeMutable(true);
	}

	override void Apply(BIO_Weapon weap) const
	{
		weap.MagazineSize1 += Modifier1;
		weap.MagazineSize2 += Modifier2;
	}

	override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		if (Modifier1 != 0)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MAGSIZE_TOSTR_1"),
				BIO_Utils.StatFontColor(Modifier1, 0),
				Modifier1 >= 0 ? "+" : "", Modifier1));
		}

		if (Modifier2 != 0)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MAGSIZE_TOSTR_2"),
				BIO_Utils.StatFontColor(Modifier2, 0),
				Modifier2 >= 0 ? "+" : "", Modifier2));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MAGSIZE_TAG");
	}

	override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_MAGSIZE;
	}
}

class BIO_WAfx_Ammoless : BIO_WeaponAffix // Implicit only
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return (weap.AffixMask & BIO_WAM_AMMOUSE) != BIO_WAM_AMMOUSE;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		weap.AmmoUse1 = weap.AmmoUse2 = 0;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_AMMOLESS_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_AMMOLESS_TAG");
	}

	final override bool CanGenerate() const { return false; }
	final override bool CanGenerateImplicit() const { return true; }
	final override bool ImplicitExplicitExclusive() const { return true; }
	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_ReserveFeed : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		if ((weap.AffixMask & BIO_WAM_MAGAZINELESS) == BIO_WAM_MAGAZINELESS)
			return false;

		if (PrimaryCompatible(weap) || SecondaryCompatible(weap))
			return true;

		return false;
	}

	private static bool PrimaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType1 != null && weap.MagazineType1 != null &&
			weap.MagazineType1 != weap.AmmoType1 && weap.MagazineSize1 > 0 &&
			weap.ReloadCost1 > 0 && weap.ShotsPerMagazine(false) >= 15;
	}

	private static bool SecondaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType2 != null && weap.MagazineType2 != null &&
			weap.MagazineType2 != weap.AmmoType2 && weap.MagazineSize2 > 0 &&
			weap.ReloadCost2 > 0 && weap.ShotsPerMagazine(true) >= 15;	
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (PrimaryCompatible(weap.AsConst()))
		{
			weap.MagazineType1 = weap.AmmoType1;
		}

		if (SecondaryCompatible(weap.AsConst()))
		{
			weap.MagazineType2 = weap.AmmoType2;
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_RESERVEFEED_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_RESERVEFEED_TAG");
	}

	final override bool CanGenerate() const { return true; }
	final override bool ImplicitExplicitExclusive() const { return true; }
	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_NthRoundCost : BIO_WeaponAffix
{
	uint8 Interval;
	int CostModifier1, CostModifier2;

	private uint8 Counter1, Counter2;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return !weap.Ammoless();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Interval = Random[BIO_Afx](3, 5);
		CostModifier1 = -weap.AmmoUse1;
		CostModifier2 = -weap.AmmoUse2;
	}

	final override void BeforeDeplete(BIO_Weapon weap,
		in out int ammoUse, bool altFire) const
	{
		if (!altFire)
		{
			if (++Counter1 >= Interval)
			{
				ammoUse += CostModifier1;
				Counter1 = 0;
			}
		}
		else
		{
			if (++Counter2 >= Interval)
			{
				ammoUse += CostModifier2;
				Counter2 = 0;
			}
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_NTHROUNDCOST_TOSTR"), Interval));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_NTHROUNDCOST_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
