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

		ret.PopulateWeaponLootTables();
		ret.PopulateMutagenLootTable();

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
	}

	class<BIO_Weapon> LootWeaponType(BIO_WeaponSpawnCategory category) const
	{
		return (class<BIO_Weapon>)(WeaponLoot[category].Result());
	}
}

// Weapon modifier cache.
extend class BIO_Global
{
	private Array<BIO_WeaponModifier> WeaponModifiers;

	private void PopulateWeaponModifierCache()
	{
		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			let mod_t = (class<BIO_WeaponModifier>)(AllClasses[i]);

			if (mod_t == null || mod_t.IsAbstract())
				continue;

			WeaponModifiers.Push(BIO_WeaponModifier(new(mod_t)));
		}
	}
}

// Mutagen loot table.
extend class BIO_Global
{
	private BIO_LootTable MutagenLoot;

	private void PopulateMutagenLootTable()
	{
		MutagenLoot = new('BIO_LootTable');

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let muta_t = (class<BIO_Mutagen>)(AllActorClasses[i]);

			if (muta_t == null || muta_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(muta_t);

			if (defs.NoLoot)
				continue;

			if (defs.DropWeight <= 0)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Mutagen class `%s` is not marked `NoLoot` "
					"but has no drop weight.", muta_t.GetClassName());
				continue;
			}

			MutagenLoot.Push(muta_t, defs.DropWeight);
		}
	}

	class<BIO_Mutagen> RandomMutagenType() const
	{
		return (class<BIO_Mutagen>)(MutagenLoot.Result());
	}
}
