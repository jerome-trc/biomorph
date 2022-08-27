// Functions used by console events,
// such as diagnostics and forced data regeneration.

extend class BIO_Global
{
	void RegenLootCore()
	{
		ZeroValueMonsters.Clear();
		MonsterLoot.Clear();
		SetupLootCore();
	}

	void RegenWeaponLoot()
	{
		for (uint i = 0; i < WeaponLoot.Size(); i++)
			WeaponLoot[i].Clear();

		PopulateWeaponLootTables();
	}

	void RegenMutagenLoot()
	{
		MutagenLoot.Clear();
		PopulateMutagenLootTable();
	}

	void RegenGeneLoot()
	{
		GeneLoot.Clear();
		PopulateGeneLootTable();
	}

	void RegenWeaponOpModeCache()
	{
		WeaponOpModeCache.Clear();
		PopulateWeaponOpModeCache();
	}

	void RegenWeaponMorphCache()
	{
		WeaponMorphRecipes.Clear();
		PopulateWeaponMorphCache();
	}

	void PrintLootDiag() const
	{
		Console.Printf(
			Biomorph.LOGPFX_INFO .. "\n"
			"\tLoot value buffer: %d\n"
			"\tLoot value multiplier: %.2f",
			LootValueBuffer, LootValueMultiplier
		);

		if (MonsterLoot.Size() > 0)
		{
			string mloot = Biomorph.LOGPFX_INFO .. "Monster loot pairs:\n";

			for (uint i = 0; i < MonsterLoot.Size(); i++)
			{
				mloot.AppendFormat(
					"\t%s - %s (exact: %s)\n",
					MonsterLoot[i].MonsterType.GetClassName(),
					MonsterLoot[i].SpawnerType.GetClassName(),
					MonsterLoot[i].Exact ? "true" : "false"
				);
			}

			mloot.DeleteLastCharacter();
			Console.Printf(mloot);
		}

		for (uint i = 0; i < WeaponLoot.Size(); i++)
			Console.Printf(Biomorph.LOGPFX_INFO .. WeaponLoot[i].ToString());

		Console.Printf(Biomorph.LOGPFX_INFO .. MutagenLoot.ToString());
		Console.Printf(Biomorph.LOGPFX_INFO .. GeneLoot.ToString());
	}
}
