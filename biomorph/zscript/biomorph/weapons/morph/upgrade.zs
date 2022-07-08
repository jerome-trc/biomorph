class BIO_WMR_AutoShotgun : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_AutoShotgun';
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return
			sim.GraphIsFull() &&
			sim.HasModifierWithCoreFlags(BIO_WCMF_FIRETIME_DEC, 2) &&
			sim.HasModifierWithCoreFlags(BIO_WCMF_MAGSIZE_INC, 2);
	}

	final override string RequirementString() const
	{
		return String.Format(
			"%s\n%s\n%s",
			StringTable.Localize("$BIO_WMR_REQ_FULLGRAPH"),
			StringTable.Localize("$BIO_WMR_REQ_FIRETIMEDEC_2"),
			StringTable.Localize("$BIO_WMR_REQ_MAGSIZEINC_2")
		);
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_UPGRADE;
	}
}

class BIO_WMR_VolleyGun : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_VolleyGun';
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return sim.HasModifierWithCoreFlags(BIO_WCMF_MAGSIZE_INC, 2);
	}

	final override string RequirementString() const
	{
		return StringTable.Localize("$BIO_WMR_REQ_MAGSIZEINC_2");
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_UPGRADE;
	}
}

class BIO_WMR_DualMachineGun : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_DualMachineGun';
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return
			sim.HasModifierWithCoreFlags(BIO_WCMF_MAGSIZE_INC) &&
			sim.HasModifierWithCoreFlags(BIO_WCMF_FIRETIME_DEC) &&
			sim.HasModifierWithCoreFlags(BIO_WCMF_RELOADTIME_DEC) &&
			sim.HasModifierWithPipelineFlags(BIO_WPMF_SHOTCOUNT_INC) &&
			sim.HasModifierWithPipelineFlags(BIO_WPMF_DAMAGE_INC) &&
			sim.HasModifierWithPipelineFlags(BIO_WPMF_SPREAD_DEC);
	}

	final override string RequirementString() const
	{
		return String.Format(
			"%s\n%s\n%s\n%s\n%s\n%s",
			StringTable.Localize("$BIO_WMR_REQ_MAGSIZEINC_1"),
			StringTable.Localize("$BIO_WMR_REQ_FIRETIMEDEC_1"),
			StringTable.Localize("$BIO_WMR_REQ_RELOADTIMEDEC_1"),
			StringTable.Localize("$BIO_WMR_REQ_SHOTCOUNTINC_1"),
			StringTable.Localize("$BIO_WMR_REQ_DAMAGEINC_1"),
			StringTable.Localize("$BIO_WMR_REQ_SPREADDEC_1")
		);
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_UPGRADE;
	}
}

class BIO_WMR_Turbovulcan : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_Turbovulcan';
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return
			sim.ContainsGeneOfType('BIO_MGene_Spooling') &&
			sim.HasModifierWithCoreFlags(BIO_WCMF_FIRETIME_DEC, 2) &&
			sim.GraphIsFull();
	}

	final override string RequirementString() const
	{
		return String.Format(
			"%s\n%s\n%s",
			StringTable.Localize("$BIO_WMR_REQ_FULLGRAPH"),
			String.Format(
				StringTable.Localize("$BIO_WMR_REQ_SPOOLING"),
				GetDefaultByType('BIO_MGene_Spooling').GetTag()
			),
			StringTable.Localize("$BIO_WMR_REQ_FIRETIMEDEC_2")
		);
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_UPGRADE;
	}
}

class BIO_WMR_Minivulcan : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_Minivulcan';
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return
			sim.HasModifierWithPipelineFlags(BIO_WPMF_DAMAGE_INC);
	}

	final override string RequirementString() const
	{
		return String.Format(
			"%s",
			StringTable.Localize("$BIO_WMR_REQ_DAMAGEINC_1")
		);
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_UPGRADE;
	}
}
