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
		return CommonDualWieldConditions(sim);
	}

	final override string RequirementString() const
	{
		return CommonDualWieldRequirements();
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_UPGRADE;
	}
}
