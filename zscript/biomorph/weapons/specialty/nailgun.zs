class BIO_Nailgun : BIO_Weapon
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Tag "$BIO_WEAP_TAG_NAILGUN";

		Inventory.Icon 'NLGNX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_NAILGUN";

		Weapon.AmmoGive 100;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN - 20;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.DamageRange 7, 20;
		BIO_Weapon.FireType 'BIO_Nail';
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 100;
		BIO_Weapon.MagazineType 'BIO_MAG_Nailgun';
		BIO_Weapon.Spread 3.6, 1.8;

		BIO_Nailgun.FireTimes 1, 1;
		BIO_Nailgun.ReloadTimes 40;
	}

	States
	{
	Ready:
		NLGN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		NLGN A 0 A_BIO_Deselect;
		Stop;
	Select:
		NLGN A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		NLGN B 1 Bright Offset(0, 32 + 2)
		{
			A_BIO_Fire();
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_Autogun', scale: 1.2);
			A_StartSound("bio/weap/nailgun/fire", CHAN_WEAPON);
		}
		NLGN C 1 Offset(0, 32) A_SetTics(invoker.FireTime1);
		NLGN D 1;
		NLGN E 1 A_SetTics(invoker.FireTime2);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		NLGN A 1 A_WeaponReady(WRF_NOFIRE);
		NLGN A 1 Offset(0, 32 + 2);
		NLGN A 1 Offset(0, 32 + 4);
		NLGN A 1 Offset(0, 32 + 6);
		NLGN A 1 Offset(0, 32 + 8);
		NLGN A 1 Offset(0, 32 + 10);
		NLGN A 1 Offset(0, 32 + 12);
		NLGN A 1 Offset(0, 32 + 14);
		NLGN A 1 Offset(0, 32 + 16);
		NLGN A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		NLGN A 40 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		NLGN A 1 Offset(0, 32 + 18) A_LoadMag;
		NLGN A 1 Offset(0, 32 + 16);
		NLGN A 1 Offset(0, 32 + 14);
		NLGN A 1 Offset(0, 32 + 12);
		NLGN A 1 Offset(0, 32 + 10);
		NLGN A 1 Offset(0, 32 + 8);
		NLGN A 1 Offset(0, 32 + 6);
		NLGN A 1 Offset(0, 32 + 4);
		NLGN A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		Goto LightDone;
	Spawn:
		NLGN X 0;
		NLGN X 0 A_BIO_Spawn;
		Stop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2);
	}

	override void GetFireTimeMinimums(in out Array<int> mins, bool _) const
	{
		mins.PushV(0, 0);
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
		if (FireType1 is 'BIO_Nail')
			stats.Push(StringTable.Localize("$BIO_WEAPSTAT_NAILSHRAPNEL"));
	}

	override int TrueFireTime() const { return 2 + FireTime1 + FireTime2; }
	override int TrueReloadTime() const { return ReloadTime + 19; }
}

class BIO_MAG_Nailgun : Ammo { mixin BIO_Magazine; }
