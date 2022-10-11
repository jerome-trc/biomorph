class BIO_MANPAT : BIO_Weapon
{
	Default
	{
		+WEAPON.EXPLOSIVE

		Tag "$BIO_MANPAT_TAG";

		Inventory.Icon 'LAUNA0';

		Weapon.AmmoGive 2;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.EnergyToMatter -1, 10;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.PickupMessages
			"$BIO_MANPAT_PKUP",
			"$BIO_MANPAT_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_RLAUNCHER;
	}

	override void SetDefaults()
	{
		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Projectile('BIO_Rocket')
				.X1D3Damage(50)
				.Spread(0.4, 0.4)
				.Splash(128, 128)
				.Build()
		);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 2;
	}

	States
	{
	Spawn:
		LAUN A 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		MISG A 0 A_BIO_Deselect;
		Stop;
	Select:
		MISG A 0 A_BIO_Select;
		Stop;
	Ready:
		MISG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo(single: true);
		MISG B 8
		{
			A_BIO_SetFireTime(0);
			A_GunFlash();
		}
		MISG B 12
		{
			A_BIO_SetFireTime(1);
			A_BIO_DepleteAmmo();
			A_BIO_Fire();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_RocketLauncher');
		}
		TNT1 A 0 A_BIO_AutoReload(single: true);
		Goto Ready;
	Flash:
		MISF A 1 Bright A_Light(1);
		MISF B 2 Bright;
		MISF CD 2 Bright A_Light(2);
		Goto LightDone;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		MISG A 3 Offset(0, 32 + 3) A_BIO_SetReloadTime(0);
		#### # 2 Offset(0, 32 + 6) A_BIO_SetReloadTime(1);
		#### # 2 Offset(0, 32 + 9) A_BIO_SetReloadTime(2);
		#### # 2 Offset(0, 32 + 6)
		{
			A_BIO_SetReloadTime(3);
			A_BIO_LoadMag();
			A_StartSound("bio/weap/mechreload", CHAN_7);
			A_BIO_Recoil('BIO_Recoil_ShotgunPump');
		}
		#### # 3 Offset(0, 32 + 3) A_BIO_SetReloadTime(4);
		Goto Ready;
	}
}
