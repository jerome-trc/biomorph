class BIO_SalvoLauncher : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4;

	Default
	{
		+WEAPON.NOAUTOFIRE

		Tag "$BIO_WEAP_TAG_SALVOLAUNCHER";
		
		Inventory.Icon 'SALVX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_SALVOLAUNCHER";

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1600;
		Weapon.SlotNumber 5;

		BIO_Weapon.AffixMasks
			BIO_WAM_MAGSIZE | BIO_WAM_RELOADTIME,
			BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.DamageRange 30, 180;
		BIO_Weapon.FireType 'BIO_Rocket';
		BIO_Weapon.MagazineType 'RocketAmmo';
		BIO_Weapon.Spread 0.2, 0.2;

		BIO_SalvoLauncher.FireTimes 2, 2, 2, 10;
	}

	States
	{
	Ready:
		SALV A 1 A_WeaponReady;
		Loop;
	Deselect:
		SALV A 0 A_BIO_Deselect;
		Stop;
	Select:
		SALV A 0 A_BIO_Select;
		Stop;
	Fire:
		#### # 0 A_JumpIf(invoker.MagazineEmpty(), 'Ready');
		SALV A 2 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1);
		SALV B 2 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
		}
		SALV C 1 Offset(0, 32 + 9);
		SALV D 1 Offset(0, 32 + 12);
		SALV C 1 Offset(0, 32 + 9);
		SALV B 2 Offset(0, 32 + 6) A_SetTics(invoker.FireTime3);
		#### # 0 A_JumpIf(invoker.MagazineEmpty(), 'Ready');
		SALV A 2 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1);
		SALV B 2 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
		}
		SALV C 1 Offset(0, 32 + 9);
		SALV D 1 Offset(0, 32 + 12);
		SALV C 1 Offset(0, 32 + 9);
		SALV B 2 Offset(0, 32 + 6) A_SetTics(invoker.FireTime3);
		#### # 0 A_JumpIf(invoker.MagazineEmpty(), 'Ready');
		SALV A 2 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1);
		SALV B 2 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
		}
		SALV C 1 Offset(0, 32 + 9);
		SALV D 1 Offset(0, 32 + 12);
		SALV C 1 Offset(0, 32 + 9);
		SALV B 2 Offset(0, 32 + 6) A_SetTics(invoker.FireTime3);
		SALV A 10 A_SetTics(invoker.FireTime4);
		#### # 0 A_ReFire;
		Goto Ready;
	AltFire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), 'Ready');
		SALV B 3 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime1 + 1);
			invoker.bAltFire = false;
			A_BIO_Fire();
		}
		SALV C 3 Offset(0, 32 + 9) A_SetTics(invoker.FireTime2 + 1);
		SALV D 3 Offset(0, 32 + 12) A_SetTics(invoker.FireTime3 + 1);
		SALV C 3 Offset(0, 32 + 9) A_SetTics(invoker.FireTime3 + 1);
		SALV B 3 Offset(0, 32 + 6) A_SetTics(invoker.FireTime2 + 1);
		SALV A 3 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1 + 1);
		// For some reason, NOAUTOFIRE blocks holding down AltFire.
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ALTATTACK, 'AltFire');
		Goto Ready;
	Spawn:
		SALV X 0;
		SALV X 0 A_BIO_Spawn;
		Loop;
	}

	override void OnTrueProjectileFired(BIO_Projectile proj)
	{
		proj.bForceRadiusDmg = true;
	}

	override void OnFastProjectileFired(BIO_FastProjectile proj)
	{
		proj.bForceRadiusDmg = true;
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

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;
		FireTime3 = Default.FireTime3;
		FireTime4 = Default.FireTime4;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericFireTimeReadout(TotalBurstFireTime(),
			"$BIO_WEAPSTAT_FIRETIME_BURST", Default.TotalBurstFireTime()));
		stats.Push(GenericFireTimeReadout(TotalAutoFireTime(),
			"$BIO_WEAPSTAT_FIRETIME_AUTO", Default.TotalAutoFireTime()));
		stats.Push(StringTable.Localize("$BIO_WEAPSTAT_FORCERADIUSDMG"));
	}

	// Note: currently unused.
	override int TrueFireTime() const { return TotalBurstFireTime(); }

	protected int TotalBurstFireTime() const
	{
		return (3 * 3) + (FireTime1 * 3) + (FireTime2 * 3) + (FireTime3 * 3) + FireTime4;
	}

	protected int TotalAutoFireTime() const
	{
		return
			((FireTime1 + 1) * 2) +
			((FireTime2 + 1) * 2) +
			((FireTime3 + 1) * 2);
	}
}
