// Weapon metamorphosis recipe cache.

extend class BIO_Global
{
	private Array<BIO_WeaponMorphRecipe> WeaponMorphRecipes;

	const LMPNAME_WEAPMORPH = "BIOWMORP";

	private void PopulateWeaponMorphCache()
	{
		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			let recipe_t = (class<BIO_WeaponMorphRecipe>)(AllClasses[i]);

			if (recipe_t == null || recipe_t.IsAbstract())
				continue;

			let recipe = BIO_WeaponMorphRecipe(new(recipe_t));

			if (!recipe.Enabled())
				continue;

			WeaponMorphRecipes.Push(recipe);
		}

		int lump = -1, next = 0;

		do
		{
			lump = Wads.FindLump(LMPNAME_WEAPMORPH, next, Wads.GLOBALNAMESPACE);

			if (lump == -1)
				break;

			next = lump + 1;

			let content = Wads.ReadLump(lump);
			Array<string> lines;
			content.Split(lines, "\n", TOK_SKIPEMPTY);

			BIO_WeaponMorphRecipe current = null;

			for (uint i = 0; i < lines.Size(); i++)
			{
				if (lines[i].Length() < 2)
					continue;

				let char1 = lines[i].Left(1);

				if (char1 ~== "\n" || lines[i].Left(2) ~== "//")
					continue;

				if (!(char1 ~== "\t"))
				{
					class<BIO_WeaponMorphRecipe> morph_t = lines[i];

					if (morph_t == null)
					{
						Console.Printf(
							Biomorph.LOGPFX_WARN ..
							"Invalid weapon morph recipe class name: %s (line %d)",
							lines[i], i
						);
					}

					current = GetMorphByType(morph_t);
					continue;
				}

				class<BIO_Weapon> weap_t = lines[i].Mid(1);

				if (weap_t == null)
				{
					Console.Printf(
						Biomorph.LOGPFX_WARN ..
						"Invalid weapon class name: %s (line %d)",
						lines[i], i
					);
					continue;
				}

				if (current == null)
				{
					Console.Printf(
						Biomorph.LOGPFX_WARN ..
						"Attempted to push weapon class `%s` as a morph input "
						"without first specifying a recipe (line %d).",
						weap_t, i
					);
					continue;
				}

				current.AddInputType(weap_t);
			}
		} while (true);
	}

	BIO_WeaponMorphRecipe GetMorphByType(class<BIO_WeaponMorphRecipe> morph_t) const
	{
		for (uint i = 0; i < WeaponMorphRecipes.Size(); i++)
			if (WeaponMorphRecipes[i].GetClass() == morph_t)
				return WeaponMorphRecipes[i];

		Console.Printf(
			Biomorph.LOGPFX_ERR ..
			"Failed to find weapon morph recipe by type: %s",
			morph_t.GetClassName()
		);
		return null;
	}

	void GetMorphsFromWeaponType(class<BIO_Weapon> type,
		in out Array<BIO_WeaponMorphRecipe> recipes)
	{
		if (recipes.Size() > 0)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"`GetMorphsFromWeaponType()` illegally received a non-empty array."
			);
			return;
		}

		for (uint i = 0; i < WeaponMorphRecipes.Size(); i++)
			if (WeaponMorphRecipes[i].TakesInputType(type))
				recipes.Push(WeaponMorphRecipes[i]);
	}
}
