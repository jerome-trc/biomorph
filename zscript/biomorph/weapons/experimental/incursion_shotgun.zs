class BIO_IncursionShotgun : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;

	Default
	{
		Tag "$BIO_WEAP_TAG_INCURSIONSHOTGUN";

		Inventory.PickupMessage "$BIO_WEAP_PICKUP_INCURSIONSHOTGUN";

		Weapon.AmmoGive 20;
		Weapon.AmmoType "Shell";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1600;
		Weapon.SlotNumber 3;

		BIO_Weapon.AffixMask BIO_WAM_SECONDARY | BIO_WAM_RELOADTIME;
		BIO_Weapon.Grade BIO_GRADE_EXPERIMENTAL;
		BIO_Weapon.DamageRange 7, 17;
		BIO_Weapon.FireCount 9;
		BIO_Weapon.FireType "BIO_ShotPellet";
		BIO_Weapon.MagazineSize 4;
		BIO_Weapon.MagazineType "BIO_Magazine_IncursionShotgun";
		BIO_Weapon.Spread 4.0, 2.0;
		
		BIO_IncursionShotgun.FireTimes 3, 4, 2, 2, 2;
	}

	States
	{
	Ready:
		INCU A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect.Loop:
		INCU A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		INCU A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		INCU B 3 Bright
		{
			A_SetTics(invoker.FireTime1);
			A_BIO_Fire();
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
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		INCU B 3 Bright
		{
			invoker.bAltFire = false;
			A_SetTics(invoker.FireTime1);
			A_BIO_Fire(factor: Min(invoker.Magazine1.Amount, 4));
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
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		INCU A 3 Offset(0, 32 + 3);
		INCU A 3 Offset(0, 32 + 6);
		INCU A 2 Offset(0, 32 + 9);
		INCU A 3 Offset(0, 32 + 6)
		{
			A_LoadMag();
			A_StartSound("weapons/incursionreload", CHAN_7);
		}
		INCU A 3 Offset(0, 32 + 3);
		Goto Ready;
	Flash:
		TNT1 A 2 A_Light(1);
		TNT1 A 2 A_Light(2);
		Goto LightDone;
	Spawn:
		INCU X -1;
		Stop;
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

	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const {}
	override void SetReloadTimes(Array<int> reloadTimes, bool _) {}

	override void ResetStats()
	{
		super.ResetStats();
		let defs = GetDefaultByType(GetClass());

		FireTime1 = defs.FireTime1;
		FireTime2 = defs.FireTime2;
		FireTime3 = defs.FireTime3;
		FireTime4 = defs.FireTime4;
		FireTime5 = defs.FireTime5;
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
			float(FireTime1 + FireTime2 + FireTime3 + FireTime4 + FireTime5) / 35.0));

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_SPREAD"),
			HSpread1, VSpread1));
	}

	protected bool FireTimeModified() const
	{
		let defs = GetDefaultByType(GetClass());
		return
			(FireTime1 + FireTime2 + FireTime3 + FireTime4 + FireTime5) !=
			(defs.FireTime1 + defs.FireTime2 + defs.FireTime3 + defs.FireTime4 + defs.FireTime5);
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
