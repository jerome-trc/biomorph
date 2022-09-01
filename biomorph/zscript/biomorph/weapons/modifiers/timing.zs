class BIO_WMod_FireTime : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (!context.Weap.FireTimesReducible())
			return false, "$BIO_WMOD_INCOMPAT_MINFIRETIMES";

		return
			context.Weap.FireTimeGroupCount() > 0,
			"$BIO_WMOD_INCOMPAT_NOFIRETIMES";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		Array<int> changes; // One per group
		changes.Resize(weap.FireTimeGroupCount());

		for (uint i = 0; i < changes.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				int delta = Min(3, weap.GetFireTimeGroup(i).PossibleReduction());

				if (delta <= 0)
					break;

				changes[i] -= delta;
				weap.GetFireTimeGroup(i).Modify(-delta);
			}
		}

		let ret = "";

		for (uint i = 0; i < changes.Size(); i++)
		{
			if (changes[i] == 0)
				continue;

			if (context.Weap.GetFireTimeGroup(i).IsHidden())
				continue;

			let qual = context.Weap.GetFireTimeGroup(i).GetTagAsQualifier();
			
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

class BIO_WMod_Spooling : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return BIO_Global.Get().WeaponHasOpMode(
			context.Weap.GetClass(),
			'BIO_OpMode_BinarySpool'
		), "$BIO_WMOD_INCOMPAT_NOSPOOL";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let globals = BIO_Global.Get();

		Array<class<BIO_WeaponOperatingMode> > opmode_ts;
		globals.FilteredOpModesForWeaponType(
			opmode_ts,
			context.Weap.GetClass(),
			'BIO_OpMode_BinarySpool'
		);

		// TODO: Gene/modifier rework needs to split this into primary/secondary
		weap.OpModes[0] = BIO_WeaponOperatingMode.Create(opmode_ts[0], weap);
		weap.OpModes[0].SideEffects(weap);

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_FIRETIME_DEC, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_SPOOLING_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SPOOLING_SUMM";
	}
}
