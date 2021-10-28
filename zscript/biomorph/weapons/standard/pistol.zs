class BIO_Pistol : BIO_Weapon replaces Pistol
{
	int FireTime1, FireTime2, FireTime3, FireTime4;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Obituary "$OB_MPPISTOL";
		Tag "$TAG_PISTOL";

		Inventory.Icon "PISTA0";
		Inventory.PickupMessage "$BIO_WEAP_PICKUP_PISTOL";

		Weapon.AmmoGive 15;
		Weapon.AmmoType "Clip";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1900;
		Weapon.SlotNumber 2;
		Weapon.UpSound "weapons/gunswap0";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Flags BIO_WF_PISTOL;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireType "BIO_Bullet";
		BIO_Weapon.MagazineSize 15;
		BIO_Weapon.MagazineType "BIO_Magazine_Pistol";
		BIO_Weapon.Spread 4.0, 2.0;
		BIO_Weapon.SwitchSpeeds 8, 8;

		BIO_Pistol.FireTimes 4, 6, 4, 5;
		BIO_Pistol.ReloadTimes 30;
	}

	States
	{
	Ready:
		PISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PISG A 0 A_BIO_Deselect;
		Stop;
	Select:
		PISG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		PISG A 4 A_SetTics(invoker.FireTime1);
		PISG B 6 Bright
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
			A_GunFlash();
			A_StartSound("weapons/pistol", CHAN_WEAPON);
		}
		PISG C 4 A_SetTics(invoker.FireTime3);
		PISG B 5
		{
			A_SetTics(invoker.FireTime4);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		PISG A 1 A_WeaponReady(WRF_NOFIRE);
		PISG A 1 Offset(0, 32 + 2);
		PISG A 1 Offset(0, 32 + 4);
		PISG A 1 Offset(0, 32 + 6);
		PISG A 1 Offset(0, 32 + 8);
		PISG A 1 Offset(0, 32 + 10);
		PISG A 1 Offset(0, 32 + 12);
		PISG A 1 Offset(0, 32 + 14);
		PISG A 1 Offset(0, 32 + 16);
		PISG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		PISG A 30 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		PISG A 1 Offset(0, 32 + 18) A_LoadMag;
		PISG A 1 Offset(0, 32 + 16);
		PISG A 1 Offset(0, 32 + 14);
		PISG A 1 Offset(0, 32 + 12);
		PISG A 1 Offset(0, 32 + 10);
		PISG A 1 Offset(0, 32 + 8);
		PISG A 1 Offset(0, 32 + 6);
		PISG A 1 Offset(0, 32 + 4);
		PISG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		PISF A 7 Bright
		{
			A_SetTics(invoker.FireTime2 + 1);
			A_Light(1);
		}
		Goto LightDone;
		PISF A 7 Bright
		{
			A_SetTics(invoker.FireTime2 + 1);
			A_Light(1);
		}
		Goto LightDone;
	Spawn:
		PIST A 0;
		PIST A 0 A_BIO_Spawn;
		Stop;
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
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericSpreadReadout());
		stats.Push(GenericFireTimeReadout(FireTime1 + FireTime2 + FireTime3 + FireTime4));
		stats.Push(GenericReloadTimeReadout(ReloadTime + 19));
	}

	override int DefaultFireTime() const
	{
		return Default.FireTime1 + Default.FireTime2 +
			Default.FireTime3 + Default.FireTime4;
	}

	override int DefaultReloadTime() const
	{
		return Default.ReloadTime + 19;
	}
}

class BIO_Magazine_Pistol : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 15;
	}
}
