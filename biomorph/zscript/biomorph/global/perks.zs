// Perk loot table.

extend class BIO_Global
{
	private BIO_LootTable PerkLoot;

	private void PopulatePerkLootTable()
	{
		PerkLoot = new('BIO_LootTable');
		PerkLoot.Label = "Perk Loot";

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let perk_t = (class<BIO_Perk>)(AllActorClasses[i]);

			if (perk_t == null || perk_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(perk_t);

			if (!defs.CanGenerate())
				continue;

			if (defs.LootWeight <= 0)
			{
				Console.Printf(
					Biomorph.LOGPFX_WARN ..
					"Perk class `%s` allows generation as loot "
					"but has an invalid loot weight of 0.",
					perk_t.GetClassName()
				);
				continue;
			}

			PerkLoot.Push(perk_t, defs.LootWeight);
		}
	}

	class<BIO_Perk> RandomPerkType() const
	{
		return (class<BIO_Perk>)(PerkLoot.Result());
	}
}
