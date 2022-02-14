enum BIO_PartyMaxWeaponGrade : uint8
{
	BIO_PMWG_SURPLUS,
	BIO_PMWG_STANDARD,
	BIO_PMWG_SPECIALTY,
	BIO_PMWG_CLASSIFIED
}

extend class BIO_GlobalData
{
	private BIO_PartyMaxWeaponGrade MaxWeaponGrade;

	// 0 is Standard, 1 is Specialty, 2 is Classified.
	private BIO_WeaponLootTable[__BIO_WEAPCAT_COUNT__][3] WeaponLootTables;
	
	// Contains all tables in `WeaponLootTables`.
	private BIO_WeaponLootTable WeaponLootMetaTable;
	
	private BIO_WeaponLootTable WRT_Mutagens;

	Class<BIO_Mutagen> RandomMutagenType() const
	{
		return (Class<BIO_Mutagen>)(WRT_Mutagens.Result());
	}

	Class<BIO_Weapon> AnyLootWeaponType() const
	{
		return (Class<BIO_Weapon>)(WeaponLootMetaTable.Result());
	}

	Class<BIO_Weapon> LootWeaponType(BIO_WeaponCategory table) const
	{
		switch (MaxWeaponGrade)
		{
		case BIO_PMWG_CLASSIFIED:
			if (table <= BIO_WEAPCAT_AUTOGUN)
			{
				return (Class<BIO_Weapon>)(WeaponLootTables[
					RandomPick[BIO_Loot](
						0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2)
				][table].Result());
			}
			else
			{
				return (Class<BIO_Weapon>)(WeaponLootTables[
					RandomPick[BIO_Loot](0, 0, 0, 1, 1, 2)
				][table].Result());
			}
		case BIO_PMWG_SPECIALTY:
			if (table <= BIO_WEAPCAT_AUTOGUN)
			{
				return (Class<BIO_Weapon>)(WeaponLootTables[
					RandomPick[BIO_Loot](0, 0, 0, 0, 0, 0, 0, 1, 1, 1)
				][table].Result());
			}
			else
			{
				return (Class<BIO_Weapon>)(WeaponLootTables[
					RandomPick[BIO_Loot](0, 0, 0, 1, 1)
				][table].Result());
			}
		default:
		case BIO_PMWG_STANDARD:
			return (Class<BIO_Weapon>)(WeaponLootTables[0][table].Result());
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

		if (prev == MaxWeaponGrade) return;

		if (BIO_debug)
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Max weapon grade increased to %s.",
				BIO_Utils.GradeToString(grade));
		}

		// If a new weapon grade precedent was set,
		// expand the weapon loot meta-table
		uint g = uint.MAX, m = 1;

		switch (MaxWeaponGrade)
		{
		case BIO_PMWG_STANDARD:
			g = 0;
			break;
		case BIO_PMWG_SPECIALTY:
			BIO_Utils.DRLMDangerLevel(2);
			g = 1;
			break;
		case BIO_PMWG_CLASSIFIED:
			BIO_Utils.DRLMDangerLevel(2);
			g = 2;
			break;
		default: return;
		}

		for (uint i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
		{
			uint weight = 0;

			switch (i)
			{
			case BIO_WEAPCAT_MELEE: weight = 3; break;
			case BIO_WEAPCAT_PISTOL: weight = 5; break;
			case BIO_WEAPCAT_SHOTGUN: weight = 9; break;
			case BIO_WEAPCAT_SSG: weight = 6; break;
			case BIO_WEAPCAT_RIFLE: weight = 9; break;
			case BIO_WEAPCAT_AUTOGUN: weight = 9; break;
			case BIO_WEAPCAT_LAUNCHER: weight = 6; break;
			case BIO_WEAPCAT_ENERGY: weight = 4; break;
			case BIO_WEAPCAT_SUPER: weight = 1; break;
			}

			if (i <= BIO_WEAPCAT_AUTOGUN)
			{
				switch (MaxWeaponGrade)
				{
				case BIO_PMWG_STANDARD: m = 7; break;
				case BIO_PMWG_SPECIALTY: m = 3; break;
				case BIO_PMWG_CLASSIFIED: m = 1; break;
				default: break;
				}
			}
			else
			{
				switch (MaxWeaponGrade)
				{
				case BIO_PMWG_STANDARD: m = 3; break;
				case BIO_PMWG_SPECIALTY: m = 2; break;
				case BIO_PMWG_CLASSIFIED: m = 1; break;
				default: break;
				}
			}

			WeaponLootMetaTable.PushLayer(WeaponLootTables[g][i], weight * m);
		}
	}

	void ResetWeaponGradePrecedent()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Resetting weapon grade precedent.");

		MaxWeaponGrade = BIO_PMWG_SURPLUS;
	}

	private void RemoveWeaponLootEntries(Class<BIO_Weapon> type)
	{
		for (uint i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
			for (uint j = 0; j < 3; j++)
				WeaponLootTables[j][i].RemoveByType(type);
	}

	private void TryReadWeaponLootArray(int lump, BIO_JsonObject loot,
		string arrName, BIO_WeaponCategory targetTables)
	{
		let arr = BIO_Utils.TryGetJsonArray(loot.get(arrName), errMsg: false);
		if (arr == null) return;
		
		for (uint i = 0; i < arr.size(); i++)
		{
			Class<BIO_Weapon> weap_t = (Class<BIO_Weapon>)
				(BIO_Utils.TryGetJsonClassName(arr.get(i)));

			if (weap_t == null)
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
					" lump %d, loot object, %s weapon %d is an invalid class.",
					lump, arrName, i);
				continue;
			}

			if (weap_t.IsAbstract())
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
					"lump %d, loot object, %s weapon includes abstract class %s.",
					lump, arrName, i, weap_t.GetClassName());
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
			uint g = uint.MAX, u = 1;

			switch (defs.Grade)
			{
			case BIO_GRADE_STANDARD: g = 0; u = 100; break;
			case BIO_GRADE_SPECIALTY: g = 1; u = 50; break;
			case BIO_GRADE_CLASSIFIED: g = 2; u = 4; break;
			default:
				Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
					" lump %d, loot object, %s weapon %d has invalid grade %s.",
					lump, arrName, i, BIO_Utils.GradeToString(defs.Grade));
				continue;
			}

			WeaponLootTables[g][targetTables].Push(weap_t,
				defs.Rarity != BIO_RARITY_UNIQUE ? u : 1);
		}
	}

	void RegenLoot()
	{
		for (uint i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
			for (uint j = 0; j < 3; j++)
				WeaponLootTables[j][i].Clear();

		for (int lump = 0; lump < Wads.GetNumLumps(); lump++)
		{
			if (Wads.GetLumpNamespace(lump) != Wads.NS_GLOBAL)
				continue;
			if (!(Wads.GetLumpFullName(lump).Left(LMPNAME_WEAPONS.Length())
				~== LMPNAME_WEAPONS))
				continue;

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

			let loot = BIO_Utils.TryGetJsonObject(obj.get("loot"), errMsg: false);
			if (loot != null)
			{
				TryReadWeaponLootArray(lump, loot, "melee", BIO_WEAPCAT_MELEE);
				TryReadWeaponLootArray(lump, loot, "pistol", BIO_WEAPCAT_PISTOL);
				TryReadWeaponLootArray(lump, loot, "shotgun", BIO_WEAPCAT_SHOTGUN);
				TryReadWeaponLootArray(lump, loot, "ssg", BIO_WEAPCAT_SSG);
				TryReadWeaponLootArray(lump, loot, "supershotgun", BIO_WEAPCAT_SSG);
				TryReadWeaponLootArray(lump, loot, "rifle", BIO_WEAPCAT_RIFLE);
				TryReadWeaponLootArray(lump, loot, "autogun", BIO_WEAPCAT_AUTOGUN);
				TryReadWeaponLootArray(lump, loot, "launcher", BIO_WEAPCAT_LAUNCHER);
				TryReadWeaponLootArray(lump, loot, "energy", BIO_WEAPCAT_ENERGY);
				TryReadWeaponLootArray(lump, loot, "super", BIO_WEAPCAT_SUPER);
			}
		}
	}

	void PrintLootDiag() const
	{
		for (uint i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
			for (uint j = 0; j < 3; j++)
				WeaponLootTables[j][i].Print();

		Console.Printf("--------------------------------------------------");
		WeaponLootMetaTable.Print();
	}
}
