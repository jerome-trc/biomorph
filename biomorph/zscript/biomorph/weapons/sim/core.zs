// Members, some miscellaneous functions.
class BIO_WeaponModSimulator : Thinker
{
	const STATNUM = Thinker.STAT_STATIC + 1;

	private BIO_Weapon Weap;

	// Representation for the state of the player's gene inventory. Upon commit,
	// genes are given to/taken away from the player according to this.
	// Is sized against `BIO_Player::MaxGenesHeld`.
	Array<BIO_WMS_Gene> Genes;
	// Upon commit, the weapon's mod graph is rebuilt to reflect this.
	Array<BIO_WMS_Node> Nodes;
	// One for each node, including home. Home (elem. [0]) reflects
	// the state of the real weapon actor before modifiers.
	// Each snapshot N reflects the simulated state of the weapon after
	// applying the gene in node N, allowing undoes and resets.
	Array<BIO_WeaponSnapshot> Snapshots;

	final override void OnDestroy()
	{
		// Prevent VM exceptions during engine teardown
		if (Weap != null && Weap.Owner != null)
		{
			Revert();
			Weap.SetupAmmo();
			Weap.SetupMagazines();
		}

		super.OnDestroy();
	}

	private void RebuildGeneInventory()
	{
		if (Weap.Owner == null)
			return;

		Genes.Clear();

		for (Inventory i = Weap.Owner.Inv; i != null; i = i.Inv)
		{
			let gene = BIO_Gene(i);

			if (gene == null)
				continue;

			let simGene = new('BIO_WMS_GeneReal');
			simGene.Gene = gene;
			simGene.UpdateModifier();
			Genes.Push(simGene);
		}

		while (Genes.Size() < BIO_Player(Weap.Owner).MaxGenesHeld)
			Genes.Push(null);
	}

	readOnly<BIO_Weapon> GetWeapon() const { return Weap.AsConst(); }
	readOnly<BIO_WeaponModSimulator> AsConst() const { return self; }
}
