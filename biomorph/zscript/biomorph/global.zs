// Note to reader: classes are defined using `extend` blocks for code folding.

class BIO_PlayerResetTracker
{
	PlayerInfo Player;
	uint Ammo, Health, Armor, Weapons;
}

class BIO_Global : Thinker
{
	static BIO_Global Create()
	{
		let iter = ThinkerIterator.Create('BIO_Global', STAT_STATIC);

		if (iter.Next(true) != null)
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data.");
			return null;
		}

		uint ms = MsTime();
		let ret = new('BIO_Global');
		ret.ChangeStatNum(STAT_STATIC);

		ret.PopulateWeaponLootTables();
		ret.PopulateMutagenLootTable();
		ret.PopulateGeneLootTable();
		ret.PopulateWeaponMorphCache();
		ret.PopulateZeroValueMonsterCache();

		for (uint i = 0; i < __BIO_WSCAT_COUNT__; i++)
		{
			if (ret.WeaponLoot[i].Size() < 1)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Failed to populate weapon loot array: %s",
					ret.WeaponLoot[i].Label);
			}
		}

		if (BIO_debug)
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);
		}

		return ret;
	}

	static clearscope BIO_Global Get()
	{
		let iter = ThinkerIterator.Create('BIO_Global', STAT_STATIC);
		return BIO_Global(iter.Next(true));
	}

	readOnly<BIO_Global> AsConst() const { return self; }

	final override void OnDestroy()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");
		
		super.OnDestroy();
	}
}

// Weapon loot tables.
extend class BIO_Global
{
	private BIO_LootTable WeaponLoot[__BIO_WSCAT_COUNT__];
	// Contains all tables in `WeaponLoot`.
	private BIO_LootTable WeaponLootMeta;

	private void PopulateWeaponLootTables()
	{
		for (uint i = 0; i < __BIO_WSCAT_COUNT__; i++)
		{
			WeaponLoot[i] = new('BIO_LootTable');

			switch (i)
			{
			case BIO_WSCAT_SHOTGUN:
				WeaponLoot[i].Label = "Weapon loot: Shotgun";
				break;
			case BIO_WSCAT_CHAINGUN:
				WeaponLoot[i].Label = "Weapon loot: Chaingun";
				break;
			case BIO_WSCAT_SSG:
				WeaponLoot[i].Label = "Weapon loot: Super Shotgun";
				break;
			case BIO_WSCAT_RLAUNCHER:
				WeaponLoot[i].Label = "Weapon loot: Rocket Launcher";
				break;
			case BIO_WSCAT_PLASRIFLE:
				WeaponLoot[i].Label = "Weapon loot: Plasma Rifle";
				break;
			case BIO_WSCAT_BFG9000:
				WeaponLoot[i].Label = "Weapon loot: BFG9000";
				break;
			case BIO_WSCAT_CHAINSAW:
				WeaponLoot[i].Label = "Weapon loot: Chainsaw";
				break;
			case BIO_WSCAT_PISTOL:
				WeaponLoot[i].Label = "Weapon loot: Pistol";
				break;
			default:
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Invalid weapon spawn category detected: %d", i);
				break;
			}
		}

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let weap_t = (class<BIO_Weapon>)(AllActorClasses[i]);

			if (weap_t == null || weap_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(weap_t);

			if (defs.SpawnCategory == __BIO_WSCAT_COUNT__)
				continue;

			WeaponLoot[defs.SpawnCategory].Push(weap_t,
				defs.Unique ? 1 : 50				
			);
		}

		WeaponLootMeta = new('BIO_LootTable');
		WeaponLootMeta.Label = "Weapon loot: meta";

		for (uint i = 0; i < __BIO_WSCAT_COUNT__; i++)
		{
			uint weight = 0;

			switch (i)
			{
			default:
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"Unhandled weapon spawn category: %d", i
				);
				break;
			case BIO_WSCAT_SHOTGUN:
			case BIO_WSCAT_CHAINGUN:
				weight = 18;
				break;
			case BIO_WSCAT_PISTOL:
			case BIO_WSCAT_SSG:
			case BIO_WSCAT_CHAINSAW:
				weight = 8;
				break;
			case BIO_WSCAT_RLAUNCHER:
				weight = 6;
				break;
			case BIO_WSCAT_PLASRIFLE:
				weight = 5;
				break;
			case BIO_WSCAT_BFG9000:
				weight = 1;
				break;
			}

			WeaponLootMeta.PushLayer(WeaponLoot[i], weight);
		}
	}

	class<BIO_Weapon> LootWeaponType(BIO_WeaponSpawnCategory category) const
	{
		return (class<BIO_Weapon>)(WeaponLoot[category].Result());
	}

	class<BIO_Weapon> AnyLootWeaponType() const
	{
		return (class<BIO_Weapon>)(WeaponLootMeta.Result());
	}
}

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

