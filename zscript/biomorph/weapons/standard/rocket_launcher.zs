class BIO_RocketLauncher : BIO_Weapon replaces RocketLauncher
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		+WEAPON.NOAUTOFIRE

		Tag "$TAG_ROCKETLAUNCHER";
		
		Inventory.Icon 'LAUNA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_ROCKETLAUNCHER";

		Weapon.AmmoGive 2;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 2500;
		Weapon.SlotNumber 5;

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 20, 160;
		BIO_Weapon.FireType 'BIO_Rocket';
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType 'BIO_Magazine_RocketLauncher';
		BIO_Weapon.Spread 0.2, 0.2;
		
		BIO_RocketLauncher.FireTimes 8, 12;
		BIO_RocketLauncher.ReloadTimes 45;
	}

	States
	{
	Ready:
		MISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		MISG A 0 A_BIO_Deselect;
		Stop;
	Select:
		MISG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		MISG B 8
		{
			A_SetTics(invoker.FireTime1);
			A_GunFlash();
		}
		MISG B 12
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
		}
		MISG B 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		MISG A 1 A_WeaponReady(WRF_NOFIRE);
		MISG A 1 Offset(0, 32 + 2);
		MISG A 1 Offset(0, 32 + 4);
		MISG A 1 Offset(0, 32 + 6);
		MISG A 1 Offset(0, 32 + 8);
		MISG A 1 Offset(0, 32 + 10);
		MISG A 1 Offset(0, 32 + 12);
		MISG A 1 Offset(0, 32 + 14);
		MISG A 1 Offset(0, 32 + 16);
		MISG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		MISG A 45 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		MISG A 1 Offset(0, 32 + 18) A_LoadMag();
		MISG A 1 Offset(0, 32 + 16);
		MISG A 1 Offset(0, 32 + 14);
		MISG A 1 Offset(0, 32 + 12);
		MISG A 1 Offset(0, 32 + 10);
		MISG A 1 Offset(0, 32 + 8);
		MISG A 1 Offset(0, 32 + 6);
		MISG A 1 Offset(0, 32 + 4);
		MISG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		MISF A 3 Bright A_Light1;
		MISF B 4 Bright;
		MISF CD 4 Bright A_Light2;
		Goto LightDone;
	Spawn:
		LAUN A 0;
		LAUN A 0 A_BIO_Spawn;
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
		stats.Push(GenericFireTimeReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
	}

	override int TrueFireTime() const { return FireTime1 + FireTime2; }
	override int TrueReloadTime() const { return ReloadTime + 19; }
}

class BIO_Magazine_RocketLauncher : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 1;
	}
}
