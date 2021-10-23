class BIO_BFG9000 : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		+WEAPON.NOAUTOFIRE;

		Height 20;
		Tag "$TAG_BFG9000";

		Weapon.SlotNumber 7;
		Weapon.AmmoUse 40;
		Weapon.AmmoGive 80;
		Weapon.AmmoType "Cell";
		
		// Affixes cannot change that this weapon fires exactly 1 BFG ball
		BIO_Weapon.AffixMask
			BIO_WAM_FIRECOUNT_1 | BIO_WAM_FIRETYPE_1 | BIO_WAM_SECONDARY;
		BIO_Weapon.FireTypes "BIO_BFGBall", "BIO_BFGExtra";
		BIO_Weapon.FireCounts 1, 40;
		BIO_Weapon.DamageRanges 100, 800, 49, 87;
		BIO_Weapon.MagazineSize 80;
		BIO_Weapon.MagazineType "BIO_Magazine_BFG9000";
		BIO_Weapon.Spread 0.2, 0.2;
		BIO_Weapon.SwitchSpeeds 5, 5;

		BIO_BFG9000.FireTimes 20, 10, 10, 20;
		BIO_BFG9000.ReloadTimes 30;
	}

	States
	{
	Ready:
		BFGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		BFGG A 1 A_BIO_Lower;
		Loop;
	Select:
		BFGG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		BFGG A 20
		{
			A_SetTics(invoker.FireTime1);
			A_BFGSound();
		}
		BFGG B 10
		{
			A_SetTics(invoker.FireTime2);
			A_GunFlash();
		}
		BFGG B 10
		{
			A_SetTics(invoker.FireTime3);
			A_BIO_Fire();
		}
		BFGG B 20
		{
			A_SetTics(invoker.FireTime4);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		BFGG A 1 A_WeaponReady(WRF_NOFIRE);
		BFGG A 1 Offset(0, 32 + 2);
		BFGG A 1 Offset(0, 32 + 4);
		BFGG A 1 Offset(0, 32 + 6);
		BFGG A 1 Offset(0, 32 + 8);
		BFGG A 1 Offset(0, 32 + 10);
		BFGG A 1 Offset(0, 32 + 12);
		BFGG A 1 Offset(0, 32 + 14);
		BFGG A 1 Offset(0, 32 + 16);
		BFGG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		BFGG A 30 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		TNT1 A 0 A_LoadMag(); 
		BFGG A 1 Offset(0, 32 + 18);
		BFGG A 1 Offset(0, 32 + 16);
		BFGG A 1 Offset(0, 32 + 14);
		BFGG A 1 Offset(0, 32 + 12);
		BFGG A 1 Offset(0, 32 + 10);
		BFGG A 1 Offset(0, 32 + 8);
		BFGG A 1 Offset(0, 32 + 6);
		BFGG A 1 Offset(0, 32 + 4);
		BFGG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		BFGF A 11 Bright A_Light(1);
		BFGF B 6 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		BFUG A -1;
		Stop;
	}

	override void OnProjectileFired(Actor proj) const
	{
		let bfgBall = BIO_BFGBall(proj);
		bfgBall.BFGRays = FireCount2;
		bfgBall.MinRayDamage = MinDamage2;
		bfgBall.MaxRayDamage = MaxDamage2;
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
		let defs = GetDefaultByType(GetClass());

		FireTime1 = defs.FireTime1;
		FireTime2 = defs.FireTime2;
		FireTime3 = defs.FireTime3;
		FireTime4 = defs.FireTime4;

		ReloadTime = defs.ReloadTime;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		// Ball stats
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
			DamageFontColor(false),
			MinDamage1, MaxDamage1,
			FireCountFontColor(false),
			FireCount1 == -1 ? 1 : FireCount1,
			FireTypeFontColor(false),
			GetDefaultByType(FireType1).GetTag()));

		// Ray stats
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
			DamageFontColor(true),
			MinDamage2, MaxDamage2,
			FireCountFontColor(true),
			FireCount2 == -1 ? 1 : FireCount2,
			FireTypeFontColor(true),
			GetDefaultByType(FireType2).GetTag()));

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIRETIME"),
			FireTimeModified() ? CRESC_STATMODIFIED : CRESC_STATUNMODIFIED,
			float(FireTime1 + FireTime2 + FireTime3 + FireTime4) / 35.0));
	}

	protected bool FireTimeModified() const
	{
		let defs = GetDefaultByType(GetClass());
		return
			(FireTime1 + FireTime2 + FireTime3 + FireTime4) !=
			(defs.FireTime1 + defs.FireTime2 + defs.FireTime3 + defs.FireTime4);
	}
}

class BIO_Magazine_BFG9000 : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 80;
	}
}
