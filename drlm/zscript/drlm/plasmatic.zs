class biomrl_walt_Plasmatic : biom_WeaponAlterant
{
	final override void Apply(biom_WeaponData wdat) const
	{
		let payload1 = wdat.GetPayload(false);

		if (payload1 != null && payload1.type is 'biom_ShotPellet')
			payload1.type = 'RLEnemyPlasmaticPuff';

		let payload2 = wdat.GetPayload(true);

		if (payload2 != null && payload2.type is 'biom_ShotPellet')
			payload2.type = 'RLEnemyPlasmaticPuff';
	}

	final override bool, string Compatible(readonly<biom_WeaponData> wdat) const
	{
		let payload1 = wdat.GetPayload(false);

		if (payload1 != null && payload1.type is 'biom_ShotPellet')
			return true, "";

		let payload2 = wdat.GetPayload(false);

		if (payload2 != null && payload2.type is 'biom_ShotPellet')
			return true, "";

		return false, "__PLACEHOLDER__";
	}

	final override int Balance(readonly<biom_WeaponData> _) const
	{
		return BIOM_BALMOD_DEC_XS * 2;
	}

	final override bool Natural() const
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
		biom_AlterantItem.Alterant 'biomrl_walt_Plasmatic';
	}
}
