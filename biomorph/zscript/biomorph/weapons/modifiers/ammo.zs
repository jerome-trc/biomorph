class BIO_WMod_ETMF : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (PrimaryCompatible(context.Weap) || SecondaryCompatible(context.Weap))
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

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		uint count = context.NodeCount;

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
				return "";
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

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		bool
			compatP = PrimaryCompatible(context.Weap),
			compatS = SecondaryCompatible(context.Weap);
		string ret = "";

		if (compatP)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_ETMF_DESC"),
				context.Weap.AmmoUse1,
				float(context.Weap.MagazineSize1) / float(TICRATE)
			);

			if (compatP && compatS)
			{
				ret.AppendFormat(
					" %s\n", StringTable.Localize("$BIO_PRIMARYQUALIFIER")
				);
			}
		}

		if (compatS)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_ETMF_DESC"),
				context.Weap.AmmoUse2,
				float(context.Weap.MagazineSize2) / float(TICRATE)
			);

			if (compatP && compatS)
			{
				ret.AppendFormat(
					" %s", StringTable.Localize("$BIO_SECONDARYQUALIFIER")
				);
			}
		}

		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_MAGTYPE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ETMF';
	}
}

class BIO_WMod_MagSize : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return
			context.Weap.MagazineSizeMutable(false) ||
			context.Weap.MagazineSizeMutable(true),
			"$BIO_WMOD_INCOMPAT_NOMUTABLEMAGS";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		if (weap.MagazineSizeMutable(false))
			weap.MagazineSize1 += MagazineSizeIncrease(weap.AsConst(), false);

		if (weap.MagazineSizeMutable(true))
			weap.MagazineSize2 += MagazineSizeIncrease(weap.AsConst(), true);

		return "";
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

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";
		bool
			compatP = context.Weap.MagazineSizeMutable(false),
			compatS = context.Weap.MagazineSizeMutable(true);

		if (compatP)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_MAGSIZE_DESC_1"),
				MagazineSizeIncrease(context.Weap, false) * context.NodeCount
			);

			if (compatP && compatS)
			{
				ret.AppendFormat(
					" %s\n", StringTable.Localize("$BIO_PRIMARYQUALIFIER")
				);
			}
		}

		if (compatS)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_MAGSIZE_DESC_2"),
				MagazineSizeIncrease(context.Weap, true) * context.NodeCount
			);

			if (compatP && compatS)
			{
				ret.AppendFormat(
					" %s", StringTable.Localize("$BIO_SECONDARYQUALIFIER")
				);
			}
		}

		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_MAGSIZE_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_MagSize';
	}
}

class BIO_WMod_InfiniteAmmo : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return !context.Weap.Ammoless(), "$BIO_WMOD_INCOMPAT_AMMOLESS";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		weap.ClearMagazines();
		weap.AmmoType1 = weap.AmmoType2 = null;
		weap.AmmoUse1 = weap.AmmoUse2 = 0;
		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_MAGTYPE | BIO_WMODF_AMMOTYPE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_InfiniteAmmo';
	}
}

class BIO_WMod_ReserveFeed : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (PrimaryCompatible(context.Weap) || SecondaryCompatible(context.Weap))
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

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		weap.SetupMagazines(
			PrimaryCompatible(weap.AsConst()) ? weap.AmmoType1 : null,
			SecondaryCompatible(weap.AsConst()) ? weap.AmmoType2 : null
		);
		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_MAGTYPE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ReserveFeed';
	}
}
