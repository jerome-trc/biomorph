// More duration from any supported powerup ====================================

class BIO_Perk_PowerupDurationMinor : BIO_Passive
{
	override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_Functor_PowerupDuration');
	}

	override void Remove(BIO_Player bioPlayer) const
	{
		bioPlayer.PopFunctor('BIO_Functor_PowerupDuration');
	}
}

class BIO_Perk_PowerupDurationMajor : BIO_Passive
{
	override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_Functor_PowerupDuration', 5);
	}

	override void Remove(BIO_Player bioPlayer) const
	{
		bioPlayer.PopFunctor('BIO_Functor_PowerupDuration', 5);
	}
}

// Give the powerup extra duration based on 5% of its default duration.
class BIO_Functor_PowerupDuration : BIO_PowerupFunctor
{
	override void OnPowerupAttach(BIO_Player bioPlayer, Powerup power) const
	{
		power.EffectTics += ((power.Default.EffectTics * 0.05) * Count);
	}
}

// Player gets allmap at start of level ========================================

class BIO_Perk_Allmap : BIO_Passive
{
	override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_Functor_Allmap');
	}

	override void Remove(BIO_Player bioPlayer) const
	{
		bioPlayer.PopFunctor('BIO_Functor_Allmap');
	}
}

class BIO_Functor_Allmap : BIO_TransitionFunctor
{
	override void WorldLoaded(BIO_Player bioPlayer, bool saveGame, bool reopen) const
	{
		if (saveGame || reopen) return;
		bioPlayer.GiveInventory('Allmap', 1);
	}
}

// Computer Area Map pickups grant scanner =====================================

class BIO_Perk_ScannerAllmap : BIO_Passive
{
	override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_Functor_ScannerAllmap');
	}

	override void Remove(BIO_Player bioPlayer) const
	{
		bioPlayer.PopFunctor('BIO_Functor_Scanner');
	}
}

class BIO_Functor_ScannerAllmap : BIO_ItemPickupFunctor
{
	override void OnMapPickup(BIO_Player bioPlayer, Allmap map) const
	{
		bioPlayer.GiveInventory('BIO_PowerScanner', 1);
	}
}

// Player gets scanner at start of level =======================================

class BIO_Perk_Scanner : BIO_Passive
{
	override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_Functor_Scanner');
	}

	override void Remove(BIO_Player bioPlayer) const
	{
		bioPlayer.PopFunctor('BIO_Functor_Scanner');
	}
}

class BIO_Functor_Scanner : BIO_TransitionFunctor
{
	override void WorldLoaded(BIO_Player bioPlayer, bool saveGame, bool reopen) const
	{
		if (saveGame || reopen) return;
		bioPlayer.GiveInventory('BIO_PowerScanner', 1);
	}
}
