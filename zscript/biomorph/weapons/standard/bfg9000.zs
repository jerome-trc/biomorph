class BIO_BFG9000 : BIO_Weapon replaces BFG9000
{
	int FireTime1, FireTime2, FireTime3, FireTime4;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		+WEAPON.NOAUTOFIRE;

		Height 20;
		Tag "$TAG_BFG9000";

		Inventory.Icon 'BFUGA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_BFG90000";

		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.AmmoUse 40;
		Weapon.AmmoGive 80;
		Weapon.AmmoType 'Cell';
		
		// Affixes cannot change that this weapon fires exactly 1 BFG ball
		BIO_Weapon.AffixMasks
			BIO_WAM_FIRECOUNT | BIO_WAM_FIRETYPE,
			BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.DamageRanges 100, 800, 49, 87;
		BIO_Weapon.FireTypes 'BIO_BFGBall', 'BIO_BFGExtra';
		BIO_Weapon.FireCounts 1, 40;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 80;
		BIO_Weapon.MagazineType 'BIO_Magazine_BFG9000';
		BIO_Weapon.Spread 0.2, 0.2;
		BIO_Weapon.SwitchSpeeds 5, 5;

		BIO_BFG9000.FireTimes 20, 10, 10, 20;
		BIO_BFG9000.ReloadTimes 50;
	}

	States
	{
	Ready:
		BFGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		BFGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		BFGG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		BFGG A 20
		{
			A_SetTics(invoker.FireTime1);
			A_BFGSound();
		}
		BFGG B 10
		{
			A_SetTics(invoker.FireTime2);
			A_GunFlash();
		}
		BFGG B 10
		{
			A_SetTics(invoker.FireTime3);
			A_BIO_Fire();
			A_PresetRecoil('BIO_BFGRecoil');
		}
		BFGG B 20
		{
			A_SetTics(invoker.FireTime4);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		BFGG A 1 A_WeaponReady(WRF_NOFIRE);
		BFGG A 1 Offset(0, 32 + 2);
		BFGG A 1 Offset(0, 32 + 4);
		BFGG A 1 Offset(0, 32 + 6);
		BFGG A 1 Offset(0, 32 + 8);
		BFGG A 1 Offset(0, 32 + 10);
		BFGG A 1 Offset(0, 32 + 12);
		BFGG A 1 Offset(0, 32 + 14);
		BFGG A 1 Offset(0, 32 + 16);
		BFGG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		BFGG A 50 Offset(0, 32 + 20)
		{
			A_SetTics(invoker.ReloadTime);
			A_PresetRecoil('BIO_HeavyReloadRecoil');
		}
		BFGG A 1 Offset(0, 32 + 18)
		{
			A_PresetRecoil('BIO_HeavyReloadRecoil', invert: true);
			A_LoadMag();
		}
		BFGG A 1 Offset(0, 32 + 16);
		BFGG A 1 Offset(0, 32 + 14);
		BFGG A 1 Offset(0, 32 + 12);
		BFGG A 1 Offset(0, 32 + 10);
		BFGG A 1 Offset(0, 32 + 8);
		BFGG A 1 Offset(0, 32 + 6);
		BFGG A 1 Offset(0, 32 + 4);
		BFGG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		BFGF A 11 Bright
		{
			A_SetTics(invoker.FireTime2 + 1);
			A_Light(1);
		}
		BFGF B 6 Bright
		{
			A_SetTics(invoker.FireTime3 - 3);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		BFUG A 0;
		BFUG A 0 A_BIO_Spawn;
		Stop;
	}

	override void OnTrueProjectileFired(BIO_Projectile proj) const
	{
		let bfgBall = BIO_BFGBall(proj);
		bfgBall.BFGRays = FireCount2;
		bfgBall.MinRayDamage = MinDamage2;
		bfgBall.MaxRayDamage = MaxDamage2;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2, FireTime3, FireTime4);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
		FireTime3 = fireTimes[2];
		FireTime4 = fireTimes[3];
	}

	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const
	{
		reloadTimes.Push(ReloadTime);
	}

	override void SetReloadTimes(Array<int> reloadTimes, bool _)
	{
		ReloadTime = reloadTimes[0];
	}

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;
		FireTime3 = Default.FireTime3;
		FireTime4 = Default.FireTime4;

		ReloadTime = Default.ReloadTime;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout(false));
		stats.Push(GenericFireDataReadout(true));
		stats.Push(GenericFireDataReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
	}

	override int TrueFireTime() const
	{
		return FireTime1 + FireTime2 + FireTime3 + FireTime4;
	}

	override int TrueReloadTime() const
	{
		return ReloadTime + 19;
	}
}

class BIO_Magazine_BFG9000 : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 80;
	}
}
