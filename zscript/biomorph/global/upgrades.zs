class BIO_WeaponUpgrade
{
	Class<BIO_Weapon> Input, Output;
	uint Cost;
}

extend class BIO_GlobalData
{
	private Array<BIO_WeaponUpgrade> WeaponUpgrades;

	void PossibleWeaponUpgrades(in out Array<BIO_WeaponUpgrade> options,
		Class<BIO_Weapon> weap_t) const
	{
		for (uint i = 0; i < WeaponUpgrades.Size(); i++)
		{
			if (WeaponUpgrades[i].Input != weap_t) continue;

			options.Push(WeaponUpgrades[i]);
		}
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
				TryReadWeaponLootArray(lump, loot, "supershotgun", LOOTTABLE_SSG);
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
