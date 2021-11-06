class BIO_HeavyBattleRifle : BIO_Weapon
{
	protected bool Zoomed;

	int FireTime1, FireTime2, FireTime3;
	property FireTimes: FireTime1, FireTime2, FireTime3;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Tag "$BIO_WEAP_TAG_HBR";

		Inventory.PickupMessage "$BIO_WEAP_PKUP_HBR";

		Weapon.AmmoGive 60;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN - 40;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.DamageRange 25, 75;
		BIO_Weapon.FireType 'BIO_Bullet';
		BIO_Weapon.MagazineSize 60;
		BIO_Weapon.MagazineType 'BIO_Magazine_HBR';
		BIO_Weapon.Spread 0.5, 0.5;

		BIO_HeavyBattleRifle.FireTimes 4, 5, 8;
		BIO_HeavyBattleRifle.ReloadTimes 40;
	}

	States
	{
	Ready:
		HVBR A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		HVBR A 0 A_BIO_Deselect;
		Stop;
	Select:
		HVBR A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		HVBR A 1 Offset(0, 32 + 3) Bright
		{
			A_BIO_Fire();
			A_GunFlash();
			A_StartSound("weapons/hbr", CHAN_WEAPON);
		}
		HVBR B 4 Offset(0, 32 + 6) Bright;
		HVBR C 5 Offset(0, 32 + 9) Bright;
		HVBR B 4 Offset(0, 32 + 6);
		HVBR A 8 Offset(0, 32 + 3) A_ReFire;
		Goto Ready;
	Flash:
		HVBR D 1 Bright A_Light(1);
		HVBR E 4 Bright A_Light(2);
		HVBR F 5 Bright A_Light(1);
		Goto LightDone;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		HVBR A 1 A_WeaponReady(WRF_NOFIRE);
		HVBR A 1 Offset(0, 32 + 2);
		HVBR A 1 Offset(0, 32 + 4);
		HVBR A 1 Offset(0, 32 + 6);
		HVBR A 1 Offset(0, 32 + 8);
		HVBR A 1 Offset(0, 32 + 10);
		HVBR A 1 Offset(0, 32 + 12);
		HVBR A 1 Offset(0, 32 + 14);
		HVBR A 1 Offset(0, 32 + 16);
		HVBR A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		HVBR A 40 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		HVBR A 1 Offset(0, 32 + 18) A_LoadMag();
		HVBR A 1 Offset(0, 32 + 16);
		HVBR A 1 Offset(0, 32 + 14);
		HVBR A 1 Offset(0, 32 + 12);
		HVBR A 1 Offset(0, 32 + 10);
		HVBR A 1 Offset(0, 32 + 8);
		HVBR A 1 Offset(0, 32 + 6);
		HVBR A 1 Offset(0, 32 + 4);
		HVBR A 1 Offset(0, 32 + 2);
		Goto Ready;
	Spawn:
		HVBR X 0;
		HVBR X 0 A_BIO_Spawn;
		Loop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2, FireTime3);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
		FireTime3 = fireTimes[2];
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

		ReloadTime = Default.ReloadTime;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericSpreadReadout());
		stats.Push(GenericFireTimeReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
	}

	override int TrueFireTime() const
	{
		return 22;
	}

	override int TrueReloadTime() const
	{
		return ReloadTime + 19;
	}
}

class BIO_Magazine_HBR : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 60;
	}
}
