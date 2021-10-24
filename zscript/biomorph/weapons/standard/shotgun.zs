class BIO_Shotgun : BIO_Weapon replaces Shotgun
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5;
	property ReloadTimes: ReloadTime1, ReloadTime2, ReloadTime3, ReloadTime4, ReloadTime5;

	Default
	{
		Obituary "$OB_MPSHOTGUN";
		Tag "$TAG_SHOTGUN";

		Weapon.AmmoGive 8;
		Weapon.AmmoType "Shell";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1300;
		Weapon.SlotNumber 3;
		Weapon.UpSound "weapons/gunswap";

		BIO_Weapon.AffixMask BIO_WAM_SECONDARY;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireCount 7;
		BIO_Weapon.FireType "BIO_ShotPellet";
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType "BIO_Magazine_Shotgun";
		BIO_Weapon.Spread 4.0, 2.0;

		BIO_Shotgun.FireTimes 3, 7;
		BIO_Shotgun.ReloadTimes 5, 4, 5, 3, 7;
	}

	States
	{
	Ready:
		SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect.Loop:
		SHTG A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		SHTG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		SHTG A 3 A_SetTics(invoker.FireTime1);
		SHTG A 7
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
			A_StartSound("weapons/shotgf", CHAN_WEAPON);
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
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
		SHTF A 4 Bright A_Light(1);
		SHTF B 3 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		SHOT A -1;
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
		let defs = GetDefaultByType(GetClass());

		FireTime1 = defs.FireTime1;
		FireTime2 = defs.FireTime2;

		ReloadTime1 = defs.ReloadTime1;
		ReloadTime2 = defs.ReloadTime2;
		ReloadTime3 = defs.ReloadTime3;
		ReloadTime4 = defs.ReloadTime4;
		ReloadTime5 = defs.ReloadTime5;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
			DamageFontColor(),
			MinDamage1, MaxDamage1,
			FireCountFontColor(),
			FireCount1 == -1 ? 1 : FireCount1,
			FireTypeFontColor(),
			GetDefaultByType(FireType1).GetTag()));
		
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIRETIME"),
			FireTimeModified() ? CRESC_STATMODIFIED : CRESC_STATUNMODIFIED,
			float(FireTime1 + FireTime2) / 35.0));

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_SPREAD"),
			HSpread1, VSpread1));
	}

	protected bool FireTimeModified() const
	{
		let defs = GetDefaultByType(GetClass());
		return (FireTime1 + FireTime2) != (defs.FireTime1 + defs.FireTime2);
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
