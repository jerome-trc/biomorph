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
			weap.ReloadCost1 > 0;
	}

	private static bool SecondaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType2 != null && weap.MagazineType2 != null &&
			weap.MagazineType2 != weap.AmmoType2 && weap.MagazineSize2 > 0 &&
			weap.ReloadCost2 > 0;	
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
