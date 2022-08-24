class BIO_WMod_FireTime : BIO_WeaponModifier
{
	private Array<int> Changes; // One per group

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (!context.Weap.FireTimesReducible())
			return false, "$BIO_WMOD_INCOMPAT_MINFIRETIMES";

		return
			context.Weap.FireTimeGroupCount() > 0,
			"$BIO_WMOD_INCOMPAT_NOFIRETIMES";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		Changes.Clear();
		Changes.Resize(weap.FireTimeGroupCount());

		for (uint i = 0; i < Changes.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				int delta = Min(3, weap.GetFireTimeGroup(i).PossibleReduction());

				if (delta <= 0)
					break;

				Changes[i] -= delta;
				weap.GetFireTimeGroup(i).Modify(-delta);
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < Changes.Size(); i++)
		{
			if (Changes[i] == 0)
				continue;

			if (context.Weap.GetFireTimeGroup(i).IsHidden())
				continue;

			let qual = context.Weap.GetFireTimeGroup(i).GetTagAsQualifier();
			
			if (qual.Length() > 1)
				qual = " " .. qual;

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_FIRETIME_DESC"),
				qual,
				float(Changes[i]) / float(TICRATE)
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

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_FireTime';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_FireTime');
		ret.Changes.Copy(Changes);
		return ret;
	}
}

class BIO_WMod_ReloadTime : BIO_WeaponModifier
{
	private Array<int> Changes; // One per group

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (!context.Weap.ReloadTimesReducible())
			return false, "$BIO_WMOD_INCOMPAT_MINRELOADTIMES";
	
		return
			context.Weap.ReloadTimeGroups.Size() > 0,
			"$BIO_WMOD_INCOMPAT_NORELOADTIMES";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		Changes.Clear();
		Changes.Resize(weap.ReloadTimeGroups.Size());

		for (uint i = 0; i < Changes.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				int delta = Min(3, weap.ReloadTimeGroups[i].PossibleReduction());

				if (delta <= 0)
					break;

				Changes[i] -= delta;
				weap.ReloadTimeGroups[i].Modify(-delta);
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < Changes.Size(); i++)
		{
			if (Changes[i] == 0)
				continue;

			if (context.Weap.ReloadTimeGroups[i].IsHidden())
				continue;

			let qual = context.Weap.ReloadTimeGroups[i].GetTagAsQualifier();
			
			if (qual.Length() > 1)
				qual = " " .. qual;

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_RELOADTIME_DESC"),
				qual,
				float(Changes[i]) / float(TICRATE)
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

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ReloadTime';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_ReloadTime');
		ret.Changes.Copy(Changes);
		return ret;
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

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
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

		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_FIRETIME_DEC, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Spooling';
	}
}
