class BIO_WeaponUpgradeRecipe abstract
{
	abstract class<BIO_Weapon> GetOutput() const;
	abstract void GetInputTypes(in out Array<class<BIO_Weapon> > types) const;
	abstract bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const;
	abstract uint MutagenCost() const;

	// Return `false` if this recipe shouldn't be added to the global cache,
	// e.g. if it's for compatibility with a mod that wasn't loaded.
	virtual bool Enabled() const { return true; }
}

class BIO_WUR_AutoShotgun : BIO_WeaponUpgradeRecipe
{
	final override class<BIO_Weapon> GetOutput() const
	{
		return 'BIO_AutoShotgun';
	}

	final override void GetInputTypes(in out Array<class<BIO_Weapon> > types) const
	{
		types.Push((class<BIO_Weapon>)('BIO_PumpShotgun'));
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return sim.GetWeapon().GetClass() == 'BIO_PumpShotgun';
	}

	final override uint MutagenCost() const
	{
		return 3;
	}
}

class BIO_WUR_VolleyGun : BIO_WeaponUpgradeRecipe
{
	final override class<BIO_Weapon> GetOutput() const
	{
		return 'BIO_VolleyGun';
	}

	final override void GetInputTypes(in out Array<class<BIO_Weapon> > types) const
	{
		types.Push((class<BIO_Weapon>)('BIO_CoachGun'));
	}

	final override bool Eligible(readOnly<BIO_WeaponModSimulator> sim) const
	{
		return sim.GetWeapon().GetClass() == 'BIO_CoachGun';
	}

	final override uint MutagenCost() const
	{
		return 2;
	}
}
