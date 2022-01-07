// Doubled effect of Armor Bonuses =============================================

class BIO_Perk_ArmorBonusX2 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_ArmorBonusX2');
	}
}

class BIO_PkupFunc_ArmorBonusX2 : BIO_ItemPickupFunctor
{
	final override void OnArmorBonusPickup(BIO_Player bioPlayer,
		BIO_ArmorBonus bonus) const
	{
		BIO_ArmorBonus.TryRepairArmor(bioPlayer);
	}
}
