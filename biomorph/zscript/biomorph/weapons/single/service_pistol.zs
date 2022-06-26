class BIO_ServicePistol : BIO_Weapon
{
	Default
	{
		Tag "$BIO_SERVICEPISTOL_TAG";

		Inventory.Icon 'PISTA0';

		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 2;
		Weapon.UpSound "bio/weap/gunswap/0";

		BIO_Weapon.GraphQuality 10;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.MagazineSize 15;
		BIO_Weapon.MagazineType 'BIO_Mag_ServicePistol';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_ServicePistol';
		BIO_Weapon.PickupMessages
			"$BIO_SERVICEPISTOL_PKUP",
			"";
		BIO_Weapon.SwitchSpeeds 14, 14;
		BIO_Weapon.SpawnCategory BIO_WSCAT_PISTOL;
	}

	States
	{
	Spawn:
		PIST A 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Ready:
		PISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PISG A 0 A_BIO_Deselect;
		Stop;
	Select:
		PISG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PISG A 2 A_BIO_SetFireTime(0);
		PISG B 2 Bright
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_Handgun');
		}
		PISG C 2 A_BIO_SetFireTime(2);
		TNT1 A 0 A_ReFire;
		PISG B 2 A_BIO_SetFireTime(3);
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		PISG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		PISF A 4 Bright
		{
			A_BIO_SetFireTime(1, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		PISG A 1 A_WeaponReady(WRF_NOFIRE);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		#### # 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		#### # 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		#### # 24 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
		#### # 1 Offset(0, 32 + 15)
		{
			A_BIO_SetReloadTime(7);
			A_BIO_LoadMag();
		}
		#### # 1 Fast Offset(0, 32 + 11) A_BIO_SetReloadTime(8);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(9);
		#### # 1 Fast Offset(0, 32 + 5) A_BIO_SetReloadTime(10);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(11);
		#### # 1 Fast Offset(0, 32 + 2) A_BIO_SetReloadTime(12);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(13);
		Goto Ready;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(10, 12)
				.Spread(1.5, 1.5)
				.FireSound("bio/weap/servicepistol/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));
	}
}

class BIO_Mag_ServicePistol : BIO_Magazine {}

class BIO_MagETM_ServicePistol : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_ServicePistol';
	}
}

class BIO_ETM_ServicePistol : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -5;
		BIO_EnergyToMatterPowerup.CellCost 1;
	}
}
