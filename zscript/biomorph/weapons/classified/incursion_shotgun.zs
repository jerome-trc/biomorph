class BIO_IncursionShotgun : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	int ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5;
	property ReloadTimes: ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5;

	Default
	{
		Tag "$BIO_WEAP_TAG_INCURSIONSHOTGUN";

		Inventory.Icon 'INCUX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_INCURSIONSHOTGUN";

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG - 40;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.DamageRange 7, 17;
		BIO_Weapon.FireCount 9;
		BIO_Weapon.FireType 'BIO_ShotPellet';
		BIO_Weapon.MagazineSize 4;
		BIO_Weapon.MagazineType 'BIO_Magazine_IncursionShotgun';
		BIO_Weapon.Spread 4.0, 2.0;
		
		BIO_IncursionShotgun.FireTimes 3, 4, 2, 2, 2;
		BIO_IncursionShotgun.ReloadTimes 3, 3, 2, 3, 3;
	}

	States
	{
	Ready:
		INCU A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		INCU A 0 A_BIO_Deselect;
		Stop;
	Select:
		INCU A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		INCU B 3 Bright
		{
			A_SetTics(invoker.FireTime1);
			A_BIO_Fire();
			A_GunFlash();
			A_StartSound("weapons/incursion", CHAN_WEAPON);
		}
		INCU C 4 Bright A_SetTics(invoker.FireTime2);
		INCU D 2 A_SetTics(invoker.FireTime3);
		INCU E 2 A_SetTics(invoker.FireTime4);
		INCU F 2
		{
			A_SetTics(invoker.FireTime5);
			A_ReFire();
		}
		Goto Ready;
	AltFire:
		TNT1 A 0 A_AutoReload;
		INCU B 3 Bright
		{
			invoker.bAltFire = false;
			A_SetTics(invoker.FireTime1);
			A_BIO_Fire(fireFactor: Min(invoker.Magazine1.Amount, 4),
				spreadFactor: 4.0);
			A_GunFlash();
			// TODO: Mix a fatter sound for quad-shot
			A_StartSound("weapons/incursion", CHAN_WEAPON);
			A_StartSound("weapons/incursion", CHAN_BODY);
			A_StartSound("weapons/incursion", CHAN_6);
			A_StartSound("weapons/incursion", CHAN_7);
			A_Kickback(2.5, 2.5);
		}
		INCU C 4 Bright A_SetTics(invoker.FireTime2);
		INCU D 2 A_SetTics(invoker.FireTime3);
		INCU E 2 A_SetTics(invoker.FireTime4);
		INCU F 2
		{
			A_SetTics(invoker.FireTime5);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		INCU A 3 Offset(0, 32 + 3) A_SetTics(invoker.ReloadTime1);
		INCU A 3 Offset(0, 32 + 6) A_SetTics(invoker.ReloadTime2);
		INCU A 2 Offset(0, 32 + 9) A_SetTics(invoker.ReloadTime3);
		INCU A 3 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.ReloadTime4);
			A_LoadMag();
			A_StartSound("weapons/incursionreload", CHAN_7);
		}
		INCU A 3 Offset(0, 32 + 3) A_SetTics(invoker.ReloadTime5);
		Goto Ready;
	Flash:
		TNT1 A 3
		{
			A_SetTics(invoker.FireTime1);
			A_Light(1);
		}
		TNT1 A 4 
		{
			A_SetTics(invoker.FireTime2);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		INCU X 0;
		INCU X 0 A_BIO_Spawn;
		Loop;
	}

	override void UpdateDictionary()
	{
		Dict = Dictionary.FromString(String.Format("{\"%s\": \"%d\"}",
			DICTKEY_PELLETCOUNT_1, Default.FireCount1));
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2, FireTime3, FireTime4, FireTime5);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
		FireTime3 = fireTimes[2];
		FireTime4 = fireTimes[3];
		FireTime5 = fireTimes[4];
	}

	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const
	{
		reloadTimes.PushV(ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5);
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
		FireTime4 = Default.FireTime4;
		FireTime5 = Default.FireTime5;

		ReloadTime1 = Default.ReloadTime1;
		ReloadTime2 = Default.ReloadTime2;
		ReloadTime3 = Default.ReloadTime3;
		ReloadTime4 = Default.ReloadTime4;
		ReloadTime5 = Default.ReloadTime5;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericSpreadReadout());
		stats.Push(GenericFireTimeReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
		stats.Push(StringTable.Localize("$BIO_WEAPSTAT_INCURSIONSHOTGUN_QUAD"));
	}

	override int TrueFireTime() const
	{
		return FireTime1 + FireTime2 + FireTime3 + FireTime4 + FireTime5;
	}

	override int TrueReloadTime() const
	{
		return ReloadTime1 + ReloadTime2 + ReloadTime3 + ReloadTime4 + ReloadTime5;
	}
}

class BIO_Magazine_IncursionShotgun : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 4;
	}
}
