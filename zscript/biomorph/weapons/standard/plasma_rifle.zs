class BIO_PlasmaRifle : BIO_Weapon replaces PlasmaRifle
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Tag "$TAG_PLASMARIFLE";
		Obituary "$OB_MPPLASMARIFLE";

		Inventory.Icon "PLASA0";
		Inventory.PickupMessage "$BIO_WEAP_PICKUP_PLASMARIFLE";

		Weapon.AmmoGive 50;
		Weapon.AmmoType "Cell";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 100;
		Weapon.SlotNumber 6;

		BIO_Weapon.AffixMask BIO_WAM_SECONDARY;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 40;
		BIO_Weapon.FireType "BIO_PlasmaBall";
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType "BIO_Magazine_PlasmaRifle";
		BIO_Weapon.Spread 0.2, 0.2;

		BIO_PlasmaRifle.FireTimes 3, 20;
		BIO_PlasmaRifle.ReloadTimes 40;
	}

	States
	{
	Ready:
		PLSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect.Loop:
		PLSG A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		PLSG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		PLSG A 3
		{
			A_SetTics(invoker.FireTime1);
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, FindState("Flash"), Random(0, 1));
		}
		PLSG B 20
		{
			A_SetTics(invoker.FireTime2);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		PLSG A 1 A_WeaponReady(WRF_NOFIRE);
		PLSG A 1 Offset(0, 32 + 2);
		PLSG A 1 Offset(0, 32 + 4);
		PLSG A 1 Offset(0, 32 + 6);
		PLSG A 1 Offset(0, 32 + 8);
		PLSG A 1 Offset(0, 32 + 10);
		PLSG A 1 Offset(0, 32 + 12);
		PLSG A 1 Offset(0, 32 + 14);
		PLSG A 1 Offset(0, 32 + 16);
		PLSG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		PLSG A 40 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		PLSG A 1 Offset(0, 32 + 18) A_LoadMag();
		PLSG A 1 Offset(0, 32 + 16);
		PLSG A 1 Offset(0, 32 + 14);
		PLSG A 1 Offset(0, 32 + 12);
		PLSG A 1 Offset(0, 32 + 10);
		PLSG A 1 Offset(0, 32 + 8);
		PLSG A 1 Offset(0, 32 + 6);
		PLSG A 1 Offset(0, 32 + 4);
		PLSG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		PLSF A 4 Bright
		{
			A_SetTics(invoker.FireTime1 + 1);
			A_Light(1);
		}
		Goto LightDone;
		PLSF B 4 Bright
		{
			A_SetTics(invoker.FireTime1 + 1);
			A_Light(1);
		}
		Goto LightDone;
	Spawn:
		PLAS A -1;
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

		string crEsc_ft = "", crEsc_delay = "";

		if (FireTime1 > Default.FireTime1)
			crEsc_ft = CRESC_STATWORSE;
		else if (FireTime1 < Default.FireTime1)
			crEsc_ft = CRESC_STATBETTER;
		else
			crEsc_ft = CRESC_STATDEFAULT;

		if (FireTime2 > Default.FireTime2)
			crEsc_delay = CRESC_STATWORSE;
		else if (FireTime2 < Default.FireTime2)
			crEsc_delay = CRESC_STATBETTER;
		else
			crEsc_delay = CRESC_STATDEFAULT;
		
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIRETIME"),
			crEsc_ft, float(FireTime1) / 35.0));

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_POSTFIREDELAY"),
			crEsc_delay, float(FireTime2) / 35.0));

		stats.Push(GenericReloadTimeReadout(ReloadTime + 19));
	}

	override int DefaultFireTime() const
	{
		return Default.FireTime1 + Default.FireTime2;
	}

	override int DefaultReloadTime() const
	{
		return Default.ReloadTime + 19;
	}
}

class BIO_Magazine_PlasmaRifle : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 50;
	}
}