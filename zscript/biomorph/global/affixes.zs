// The static global thinker keeps prototypes of all affixes for calls to 
// metadata-providing virtual functions like `Compatible()` and `CanGenerate()`,
// since `GetDefaultByType()` is only for actor classes.
extend class BIO_GlobalData
{
	private Array<BIO_WeaponAffix> WeaponAffixDefaults;

	// Weapons =================================================================

	private bool WeaponAffixObjCompatible(BIO_WeaponAffix afx,
		readOnly<BIO_Weapon> weap, bool implicit) const
	{
		if (!afx.Compatible(weap))
			return false;

		let afx_t = afx.GetClass();

		if (!implicit && weap.HasAffixOfType(afx_t, false) ||
			implicit && weap.HasAffixOfType(afx_t, true))
			return false;

		if (afx.ImplicitExplicitExclusive())
		{
			if (!implicit && weap.HasAffixOfType(afx.GetClass(), true) ||
				implicit && weap.HasAffixOfType(afx.GetClass(), false))
				return false;
		}

		return true;
	}

	bool WeaponAffixCompatible(Class<BIO_WeaponAffix> afx_t,
		readOnly<BIO_Weapon> weap, bool implicit = false) const
	{
		if (!implicit && weap.HasAffixOfType(afx_t, false) ||
			implicit && weap.HasAffixOfType(afx_t, true))
			return false;

		let afx = BIO_WeaponAffix(new(afx_t));

		if (afx.ImplicitExplicitExclusive())
		{
			if (!implicit && weap.HasAffixOfType(afx.GetClass(), true) ||
				implicit && weap.HasAffixOfType(afx.GetClass(), false))
				return false;
		}

		if (!afx.Compatible(weap))
			return false;

		return true;
	}

	bool EligibleWeaponAffixes(in out Array<Class<BIO_WeaponAffix> > eligibles,
		readOnly<BIO_Weapon> weap, bool implicit = false) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			let afx_t = WeaponAffixDefaults[i].GetClass();

			if (!WeaponAffixObjCompatible(WeaponAffixDefaults[i], weap, implicit))
				continue;

			if (!implicit && !WeaponAffixDefaults[i].CanGenerate() ||
				implicit && !WeaponAffixDefaults[i].CanGenerateImplicit())
				continue;

			eligibles.Push(afx_t);
		}

		return eligibles.Size() > 0;
	}

	bool EligibleWeaponAffixesByFlagsOr(in out Array<Class<BIO_WeaponAffix> > eligibles,
		readOnly<BIO_Weapon> weap, BIO_WeaponAffixFlags flags, bool implicit = false) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			let afx_t = WeaponAffixDefaults[i].GetClass();

			if (!WeaponAffixObjCompatible(WeaponAffixDefaults[i], weap, implicit))
				continue;

			if (!implicit && !WeaponAffixDefaults[i].CanGenerate() ||
				implicit && WeaponAffixDefaults[i].CanGenerateImplicit())
				continue;

			if ((WeaponAffixDefaults[i].GetFlags() & flags) == 0)
				continue;

			eligibles.Push(afx_t);
		}

		return eligibles.Size() > 0;
	}

	bool EligibleWeaponAffixesByFlagsAnd(in out Array<Class<BIO_WeaponAffix> > eligibles,
		readOnly<BIO_Weapon> weap, BIO_WeaponAffixFlags flags, bool implicit = false) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			let afx_t = WeaponAffixDefaults[i].GetClass();

			if (!WeaponAffixObjCompatible(WeaponAffixDefaults[i], weap, implicit))
				continue;

			if (!implicit && !WeaponAffixDefaults[i].CanGenerate() ||
				implicit && WeaponAffixDefaults[i].CanGenerateImplicit())
				continue;

			if ((WeaponAffixDefaults[i].GetFlags() & flags) == 0)
				continue;
			
			if ((WeaponAffixDefaults[i].GetFlags() & flags) != flags)
				continue;

			eligibles.Push(afx_t);
		}

		return eligibles.Size() > 0;
	}

	// Equipment ===============================================================

	private Array<BIO_EquipmentAffix> EquipmentAffixDefaults;

	private bool EquipmentAffixObjCompatible(BIO_EquipmentAffix afx,
		readOnly<BIO_Equipment> equip, bool implicit) const
	{
		if (!afx.Compatible(equip))
			return false;

		let afx_t = afx.GetClass();

		if (!implicit && equip.HasAffixOfType(afx_t, false) ||
			implicit && equip.HasAffixOfType(afx_t, true))
			return false;

		if (afx.ImplicitExplicitExclusive())
		{
			if (!implicit && equip.HasAffixOfType(afx.GetClass(), true) ||
				implicit && equip.HasAffixOfType(afx.GetClass(), false))
				return false;
		}

		return true;
	}

	bool EquipmentAffixCompatible(Class<BIO_EquipmentAffix> afx_t,
		readOnly<BIO_Equipment> equip, bool implicit = false) const
	{
		if (!implicit && equip.HasAffixOfType(afx_t, false) ||
			implicit && equip.HasAffixOfType(afx_t, true))
			return false;

		let afx = BIO_EquipmentAffix(new(afx_t));
		
		if (afx.ImplicitExplicitExclusive())
		{
			if (!implicit && equip.HasAffixOfType(afx.GetClass(), true) ||
				implicit && equip.HasAffixOfType(afx.GetClass(), false))
				return false;
		}

		if (!afx.Compatible(equip))
			return false;

		return true;
	}

	bool EligibleEquipmentAffixes(in out Array<Class<BIO_EquipmentAffix> > eligibles,
		readOnly<BIO_Equipment> equip, bool implicit = false) const
	{
		for (uint i = 0; i < EquipmentAffixDefaults.Size(); i++)
		{
			let afx_t = EquipmentAffixDefaults[i].GetClass();

			if (!EquipmentAffixObjCompatible(EquipmentAffixDefaults[i], equip, implicit))
				continue;

			if (!implicit && !EquipmentAffixDefaults[i].CanGenerate() ||
				implicit && !EquipmentAffixDefaults[i].CanGenerateImplicit())
				continue;

			eligibles.Push(afx_t);
		}

		return eligibles.Size() > 0;
	}
}
