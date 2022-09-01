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

	protected static string CommonDualWieldRequirements()
	{
		return StringTable.Localize("$BIO_WMR_REQ_DUALWIELDCOMMON");
	}

	protected static bool CommonDualWieldConditions(readOnly<BIO_WeaponModSimulator> sim)
	{
		static const BIO_WeaponCoreModFlags CORE_IMPROVEMENTS[] = {
			BIO_WCMF_SWITCHSPEED_INC,
			BIO_WCMF_AMMOUSE_DEC,
			BIO_WCMF_RELOADCOST_DEC,
			BIO_WCMF_RELOADOUTPUT_INC,
			BIO_WCMF_MAGSIZE_INC,
			BIO_WCMF_FIRETIME_DEC,
			BIO_WCMF_RELOADTIME_DEC
		};

		static const BIO_WeaponCoreModFlags PIPELINE_IMPROVEMENTS[] = {
			BIO_WPMF_SHOTCOUNT_INC,
			BIO_WPMF_DAMAGE_INC,
			BIO_WPMF_SPREAD_DEC,
			BIO_WPMF_SPLASHDAMAGE_INC,
			BIO_WPMF_SPLASHRADIUS_INC,
			BIO_WPMF_PROJSPEED_INC,
			BIO_WPMF_BOUNCE_ADD,
			BIO_WPMF_SEEKING_ADD,
			BIO_WPMF_LIFESTEAL_INC,
			BIO_WPMF_MELEERANGE_INC
		};

		if (sim.GraphIsHomogeneous() && sim.GraphIsFull())
			return true;

		BIO_WeaponCoreModFlags coreFlags = BIO_WCMF_NONE;
		BIO_WeaponPipelineModFlags pplFlags = BIO_WPMF_NONE;

		for (uint i = 0; i < sim.Nodes.Size(); i++)
		{
			if (!sim.Nodes[i].IsOccupied())
				continue;

			BIO_WeaponCoreModFlags cf = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags pf = BIO_WPMF_NONE;
			[cf, pf] = sim.Nodes[i].CombinedModifierFlags();

			coreFlags |= cf;
			pplFlags |= pf;
		}

		uint variety = 0;

		for (uint i = 0; i < CORE_IMPROVEMENTS.Size(); i++)
			if (coreFlags & CORE_IMPROVEMENTS[i])
				variety++;

		for (uint i = 0; i < PIPELINE_IMPROVEMENTS.Size(); i++)
			if (pplFlags & PIPELINE_IMPROVEMENTS[i])
				variety++;

		return variety >= Min(
			CORE_IMPROVEMENTS.Size() + PIPELINE_IMPROVEMENTS.Size(),
			sim.Nodes.Size() - 1
		);
	}
}
