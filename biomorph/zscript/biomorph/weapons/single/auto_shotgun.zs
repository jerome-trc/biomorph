class BIO_AutoShotgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_AUTOSHOTGUN_TAG";

		Inventory.Icon 'AUSGZ0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 4;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.MagazineSize 8;
		BIO_Weapon.MagazineType 'BIO_Mag_AutoShotgun';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_AutoShotgun';
		BIO_Weapon.ModCostMultiplier 2;
		BIO_Weapon.PickupMessages
			"$BIO_AUTOSHOTGUN_PKUP",
			"$BIO_AUTOSHOTGUN_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_SSG;
	}

	States
	{
	Spawn:
		AUSG Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Ready:
		AUSG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		AUSG A 0 A_BIO_Deselect;
		Stop;
	Select:
		AUSG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		AUSG B 3 Bright
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_Shotgun');
		}
		AUSG C 4 Bright A_BIO_SetFireTime(1);
		AUSG D 2 A_BIO_SetFireTime(2);
		AUSG E 2 A_BIO_SetFireTime(3);
		AUSG F 2
		{
			A_BIO_SetFireTime(4);
			A_ReFire();
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		AUSG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		TNT1 A 3
		{
			A_BIO_SetFireTime(0);
			A_Light(1);
		}
		TNT1 A 4 
		{
			A_BIO_SetFireTime(1);
			A_Light(2);
		}
		Goto LightDone;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		AUSG A 1 A_WeaponReady(WRF_NOFIRE);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		#### # 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		#### # 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		#### # 40 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
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
	Zoom:
		TNT1 A 0 A_BIO_WeaponSpecial;
		Goto Ready;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 7)
				.RandomDamage(10, 15)
				.Spread(4.0, 4.0)
				.FireSound("bio/weap/autoshotgun/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));
	}
}

class BIO_Mag_AutoShotgun : BIO_Magazine {}

class BIO_MagETM_AutoShotgun : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_AutoShotgun';
	}
}

class BIO_ETM_AutoShotgun : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -1;
		BIO_EnergyToMatterPowerup.CellCost 15;
	}
}
