class BIO_Stormgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_STORMGUN_TAG";

		Inventory.Icon 'TYPHZ0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";
		
		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.EnergyToMatter -1, 8;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineSize 20;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.PickupMessages
			"$BIO_STORMGUN_PKUP",
			"$BIO_STORMGUN_SCAV";
		BIO_Weapon.ReloadRatio 1, 10;
		BIO_Weapon.SpawnCategory BIO_WSCAT_SSG;
	}

	override void SetDefaults()
	{
		FireTimeGroups.Push(StateTimeGroupFrom('Fire.Loop'));
		FireTimeGroups.Push(StateTimeGroupFrom('Fire.Finish'));

		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 2)
				.RandomDamage(10, 15)
				.Spread(9.0, 9.0)
				.FireSound("bio/weap/stormgun/fire")
				.AmmoUseMulti(2)
				.Build()
		);
	}

	States
	{
	Spawn:
		TYPH Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Ready:
		TYPH A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		TYPH A 0 A_BIO_Deselect;
		Stop;
	Select:
		TYPH A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		TNT1 A 0 A_BIO_DepleteAmmo;
		Goto Fire.Loop;
	Fire.Loop:
		TYPH B 1
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		TYPH C 1 A_BIO_SetFireTime(1);
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), 'Fire.Finish');
		Loop;
	Fire.Finish:
		TYPH D 3 A_BIO_SetFireTime(0, 1);
		TYPH E 3 A_BIO_SetFireTime(1, 1);
		TYPH F 3 A_BIO_SetFireTime(2, 1);
		TNT1 A 0 A_BIO_AutoReload(single: true);
		Goto Ready;
	Dryfire:
		TYPH A 1 Offset(0, 32 + 1);
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
	Reload: // 52 tics default
		TNT1 A 0 A_BIO_CheckReload;
		TYPH A 1 A_WeaponReady(WRF_NOFIRE);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		#### # 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		#### # 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		#### # 30 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
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
}
