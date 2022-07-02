class BIO_WeaponMorphRecipe abstract
{
	private Array<class<BIO_Weapon> > InputTypes;

	abstract class<BIO_Weapon> Output() const;

	abstract bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const;

	// So the user knows what they did to fulfill the eligibility constraints.
	// Normally presented as a series of bullet points.
	abstract string RequirementString() const;

	// The cost for weapon metamorphosis is:
	// `((sim.GeneValue() + sim.CommitCost()) * MutagenCostMultiplier()) + MutagenCostAdded()`.
	// Note that `GeneValue()` includes the weapon's mod. cost multiplier.

	virtual uint MutagenCostAdded() const { return 0; }
	virtual uint MutagenCostMultiplier() const { return 1; }

	// For use in sidegrades and downgrades; as a reward for losing genes and
	// trading in one's more advanced weapon, the output gets more nodes baked
	// into its graph, and this effect is carried on to that weapon's upgrades.
	virtual uint QualityAdded() const { return 0; }

	// Return `false` if this recipe shouldn't be added to the global cache,
	// e.g. if it's for compatibility with a mod that wasn't loaded.
	virtual bool Enabled() const { return true; }

	void AddInputType(class<BIO_Weapon> type) const
	{
		if (!TakesInputType(type))
			InputTypes.Push(type);
	}

	bool TakesInputType(class<BIO_Weapon> type) const
	{
		return InputTypes.Find(type) != InputTypes.Size();
	}
}

class BIO_WMR_AutoShotgun : BIO_WeaponMorphRecipe
{
	final override class<BIO_Weapon> Output() const
	{
		return 'BIO_AutoShotgun';
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return
			sim.HasModifierWithCoreFlags(BIO_WCMF_FIRETIME_DEC) &&
			sim.HasModifierWithCoreFlags(BIO_WCMF_MAGSIZE_INC);
	}

	final override string RequirementString() const
	{
		return String.Format(
			"%s\n%s",
			StringTable.Localize("$BIO_WMR_REQ_FIRETIMEDEC_1"),
			StringTable.Localize("$BIO_WMR_REQ_MAGSIZEINC_1")
		);
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
}
