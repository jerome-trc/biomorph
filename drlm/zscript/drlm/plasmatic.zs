
class biomrl_alter_Plasmatic : biom_WeaponAlterant
{
	final override void Apply(biom_Player pawn) const
	{
		let wtdefs = GetDefaultByType(self.weaponType);
		let wdat = pawn.GetData().GetWeaponDataMut(wtdefs.DATA_CLASS);

		let payload1 = wdat.GetPayload(false);

		if (payload1 != null && payload1.type is 'biom_ShotPellet')
			payload1.type = 'RLEnemyPlasmaticPuff';

		let payload2 = wdat.GetPayload(true);

		if (payload2 != null && payload2.type is 'biom_ShotPellet')
			payload2.type = 'RLEnemyPlasmaticPuff';
	}

	final override bool, string Compatible(readonly<biom_Player> pawn) const
	{
		let wtdefs = GetDefaultByType(self.weaponType);
		let wdat = pawn.GetData().GetWeaponData(wtdefs.DATA_CLASS);
		return CompatibleWith(wdat), "$BIOMRL_ALTER_PLASMATIC_INCOMPAT";
	}

	static bool CompatibleWith(readonly<biom_WeaponData> wdat)
	{
		let payload1 = wdat.GetPayload(false);

		if (payload1 != null && payload1.type is 'biom_ShotPellet')
			return true;

		let payload2 = wdat.GetPayload(false);

		if (payload2 != null && payload2.type is 'biom_ShotPellet')
			return true;

		return false;
	}

	final override int Balance() const
	{
		return BIOM_BALMOD_DEC_XS * 2;
	}

	final override bool IsSidegrade() const
	{
		return false;
	}

	final override string Tag() const
	{
		return "$BIOMRL_ALTER_PLASMATIC_TAG";
	}

	final override string Summary() const
	{
		return "$BIOMRL_ALTER_PLASMATIC_SUMMARY";
	}
}

class biomrl_alti_Plasmatic : biom_AlterantItem
{
	Default
	{
		Tag "$BIOMRL_ALTI_PLASMATIC_TAG";
		Inventory.PickupMessage "$BIOMRL_ALTI_PLASMATIC_PKUP";
		biom_AlterantItem.Alterant 'biomrl_alter_Plasmatic';
	}

	override class<biom_Weapon> ApplicableWeapon(readonly<biom_Player> pawn) const
	{
		array<class<biom_Weapon> > types;
		let pdat = pawn.GetData();

		for (int i = 0; i < pdat.weapons.Size(); ++i)
		{
			let defs = GetDefaultByType(pdat.weapons[i]);
			let wdat = pdat.GetWeaponData(defs.DATA_CLASS);

			if (biomrl_alter_Plasmatic.CompatibleWith(wdat))
				return pdat.weapons[i];
		}

		return null;
	}
}
