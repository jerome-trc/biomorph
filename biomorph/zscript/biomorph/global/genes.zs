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
			let gene_t = (class<BIO_ProceduralGene>)(AllActorClasses[i]);

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

	class<BIO_ProceduralGene> RandomGeneType() const
	{
		return (class<BIO_ProceduralGene>)(GeneLoot.Result());
	}
}

class BIO_ProcGeneBase
{
	string Tag;
	Array<BIO_WeaponModifier> Modifiers;
}

// Procedural modifier gene permutation queue.
extend class BIO_Global
{
	private Array<BIO_ProcGeneBase> ProcGeneQueue;

	void GenerateProcGenePermutations(uint count)
	{
		for (uint i = 0; i < count; i++)
		{
			Array<BIO_WeaponModifier> mods;
			let p = new('BIO_ProcGeneBase');
			p.Tag = BIO_ProceduralGene.GenerateTag();
			p.Modifiers.Move(mods);
			ProcGeneQueue.Push(p);
		}
	}

	BIO_ProcGeneBase PopProcGenePermutation()
	{
		if (ProcGeneQueue.Size() < 1)
			GenerateProcGenePermutations(5);

		let ret = ProcGeneQueue[ProcGeneQueue.Size() - 1];
		ProcGeneQueue.Pop();
		return ret;
	}
}
