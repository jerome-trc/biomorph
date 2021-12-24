enum BIO_PartyMaxWeaponGrade : uint8
{
	BIO_PMWG_SURPLUS,
	BIO_PMWG_STANDARD,
	BIO_PMWG_SPECIALTY,
	BIO_PMWG_CLASSIFIED
}

// The associated perk class and a position on the perk menu.
class BIO_PerkGraphNode
{
	string UUID;
	bool Active;
	Vector2 Position;
	Class<BIO_Passive> PerkClass;
}

// Information about what nodes on the perk graph a player has filled out.
class BIO_PerkGraph
{
	PlayerInfo Player;
	Array<BIO_PerkGraphNode> Nodes;
}

class BIO_WeaponUpgrade
{
	Class<BIO_Weapon> Input, Output;
	uint Cost;
}

class BIO_GlobalData : Thinker
{
	private uint PartyXP, PartyLevel;
	private BIO_PartyMaxWeaponGrade MaxWeaponGrade;
	BIO_PerkGraph BasePerkGraph; // Generated on Thinker creation
	private Array<BIO_PerkGraph> PerkGraphs; // One per player

	private Array<BIO_WeaponAffix> WeaponAffixDefaults;
	private Array<BIO_EquipmentAffix> EquipmentAffixDefaults;

	private Array<BIO_WeaponUpgrade> WeaponUpgrades;

	enum LootTable : uint
	{
		LOOTTABLE_MELEE = 0,
		LOOTTABLE_PISTOL,
		LOOTTABLE_SHOTGUN,
		LOOTTABLE_SSG,
		LOOTTABLE_AUTOGUN,
		LOOTTABLE_LAUNCHER,
		LOOTTABLE_ENERGY,
		LOOTTABLE_SUPER = 7,
		LOOTTABLE_ARRAY_LENGTH = 8
	}

	// 0 is Standard, 1 is Specialty, 2 is Classified
	private WeightedRandomTable[LOOTTABLE_ARRAY_LENGTH][3] WeaponLootTables;
	
	// Contains all tables in `WeaponLootTables`
	private WeightedRandomTable WeaponLootMetaTable;
	
	private WeightedRandomTable WRT_Mutagens;

	// Getters =================================================================

	uint GetPartyXP() const { return PartyXP; }
	uint GetPartyLevel() const { return PartyLevel; }
	uint XPToNextLevel() const { return 1000 * (PartyLevel ** 1.4); }

	BIO_PerkGraph GetPerkGraph(PlayerInfo pInfo) const
	{
		if (!(pInfo.Cls is 'BIO_Player')) return null;

		for (uint i = 0; i < PerkGraphs.Size(); i++)
		{
			if (PerkGraphs[i].Player != pInfo) continue;
			return PerkGraphs[i];
		}

		// This player has no perk graph yet. Create it
		uint e = PerkGraphs.Push(new('BIO_PerkGraph'));
		PerkGraphs[e].Player = pInfo;
		PerkGraphs[e].Nodes.Copy(BasePerkGraph.Nodes);
		return PerkGraphs[e];
	}

