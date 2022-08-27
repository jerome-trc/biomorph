// Mutagen loot table.

extend class BIO_Global
{
	private BIO_LootTable MutagenLoot;

	private void PopulateMutagenLootTable()
	{
		MutagenLoot = new('BIO_LootTable');
		MutagenLoot.Label = "Mutagen Loot";

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let muta_t = (class<BIO_Mutagen>)(AllActorClasses[i]);

			if (muta_t == null || muta_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(muta_t);

			if (defs.NoLoot)
				continue;

			if (defs.LootWeight <= 0)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Mutagen class `%s` is not marked `NoLoot` "
					"but has no drop weight.", muta_t.GetClassName());
				continue;
			}

			MutagenLoot.Push(muta_t, defs.LootWeight);
		}
	}

	class<BIO_Mutagen> RandomMutagenType() const
	{
		return (class<BIO_Mutagen>)(MutagenLoot.Result());
	}
}
