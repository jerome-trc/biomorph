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

class BIO_WMod_ETMF : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap, uint _) const
	{
		if (PrimaryCompatible(weap) || SecondaryCompatible(weap))
			return true, "";

		return false, "$BIO_WMOD_INCOMPAT_ETMF";
	}

	private static bool PrimaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.MagazineTypeETM1 != null &&
			weap.MagazineType1 != weap.MagazineTypeETM1;
	}

	private static bool SecondaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.MagazineTypeETM2 != null &&
			weap.MagazineType2 != weap.MagazineTypeETM2;
	}

	final override void Apply(BIO_Weapon weap, uint count) const
	{
		Ammo mag1 = null, mag2 = null;
		[mag1, mag2] = weap.GetMagazines();
		bool a1 = mag1 is weap.MagazineTypeETM1, a2 = mag2 is weap.MagazineTypeETM2;

		if (!a1 && !a2)
		{
			bool
				compatP = PrimaryCompatible(weap.AsConst()),
				compatS = SecondaryCompatible(weap.AsConst());

			if (compatP)
			{
				let magDefs = GetDefaultByType(weap.MagazineTypeETM1);
				let powupDefs = GetDefaultByType(magDefs.PowerupType);
				weap.AmmoType1 = 'Cell';
				weap.AmmoUse1 = powupDefs.CellCost;
				weap.MagazineSize1 = powupDefs.EffectTics;
			}

			if (compatS)
			{
				let magDefs = GetDefaultByType(weap.MagazineTypeETM2);
				let powupDefs = GetDefaultByType(magDefs.PowerupType);
				weap.AmmoType2 = 'Cell';
				weap.AmmoUse2 = powupDefs.CellCost;
				weap.MagazineSize2 = powupDefs.EffectTics;
			}

			weap.SetupAmmo();

			weap.SetupMagazines(
				compatP ? weap.MagazineTypeETM1 : null,
				compatS ? weap.MagazineTypeETM2 : null
			);

			if (--count <= 0)
				return;
		}

		[mag1, mag2] = weap.GetMagazines();
		a1 = mag1 is weap.MagazineTypeETM1;
		a2 = mag2 is weap.MagazineTypeETM2;

		for (uint i = 0; i < count; i++)
		{
			if (a1)
				weap.MagazineSize1 += (TICRATE / 2);
			if (a2)
				weap.MagazineSize2 += (TICRATE / 2);
		}
	}

	final override bool AllowMultiple() const
	{
		return true;
	}

	final override BIO_WeapModRepeatRules RepeatRules() const
	{
		return BIO_WMODREPEATRULES_INTERNAL;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_ETMF_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_ETMF_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap, uint _) const
	{
		bool compatP = PrimaryCompatible(weap), compatS = SecondaryCompatible(weap);

		if (compatP)
		{
			let e = strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_ETMF_DESC"),
					weap.AmmoUse1, float(weap.MagazineSize1) / float(TICRATE)
				)
			);

			if (compatP && compatS)
			{
				strings[e].AppendFormat(
					" %s", StringTable.Localize("$BIO_PRIMARYQUALIFIER")
				);
			}
		}

		if (compatS)
		{
			let e = strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_ETMF_DESC"),
					weap.AmmoUse2, float(weap.MagazineSize2) / float(TICRATE)
				)
			);

			if (compatP && compatS)
			{
				strings[e].AppendFormat(
					" %s", StringTable.Localize("$BIO_SECONDARYQUALIFIER")
				);
			}
		}
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
