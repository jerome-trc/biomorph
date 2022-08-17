// Note to reader: classes are defined using `extend` blocks for code folding.

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

		ret.DetectContext();
		ret.PopulateWeaponLootTables();
		ret.PopulateWeaponMorphCache();
		ret.PopulateWeaponOpModeCache();
		ret.PopulateMutagenLootTable();
		ret.PopulateGeneLootTable();
		ret.PopulatePerkLootTable();
		ret.SetupLootCore();

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

// Global context information.

enum BIO_GlobalContext : uint8
{
	BIO_GCTX_NONE = 0,
	BIO_GCTX_VALIANT = 1 << 0
}

extend class BIO_Global
{
	private BIO_GlobalContext ContextFlags;

	private void DetectContext()
	{
		if (BIO_Utils.Valiant())
		{
			ContextFlags |= BIO_GCTX_VALIANT;
		}
	}

	bool InValiant() const
	{
		return ContextFlags & BIO_GCTX_VALIANT;
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

// Weapon operating mode cache.
extend class BIO_Global
{
	private Array<BIO_WeaponOperatingMode> WeaponOpModeCache;

	private void PopulateWeaponOpModeCache()
	{
		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			let opmode_t = (class<BIO_WeaponOperatingMode>)(AllClasses[i]);

			if (opmode_t == null || opmode_t.IsAbstract())
				continue;

			WeaponOpModeCache.Push(BIO_WeaponOperatingMode(new(opmode_t)));
		}
	}

	void AllOpModesForWeaponType(
		in out Array<class<BIO_WeaponOperatingMode> > opmodes,
		class<BIO_Weapon> weap_t
	) const
	{
		for (uint i = 0; i < WeaponOpModeCache.Size(); i++)
			if (WeaponOpModeCache[i].WeaponType() == weap_t)
				opmodes.Push(WeaponOpModeCache[i].GetClass());
	}

	// Returns `true` if any operating modes matching the criteria were found.
	bool FilteredOpModesForWeaponType(
		in out Array<class<BIO_WeaponOperatingMode> > opmodes,
		class<BIO_Weapon> weap_t,
		class<BIO_WeaponOperatingMode> filter
	) const
	{
		for (uint i = 0; i < WeaponOpModeCache.Size(); i++)
			if (WeaponOpModeCache[i].WeaponType() == weap_t &&
				WeaponOpModeCache[i] is filter)
			opmodes.Push(WeaponOpModeCache[i].GetClass());

		return opmodes.Size() > 0;
	}

	bool WeaponHasOpMode(class<BIO_Weapon> weap_t, class<BIO_WeaponOperatingMode> filter) const
	{
		for (uint i = 0; i < WeaponOpModeCache.Size(); i++)
			if (WeaponOpModeCache[i].WeaponType() == weap_t &&
				WeaponOpModeCache[i] is filter)
			return true;

		return false;
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

class BIO_LootTable : BIO_WeightedRandomTable
{
	final override uint RandomImpl() const
	{
		return Random[BIO_Loot](1, WeightSum);
	}
}

class BIO_MonsterLootPair
{
	class<Actor> MonsterType;
	class<BIO_LootSpawner> SpawnerType;
	// If `true`, check `GetClass() == MonsterType`.
	// Else, check `Monster is MonsterType`.
	bool Exact;
}

// After being spawned, `Target` will point to the killed monster.
class BIO_LootSpawner : BIO_IntangibleActor abstract
{
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 1 { invoker.SpawnLoot(); }
		Stop;
	}

	// If returning `false`, this type will not be cached at new-game.
	virtual bool CanSpawn() const { return true; }

	abstract void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const;

	protected abstract void SpawnLoot() const;

	protected void PlayRareSound() const
	{
		A_StartSound("bio/loot/rare", CHAN_AUTO);
	}

	protected void PlayVeryRareSound() const
	{
		A_StartSound("bio/loot/veryrare", CHAN_AUTO);
	}
}

// Loot core subsystem. Includes the loot value buffer and multiplier,
// list of monsters which give 0 value, and monster/loot spawner key-value pairs.
extend class BIO_Global
{
	const LOOT_VALUE_THRESHOLD = 1000;

	// Collection of monster types which don't contribute to the loot value buffer.
	// Ensures there's no incentive to farm Pain Elementals or The Hungry, etc.
	// It's context-sensitive; monsters only get added if the mod which
	// defines them has been loaded.
	// (Currently unused! Never gets written to or read from. May be used later.)
	private Array<class<Actor> > ZeroValueMonsters;
	private float LootValueMultiplier; // Applied after all other factors.
	uint LootValueBuffer;

	Array<BIO_MonsterLootPair> MonsterLoot;

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
		let ret = uint(Max(mons.Default.Health, mons.GetMaxHealth(true)));

		if (mons.bAlwaysFast)
			ret *= 1.2;

		if (mons.bJumpDown)
			ret *= 1.2;

		if (mons.bMissileMore)
			ret *= 1.2;

		if (mons.bMissileEvenMore)
			ret *= 1.2;

		if (mons.bNoInfighting)
			ret *= 1.2;

		if (mons.bNoTarget)
			ret *= 1.2;

		if (mons.bQuickToRetaliate)
			ret *= 1.2;

		// TODO: Refine further
		return ret * LootValueMultiplier;
	}

	clearscope float GetLootValueMultiplier() const { return LootValueMultiplier; }

	void ModifyLootValueMultiplier(float change)
	{
		LootValueMultiplier = Max(0.0, LootValueMultiplier + change);		
	}

	private void SetupLootCore()
	{
		LootValueMultiplier = 1.0;

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let loot_t = (class<BIO_LootSpawner>)(AllActorClasses[i]);

			if (loot_t == null || loot_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(loot_t);

			if (!defs.CanSpawn())
				continue;

			Array<class<Actor> > monstypes;
			Array<bool> exact;

			defs.AssociatedMonsters(monstypes, exact);

			if (monstypes.Size() < 1)
			{
				Console.Printf(
					Biomorph.LOGPFX_WARN ..
					"Loot spawner type `%s` has no associated monsters, and will "
					"not be registered.", loot_t.GetClassName()
				);
				continue;
			}

			if (monstypes.Size() < exact.Size())
			{
				Console.Printf(
					Biomorph.LOGPFX_WARN ..
					"Loot spawner type `%s` does not provide %d subclass-check "
					"specifications, and will not be registered.",
					loot_t.GetClassName(), monstypes.Size()
				);
				continue;
			}

			for (uint j = 0; j < monstypes.Size(); j++)
			{
				if (monstypes[j] == null)
				{
					Console.Printf(
						Biomorph.LOGPFX_WARN ..
						"Loot spawner type `%s` tried to register an association "
						"with a null actor type (index %d).",
						loot_t.GetClassName(), j
					);
					continue;
				}

				let pair = new('BIO_MonsterLootPair');
				pair.MonsterType = monstypes[j];
				pair.SpawnerType = loot_t;
				pair.Exact = exact[j];
				MonsterLoot.Push(pair);
			}
		}
	}

	private void PushZeroValueMonster(name typename)
	{
		let type = (class<Actor>)(typename);

		if (type == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_WARN ..
				"Tried to push null type `%s` onto zero value monster array.",
				typename
			);
			return;
		}

		ZeroValueMonsters.Push(type);
	}

	private void PopulateZeroValueMonsterCache()
	{
		// Acknowledge the possibility of mix-n-match involvement here

		PushZeroValueMonster('LostSoul');

		if (BIO_Utils.DoomRLMonsterPack())
		{
			PushZeroValueMonster('RLArmageddonLostSoul'); // a.k.a. unlimited teeth works
			PushZeroValueMonster('RLCyberneticLostSoul'); // a.k.a. Hellmine
			PushZeroValueMonster('RLLostSoul');
			PushZeroValueMonster('RLNightmareLostSoulNPE');
		}

		if (BIO_Utils.IronSnail())
		{
			PushZeroValueMonster('BigEye');
		}

		if (BIO_Utils.PandemoniaMonsterPack())
		{
			PushZeroValueMonster('ChaosUmbra');
			PushZeroValueMonster('NewLostSoul');
			PushZeroValueMonster('Phantasm');
		}

		if (BIO_Utils.Rampancy())
		{
			PushZeroValueMonster('Robot_GunTurret');
			PushZeroValueMonster('Robot_ScoutDrone');
		}

		// TODO: More support for more monster packs
	}
}

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

class BIO_PlayerResetTracker
{
	PlayerInfo Player;
	uint Ammo, Health, Armor, Weapons;
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

	bool ResetPlayerAmmo(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Ammo(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Ammo == interval)
		{
			tracker.Ammo = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerArmor(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Armor(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Armor == interval)
		{
			tracker.Armor = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerHealth(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Health(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Health == interval)
		{
			tracker.Health = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerWeapons(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Weapons(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Weapons == interval)
		{
			tracker.Weapons = 0;
			return true;
		}

		return false;
	}
}
