class BIO_WMod_NodeMultiEast : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let east = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX + 1, myNode.Basis.PosY
		);

		if (east == null)
			return false, "$BIO_WMOD_INCOMPAT_NONODEEAST";

		return true, "";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let east = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX + 1, myNode.Basis.PosY
		);

		for (uint i = 0; i < context.NodeCount; i++)
			east.Multiplier++;

		return String.Format(
			StringTable.Localize("$BIO_WMOD_NODEMULTI_DESC"),
			east.Basis.UUID
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_NONE;
	}

	final override BIO_WeaponModSimPass SimPass() const
	{
		return BIO_SIMPASS_GRAPHMOD;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_EASTNODEMULTI_TAG";
	}

	final override string Summary() const
	{
		return String.Format(
			"%s\n%s",
			StringTable.Localize("$BIO_WMOD_NODEMULTIEAST_SUMM"),
			StringTable.Localize("$BIO_WMOD_NODEMULTI_SUMMQUAL")
		);
	}
}

class BIO_WMod_NodeMultiNorth : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let north = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		if (north == null)
			return false, "$BIO_WMOD_INCOMPAT_NONODENORTH";

		return true, "";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let north = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		for (uint i = 0; i < context.NodeCount; i++)
			north.Multiplier++;

		return String.Format(
			StringTable.Localize("$BIO_WMOD_NODEMULTI_DESC"),
			north.Basis.UUID
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_NONE;
	}

	final override BIO_WeaponModSimPass SimPass() const
	{
		return BIO_SIMPASS_GRAPHMOD;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_NODEMULTINORTH_TAG";
	}

	final override string Summary() const
	{
		return String.Format(
			"%s\n%s",
			StringTable.Localize("$BIO_WMOD_NODEMULTINORTH_SUMM"),
			StringTable.Localize("$BIO_WMOD_NODEMULTI_SUMMQUAL")
		);
	}
}

class BIO_WMod_NodeMultiSouth : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let south = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY + 1
		);

		if (south == null)
			return false, "$BIO_WMOD_INCOMPAT_NONODESOUTH";

		return true, "";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let south = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY + 1
		);

		for (uint i = 0; i < context.NodeCount; i++)
			south.Multiplier++;

		return String.Format(
			StringTable.Localize("$BIO_WMOD_NODEMULTI_DESC"),
			south.Basis.UUID
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_NONE;
	}

	final override BIO_WeaponModSimPass SimPass() const
	{
		return BIO_SIMPASS_GRAPHMOD;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_NODEMULTISOUTH_TAG";
	}

	final override string Summary() const
	{
		return String.Format(
			"%s\n%s",
			StringTable.Localize("$BIO_WMOD_NODEMULTISOUTH_SUMM"),
			StringTable.Localize("$BIO_WMOD_NODEMULTI_SUMMQUAL")
		);
	}
}

class BIO_WMod_NodeMultiWest : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let west = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX - 1, myNode.Basis.PosY
		);

		if (west == null)
			return false, "$BIO_WMOD_INCOMPAT_NONODEWEST";

		return true, "";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let west = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX - 1, myNode.Basis.PosY
		);

		for (uint i = 0; i < context.NodeCount; i++)
			west.Multiplier++;

		return String.Format(
			StringTable.Localize("$BIO_WMOD_NODEMULTI_DESC"),
			west.Basis.UUID
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_NONE;
	}

	final override BIO_WeaponModSimPass SimPass() const
	{
		return BIO_SIMPASS_GRAPHMOD;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_NODEMULTIWEST_TAG";
	}

	final override string Summary() const
	{
		return String.Format(
			"%s\n%s",
			StringTable.Localize("$BIO_WMOD_NODEMULTIWEST_SUMM"),
			StringTable.Localize("$BIO_WMOD_NODEMULTI_SUMMQUAL")
		);
	}
}