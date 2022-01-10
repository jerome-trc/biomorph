// Health Bonuses also fix armor; Armor Bonuses also grant 1 HP ================

class BIO_Perk_BonusCrossover : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_BonusCrossover');
	}
}

class BIO_PkupFunc_BonusCrossover : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer,
		Inventory item) const
	{
		if (item.GetClass() != 'BIO_HealthBonus') return;

		for (uint i = 0; i < Count; i++)
			BIO_ArmorBonus.TryRepairArmor(bioPlayer);
	}

	final override void OnArmorBonusPickup(BIO_Player bioPlayer,
		BIO_ArmorBonus bonus) const
	{
		for (uint i = 0; i < Count; i++)
			bioPlayer.GiveBody(1, bioPlayer.GetMaxHealth(true) + 100);
	}
}

// Weapon/equipment capacity ===================================================

class BIO_Perk_WeaponCapacity : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.MaxWeaponsHeld++;
	}
}

// The miscellaneous of the miscellaneous ======================================

class BIO_Perk_CantSeek : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.bCantSeek = true;
	}
}

class BIO_Perk_DontThrust : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.bDontThrust = true;
	}
}

class BIO_Perk_SlimeResist_Minor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.SlimeDamageFactor = Max(bioPlayer.SlimeDamageFactor - 0.05, 0.0);
	}
}

class BIO_Perk_SlimeResist_Major : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.SlimeDamageFactor = Max(bioPlayer.SlimeDamageFactor - 0.15, 0.0);
	}
}
