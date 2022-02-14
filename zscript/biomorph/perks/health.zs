// `BonusHealth` increases =====================================================

class BIO_Perk_BonusHealth1 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.BonusHealth += 1;
	}
}

class BIO_Perk_BonusHealth2 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.BonusHealth += 2;
	}
}

class BIO_Perk_BonusHealth5 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.BonusHealth += 5;
	}
}

class BIO_Perk_BonusHealth10 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.BonusHealth += 10;
	}
}

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

// +10 effect of Soulspheres ===================================================

class BIO_Perk_BetterSoulspheres : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_BetterSoulspheres');
	}
}

class BIO_PkupFunc_BetterSoulspheres : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (!(item is 'Soulsphere')) return;

		for (uint i = 0; i < Count; i++)
			bioPlayer.GiveBody(10, bioPlayer.GetMaxHealth(true));
	}
}

// +10 increase to `BonusHealth` from each Soulsphere ==========================

class BIO_Perk_SoulsphereBonusHealth : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_SoulsphereBonusHealth');
	}
}

class BIO_PkupFunc_SoulsphereBonusHealth : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (!(item is 'Soulsphere')) return;

		for (uint i = 0; i < Count; i++)
		{
			bioPlayer.BonusHealth += 10;
			bioPlayer.PersistentHealth += 10;
		}
	}
}

// 5% overhealing from Megaspheres =============================================

class BIO_Perk_BetterMegaspheres : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_BetterMegaspheres');
	}
}

class BIO_PkupFunc_BetterMegaspheres : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (!(item is 'Megasphere')) return;

		for (uint i = 0; i < Count; i++)
			bioPlayer.GiveBody(bioPlayer.GetMaxHealth(true) * 0.05, int.MAX);
	}
}

// +10 increase to `BonusHealth` from each Megasphere ==========================

class BIO_Perk_MegasphereBonusHealth : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_MegasphereBonusHealth');
	}
}

class BIO_PkupFunc_MegasphereBonusHealth : BIO_ItemPickupFunctor
{
	final override void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const
	{
		if (!(item is 'Megasphere')) return;

		for (uint i = 0; i < Count; i++)
		{
			bioPlayer.BonusHealth += 10;
			bioPlayer.PersistentHealth += 10;
		}
	}
}
