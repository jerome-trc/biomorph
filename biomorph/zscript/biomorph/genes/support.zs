class BIO_SGene_AddEast : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDEAST_TAG";
		Inventory.Icon 'GENXB0';
		Inventory.PickupMessage "$BIO_SGENE_ADDEAST_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_SupportGene.Summary "$BIO_MODSUP_ADDEAST_SUMM";
	}

	States
	{
	Spawn:
		GENX B 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let east = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX + 1, myNode.Basis.PosY
		);

		if (east == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODEEAST";

		if (!east.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODEAST";

		return true, "";
	}

	final override string Apply(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let east = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX + 1, myNode.Basis.PosY
		);

		east.Multiplier++;

		return "";
	}
}

class BIO_SGene_AddNorth : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDNORTH_TAG";
		Inventory.Icon 'GENXA0';
		Inventory.PickupMessage "$BIO_SGENE_ADDNORTH_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_SupportGene.Summary "$BIO_MODSUP_ADDNORTH_SUMM";
	}

	States
	{
	Spawn:
		GENX A 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let north = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		if (north == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODENORTH";

		if (!north.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODNORTH";

		return true, "";
	}

	final override string Apply(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let north = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		north.Multiplier++;

		return "";
	}
}

class BIO_SGene_AddSouth : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDSOUTH_TAG";
		Inventory.Icon 'GENXC0';
		Inventory.PickupMessage "$BIO_SGENE_ADDSOUTH_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_SupportGene.Summary "$BIO_MODSUP_ADDSOUTH_SUMM";
	}

	States
	{
	Spawn:
		GENX C 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let south = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY + 1
		);

		if (south == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODESOUTH";

		if (!south.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODSOUTH";

		return true, "";
	}

	final override string Apply(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let south = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY + 1
		);

		south.Multiplier++;

		return "";
	}
}

class BIO_SGene_AddWest : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDWEST_TAG";
		Inventory.Icon 'GENXD0';
		Inventory.PickupMessage "$BIO_SGENE_ADDWEST_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_SupportGene.Summary "$BIO_MODSUP_ADDWEST_SUMM";
	}

	States
	{
	Spawn:
		GENX D 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let west = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX - 1, myNode.Basis.PosY
		);

		if (west == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODEWEST";

		if (!west.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODWEST";

		return true, "";
	}

	final override string Apply(BIO_GeneContext context) const
	{
		let myNode = context.Sim.Nodes[context.Node];

		let west = context.Sim.GetNodeByPosition(
			myNode.Basis.PosX - 1, myNode.Basis.PosY
		);

		west.Multiplier++;

		return "";
	}
}
