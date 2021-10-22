class BIO_GlobalData : Thinker
{
	private Array<Class<BIO_WeaponAffix> > AllWeaponAffixClasses;
	private Array<BIO_WeaponAffix> WeaponAffixDefaults;

	private Array<Class<BIO_EquipmentAffix> > AllEquipmentAffixClasses;
	private Array<BIO_EquipmentAffix> EquipmentAffixDefaults;

	// Getters =================================================================

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

	// The singleton getter and its "constructor" ==============================

	private static BIO_GlobalData Create()
	{
		uint ms = MsTime();
		let ret = new("BIO_GlobalData");
		ret.ChangeStatNum(STAT_STATIC);

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
		}

		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);

		return ret;
	}

	static BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create("BIO_GlobalData", STAT_STATIC);
		let ret = BIO_GlobalData(iter.Next(true));
		if (ret == null) ret = BIO_GlobalData.Create();
		return ret;
	}
}
