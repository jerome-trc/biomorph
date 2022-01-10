// Doubled effect of Health Bonuses ============================================

class BIO_Perk_HealthBonusX2 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_HealthBonusX2');
	}
}

class BIO_PkupFunc_HealthBonusX2 : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (item.GetClass() != 'BIO_HealthBonus') return;

		for (uint i = 0; i < Count; i++)
			bioPlayer.GiveBody(1, bioPlayer.GetMaxHealth(true) + 100);
	}
}

// 10% increase to effect of Stimpacks and Medikits ============================

class BIO_Perk_BetterStimpacks : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_BetterStimpacks');
	}
}

class BIO_Perk_BetterMedikits : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_BetterMedikits');
	}
}

class BIO_PkupFunc_BetterStimpacks : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (!BIO_Utils.IsStimpack(item.GetClass())) return;

		for (uint i = 0; i < Count; i++)
			bioPlayer.GiveBody(2, bioPlayer.GetMaxHealth());
	}
}

class BIO_PkupFunc_BetterMedikits : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (!BIO_Utils.IsMedikit(item.GetClass())) return;

		for (uint i = 0; i < Count; i++)
			bioPlayer.GiveBody(5, bioPlayer.GetMaxHealth());
	}
}

// `BonusHealth` increases =====================================================

class BIO_Perk_MaxBonusHealth_Minor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.BonusHealth += 2;
	}
}
