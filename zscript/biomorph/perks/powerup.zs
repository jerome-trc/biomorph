// More duration from any supported powerup ====================================

class BIO_Perk_PowerupDurationMinor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration');
	}
}

class BIO_Perk_PowerupDurationMajor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration', 5);
	}
}

// Give the powerup extra duration based on 5% of its default duration.
class BIO_PUpFunc_PowerupDuration : BIO_PowerupFunctor
{
	final override void OnPowerupAttach(BIO_Player bioPlayer, Powerup power) const
	{
		power.EffectTics += ((power.Default.EffectTics * 0.05) * Count);
	}
}

// Player gets allmap at start of level ========================================

class BIO_Perk_StartingAllmap : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_TransFunc_StartingAllmap');
	}
}

class BIO_TransFunc_StartingAllmap : BIO_TransitionFunctor
{
	final override void WorldLoaded(BIO_Player bioPlayer, bool saveGame, bool reopen) const
	{
		if (saveGame || reopen) return;
		bioPlayer.GiveInventory('Allmap', 1);
	}
}

// Computer Area Map pickups grant scanner =====================================

class BIO_Perk_ScannerAllmap : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_ScannerAllmap');
	}
}

class BIO_PkupFunc_ScannerAllmap : BIO_ItemPickupFunctor
{
	final override void OnMapPickup(BIO_Player bioPlayer, Allmap map) const
	{
		bioPlayer.GiveInventory('BIO_PowerScanner', 1);
	}
}