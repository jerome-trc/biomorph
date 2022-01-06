class BIO_Perk_MaxBonusHealth : BIO_Passive
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.BonusHealth += 2;
	}
}

class BIO_Perk_CantSeek : BIO_Passive
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.bCantSeek = true;
	}
}

class BIO_Perk_DontThrust : BIO_Passive
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.bDontThrust = true;
	}
}

// Pistol-specific perks =======================================================

class BIO_Perk_ScaledPistolDamage : BIO_Passive
{
	final override void Apply(BIO_Player bioPlayer)
	{
		bioPlayer.PushFunctor('BIO_WeapFunc_ScaledPistolDamage');
	}
}

class BIO_WeapFunc_ScaledPistolDamage : BIO_WeaponFunctor
{
	final override void BeforeEachFire(BIO_Player bioPlayer, in out BIO_FireData fireData) const
	{
		let weap = BIO_Weapon(bioPlayer.Player.ReadyWeapon);
		
		if (weap == null) return;
		if (!(weap.BIOFlags & BIO_WF_PISTOL)) return;

		fireData.Damage *= (weap.LastFireTime() * 0.125);
	}
}

// More duration from any supported powerup ====================================

class BIO_Perk_PowerupDurationMinor : BIO_Passive
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PUpFunc_PowerupDuration');
	}
}

class BIO_Perk_PowerupDurationMajor : BIO_Passive
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

class BIO_Perk_StartingAllmap : BIO_Passive
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

class BIO_Perk_ScannerAllmap : BIO_Passive
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

// Doubled effect of Health Bonuses ============================================

class BIO_Perk_HealthBonusX2 : BIO_Passive
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
		bioPlayer.GiveBody(1, bioPlayer.GetMaxHealth(true) + 100);
	}
}

// Doubled effect of Armor Bonuses =============================================

class BIO_Perk_ArmorBonusX2 : BIO_Passive
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

// Health Bonuses also fix armor; Armor Bonuses also grant 1 HP ================

class BIO_Perk_BonusCrossover : BIO_Passive
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
		BIO_ArmorBonus.TryRepairArmor(bioPlayer);
	}

	final override void OnArmorBonusPickup(BIO_Player bioPlayer,
		BIO_ArmorBonus bonus) const
	{
		bioPlayer.GiveBody(1, bioPlayer.GetMaxHealth(true) + 100);
	}
}
