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

	readOnly<BIO_WeaponModifier> GetWeaponModifierByType(
		class<BIO_WeaponModifier> mod_t
	) const
	{
		for (uint i = 0; i < WeaponModifiers.Size(); i++)
			if (WeaponModifiers[i].GetClass() == mod_t)
				return WeaponModifiers[i].AsConst();

		Console.Printf(
			Biomorph.LOGPFX_ERR ..
			"Failed to find weapon modifier instance by type: %s",
			mod_t
		);
		return null;
	}

	readOnly<BIO_WeaponModifier> GetWeaponModifier(uint index) const
	{
		return WeaponModifiers[index].AsConst();
	}
}
