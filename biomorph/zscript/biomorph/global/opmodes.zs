// Weapon operating mode cache.
extend class BIO_Global
{
	private Array<BIO_WeaponOperatingMode> WeaponOpModeCache;

	private void PopulateWeaponOpModeCache()
	{
		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			let opmode_t = (class<BIO_WeaponOperatingMode>)(AllClasses[i]);

			if (opmode_t == null || opmode_t.IsAbstract())
				continue;

			WeaponOpModeCache.Push(BIO_WeaponOperatingMode(new(opmode_t)));
		}
	}

	void AllOpModesForWeaponType(
		in out Array<class<BIO_WeaponOperatingMode> > opmodes,
		class<BIO_Weapon> weap_t
	) const
	{
		for (uint i = 0; i < WeaponOpModeCache.Size(); i++)
			if (WeaponOpModeCache[i].WeaponType() == weap_t)
				opmodes.Push(WeaponOpModeCache[i].GetClass());
	}

	// Returns `true` if any operating modes matching the criteria were found.
	bool FilteredOpModesForWeaponType(
		in out Array<class<BIO_WeaponOperatingMode> > opmodes,
		class<BIO_Weapon> weap_t,
		class<BIO_WeaponOperatingMode> filter
	) const
	{
		for (uint i = 0; i < WeaponOpModeCache.Size(); i++)
			if (WeaponOpModeCache[i].WeaponType() == weap_t &&
				WeaponOpModeCache[i] is filter)
			opmodes.Push(WeaponOpModeCache[i].GetClass());

		return opmodes.Size() > 0;
	}

	bool WeaponHasOpMode(class<BIO_Weapon> weap_t, class<BIO_WeaponOperatingMode> filter) const
	{
		for (uint i = 0; i < WeaponOpModeCache.Size(); i++)
			if (WeaponOpModeCache[i].WeaponType() == weap_t &&
				WeaponOpModeCache[i] is filter)
			return true;

		return false;
	}
}
