class BIO_PlasmaCannon : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Tag "$BIO_WEAP_TAG_PLASMACANNON";

		Inventory.Icon 'PLSCX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_PLASMACANNON";

		Weapon.AmmoGive 50;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 2;
		Weapon.SelectionOrder SELORDER_PLASMARIFLE - 20;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "weapons/plasmacannonraise";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.DamageRange 10, 80;
		BIO_Weapon.FireType 'BIO_PlasmaGlobule';
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType 'BIO_MAG_PlasmaCannon';
		BIO_Weapon.Spread 0.2, 0.2;

		BIO_PlasmaCannon.FireTimes 1, 1, 1, 1, 1;
		BIO_PlasmaCannon.ReloadTimes 40;
	}

	States
	{
	Ready:
		PLSC A 1
		{
			A_WeaponReady(WRF_ALLOWRELOAD);
			A_StartSound("weapons/plasmacannonidle", CHAN_7, CHANF_DEFAULT, 0.6, 0.2);
		}
		PLSC B 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC C 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC D 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC E 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC F 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC G 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC H 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC I 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC J 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PLSC W 0 A_BIO_Deselect;
		Stop;
	Select:
		PLSC W 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		PLSC K 1 A_SetTics(invoker.FireTime1);
		PLSC L 1 A_SetTics(invoker.FireTime2);
		PLSC M 1 A_SetTics(invoker.FireTime3);
		PLSC N 1 A_SetTics(invoker.FireTime4);
		PLSC O 1;
		PLSC P 1 A_BIO_Fire;
		PLSC L 1 A_ReFire;
		PLSC K 1 A_SetTics(invoker.FireTime5);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		PLSC W 1 A_WeaponReady(WRF_NOFIRE);
		PLSC W 1 Offset(0, 32 + 2);
		PLSC W 1 Offset(0, 32 + 4);
		PLSC W 1 Offset(0, 32 + 6);
		PLSC W 1 Offset(0, 32 + 8);
		PLSC W 1 Offset(0, 32 + 10);
		PLSC W 1 Offset(0, 32 + 12);
		PLSC W 1 Offset(0, 32 + 14);
		PLSC W 1 Offset(0, 32 + 16);
		PLSC W 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		PLSC W 40 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		PLSC W 1 Offset(0, 32 + 18) A_LoadMag;
		PLSC W 1 Offset(0, 32 + 16);
		PLSC W 1 Offset(0, 32 + 14);
		PLSC W 1 Offset(0, 32 + 12);
		PLSC W 1 Offset(0, 32 + 10);
		PLSC W 1 Offset(0, 32 + 8);
		PLSC W 1 Offset(0, 32 + 6);
		PLSC W 1 Offset(0, 32 + 4);
		PLSC W 1 Offset(0, 32 + 2);
		Goto Ready;
	Spawn:
		PLSC X 0;
		PLSC X 0 A_BIO_Spawn;
		Stop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2, FireTime3, FireTime4, FireTime5);
	}

	override void GetFireTimeMinimums(in out Array<int> mins, bool _) const
	{
		mins.PushV(0, 0, 0, 0, 0);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
		FireTime3 = fireTimes[2];
		FireTime4 = fireTimes[3];
		FireTime5 = fireTimes[4];
	}

	override int TrueFireTime() const
	{
		return 3 + FireTime1 + FireTime2 + FireTime3 + FireTime4 + FireTime5;
	}

	override int TrueReloadTime() const
	{
		return ReloadTime + 19;
	}

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;
		FireTime3 = Default.FireTime3;
		FireTime4 = Default.FireTime4;
		FireTime5 = Default.FireTime5;

		ReloadTime = Default.ReloadTime;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericFireTimeReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
	}
}

class BIO_MAG_PlasmaCannon : Ammo { mixin BIO_Magazine; }
