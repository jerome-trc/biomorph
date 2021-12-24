class BIO_GlobalData : Thinker
{
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
			{
				string category = "";

				switch (i)
				{
				case LOOTTABLE_MELEE: category = "melee"; break;
				case LOOTTABLE_PISTOL: category = "pistol"; break;
				case LOOTTABLE_SHOTGUN: category = "shotgun"; break;
				case LOOTTABLE_SSG: category = "ssg"; break;
				case LOOTTABLE_AUTOGUN: category = "autogun"; break;
				case LOOTTABLE_LAUNCHER: category = "launcher"; break;
				case LOOTTABLE_ENERGY: category = "energy"; break;
				case LOOTTABLE_SUPER: category = "super"; break;
				}

				ret.WeaponLootTables[j][i] = new('WeightedRandomTable');
				ret.WeaponLootTables[j][i].Label = String.Format("%s_%s",
					BIO_Utils.GradeToString(j + 2), category);
			}

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
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"%d weapon upgrades generated.", ret.WeaponUpgrades.Size());

			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);
		}

		return ret;
	}

	const LMPNAME_WEAPONS = "BIOWEAP";

	private void ReadWeaponLumps()
	{
		for (int lump = 0; lump < Wads.GetNumLumps(); lump++)
		{
			if (Wads.GetLumpNamespace(lump) != Wads.NS_GLOBAL)
				continue;
			if (!(Wads.GetLumpFullName(lump).Left(7) ~== LMPNAME_WEAPONS))
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

			// If the user gives a compatibility class name here, only parse
			// this lump if that class exists in the current setup.
			let compatJson = BIO_JsonString(obj.get("compat"));
			if (compatJson != null)
			{
				let compat_t = BIO_Utils.TryGetJsonClassName(
					compatJson, errMsg: false);
				if (compat_t == null) continue;
			}

			let upgrades = BIO_Utils.TryGetJsonArray(
				obj.get("upgrades"), errMsg: false);
			if (upgrades != null)
				ReadWeaponUpgradeJSON(upgrades, lump);

			let loot = BIO_Utils.TryGetJsonObject(obj.get("loot"), errMsg: false);
			if (loot != null)
			{
				TryReadWeaponLootArray(lump, loot, "melee", LOOTTABLE_MELEE);
				TryReadWeaponLootArray(lump, loot, "pistol", LOOTTABLE_PISTOL);
				TryReadWeaponLootArray(lump, loot, "shotgun", LOOTTABLE_SHOTGUN);
				TryReadWeaponLootArray(lump, loot, "ssg", LOOTTABLE_SSG);
				TryReadWeaponLootArray(lump, loot, "supershotgun", LOOTTABLE_SSG);
				TryReadWeaponLootArray(lump, loot, "autogun", LOOTTABLE_AUTOGUN);
				TryReadWeaponLootArray(lump, loot, "launcher", LOOTTABLE_LAUNCHER);
				TryReadWeaponLootArray(lump, loot, "energy", LOOTTABLE_ENERGY);
				TryReadWeaponLootArray(lump, loot, "super", LOOTTABLE_SUPER);
			}
		}
	}

	static clearscope BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create('BIO_GlobalData', STAT_STATIC);
		return BIO_GlobalData(iter.Next(true));
	}
}
