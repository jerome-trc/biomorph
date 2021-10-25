// Track the highest-grade weapon the party has found.
enum BIO_PartyMaxWeaponGrade : uint8
{
	BIO_PMWG_STANDARD = 0,
	BIO_PMWG_SPECIALTY = 1,
	BIO_PMWG_EXPERIMENTAL = 2,
	BIO_PMWG_CLASSIFIED = 3
}

class BIO_WeaponUpgrade
{
	Class<BIO_Weapon> Input, Output;
	uint KitCost;
}

class BIO_GlobalData : Thinker
{
	private uint PartyXP;
	private BIO_PartyMaxWeaponGrade MaxWeaponGrade;

	private Array<Class<BIO_WeaponAffix> > AllWeaponAffixClasses;
	private Array<BIO_WeaponAffix> WeaponAffixDefaults;

	private Array<Class<BIO_EquipmentAffix> > AllEquipmentAffixClasses;
	private Array<BIO_EquipmentAffix> EquipmentAffixDefaults;

	private Array<BIO_WeaponUpgrade> WeaponUpgrades;

	private WeightedRandomTable WRT_Mutagens;

	// Getters =================================================================

	uint GetPartyXP() const { return PartyXP; }

	bool WeaponAffixCompatible(Class<BIO_WeaponAffix> afx_t, BIO_Weapon weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() == afx_t)
				return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to WeaponAffixCompatible: %s", afx_t.GetClassName());
		return false;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleWeaponAffixes(Array<BIO_WeaponAffix> eligibles, BIO_Weapon weap) const
	{
		for (uint i = 0; i < AllWeaponAffixClasses.Size(); i++)
		{
			let wafx_t = AllWeaponAffixClasses[i];
			if (weap.HasAffixOfType(wafx_t)) continue;

			let wafx = BIO_WeaponAffix(new(wafx_t));
			if (!wafx.Compatible(weap)) continue;

			eligibles.Push(wafx);
		}

		return eligibles.Size() > 0;
	}

	bool AllEligibleEquipmentAffixes(Array<BIO_EquipmentAffix> eligibles, BIO_Equipment equip) const
	{
		for (uint i = 0; i < AllEquipmentAffixClasses.Size(); i++)
		{
			let eafx_t = AllEquipmentAffixClasses[i];
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

	// Setters =================================================================

	void AddPartyXP(uint xp) { PartyXP += xp; }

	void OnWeaponAcquired(BIO_Grade grade)
	{
		let prev = MaxWeaponGrade;

		switch (grade)
		{
		case BIO_GRADE_SPECIALTY:
			MaxWeaponGrade = Max(MaxWeaponGrade, BIO_PMWG_SPECIALTY);
			break;
		case BIO_GRADE_EXPERIMENTAL:
			MaxWeaponGrade = Max(MaxWeaponGrade, BIO_PMWG_EXPERIMENTAL);
			break;
		case BIO_GRADE_CLASSIFIED:
			MaxWeaponGrade = Max(MaxWeaponGrade, BIO_PMWG_CLASSIFIED);
			break;
		default:
			return;
		}

		if (prev != MaxWeaponGrade && BIO_CVar.Debug())
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Max weapon grade increased to %s.",
				BIO_Utils.GradeToString(grade));
		}
	}

	// The singleton getter and its "constructor" ==============================

	private static BIO_GlobalData Create()
	{
		uint ms = MsTime();
		let ret = new("BIO_GlobalData");
		ret.ChangeStatNum(STAT_STATIC);

		ret.WRT_Mutagens = new("WeightedRandomTable");

		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			if (AllClasses[i].GetParentClass() is "BIO_WeaponAffix")
			{
				ret.AllWeaponAffixClasses.Push(AllClasses[i]);
				let wafx = BIO_WeaponAffix(new(AllClasses[i]));
				ret.WeaponAffixDefaults.Push(wafx);
			}
			else if (AllClasses[i].GetParentClass() is "BIO_EquipmentAffix")
			{
				ret.AllEquipmentAffixClasses.Push(AllClasses[i]);
				let eafx = BIO_EquipmentAffix(new(AllClasses[i]));
				ret.EquipmentAffixDefaults.Push(eafx);
			}
			else if (AllClasses[i].GetParentClass() is "BIO_Mutagen")
			{
				let mut_t = (Class<BIO_Mutagen>)(AllClasses[i]);
				let defs = GetDefaultByType(mut_t);
				ret.WRT_Mutagens.Push(mut_t, defs.DropWeight);
			}
		}

		ret.ReadWeaponLumps();

		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);

		return ret;
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
			if (fileOpt is "BIO_JsonError")
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. 
					"Skipping malformed %s lump %d. Details: %s", lump,
					LMPNAME_WEAPONS, BIO_JsonError(fileOpt).what);
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
					if (input_t == null)
					{
						Console.Printf(errpfx .. "invalid input class given.");
						continue;
					}

					Class<BIO_Weapon> output_t = (Class<BIO_Weapon>)
						(BIO_Utils.TryGetJsonClassName(upgrade.get("output")));
					if (output_t == null)
					{
						Console.Printf(errpfx .. "invalid output class given.");
						continue;
					}

					let kitCost = BIO_Utils.TryGetJsonInt(upgrade.get("cost"));
					if (kitCost == null)
					{
						Console.Printf(errpfx ..
							"upgrade kit cost field is missing or malformed.");
						continue;
					}

					let kc = kitCost.i;
					let wukDefs = GetDefaultByType("BIO_WeaponUpgradeKit");
					if (kc < 0 || kc > wukDefs.MaxAmount)
					{
						Console.Printf(errpfx ..
							"upgrade kit cost is invalid (must be between 0 and %d inclusive).",
							wukDefs.MaxAmount);
						continue;
					}

					uint e = WeaponUpgrades.Push(new("BIO_WeaponUpgrade"));
					WeaponUpgrades[e].Input = input_t;
					WeaponUpgrades[e].Output = output_t;
					WeaponUpgrades[e].KitCost = kc;
				}
			}
		}
		while (true);
	}

	static BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create("BIO_GlobalData", STAT_STATIC);
		let ret = BIO_GlobalData(iter.Next(true));
		if (ret == null) ret = BIO_GlobalData.Create();
		return ret;
	}
}
