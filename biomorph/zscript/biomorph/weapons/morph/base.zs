enum BIO_WeaponMorphClassification : uint8
{
	BIO_WMC_UPGRADE,
	BIO_WMC_SIDEGRADE,
	BIO_WMC_DOWNGRADE
}

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

	abstract BIO_WeaponMorphClassification Classification() const;

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
