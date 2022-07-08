class BIO_WMR_Microvulcan : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_Microvulcan';
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_DOWNGRADE;
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return sim.GraphIsFull();
	}

	final override uint QualityAdded() const
	{
		return 1;
	}

	final override string RequirementString() const
	{
		return String.Format("%s", StringTable.Localize("$BIO_WMR_REQ_FULLGRAPH"));
	}
}

class BIO_WMR_PumpShotgun : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_PumpShotgun';
	}

	final override BIO_WeaponMorphClassification Classification() const
	{
		return BIO_WMC_DOWNGRADE;
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return sim.GraphIsFull();
	}

	final override uint QualityAdded() const
	{
		return 1;
	}

	final override string RequirementString() const
	{
		return String.Format("%s", StringTable.Localize("$BIO_WMR_REQ_FULLGRAPH"));
	}
}
