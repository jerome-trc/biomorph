class BIO_Shotgun : BIO_Weapon replaces Shotgun
{
	int FireTime1, FireTime2, FireTime3;
	property FireTimes: FireTime1, FireTime2, FireTime3;
	int ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5;
	property ReloadTimes: ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5;

	Default
	{
		Obituary "$OB_MPSHOTGUN";
		Tag "$TAG_SHOTGUN";

		Inventory.Icon 'SHOTA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_SHOTGUN";

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "weapons/gunswap";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireCount 7;
		BIO_Weapon.FireType 'BIO_ShotPellet';
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType 'BIO_Magazine_Shotgun';
		BIO_Weapon.Spread 4.0, 2.0;

		BIO_Shotgun.FireTimes 3, 4, 3;
		BIO_Shotgun.ReloadTimes 5, 4, 5, 3, 7;
	}

	States
	{
	Ready:
		SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		SHTG A 0 A_BIO_Deselect;
		Stop;
	Select:
		SHTG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload(single: true);
		SHTG A 3 A_SetTics(invoker.FireTime1);
		SHTG A 4 Bright
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
			A_GunFlash();
			A_StartSound("weapons/shotgf", CHAN_WEAPON);
		}
		SHTG A 3 Bright A_SetTics(invoker.FireTime3);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		SHTG BC 5 A_SetTics(invoker.ReloadTime1);
		SHTG D 4
		{
			A_SetTics(invoker.ReloadTime2);
			A_LoadMag();
		}
		SHTG CB 5 A_SetTics(invoker.ReloadTime3);
		SHTG A 3 A_SetTics(invoker.ReloadTime4);
		SHTG A 7
		{
			A_SetTics(invoker.ReloadTime5);
			A_ReFire();
		}
		Goto Ready;
	Flash:
		SHTF A 4 Bright
		{
			A_SetTics(invoker.FireTime2);
			A_Light(1);
		}
		SHTF B 3 Bright
		{
			A_SetTics(invoker.FireTime3);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		SHOT B 0;
		SHOT B 0 A_BIO_Spawn;
		Stop;
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
		reloadTimes.PushV(
			ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5);
	}

	override void SetReloadTimes(Array<int> reloadTimes, bool _)
	{
		ReloadTime1 = reloadTimes[0];
		ReloadTime2 = reloadTimes[1];
		ReloadTime3 = reloadTimes[2];
		ReloadTime4 = reloadTimes[3];
		ReloadTime5 = reloadTimes[4];
	}

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;
		FireTime3 = Default.FireTime3;

		ReloadTime1 = Default.ReloadTime1;
		ReloadTime2 = Default.ReloadTime2;
		ReloadTime3 = Default.ReloadTime3;
		ReloadTime4 = Default.ReloadTime4;
		ReloadTime5 = Default.ReloadTime5;
	}

	override void UpdateDictionary()
	{
		Dict = Dictionary.FromString(String.Format("{\"%s\": \"%d\"}",
			DICTKEY_PELLETCOUNT_1, Default.FireCount1));
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
		return FireTime1 + FireTime2 + FireTime3;
	}

	override int TrueReloadTime() const
	{
		return ReloadTime1 + ReloadTime2 + ReloadTime3 + ReloadTime4 + ReloadTime5;
	}
}

class BIO_Magazine_Shotgun : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 1;
	}
}
