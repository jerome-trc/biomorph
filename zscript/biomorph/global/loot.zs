enum BIO_PartyMaxWeaponGrade : uint8
{
	BIO_PMWG_SURPLUS,
	BIO_PMWG_STANDARD,
	BIO_PMWG_SPECIALTY,
	BIO_PMWG_CLASSIFIED
}

extend class BIO_GlobalData
{
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

	private BIO_PartyMaxWeaponGrade MaxWeaponGrade;

	// 0 is Standard, 1 is Specialty, 2 is Classified.
	private WeightedRandomTable[LOOTTABLE_ARRAY_LENGTH][3] WeaponLootTables;
	
	// Contains all tables in `WeaponLootTables`.
	private WeightedRandomTable WeaponLootMetaTable;
	
	private WeightedRandomTable WRT_Mutagens;

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

	Class<BIO_Mutagen> RandomMutagenType() const
	{
		return (Class<BIO_Mutagen>)(WRT_Mutagens.Result());
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

	private void TryReadWeaponLootArray(int lump, BIO_JsonObject loot,
		string arrName, LootTable targetTables)
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

			if (defs.Rarity != BIO_RARITY_UNIQUE) wt *= 2;

			WeaponLootTables[g][targetTables].Push(weap_t, wt);
		}
	}
}
