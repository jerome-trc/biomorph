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

		for (uint i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
			for (uint j = 0; j < 3; j++)
			{
				string category = BIO_Weapon.CATEGORY_IDS[i];
				ret.WeaponLootTables[j][i] = new('WeightedRandomTable');
				ret.WeaponLootTables[j][i].Label = String.Format(
					"weap_loot_%s_%s", BIO_Utils.GradeToString(j + 2), category);
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
		ret.WeaponLootMetaTable.Label = "weap_loot_meta";

		if (BIO_debug)
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"%d weapon upgrade(s) generated.", ret.WeaponUpgrades.Size());

			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);
		}

		return ret;
	}

	const LMPNAME_WEAPONS = "BIOWEAP";

	private void ReadWeaponLumps()
	{
		Array<Class<BIO_Weapon> >
			agwuStd[__BIO_WEAPCAT_COUNT__],
			agwuSpec[__BIO_WEAPCAT_COUNT__],
			agwuClsf[__BIO_WEAPCAT_COUNT__];

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

			// If the user gives a compatibility class name here, only parse
			// this lump if that class exists in the current setup.
			let compatJson = BIO_JsonString(obj.get("compat"));
			if (compatJson != null)
			{
				let compat_t = BIO_Utils.TryGetJsonClassName(
					compatJson, errMsg: false);
				if (compat_t == null) continue;
			}

			let autoup = BIO_Utils.TryGetJsonObject(
				obj.get("upgrades_auto"), errMsg: false);
			if (autoup != null)
			{
				for (BIO_WeaponCategory i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
					ReadWeaponAutoUpgradeJSON(autoup, lump, i,
						agwuStd[i], agwuSpec[i], agwuClsf[i]);
			}

			let upgrades = BIO_Utils.TryGetJsonArray(
				obj.get("upgrades"), errMsg: false);
			if (upgrades != null)
				ReadWeaponUpgradeJSON(upgrades, lump);

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

		for (uint i = 0; i < __BIO_WEAPCAT_COUNT__; i++)
			AutogenWeaponUpgradeRecipes(i, agwuStd[i], agwuSpec[i], agwuClsf[i]);
	}

	static clearscope BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create('BIO_GlobalData', STAT_STATIC);
		return BIO_GlobalData(iter.Next(true));
	}

	final override void OnDestroy()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");
		
		super.OnDestroy();
	}
}
