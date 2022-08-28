// Helpers specifically for the weapon mod menu.
extend class BIO_WeaponModSimulator
{
	string GetNodeTooltip(uint node) const
	{
		if (Nodes[node].IsMorph())
			return GetMorphTooltip(node);

		let n = Nodes[node];

		if (!n.Valid)
		{
			return String.Format(
				StringTable.Localize("$BIO_WMOD_INCOMPAT_TEMPLATE"),
				StringTable.Localize(n.GetTag()),
				StringTable.Localize(n.Message)
			);
		}

		return String.Format(
			"%s\n\n%s",
			StringTable.Localize(n.GetTag()),
			StringTable.Localize(n.Message)	
		);
	}

	string GetGeneSlotTooltip(uint slot) const
	{
		return Genes[slot].GetSummaryTooltip();
	}

	private string GetMorphTooltip(uint node) const
	{
		let morph = Nodes[node].MorphRecipe;

		let ret = String.Format(
			StringTable.Localize("$BIO_MENU_WEAPMOD_MORPH"),
			GetDefaultByType(morph.Output()).ColoredTag(),
			morph.RequirementString(),
			MorphCost(node),
			GetDefaultByType('BIO_Muta_General').GetTag()
		);

		if (morph.QualityAdded() > 0)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_MENU_WEAPMOD_MORPH_QUALITY"),
				morph.QualityAdded()
			);
		}

		return ret;
	}
}
