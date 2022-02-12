// More duration from any supported powerup ====================================

class BIO_Perk_PowerupDuration1 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration');
	}
}

class BIO_Perk_PowerupDuration2 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration', 2);
	}
}

class BIO_Perk_PowerupDuration5 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration', 5);
	}
}

class BIO_Perk_PowerupDuration10 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration', 10);
	}
}

// Give the powerup extra duration based on 1% of its default duration.
class BIO_PUpFunc_PowerupDuration : BIO_PowerupFunctor
{
	final override void PrePowerupHandlePickup(BIO_Player bioPlayer,
		Powerup handler, Powerup other) const
	{
		if (handler.GetClass() == other.GetClass())
			other.EffectTics += (other.Default.EffectTics * 0.01 * Count);
	}

	final override void PrePowerupAttach(BIO_Player bioPlayer, Powerup power) const
	{
		power.EffectTics += (power.Default.EffectTics * 0.01 * Count);
	}
}

// Extra duration for specific powerup types ===================================

// (Each of the following adds one second of duration/count, not one percent)

class BIO_Perk_RadsuitDuration1 : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_RadsuitDuration');
	}
}

class BIO_PUpFunc_RadsuitDuration : BIO_PowerupFunctor
{
	final override void PrePowerupHandlePickup(BIO_Player bioPlayer,
		Powerup handler, Powerup other) const
	{
		if (handler is 'PowerIronFeet' && other is 'PowerIronFeet')
			other.EffectTics += TICRATE * Count;
	}

	final override void PrePowerupAttach(BIO_Player bioPlayer, Powerup power) const
	{
		if (power is 'PowerIronFeet')
			power.EffectTics += TICRATE * Count;
	}
}

// Radsuits are time-additive ==================================================

class BIO_Perk_AdditiveRadsuits : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_AdditiveRadsuits');
	}
}

class BIO_PUpFunc_AdditiveRadsuits : BIO_PowerupFunctor
{
	final override void PrePowerupHandlePickup(BIO_Player bioPlayer,
		Powerup handler, Powerup other) const
	{
		if (handler is 'PowerIronFeet' && other is 'PowerIronFeet')
			other.bAdditiveTime = true;
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
