class BIO_WMod_MagSize : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap, uint _) const
	{
		if (weap.MagazineSizeMutable(false) || weap.MagazineSizeMutable(true))
			return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOMUTABLEMAGS";
	}

	final override void Apply(BIO_Weapon weap, uint _) const
	{
		if (weap.MagazineSizeMutable(false))
			weap.MagazineSize1 += MagazineSizeIncrease(weap.AsConst(), false);

		if (weap.MagazineSizeMutable(true))
			weap.MagazineSize2 += MagazineSizeIncrease(weap.AsConst(), true);
	}

	private static uint MagazineSizeIncrease(readOnly<BIO_Weapon> weap, bool secondary)
	{
		uint magSize = !secondary ?
			weap.Default.MagazineSize1 :
			weap.Default.MagazineSize2;

		switch (magSize)
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

	final override BIO_WeapModRepeatRules RepeatRules() const
	{
		return BIO_WMODREPEATRULES_EXTERNAL;
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
		readOnly<BIO_Weapon> weap, uint count) const
	{
		if (weap.MagazineSizeMutable(false))
		{
			strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_MAGSIZE_DESC_1"),
					MagazineSizeIncrease(weap, false) * count
				)
			);
		}

		if (weap.MagazineSizeMutable(true))
		{
			strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_MAGSIZE_DESC_2"),
					MagazineSizeIncrease(weap, true) * count
				)
			);
		}
	}
}

class BIO_WMod_ReserveFeed : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap, uint _) const
	{
		if (PrimaryCompatible(weap) || SecondaryCompatible(weap))
			return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOMAGAZINE";
	}

	private static bool PrimaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType1 != null &&
			weap.MagazineType1 != null &&
			weap.MagazineType1 != weap.AmmoType1 &&
			weap.MagazineSize1 > 0 &&
			weap.ReloadCost1 > 0;
	}

	private static bool SecondaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType2 != null &&
			weap.MagazineType2 != null &&
			weap.MagazineType2 != weap.AmmoType2 &&
			weap.MagazineSize2 > 0 &&
			weap.ReloadCost2 > 0;	
	}

	final override void Apply(BIO_Weapon weap, uint _) const
	{
		weap.SetupMagazines(
			PrimaryCompatible(weap.AsConst()) ? weap.AmmoType1 : null,
			SecondaryCompatible(weap.AsConst()) ? weap.AmmoType2 : null
		);
	}

	final override bool AllowMultiple() const
	{
		return false;
	}

	final override BIO_WeapModRepeatRules RepeatRules() const
	{
		return BIO_WMODREPEATRULES_NONE;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_RESERVEFEED_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_RESERVEFEED_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> _, uint _) const
	{
		Summary(strings);
	}
}

class BIO_WMod_InfiniteAmmo : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap, uint _) const
	{
		return !weap.Ammoless(), "$BIO_WMOD_INCOMPAT_AMMOLESS";
	}

	final override void Apply(BIO_Weapon weap, uint _) const
	{
		weap.ClearMagazines();
		weap.AmmoType1 = weap.AmmoType2 = null;
		weap.AmmoUse1 = weap.AmmoUse2 = 0;
	}

	final override bool AllowMultiple() const
	{
		return false;
	}

	final override BIO_WeapModRepeatRules RepeatRules() const
	{
		return BIO_WMODREPEATRULES_NONE;
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
		readOnly<BIO_Weapon> _, uint _) const
	{
		Summary(strings);
	}
}
