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
