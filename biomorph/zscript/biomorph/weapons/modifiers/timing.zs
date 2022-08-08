class BIO_WMod_FireTime : BIO_WeaponModifier
{
	private Array<int> Changes; // One per group

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (!context.Weap.FireTimesReducible())
			return false, "$BIO_WMOD_INCOMPAT_MINFIRETIMES";

		return
			context.Weap.FireTimeGroups.Size() > 0,
			"$BIO_WMOD_INCOMPAT_NOFIRETIMES";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		Changes.Clear();
		Changes.Resize(weap.FireTimeGroups.Size());

		for (uint i = 0; i < Changes.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				int delta = Min(3, weap.FireTimeGroups[i].PossibleReduction());

				if (delta <= 0)
					break;

				Changes[i] -= delta;
				weap.FireTimeGroups[i].Modify(-delta);
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

			if (context.Weap.FireTimeGroups[i].IsHidden())
				continue;

			let qual = context.Weap.FireTimeGroups[i].GetTagAsQualifier();
			
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
	private int FireTimeChange;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (context.Weap.FindState('SpoolUp') == null ||
			context.Weap.FindState('FireSpooled') == null ||
			context.Weap.FindState('SpoolDown') == null)
			return false, "$BIO_WMOD_INCOMPAT_NOSPOOL";

		if (context.Weap.bSpooling)
			return false, "$BIO_WMOD_INCOMPAT_ALREADYSPOOLING";

		return true, "";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		weap.bSpooling = true;

		for (uint i = 0; i < weap.FireTimeGroups.Size(); i++)
		{
			let ftg = weap.FireTimeGroups[i];

			if (!ftg.IsAuxiliary())
				ftg.Flags |= BIO_STGF_HIDDEN;

			switch (ftg.Designation)
			{
			case BIO_STGD_SPOOLUP:
			case BIO_STGD_FIRESPOOLED:
			case BIO_STGD_SPOOLDOWN:
				ftg.Flags &= ~BIO_STGF_HIDDEN;
			default:
				break;
			}
		}

		let ftgFire = context.Weap.GetFireTimeGroupByDesignation(BIO_STGD_FIRESPOOLED);

		if (ftgFire == null)
			return "$BIO_WMOD_SPOOLING_NOBENEFIT";
	
		let pr = ftgFire.PossibleReduction();

		if (pr < 1)
			return "$BIO_WMOD_SPOOLING_NOBENEFIT";

		FireTimeChange = -Min(4, pr);
		ftgFire.Modify(FireTimeChange);
		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		let ret = StringTable.Localize("$BIO_WMOD_SPOOLING_DESC");

		if (FireTimeChange == 0)
			return ret;

		ret = ret .. "\n";
		let ftg = context.Weap.GetFireTimeGroupByDesignation(BIO_STGD_FIRESPOOLED);
		let qual = " " .. ftg.GetTagAsQualifier();

		ret.AppendFormat(
			StringTable.Localize("$BIO_WMOD_FIRETIME_DESC"),
			qual, float(FireTimeChange) / float(TICRATE)
		);
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_FIRETIME_DEC, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Spooling';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_Spooling');
		ret.FireTimeChange = FireTimeChange;
		return ret;
	}
}
