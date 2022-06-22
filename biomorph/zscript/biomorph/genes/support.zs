
class BIO_SGene_AddEast : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDEAST_TAG";
		Inventory.Icon 'GEN1B0';
		Inventory.PickupMessage "$BIO_SGENE_ADDEAST_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Summary "$BIO_MODSUP_ADDEAST_SUMM";
	}

	States
	{
	Spawn:
		GEN1 B 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let east = sim.GetNodeByPosition(
			myNode.Basis.PosX + 1, myNode.Basis.PosY
		);

		if (east == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODEEAST";

		if (!east.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODEAST";

		return true, "";
	}

	final override string Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let east = sim.GetNodeByPosition(
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
		Inventory.Icon 'GEN1A0';
		Inventory.PickupMessage "$BIO_SGENE_ADDNORTH_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Summary "$BIO_MODSUP_ADDNORTH_SUMM";
	}

	States
	{
	Spawn:
		GEN1 A 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let north = sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		if (north == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODENORTH";

		if (!north.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODNORTH";

		return true, "";
	}

	final override string Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let north = sim.GetNodeByPosition(
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
		Inventory.Icon 'GEN1C0';
		Inventory.PickupMessage "$BIO_SGENE_ADDSOUTH_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Summary "$BIO_MODSUP_ADDSOUTH_SUMM";
	}

	States
	{
	Spawn:
		GEN1 C 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let south = sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY + 1
		);

		if (south == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODESOUTH";

		if (!south.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODSOUTH";

		return true, "";
	}

	final override string Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let south = sim.GetNodeByPosition(
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
		Inventory.Icon 'GEN1D0';
		Inventory.PickupMessage "$BIO_SGENE_ADDWEST_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Summary "$BIO_MODSUP_ADDWEST_SUMM";
	}

	States
	{
	Spawn:
		GEN1 D 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let west = sim.GetNodeByPosition(
			myNode.Basis.PosX - 1, myNode.Basis.PosY
		);

		if (west == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODEWEST";

		if (!west.HasModifier())
			return false, "$BIO_MODSUP_INCOMPAT_NOMODWEST";

		return true, "";
	}

	final override string Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let west = sim.GetNodeByPosition(
			myNode.Basis.PosX - 1, myNode.Basis.PosY
		);

		west.Multiplier++;

		return "";
	}
}