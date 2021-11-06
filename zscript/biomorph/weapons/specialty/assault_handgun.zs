class BIO_AssaultHandgun : BIO_Weapon
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Obituary "$OB_MPPISTOL";
		Tag "$BIO_WEAP_TAG_ASSAULTHANDGUN";

		Inventory.Icon 'ASHGX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_ASSAULTHANDGUN";

		Weapon.AmmoGive 18;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PISTOL - 20;
		Weapon.SlotNumber 2;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "weapons/gunswap0";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Flags BIO_WF_PISTOL;
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.DamageRange 6, 16;
		BIO_Weapon.FireType 'BIO_Bullet';
		BIO_Weapon.MagazineSize 18;
		BIO_Weapon.MagazineType 'BIO_Magazine_AssaultHandgun';
		BIO_Weapon.Spread 3.6, 1.4;
		BIO_Weapon.SwitchSpeeds 9, 9;

		BIO_AssaultHandgun.FireTimes 2, 2;
		BIO_AssaultHandgun.ReloadTimes 30;
	}

	States
	{
	Ready:
		ASHG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		ASHG A 0 A_BIO_Deselect;
		Stop;
	Select:
		ASHG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		ASHG B 2 A_SetTics(invoker.FireTime1);
		ASHG D 1 Bright
		{
			A_BIO_Fire();
			A_PresetRecoil('BIO_AutogunRecoil');
			A_GunFlash();
			A_StartSound("weapons/assaulthandgun", CHAN_WEAPON);
		}
		ASHG C 1;
		ASHG B 1;
		TNT1 A 0 A_AutoReload;
		ASHG E 1 Bright
		{
			A_BIO_Fire();
			A_PresetRecoil('BIO_AutogunRecoil');
			A_GunFlash();
			A_StartSound("weapons/assaulthandgun", CHAN_WEAPON);
		}
		ASHG C 2 A_SetTics(invoker.FireTime2);
		ASHG C 1;
		TNT1 A 0 A_AutoReload;
		ASHG D 1 Bright
		{
			A_BIO_Fire();
			A_PresetRecoil('BIO_AutogunRecoil');
			A_GunFlash();
			A_StartSound("weapons/assaulthandgun", CHAN_WEAPON);
		}
		ASHG C 1;
		ASHG B 1;
		ASHG B 0 A_ReFire;
		Goto Ready;
	AltFire:
		ASHG B 3 A_SetTics(invoker.FireTime1 + 1);
		ASHG D 3 Bright
		{
			A_SetTics(invoker.FireTime1 + 1);
			invoker.bAltFire = false;
			A_BIO_Fire(spreadFactor: 0.5);
			A_PresetRecoil('BIO_HandgunRecoil');
			A_GunFlash();
			A_StartSound("weapons/assaulthandgun", CHAN_WEAPON);
		}
		ASHG C 3 A_SetTics(invoker.FireTime2 + 1);
		ASHG B 3 A_SetTics(invoker.FireTime2 + 1);
		ASHG A 1 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		ASHG A 1 A_WeaponReady(WRF_NOFIRE);
		ASHG A 1 Offset(0, 32 + 2);
		ASHG A 1 Offset(0, 32 + 4);
		ASHG A 1 Offset(0, 32 + 6);
		ASHG A 1 Offset(0, 32 + 8);
		ASHG A 1 Offset(0, 32 + 10);
		ASHG A 1 Offset(0, 32 + 12);
		ASHG A 1 Offset(0, 32 + 14);
		ASHG A 1 Offset(0, 32 + 16);
		ASHG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		ASHG A 30 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		ASHG A 1 Offset(0, 32 + 18) A_LoadMag;
		ASHG A 1 Offset(0, 32 + 16);
		ASHG A 1 Offset(0, 32 + 14);
		ASHG A 1 Offset(0, 32 + 12);
		ASHG A 1 Offset(0, 32 + 10);
		ASHG A 1 Offset(0, 32 + 8);
		ASHG A 1 Offset(0, 32 + 6);
		ASHG A 1 Offset(0, 32 + 4);
		ASHG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light(1);
		TNT1 A 1 Bright A_Light(0);
		Stop;
	Spawn:
		ASHG X 0;
		ASHG X 0 A_BIO_Spawn;
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

		stats.Push(GenericFireTimeReadout(TotalBurstFireTime(),
			"$BIO_WEAPSTAT_FIRETIME_BURST", Default.TotalBurstFireTime()));
		stats.Push(GenericFireTimeReadout(TotalSemiAutoFireTime(),
			"$BIO_WEAPSTAT_FIRETIME_SEMIAUTO", Default.TotalSemiAutoFireTime()));
		
		stats.Push(GenericReloadTimeReadout(ReloadTime + 19));
	}

	// Note: currently unused.
	override int TrueFireTime() const { return TotalBurstFireTime(); }
	override int TrueReloadTime() const { return ReloadTime + 19; }

	protected int TotalBurstFireTime() const
	{
		return FireTime1 + 4 + FireTime2 + 4;
	}

	protected int TotalSemiAutoFireTime() const
	{
		return ((FireTime1 + 1) * 2) + ((FireTime2 + 1) * 2) + 1;
	}
}

class BIO_Magazine_AssaultHandgun : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 18;
	}
}
