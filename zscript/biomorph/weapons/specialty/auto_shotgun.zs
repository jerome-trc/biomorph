class BIO_AutoShotgun : BIO_Weapon
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Tag "$BIO_WEAP_TAG_AUTOSHOTGUN";

		Inventory.Icon 'AUSGX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_AUTOSHOTGUN";

		Weapon.AmmoGive 15;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN - 20;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.DamageRange 6, 16;
		BIO_Weapon.FireCount 8;
		BIO_Weapon.FireType 'BIO_ShotPellet';
		BIO_Weapon.MagazineType 'BIO_MAG_AutoShotgun';
		BIO_Weapon.MagazineSize 15;
		BIO_Weapon.Spread 3.8, 1.9;

		BIO_AutoShotgun.FireTimes 2, 7;
		BIO_AutoShotgun.ReloadTimes 40;
	}

	States
	{
	Ready:
		AUSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		AUSG A 0 A_BIO_Deselect;
		Stop;
	Select:
		AUSG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		AUSG B 1 Bright Offset(0, 32 + 2)
		{
			A_BIO_Fire();
			A_StartSound("bio/weap/autoshotgun/fire", CHAN_WEAPON);
			A_GunFlash();
			A_PresetRecoil('BIO_ShotgunRecoil', scale: 1.2);
		}
		AUSG C 2 Bright Offset(0, 32 + 6);
		AUSG D 3 Offset(0, 32 + 12) A_SetTics(invoker.FireTime1);
		AUSG A 3 Offset(0, 32 + 2) A_SetTics(invoker.FireTime1);
		AUSG A 7 Offset(0, 32)
		{
			A_SetTics(invoker.FireTime2);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		AUSG A 1 A_WeaponReady(WRF_NOFIRE);
		AUSG A 1 Offset(0, 32 + 2);
		AUSG A 1 Offset(0, 32 + 4);
		AUSG A 1 Offset(0, 32 + 6);
		AUSG A 1 Offset(0, 32 + 8);
		AUSG A 1 Offset(0, 32 + 10);
		AUSG A 1 Offset(0, 32 + 12);
		AUSG A 1 Offset(0, 32 + 14);
		AUSG A 1 Offset(0, 32 + 16);
		AUSG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		AUSG A 40 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		AUSG A 1 Offset(0, 32 + 18) A_LoadMag;
		AUSG A 1 Offset(0, 32 + 16);
		AUSG A 1 Offset(0, 32 + 14);
		AUSG A 1 Offset(0, 32 + 12);
		AUSG A 1 Offset(0, 32 + 10);
		AUSG A 1 Offset(0, 32 + 8);
		AUSG A 1 Offset(0, 32 + 6);
		AUSG A 1 Offset(0, 32 + 4);
		AUSG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light(1);
		TNT1 A 2 Bright A_SetTics(invoker.FireTime1);
		TNT1 A 3 Bright
		{
			A_SetTics(invoker.FireTime1 + 1);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		AUSG X 0;
		AUSG X 0 A_BIO_Spawn;
		Stop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
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
		return 2 + (FireTime1 * 2) + FireTime2;
	}

	override int TrueReloadTime() const { return ReloadTime + 19; }
}

class BIO_MAG_AutoShotgun : Ammo { mixin BIO_Magazine; }
