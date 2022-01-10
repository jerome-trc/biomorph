// The static global thinker keeps prototypes of all affixes for calls to 
// metadata-providing virtual functions like `Compatible()` and `CanGenerate()`,
// since `GetDefaultByType()` is only for actor classes.
extend class BIO_GlobalData
{
	// Weapons =================================================================

	private Array<BIO_WeaponAffix> WeaponAffixDefaults;

	bool WeaponAffixCompatible(
		Class<BIO_WeaponAffix> afx_t, readOnly<BIO_Weapon> weap) const
	{
		if (weap.HasAffixOfType(afx_t))
			return false;

		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() != afx_t)
				continue;
			
			return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `WeaponAffixCompatible()`: %s",
			afx_t.GetClassName());

		return false;
	}

	// The same check as `WeaponAffixCompatible()`, except it considers
	// whether the given type returns `true` from `CanGenerate()`.
	bool WeaponAffixEligible(
		Class<BIO_WeaponAffix> afx_t, readOnly<BIO_Weapon> weap) const
	{
		if (weap.HasAffixOfType(afx_t))
			return false;

		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() != afx_t)
				continue;
			
			if (!WeaponAffixDefaults[i].CanGenerate())
				return false;
			
			return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `WeaponAffixEligible()`: %s",
			afx_t.GetClassName());

		return false;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleWeaponAffixes(
		in out Array<Class<BIO_WeaponAffix> > eligibles,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].Compatible(weap))
				continue;

			if (!WeaponAffixDefaults[i].CanGenerate())
				continue;

			if (weap.HasAffixOfType(WeaponAffixDefaults[i].GetClass()))
				continue;

			eligibles.Push(WeaponAffixDefaults[i].GetClass());
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool EligibleWeaponAffixesByFlag(
		in out Array<Class<BIO_WeaponAffix> > eligibles,
		readOnly<BIO_Weapon> weap, BIO_WeaponAffixFlags flag) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerate())
				continue;

			if (!WeaponAffixDefaults[i].Compatible(weap))
				continue;

			if (!(WeaponAffixDefaults[i].GetFlags() & flag))
				continue;

			if (weap.HasAffixOfType(WeaponAffixDefaults[i].GetClass()))
				continue;

			eligibles.Push(WeaponAffixDefaults[i].GetClass());
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool EligibleImplicitWeaponAffixes(
		in out Array<Class<BIO_WeaponAffix> > eligibles,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerateImplicit())
				continue;

			if (!WeaponAffixDefaults[i].Compatible(weap))
				continue;

			let wafx_t = WeaponAffixDefaults[i].GetClass();

			if (weap.HasAffixOfType(wafx_t))
				continue;

			eligibles.Push(wafx_t);
		}

		return eligibles.Size() > 0;
	}

	// Equipment ===============================================================

	private Array<BIO_EquipmentAffix> EquipmentAffixDefaults;

	bool EquipmentAffixCompatible(Class<BIO_EquipmentAffix> afx_t,
		readOnly<BIO_Equipment> equip) const
	{
		if (equip.HasAffixOfType(afx_t))
			return false;

		for (uint i = 0; i < EquipmentAffixDefaults.Size(); i++)
		{
			if (EquipmentAffixDefaults[i].GetClass() != afx_t)
				continue;

			return EquipmentAffixDefaults[i].Compatible(equip);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `EquipmentAffixCompatible()`: %s",
			afx_t.GetClassName());

		return false;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleEquipmentAffixes(
		in out Array<Class<BIO_EquipmentAffix> > eligibles,
		readOnly<BIO_Equipment> equip) const
	{
		for (uint i = 0; i < EquipmentAffixDefaults.Size(); i++)
		{
			if (!EquipmentAffixDefaults[i].CanGenerate())
				continue;

			if (!EquipmentAffixDefaults[i].Compatible(equip))
				continue;

			if (equip.HasAffixOfType(EquipmentAffixDefaults[i].GetClass()))
				continue;

			eligibles.Push(EquipmentAffixDefaults[i].GetClass());
		}

		return eligibles.Size() > 0;
	}
}
