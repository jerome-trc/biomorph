class BIO_WMod_FireTime : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (!context.Weap.FireTimesReducible())
			return false, "$BIO_WMOD_INCOMPAT_MINFIRETIMES";

		return
			context.Weap.FireTimeGroups.Size() > 0,
			"$BIO_WMOD_INCOMPAT_NOFIRETIMES";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		Array<int> changes; // One per group
		changes.Resize(weap.FireTimeGroups.Size());

		for (uint i = 0; i < changes.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				int delta = Min(3, weap.FireTimeGroups[i].PossibleReduction());

				if (delta <= 0)
					break;

				changes[i] -= delta;
				weap.FireTimeGroups[i].Modify(-delta);
			}
		}

		let ret = "";

		for (uint i = 0; i < changes.Size(); i++)
		{
			if (changes[i] == 0)
				continue;

			if (context.Weap.FireTimeGroups[i].IsHidden())
				continue;

			let qual = context.Weap.FireTimeGroups[i].GetTagAsQualifier();
			
			if (qual.Length() > 1)
				qual = " " .. qual;

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_FIRETIME_DESC"),
				qual,
				float(changes[i]) / float(TICRATE)
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_FIRETIME_DEC, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_FIRETIME_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_FIRETIME_SUMM";
	}
}

class BIO_WMod_ReloadTime : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (!context.Weap.ReloadTimesReducible())
			return false, "$BIO_WMOD_INCOMPAT_MINRELOADTIMES";
	
		return
			context.Weap.ReloadTimeGroups.Size() > 0,
			"$BIO_WMOD_INCOMPAT_NORELOADTIMES";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		Array<int> changes; // One per group
		changes.Resize(weap.ReloadTimeGroups.Size());

		for (uint i = 0; i < changes.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				int delta = Min(3, weap.ReloadTimeGroups[i].PossibleReduction());

				if (delta <= 0)
					break;

				changes[i] -= delta;
				weap.ReloadTimeGroups[i].Modify(-delta);
			}
		}

		let ret = "";

		for (uint i = 0; i < changes.Size(); i++)
		{
			if (changes[i] == 0)
				continue;

			if (context.Weap.ReloadTimeGroups[i].IsHidden())
				continue;

			let qual = context.Weap.ReloadTimeGroups[i].GetTagAsQualifier();
			
			if (qual.Length() > 1)
				qual = " " .. qual;

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_RELOADTIME_DESC"),
				qual,
				float(changes[i]) / float(TICRATE)
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_RELOADTIME_DEC, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_RELOADTIME_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_RELOADTIME_SUMM";
	}
}
