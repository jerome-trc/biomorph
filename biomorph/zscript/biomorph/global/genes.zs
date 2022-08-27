// Gene loot table.
extend class BIO_Global
{
	private BIO_LootTable GeneLoot;

	private void PopulateGeneLootTable()
	{
		GeneLoot = new('BIO_LootTable');
		GeneLoot.Label = "Gene Loot";

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let gene_t = (class<BIO_Gene>)(AllActorClasses[i]);

			if (gene_t == null || gene_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(gene_t);

			if (!defs.CanGenerate())
				continue;

			if (defs.LootWeight <= 0)
			{
				Console.Printf(
					Biomorph.LOGPFX_WARN ..
					"Gene class `%s` allows generation as loot "
					"but has an invalid loot weight of 0.",
					gene_t.GetClassName()
				);
				continue;
			}

			GeneLoot.Push(gene_t, defs.LootWeight);
		}
	}

	class<BIO_Gene> RandomGeneType() const
	{
		return (class<BIO_Gene>)(GeneLoot.Result());
	}
}
