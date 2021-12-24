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

	static clearscope BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create('BIO_GlobalData', STAT_STATIC);
		return BIO_GlobalData(iter.Next(true));
	}
}
