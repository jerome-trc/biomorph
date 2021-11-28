class BIO_BarrageLauncher : BIO_Weapon
{
	int FireTime1, FireTime2, FireTime3, FireTime4;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4;

	Default
	{
		+WEAPON.BFG
		+WEAPON.EXPLOSIVE
		+WEAPON.NOAUTOFIRE

		Tag "$BIO_WEAP_TAG_BARRAGELAUNCHER";
		
		Inventory.Icon 'BARRX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_BARRAGELAUNCHER";

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_RLAUNCHER + 40;
		Weapon.SlotNumber 5;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.AffixMasks BIO_WAM_MAGAZINELESS, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.DamageRange 30, 180;
		BIO_Weapon.FireType 'BIO_Rocket';
		BIO_Weapon.MagazineType 'RocketAmmo';
		BIO_Weapon.Spread 0.2, 0.2;

		BIO_BarrageLauncher.FireTimes 2, 2, 2, 10;
	}

	States
	{
	Ready:
		BARR A 1 A_WeaponReady;
		Loop;
	Deselect:
		BARR A 0 A_BIO_Deselect;
		Stop;
	Select:
		BARR A 0 A_BIO_Select;
		Stop;
	Fire:
		#### # 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR A 2 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1);
		BARR B 2 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 1 Offset(0, 32 + 9);
		BARR D 1 Offset(0, 32 + 12);
		BARR C 1 Offset(0, 32 + 9);
		BARR B 2 Offset(0, 32 + 6) A_SetTics(invoker.FireTime3);
		#### # 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR A 2 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1);
		BARR B 2 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 1 Offset(0, 32 + 9);
		BARR D 1 Offset(0, 32 + 12);
		BARR C 1 Offset(0, 32 + 9);
		BARR B 2 Offset(0, 32 + 6) A_SetTics(invoker.FireTime3);
		#### # 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR A 2 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1);
		BARR B 2 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 1 Offset(0, 32 + 9);
		BARR D 1 Offset(0, 32 + 12);
		BARR C 1 Offset(0, 32 + 9);
		BARR B 2 Offset(0, 32 + 6) A_SetTics(invoker.FireTime3);
		BARR A 10 A_SetTics(invoker.FireTime4);
		#### # 0 A_ReFire;
		Goto Ready;
	AltFire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR B 3 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.FireTime1 + 1);
			invoker.bAltFire = false;
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 3 Offset(0, 32 + 9) A_SetTics(invoker.FireTime2 + 1);
		BARR D 3 Offset(0, 32 + 12) A_SetTics(invoker.FireTime3 + 1);
		BARR C 3 Offset(0, 32 + 9) A_SetTics(invoker.FireTime3 + 1);
		BARR B 3 Offset(0, 32 + 6) A_SetTics(invoker.FireTime2 + 1);
		BARR A 3 Offset(0, 32 + 3) A_SetTics(invoker.FireTime1 + 1);
		// For some reason, NOAUTOFIRE blocks holding down AltFire.
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ALTATTACK, 'AltFire');
		Goto Ready;
	Spawn:
		BARR X 0;
		BARR X 0 A_BIO_Spawn;
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