// Loot value buffer and related symbols.
extend class BIO_Global
{
	const LOOT_VALUE_THRESHOLD = 800;

	private Array<class<Actor> > ZeroValueMonsters;
	uint LootValueBuffer;

	bool DrainLootValueBuffer()
	{
		if (LootValueBuffer >= LOOT_VALUE_THRESHOLD)
		{
			LootValueBuffer -= LOOT_VALUE_THRESHOLD;
			return true;
		}

		return false;
	}

	clearscope uint GetMonsterValue(Actor mons) const
	{
		if (ZeroValueMonsters.Find(mons.GetClass()) != ZeroValueMonsters.Size())
			return 0;

		let ret = uint(Max(mons.Default.Health, mons.GetMaxHealth(true)));
		// TODO: Refine
		return ret;
	}

	private void PopulateZeroValueMonsterCache()
	{
		ZeroValueMonsters.Push((class<Actor>)('LostSoul'));
		// TODO: Support for however many monster packs
	}
}

// Functions used by console events,
// such as diagnostics and forced data regeneration.
extend class BIO_Global
{
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

	void RegenWeaponMorphCache()
	{
		WeaponMorphRecipes.Clear();
		PopulateWeaponMorphCache();
	}

	void PrintLootDiag() const
	{
		Console.Printf(
			Biomorph.LOGPFX_INFO ..
			"Loot value buffer: %d", LootValueBuffer
		);

		for (uint i = 0; i < WeaponLoot.Size(); i++)
			Console.Printf(Biomorph.LOGPFX_INFO .. WeaponLoot[i].ToString());

		Console.Printf(Biomorph.LOGPFX_INFO .. MutagenLoot.ToString());
		Console.Printf(Biomorph.LOGPFX_INFO .. GeneLoot.ToString());
	}
}

// Player inventory reset scheduling.
extend class BIO_Global
{
	private Array<BIO_PlayerResetTracker> PlayerResetTrackers;

	// Also performs lazy initialization.
	private BIO_PlayerResetTracker GetPlayerResetTracker(PlayerInfo pInfo) const
	{
		for (uint i = 0; i < PlayerResetTrackers.Size(); i++)
			if (PlayerResetTrackers[i].Player == pInfo)
				return PlayerResetTrackers[i];
		
		let ret = new('BIO_PlayerResetTracker');
		ret.Player = pInfo;
		PlayerResetTrackers.Push(ret);
		return ret;
	}

	bool ResetPlayerAmmo(PlayerInfo pInfo) const
	{
		let interval = BIO_CVar.ResetInterval_Ammo(pInfo);
		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Ammo == interval)
		{
			tracker.Ammo = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerArmor(PlayerInfo pInfo) const
	{
		let interval = BIO_CVar.ResetInterval_Armor(pInfo);
		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Armor == interval)
		{
			tracker.Armor = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerHealth(PlayerInfo pInfo) const
	{
		let interval = BIO_CVar.ResetInterval_Health(pInfo);
		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Health == interval)
		{
			tracker.Health = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerWeapons(PlayerInfo pInfo) const
	{
		let interval = BIO_CVar.ResetInterval_Weapons(pInfo);
		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Weapons == interval)
		{
			tracker.Weapons = 0;
			return true;
		}

		return false;
	}
}
