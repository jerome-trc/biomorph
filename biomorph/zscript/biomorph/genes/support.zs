class BIO_SGene_AddNorth : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDNORTH_TAG";
		Inventory.Icon 'GENSN0';
		Inventory.PickupMessage "$BIO_SGENE_ADDNORTH_PKUP";
	}

	States
	{
	Spawn:
		GENS N 6;
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

		let mod = north.GetModifier();

		if (mod == null)
			return false, "$BIO_MODSUP_INCOMPAT_NOMODNORTH";

		return true, "";
	}

	final override void Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let north = sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		north.Multiplier++;
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_MODSUP_ADDNORTH_SUMM");
	}
}
