class BIO_BFG : BIO_Weapon
{
	Default
	{
		+WEAPON.BFG
		+WEAPON.NOAUTOFIRE

		Tag "$BIO_BFG_TAG";

		Inventory.Icon 'BBFGZ0';

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 40;
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.EnergyToMatter -1, 40;
		BIO_Weapon.MagazineFlags BIO_MAGF_PLASMA_1;
		BIO_Weapon.MagazineType 'BIO_RechargingMagazine';
		BIO_Weapon.MagazineSize 200;
		BIO_Weapon.PickupMessages
			"$BIO_BFG_PKUP",
			"$BIO_BFG_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_BFG9000;
	}

	override void SetDefaults()
	{
		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(BIO_StateTimeGroup.RechargeTime(3));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Projectile('BIO_BFGBall')
				.AddBFGSpray()
				.X1D8Damage(100)
				.FireSound("weapons/bfgf")
				.Build()
		);
	}

	States
	{
	Spawn:
		BBFG Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		BBFG A 0 A_BIO_Deselect;
		Stop;
	Select:
		BBFG A 0 A_BIO_Select;
		Stop;
	Ready:
		BBFG A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Fire: // Default 60 tics
		TNT1 A 0 A_BIO_CheckAmmo;
		BBFG B 18
		{
			A_BIO_SetFireTime(0);
			A_BIO_FireSound();
		}
		BBFG C 7 Bright A_BIO_SetFireTime(1);
		BBFG D 4 Bright A_BIO_SetFireTime(2);
		BBFG E 2 Bright
		{
			A_BIO_SetFireTime(3);
			A_BIO_Fire();
			A_BIO_DepleteAmmo();
			A_BIO_Recoil('BIO_Recoil_BFG');
		}
		BBFG D 4 Bright A_BIO_SetFireTime(4);
		BBFG C 7 Bright A_BIO_SetFireTime(5);
		BBFG B 18
		{
			A_BIO_SetFireTime(6);
			A_Refire();
		}
		TNT1 A 0 A_BIO_AutoReload;
		TNT1 A 0 A_ReFire;
		Goto Ready;
	Flash:
		TNT1 A 36 Bright
		{
			A_BIO_SetFireTime(0);
			A_Light(1);
		}
		TNT1 A 7 Bright
		{
			A_BIO_SetFireTime(1);
			A_Light(2);
		}
		TNT1 A 4 Bright
		{
			A_BIO_SetFireTime(2);
			A_Light(3);
		}
		TNT1 A 2 Bright
		{
			A_BIO_SetFireTime(3);
			A_Light(5);
		}
		TNT1 A 4 Bright
		{
			A_BIO_SetFireTime(4);
			A_Light(3);
		}
		TNT1 A 7 Bright
		{
			A_BIO_SetFireTime(5);
			A_Light(2);
		}
		Goto LightDone;
	}
}
