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
			weap.MagazineFlags & BIO_MAGF_ETMF_1 &&
			weap.MagazineType1 != 'BIO_ETMFMagazine';
	}

	private static bool SecondaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.MagazineFlags & BIO_MAGF_ETMF_2 &&
			weap.MagazineType2 != 'BIO_ETMFMagazine';
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		uint count = context.NodeCount;

		bool
			a1 = weap.Magazine1 is 'BIO_ETMFMagazine',
			a2 = weap.Magazine2 is 'BIO_ETMFMagazine';

		// Check if this modifier has already been applied earlier in the graph
		if (!a1 && !a2)
		{
			bool
				compatP = PrimaryCompatible(weap.AsConst()),
				compatS = SecondaryCompatible(weap.AsConst());

			if (compatP)
			{
				weap.AmmoType1 = 'Cell';
				weap.MagazineType1 = 'BIO_ETMFMagazine';

				if (weap.ETMFDuration1 < 0)
					weap.MagazineSize1 = -(weap.ETMFDuration1 * TICRATE);
				else
					weap.MagazineSize1 = weap.ETMFDuration1;

				weap.AmmoUse1 = weap.ETMFCellCost1;
			}

			if (compatS)
			{
				weap.AmmoType2 = 'Cell';
				weap.MagazineType2 = 'BIO_ETMFMagazine';

				if (weap.ETMFDuration1 < 0)
					weap.MagazineSize2 = -(weap.ETMFDuration2 * TICRATE);
				else
					weap.MagazineSize2 = weap.ETMFDuration2;

				weap.AmmoUse2 = weap.ETMFCellCost2;
			}

			if (--count <= 0)
				return "";
		}

		weap.SetupAmmo();
		weap.SetupMagazines();

		a1 = weap.Magazine1 is 'BIO_ETMFMagazine';
		a2 = weap.Magazine2 is 'BIO_ETMFMagazine';

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

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_AMMOTYPE, BIO_WPMF_NONE;
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

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_MAGSIZE_INC, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_MagSize';
	}
}

class BIO_WMod_NthRoundCost : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return !context.Weap.Ammoless(), "$BIO_WMOD_INCOMPAT_AMMOLESS";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		let afx = weap.GetAffixByType('BIO_WAfx_NthRoundCost');

		if (afx == null)
		{
			afx = new('BIO_WAfx_NthRoundCost');
			weap.Affixes.Push(afx);
		}

		for (uint i = 0; i < context.NodeCount; i++)
			BIO_WAfx_NthRoundCost(afx).Upgrade();

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		let afx = context.Weap.GetAffixByType('BIO_WAfx_NthRoundCost');
		return afx.Description(context.Weap);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_AMMOUSE_DEC, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_NthRoundCost';
	}
}

class BIO_WAfx_NthRoundCost : BIO_WeaponAffix
{
	private bool EveryNCosts; // Otherwise, every nth round is free
	private uint8 Interval;
	private uint8 Counter1, Counter2;

	void Upgrade()
	{
		// First call acts as initialization
		if (Interval == 0)
		{
			Interval = 5;
			return;
		}

		if (EveryNCosts)
		{
			Interval++;
		}
		else if (--Interval <= 2)
		{
			EveryNCosts = true;
		}
	}

	final override void BeforeAmmoDeplete(BIO_Weapon weap,
		in out int ammoUse, bool altFire)
	{
		if (!EveryNCosts)
		{
			if (!altFire)
			{
				if (++Counter1 >= Interval)
				{
					ammoUse = 0;
					Counter1 = 0;
				}
			}
			else
			{
				if (++Counter2 >= Interval)
				{
					ammoUse = 0;
					Counter2 = 0;
				}
			}
		}
		else
		{
			if (!altFire)
			{
				if (++Counter1 >= Interval)
					Counter1 = 0;
				else
					ammoUse = 0;
			}
			else
			{
				if (++Counter2 >= Interval)
					Counter2 = 0;
				else
					ammoUse = 0;
			}
		}
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return String.Format(
			EveryNCosts ?
				StringTable.Localize("$BIO_WMOD_NTHROUNDCOST_DESC_NTHCOST") :
				StringTable.Localize("$BIO_WMOD_NTHROUNDCOST_DESC_NTHFREE"),
			Interval
		);
	}

	final override BIO_WeaponAffix Copy() const
	{
		let ret = new('BIO_WAfx_NthRoundCost');
		ret.EveryNCosts = EveryNCosts;
		ret.Interval = Interval;
		return ret;
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
		weap.AmmoType1 = weap.AmmoType2 = null;
		weap.AmmoUse1 = weap.AmmoUse2 = 0;
		weap.MagazineType1 = weap.MagazineType2 = null;
		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_MAGTYPE | BIO_WCMF_AMMOTYPE, BIO_WPMF_NONE;
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

		return false, "$BIO_WMOD_INCOMPAT_RESERVEFEED";
	}

	private static bool PrimaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType1 != null && weap.Magazine1 != null &&
			weap.MagazineSize1 > 0 && weap.ReloadCost1 > 0;
	}

	private static bool SecondaryCompatible(readOnly<BIO_Weapon> weap)
	{
		return
			weap.AmmoType2 != null && weap.Magazine2 != null &&
			weap.MagazineSize2 > 0 && weap.ReloadCost2 > 0;	
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		if (PrimaryCompatible(weap.AsConst()))
			weap.MagazineType1 = null;
		if (SecondaryCompatible(weap.AsConst()))
			weap.MagazineType2 = null;

		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_MAGTYPE, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ReserveFeed';
	}
}
