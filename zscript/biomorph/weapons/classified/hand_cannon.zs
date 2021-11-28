class BIO_HandCannon : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4, FireTime5, FireTime6;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4, FireTime5, FireTime6;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Tag "$BIO_WEAP_TAG_HANDCANNON";

		Inventory.Icon 'HCANX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_HANDCANNON";

		Weapon.AmmoGive 15;
		Weapon.AmmoType 'Clip';
		Weapon.Ammouse 1;
		Weapon.SelectionOrder SELORDER_PISTOL - 40;
		Weapon.SlotNumber 2;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;
		Weapon.UpSound "bio/weap/gunswap_0";
		
		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Flags BIO_WF_PISTOL;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.DamageRange 50, 70;
		BIO_Weapon.FireType 'BIO_Bullet';
		BIO_Weapon.MagazineSize 7;
		BIO_Weapon.MagazineType 'BIO_MAG_HandCannon';
		BIO_Weapon.Spread 1.0, 1.0;
		BIO_Weapon.SwitchSpeeds 8, 8;

		BIO_HandCannon.FireTimes 3, 2, 2, 2, 2, 2;
		BIO_HandCannon.ReloadTimes 35;
	}

	States
	{
	Ready:
		HCAN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		HCAN A 1 A_BIO_Deselect;
		Stop;
	Select:
		HCAN A 1 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		#### # 0 A_StartSound("bio/weap/handcannon/fire", CHAN_WEAPON);
		HCAN E 1 Bright;
		HCAN F 1 Bright
		{
			A_BIO_Fire();
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_HandCannon');
		}
		HCAN G 1;
		HCAN D 3 A_SetTics(invoker.FireTime1);
		HCAN G 2 A_SetTics(invoker.FireTime2);
		HCAN C 2 A_SetTics(invoker.FireTime3);
		HCAN B 2 A_SetTics(invoker.FireTime4);
		HCAN A 2 A_SetTics(invoker.FireTime5);
		HCAN A 2 A_SetTics(invoker.FireTime6);
		HCAN A 1 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		HCAN A 1 A_WeaponReady(WRF_NOFIRE);
		HCAN A 1 Offset(0, 32 + 2);
		HCAN A 1 Offset(0, 32 + 4);
		HCAN A 1 Offset(0, 32 + 6);
		HCAN A 1 Offset(0, 32 + 8);
		HCAN A 1 Offset(0, 32 + 10);
		HCAN A 1 Offset(0, 32 + 12);
		HCAN A 1 Offset(0, 32 + 14);
		HCAN A 1 Offset(0, 32 + 16);
		HCAN A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		HCAN A 35 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		HCAN A 1 Offset(0, 32 + 18) A_LoadMag;
		HCAN A 1 Offset(0, 32 + 16);
		HCAN A 1 Offset(0, 32 + 14);
		HCAN A 1 Offset(0, 32 + 12);
		HCAN A 1 Offset(0, 32 + 10);
		HCAN A 1 Offset(0, 32 + 8);
		HCAN A 1 Offset(0, 32 + 6);
		HCAN A 1 Offset(0, 32 + 4);
		HCAN A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light(1);
		TNT1 A 1 Bright A_Light(0);
		Stop;
	Spawn:
		HCAN X 0;
		HCAN X 0 A_BIO_Spawn;
		Loop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(
			FireTime1, FireTime2, FireTime3,
			FireTime4, FireTime5, FireTime6);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
		FireTime3 = fireTimes[2];
		FireTime4 = fireTimes[3];
		FireTime5 = fireTimes[4];
		FireTime6 = fireTimes[5];
	}

	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const
	{
		reloadTimes.Push(ReloadTime);
	}

	override void SetReloadTimes(Array<int> reloadTimes, bool _)
	{
		ReloadTime = reloadTimes[0];
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
		return
			3 + FireTime1 + FireTime2 + FireTime3 +
			FireTime4 + FireTime5 + FireTime6 + 1;
	}

	override int TrueReloadTime() const
	{
		return ReloadTime + 19;
	}
}

class BIO_MAG_HandCannon : Ammo { mixin BIO_Magazine; }