	bool WeaponAffixCompatible(
		Class<BIO_WeaponAffix> afx_t, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() != afx_t) continue;
			if (weap.HasAffixOfType(WeaponAffixDefaults[i].GetClass())) continue;
			return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `WeaponAffixCompatible()`: %s",
			afx_t.GetClassName());
		return false;
	}

	bool WeaponAffixEligible(
		Class<BIO_WeaponAffix> afx_t, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() != afx_t) continue;
			if (!WeaponAffixDefaults[i].CanGenerate()) continue;
			if (weap.HasAffixOfType(WeaponAffixDefaults[i].GetClass())) continue;
			return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `WeaponAffixEligible()`: %s",
			afx_t.GetClassName());
		return false;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleWeaponAffixes(
		in out Array<BIO_WeaponAffix> eligibles, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerate()) continue;
			if (!WeaponAffixDefaults[i].Compatible(weap)) continue;
			let wafx_t = WeaponAffixDefaults[i].GetClass();
			if (weap.HasAffixOfType(wafx_t)) continue;
			eligibles.Push(BIO_WeaponAffix(new(wafx_t)));
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool EligibleWeaponAffixesByFlag(in out Array<BIO_WeaponAffix> eligibles,
		readOnly<BIO_Weapon> weap, BIO_WeaponAffixFlags flag) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerate()) continue;
			if (!WeaponAffixDefaults[i].Compatible(weap)) continue;
			if (!(WeaponAffixDefaults[i].GetFlags() & flag)) continue;
			let wafx_t = WeaponAffixDefaults[i].GetClass();
			if (weap.HasAffixOfType(wafx_t)) continue;
			eligibles.Push(BIO_WeaponAffix(new(wafx_t)));
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool EligibleImplicitWeaponAffixes(in out Array<BIO_WeaponAffix> eligibles,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerateImplicit()) continue;
			if (!WeaponAffixDefaults[i].Compatible(weap)) continue;
			let wafx_t = WeaponAffixDefaults[i].GetClass();
			if (weap.HasAffixOfType(wafx_t)) continue;
			eligibles.Push(BIO_WeaponAffix(new(wafx_t)));
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleEquipmentAffixes(in out Array<BIO_EquipmentAffix> eligibles,
		readOnly<BIO_Equipment> equip) const
	{
		for (uint i = 0; i < EquipmentAffixDefaults.Size(); i++)
		{
			let eafx_t = EquipmentAffixDefaults[i].GetClass();
			if (equip.HasAffixOfType(eafx_t)) continue;

			let eafx = BIO_EquipmentAffix(new(eafx_t));
			if (!eafx.Compatible(equip)) continue;

			eligibles.Push(eafx);
		}

		return eligibles.Size() > 0;
	}

	Class<BIO_Mutagen> RandomMutagenType() const
	{
		return (Class<BIO_Mutagen>)(WRT_Mutagens.Result());
	}

	void PossibleWeaponUpgrades(in out Array<BIO_WeaponUpgrade> options,
		Class<BIO_Weapon> weap_t) const
	{
		for (uint i = 0; i < WeaponUpgrades.Size(); i++)
		{
			if (WeaponUpgrades[i].Input != weap_t) continue;

			options.Push(WeaponUpgrades[i]);
		}
	}

	Class<BIO_Weapon> AnyLootWeaponType() const
	{
		return (Class<BIO_Weapon>)(WeaponLootMetaTable.Result());
	}

	Class<BIO_Weapon> LootWeaponType(LootTable table) const
	{
		uint i = int.MAX;

		switch (MaxWeaponGrade)
		{
		default:
		case BIO_PMWG_STANDARD:
			i = 0; break;
		case BIO_PMWG_SPECIALTY:
			i = 1; break;
		case BIO_PMWG_CLASSIFIED:
			i = 2; break;
		}

		return (Class<BIO_Weapon>)(WeaponLootTables[Random(0, i)][table].Result());
	}

	// Setters =================================================================

	void AddPartyXP(uint xp)
	{
		PartyXP += xp;
		while (PartyXP >= XPToNextLevel())
		{
			PartyLevel++;

			if (BIO_debug)
				Console.Printf(Biomorph.LOGPFX_DEBUG ..
					"Party leveled up to %d.", PartyLevel);
		}
	}

	void OnWeaponAcquired(BIO_Grade grade)
	{
		let prev = MaxWeaponGrade;

		switch (grade)
		{
		case BIO_GRADE_STANDARD:
			MaxWeaponGrade = Max(MaxWeaponGrade, BIO_PMWG_STANDARD);
			break;
		case BIO_GRADE_SPECIALTY:
			MaxWeaponGrade = Max(MaxWeaponGrade, BIO_PMWG_SPECIALTY);
			break;
		case BIO_GRADE_CLASSIFIED:
			MaxWeaponGrade = Max(MaxWeaponGrade, BIO_PMWG_CLASSIFIED);
			break;
		default:
			return;
		}

		if (prev != MaxWeaponGrade && BIO_debug)
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Max weapon grade increased to %s.",
				BIO_Utils.GradeToString(grade));
		}
	}

	// The singleton getter and its "constructor" ==============================

	static BIO_GlobalData Create()
	{
		let iter = ThinkerIterator.Create('BIO_GlobalData', STAT_STATIC);
		if (iter.Next(true) != null)
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data.");
			return null;
		}

		uint ms = MsTime();
		let ret = new('BIO_GlobalData');
		ret.ChangeStatNum(STAT_STATIC);

		for (uint i = 0; i < LOOTTABLE_ARRAY_LENGTH; i++)
			for (uint j = 0; j < 3; j++)
				ret.WeaponLootTables[j][i] = new('WeightedRandomTable');

		ret.WRT_Mutagens = new('WeightedRandomTable');

		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			if (AllClasses[i].IsAbstract()) continue;

			if (AllClasses[i] is 'BIO_WeaponAffix')
			{
				let wafx = BIO_WeaponAffix(new(AllClasses[i]));
				ret.WeaponAffixDefaults.Push(wafx);
			}
			else if (AllClasses[i] is 'BIO_EquipmentAffix')
			{
				let eafx = BIO_EquipmentAffix(new(AllClasses[i]));
				ret.EquipmentAffixDefaults.Push(eafx);
			}
			else if (AllClasses[i] is 'BIO_Mutagen')
			{
				let mut_t = (Class<BIO_Mutagen>)(AllClasses[i]);
				let defs = GetDefaultByType(mut_t);
				if (defs.NoLoot) continue;
				ret.WRT_Mutagens.Push(mut_t, defs.DropWeight);
			}
		}

		ret.CreateBasePerkGraph();
		ret.ReadWeaponLumps();

		ret.WeaponLootMetaTable = new('WeightedRandomTable');

		for (uint i = 0; i < LOOTTABLE_ARRAY_LENGTH; i++)
		{
			uint weight = 0;

			switch (i)
			{
			case LOOTTABLE_MELEE: weight = 3; break;
			case LOOTTABLE_PISTOL: weight = 5; break;
			case LOOTTABLE_SHOTGUN: weight = 9; break;
			case LOOTTABLE_SSG: weight = 6; break;
			case LOOTTABLE_AUTOGUN: weight = 9; break;
			case LOOTTABLE_LAUNCHER: weight = 6; break;
			case LOOTTABLE_ENERGY: weight = 4; break;
			case LOOTTABLE_SUPER: weight = 1; break;
			}

			ret.WeaponLootMetaTable.PushLayer(ret.WeaponLootTables[0][i], weight * 3);
			ret.WeaponLootMetaTable.PushLayer(ret.WeaponLootTables[1][i], weight * 2);
			ret.WeaponLootMetaTable.PushLayer(ret.WeaponLootTables[2][i], weight);
		}

		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);

		return ret;
	}

	const LMPNAME_PERKS = "BIOPERK";

	private void CreateBasePerkGraph()
	{
		BasePerkGraph = new('BIO_PerkGraph');

		{
			// Create the starter node
			uint e = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
			BasePerkGraph.Nodes[e].UUID = "bio_start";
		}

		int lump = -1, next = 0;

		do
		{
			lump = Wads.FindLump(LMPNAME_PERKS, next, Wads.GLOBALNAMESPACE);
			if (lump == -1) break;
			next = lump + 1;

			BIO_JsonElementOrError fileOpt = BIO_JSON.parse(Wads.ReadLump(lump));
			if (fileOpt is 'BIO_JsonError')
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. 
					"Skipping malformed %s lump %d. Details: %s", lump,
					LMPNAME_PERKS, BIO_JsonError(fileOpt).what);
				continue;
			}

			let obj = BIO_Utils.TryGetJsonObject(BIO_JsonElement(fileOpt));
			if (obj == null)
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_PERKS ..
					" lump %d has malformed contents.", lump);
				continue;
			}

			let perks = BIO_Utils.TryGetJsonArray(obj.get("perks"), errMsg: false);
			if (perks != null)
			{
				for (uint i = 0; i < perks.size(); i++)
				{
					string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
						LMPNAME_PERKS .. " lump %d, upgrade object %d; ", lump, i);

					let perk = BIO_Utils.TryGetJsonObject(perks.get(i));
					if (perk == null)
					{
						Console.Printf(errpfx .. "skipping it.");
						continue;
					}

					let uuid = BIO_Utils.StringFromJson(perk.get("uuid"));
					if (uuid == "")
					{
						Console.Printf(errpfx .. "malformed or missing UUID.");
						continue;
					}

					if (uuid == "bio_start")
					{
						Console.Printf(errpfx .. "the starting node cannot be modified.");
						continue;
					}

					let perk_t = (Class<BIO_Passive>)
						(BIO_Utils.TryGetJsonClassName(perk.get("class")));
					if (perk_t == null)
					{
						Console.Printf(errpfx .. "malformed or invalid class name.");
						continue;
					}

					let posX_json = BIO_Utils.TryGetJsonInt(perk.get("x"));
					if (posX_json == null)
					{
						Console.Printf(errpfx .. "malformed or missing x-position.");
						continue;
					}

					let posY_json = BIO_Utils.TryGetJsonInt(perk.get("y"));
					if (posY_json == null)
					{
						Console.Printf(errpfx .. "malformed or missing y-position.");
						continue;
					}

					uint e = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
					BasePerkGraph.Nodes[e].UUID = uuid;
					BasePerkGraph.Nodes[e].PerkClass = perk_t;
					BasePerkGraph.Nodes[e].Position = (posX_json.i, posY_json.i);
				}
			}
		} while (true);
	}

	const LMPNAME_WEAPONS = "BIOWEAP";

	private void ReadWeaponLumps()
	{
		int lump = -1, next = 0;
		
		do
		{
			lump = Wads.FindLump(LMPNAME_WEAPONS, next, Wads.GLOBALNAMESPACE);
			if (lump == -1) break;
			next = lump + 1;

			BIO_JsonElementOrError fileOpt = BIO_JSON.parse(Wads.ReadLump(lump));
			if (fileOpt is 'BIO_JsonError')
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. 
					"Skipping malformed %s lump %d. Details: %s", LMPNAME_WEAPONS,
					lump, BIO_JsonError(fileOpt).what);
				continue;
			}

			let obj = BIO_Utils.TryGetJsonObject(BIO_JsonElement(fileOpt));
			if (obj == null)
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
					" lump %d has malformed contents.", lump);
				continue;
			}

			let upgrades = BIO_Utils.TryGetJsonArray(obj.get("upgrades"));
			if (upgrades != null)
			{
				for (uint i = 0; i < upgrades.size(); i++)
				{
					string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
						LMPNAME_WEAPONS .. " lump %d, upgrade object %d; ", lump, i);

					let upgrade = BIO_Utils.TryGetJsonObject(upgrades.get(i));
					if (upgrade == null)
					{
						Console.Printf(errpfx .. "skipping it.");
						continue;
					}

					Class<BIO_Weapon> input_t = (Class<BIO_Weapon>)
						(BIO_Utils.TryGetJsonClassName(upgrade.get("input")));
					if (input_t == null || input_t == 'BIO_Weapon')
					{
						Console.Printf(errpfx .. "invalid input class given.");
						continue;
					}

					if (input_t == 'BIO_Fist')
					{
						Console.Printf(errpfx .. "`BIO_Fist` cannot be an upgrade input.");
						continue;
					}

					Class<BIO_Weapon> output_t = (Class<BIO_Weapon>)
						(BIO_Utils.TryGetJsonClassName(upgrade.get("output")));
					if (output_t == null || output_t == 'BIO_Weapon')
					{
						Console.Printf(errpfx .. "invalid output class given.");
						continue;
					}

					if (output_t == "BIO_Fist")
					{
						Console.Printf(errpfx .. "`BIO_Fist` cannot be an upgrade output.");
						continue;
					}

					let cost = BIO_Utils.TryGetJsonInt(upgrade.get("cost"));
					if (cost == null)
					{
						Console.Printf(errpfx ..
							"upgrade cost field is missing or malformed.");
						continue;
					}

					let uc = cost.i;
					let wupItemDefs = GetDefaultByType('BIO_Muta_Upgrade');
					if (uc < 0 || uc > wupItemDefs.MaxAmount)
					{
						Console.Printf(errpfx ..
							"upgrade cost is invalid (must be between 0 and %d inclusive).",
							wupItemDefs.MaxAmount);
						continue;
					}

					uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
					WeaponUpgrades[e].Input = input_t;
					WeaponUpgrades[e].Output = output_t;
					WeaponUpgrades[e].Cost = uc;

					let reversible = BIO_Utils.TryGetJsonBool(
						upgrade.get("reversible"), errMsg: false);
					if (reversible != null && reversible.b)
					{
						uint er = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
						WeaponUpgrades[er].Input = output_t;
						WeaponUpgrades[er].Output = input_t;
						WeaponUpgrades[er].Cost = uc;
					}
				}
			}

			let loot = BIO_Utils.TryGetJsonObject(obj.get("loot"), errMsg: false);
			if (loot != null)
			{
				TryReadWeaponLootArray(lump, loot, "melee", LOOTTABLE_MELEE);
				TryReadWeaponLootArray(lump, loot, "pistol", LOOTTABLE_PISTOL);
				TryReadWeaponLootArray(lump, loot, "shotgun", LOOTTABLE_SHOTGUN);
				TryReadWeaponLootArray(lump, loot, "ssg", LOOTTABLE_SSG);
				TryReadWeaponLootArray(lump, loot, "autogun", LOOTTABLE_AUTOGUN);
				TryReadWeaponLootArray(lump, loot, "launcher", LOOTTABLE_LAUNCHER);
				TryReadWeaponLootArray(lump, loot, "energy", LOOTTABLE_ENERGY);
				TryReadWeaponLootArray(lump, loot, "super", LOOTTABLE_SUPER);
			}
		}
		while (true);
	}

	private void TryReadWeaponLootArray(int lump, BIO_JsonObject loot,
		string arrName, LootTable targetTables)
	{
		let arr = BIO_Utils.TryGetJsonArray(loot.get(arrName));
		if (arr != null)
		{
			for (uint i = 0; i < arr.size(); i++)
			{
				Class<BIO_Weapon> weap_t = (Class<BIO_Weapon>)
					(BIO_Utils.TryGetJsonClassName(arr.get(i)));

				if (weap_t == null || weap_t == 'BIO_Weapon')
				{
					Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
						" lump %d, loot object, %s weapon %d is an invalid class.",
						lump, arrName, i);
					continue;
				}

				if (weap_t == 'BIO_Fist')
				{
					Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
						"lump %d, loot object, %s weapon includes illegal class `BIO_Fist`.",
						lump, arrName, i);
					continue;
				}

				let defs = GetDefaultByType(weap_t);
				uint g = uint.MAX, wt = 0;

				switch (defs.Grade)
				{
				case BIO_GRADE_STANDARD:
					g = 0; wt = 7; break;
				case BIO_GRADE_SPECIALTY:
					g = 1; wt = 3; break;
				case BIO_GRADE_CLASSIFIED:
					g = 2; wt = 1; break;
				default:
					Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
						" lump %d, loot object, %s weapon %d has invalid grade %s.",
						lump, arrName, i, BIO_Utils.GradeToString(defs.Grade));
					continue;
				}

				WeaponLootTables[g][targetTables].Push(weap_t, 1);
			}
		}
	}

	static clearscope BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create('BIO_GlobalData', STAT_STATIC);
		return BIO_GlobalData(iter.Next(true));
	}
}
