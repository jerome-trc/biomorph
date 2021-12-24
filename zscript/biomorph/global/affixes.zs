extend class BIO_GlobalData
{
	private Array<BIO_WeaponAffix> WeaponAffixDefaults;
	private Array<BIO_EquipmentAffix> EquipmentAffixDefaults;

	bool WeaponAffixCompatible(
		Class<BIO_WeaponAffix> afx_t, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() != afx_t) continue;
			if (weap.HasAffixOfType(WeaponAffixDefaults[i].GetClass())) continue;
			return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `WeaponAffixCompatible()`: %s",
			afx_t.GetClassName());
		return false;
	}

	bool WeaponAffixEligible(
		Class<BIO_WeaponAffix> afx_t, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (WeaponAffixDefaults[i].GetClass() != afx_t) continue;
			if (!WeaponAffixDefaults[i].CanGenerate()) continue;
			if (weap.HasAffixOfType(WeaponAffixDefaults[i].GetClass())) continue;
			return WeaponAffixDefaults[i].Compatible(weap);
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Illegal type passed to `WeaponAffixEligible()`: %s",
			afx_t.GetClassName());
		return false;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleWeaponAffixes(
		in out Array<BIO_WeaponAffix> eligibles, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerate()) continue;
			if (!WeaponAffixDefaults[i].Compatible(weap)) continue;
			let wafx_t = WeaponAffixDefaults[i].GetClass();
			if (weap.HasAffixOfType(wafx_t)) continue;
			eligibles.Push(BIO_WeaponAffix(new(wafx_t)));
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool EligibleWeaponAffixesByFlag(in out Array<BIO_WeaponAffix> eligibles,
		readOnly<BIO_Weapon> weap, BIO_WeaponAffixFlags flag) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerate()) continue;
			if (!WeaponAffixDefaults[i].Compatible(weap)) continue;
			if (!(WeaponAffixDefaults[i].GetFlags() & flag)) continue;
			let wafx_t = WeaponAffixDefaults[i].GetClass();
			if (weap.HasAffixOfType(wafx_t)) continue;
			eligibles.Push(BIO_WeaponAffix(new(wafx_t)));
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool EligibleImplicitWeaponAffixes(in out Array<BIO_WeaponAffix> eligibles,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < WeaponAffixDefaults.Size(); i++)
		{
			if (!WeaponAffixDefaults[i].CanGenerateImplicit()) continue;
			if (!WeaponAffixDefaults[i].Compatible(weap)) continue;
			let wafx_t = WeaponAffixDefaults[i].GetClass();
			if (weap.HasAffixOfType(wafx_t)) continue;
			eligibles.Push(BIO_WeaponAffix(new(wafx_t)));
		}

		return eligibles.Size() > 0;
	}

	// Returns `false` if no affixes are compatible.
	bool AllEligibleEquipmentAffixes(in out Array<BIO_EquipmentAffix> eligibles,
		readOnly<BIO_Equipment> equip) const
	{
		for (uint i = 0; i < EquipmentAffixDefaults.Size(); i++)
		{
			let eafx_t = EquipmentAffixDefaults[i].GetClass();
			if (equip.HasAffixOfType(eafx_t)) continue;

			let eafx = BIO_EquipmentAffix(new(eafx_t));
			if (!eafx.Compatible(equip)) continue;

			eligibles.Push(eafx);
		}

		return eligibles.Size() > 0;
	}
}
