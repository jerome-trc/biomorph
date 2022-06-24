class BIO_MachineGun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_MACHINEGUN_TAG";

		Inventory.Icon 'GPMGZ0';

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.MagazineSize 150;
		BIO_Weapon.MagazineType 'BIO_Mag_MachineGun';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_MachineGun';
		BIO_Weapon.PickupMessages
			"$BIO_MACHINEGUN_PKUP",
			"$BIO_MACHINEGUN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINGUN;
	}

	States
	{
	Spawn:
		GPMG Z 0;
		GPMG Z 0 A_BIO_Spawn;
		Stop;
	Ready:
		GPMG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		GPMG A 0 A_BIO_Deselect;
		Stop;
	Select:
		GPMG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		GPMG B 1 Bright Offset(0, 33)
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		GPMG C 1 Bright Offset(0, 34) A_BIO_SetFireTime(1);
		GPMG B 1 Bright Offset(0, 33) A_BIO_SetFireTime(2);
		GPMG A 1 Fast A_BIO_SetFireTime(3);
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		GPMG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		GPMG D 1 Bright A_Light(1);
		GPMG E 1 Bright A_Light(2);
		GPMG F 1 Bright A_Light(1);
		Goto LightDone;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_BIO_CheckReload;
		GPMG A 1 A_WeaponReady(WRF_NOFIRE);
		GPMG A 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		GPMG A 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		GPMG A 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		GPMG A 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		GPMG A 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		GPMG A 30 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
		GPMG A 1 Offset(0, 32 + 15)
		{
			A_BIO_SetReloadTime(7);
			A_BIO_LoadMag();
		}
		GPMG A 1 Fast Offset(0, 32 + 11) A_BIO_SetReloadTime(8);
		GPMG A 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(9);
		GPMG A 1 Fast Offset(0, 32 + 5) A_BIO_SetReloadTime(10);
		GPMG A 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(11);
		GPMG A 1 Fast Offset(0, 32 + 2) A_BIO_SetReloadTime(12);
		GPMG A 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(13);
		Goto Ready;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(2.0, 1.0)
				.FireSound("bio/weap/machinegun/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));
	}
}

class BIO_Mag_MachineGun : BIO_Magazine {}

class BIO_MagETM_MachineGun : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_MachineGun';
	}
}

class BIO_ETM_MachineGun : BIO_EnergyToMatterPowerup {}
