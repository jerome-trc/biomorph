class BIO_ServicePistol : BIO_Weapon
{
	flagdef SlideBack: DynFlags, 31;

	Default
	{
		Tag "$BIO_SERVICEPISTOL_TAG";

		Inventory.Icon 'SVCPZ0';

		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 2;
		Weapon.UpSound "bio/weap/gunswap/0";

		BIO_Weapon.GraphQuality 10;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.EnergyToMatter -5, 1;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.MagazineSize 15;
		BIO_Weapon.PickupMessages
			"$BIO_SERVICEPISTOL_PKUP",
			"";
		BIO_Weapon.SwitchSpeeds 14, 14;
		BIO_Weapon.SpawnCategory BIO_WSCAT_PISTOL;
		BIO_Weapon.Summary "$BIO_SERVICEPISTOL_SUMM";
	}

	override void SetDefaults()
	{
		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload.FromEmpty'));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(10, 12)
				.Spread(1.5, 1.5)
				.FireSound("bio/weap/servicepistol/fire")
				.Build()
		);
	}

	States
	{
	Spawn:
		SVCP Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		SVCP # 0 A_BIO_Deselect;
		Stop;
	Select:
		SVCP # 0 A_BIO_Select;
		Stop;
	Ready:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), 'Ready.Empty');
	Ready.Chambered:
		SVCP A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Ready.Empty:
		SVCP B 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		SVCP C 4
		{
			A_BIO_SetFireTime(0);
			A_BIO_DepleteAmmo();
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_Handgun');
		}
		SVCP D 4 A_BIO_SetFireTime(1);
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		SVCP B 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		SVCP Y 4 Bright
		{
			A_BIO_SetFireTime(0);
			A_Light(1);
		}
		Goto LightDone;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), 'Reload.FromEmpty');
	Reload.FromLoaded:
		SVCP E 1 A_WeaponReady(WRF_NOFIRE);
		Goto Reload.Common;
	Reload.FromEmpty:
		SVCP F 1 A_WeaponReady(WRF_NOFIRE);
	Reload.Common:
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		#### # 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		#### # 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		#### # 24 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
		#### # 1 Offset(0, 32 + 15)
		{
			invoker.bSlideBack = invoker.MagazineEmpty();
			A_BIO_SetReloadTime(7);
			A_BIO_LoadMag();
		}
		#### # 1 Fast Offset(0, 32 + 11) A_BIO_SetReloadTime(8);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(9);
		#### # 1 Fast Offset(0, 32 + 5) A_BIO_SetReloadTime(10);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(11);
		#### # 1 Fast Offset(0, 32 + 2) A_BIO_SetReloadTime(12);
		#### # 1 Fast Offset(0, 32 + 1) 
		{
			A_BIO_SetReloadTime(13);

			if (invoker.bSlideBack)
			{
				A_StartSound("bio/weap/servicepistol/reload/end", CHAN_AUTO);
				invoker.bSlideBack = false;
			}
		}
		Goto Ready;
	}
}
