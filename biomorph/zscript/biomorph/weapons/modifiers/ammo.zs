class BIO_WMod_MagSize : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap) const
	{
		if (weap.MagazineSizeMutable(false) || weap.MagazineSizeMutable(true))
			return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOMUTABLEMAGS";
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (weap.MagazineSizeMutable(false))
			weap.MagazineSize1 += MagazineSizeIncrease(weap.AsConst(), false);

		if (weap.MagazineSizeMutable(true))
			weap.MagazineSize2 += MagazineSizeIncrease(weap.AsConst(), true);
	}

	private static uint MagazineSizeIncrease(readOnly<BIO_Weapon> weap, bool secondary)
	{
		uint magSize = !secondary ? weap.MagazineSize1 : weap.MagazineSize2;

		switch (weap.MagazineSize1)
		{
		case 0: return 0;
		case 1:
		case 2:
		case 3: return 1;
		case 4: return 2;
		default: return uint(Ceil(float(magSize) * 0.33));
		}
	}

	final override bool AllowMultiple() const
	{
		return true;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_MAGSIZE_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_MAGSIZE_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		if (weap.MagazineSizeMutable(false))
		{
			strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_MAGSIZE_DESC_1"),
					MagazineSizeIncrease(weap, false)
				)
			);
		}

		if (weap.MagazineSizeMutable(true))
		{
			strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_MAGSIZE_DESC_2"),
					MagazineSizeIncrease(weap, true)
				)
			);
		}
	}
}

class BIO_WMod_InfiniteAmmo : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap) const
	{
		return !weap.Ammoless(), "$BIO_WMOD_INCOMPAT_AMMOLESS";
	}

	final override void Apply(BIO_Weapon weap) const
	{
		weap.ClearMagazines();
		weap.AmmoType1 = weap.AmmoType2 = null;
		weap.AmmoUse1 = weap.AmmoUse2 = 0;
	}

	final override bool AllowMultiple() const
	{
		return false;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_INFINITEAMMO_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_INFINITEAMMO_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push("$BIO_WMOD_INFINITEAMMO_SUMM");
	}
}
