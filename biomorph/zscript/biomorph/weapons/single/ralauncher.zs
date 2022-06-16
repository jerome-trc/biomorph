class BIO_RocketAutoLauncher : BIO_Weapon
{
	Default
	{
		+WEAPON.EXPLOSIVE

		Tag "$BIO_ROCKETAUTOLAUNCHER_TAG";

		Inventory.Icon 'LAUNA0';

		Weapon.AmmoGive 2;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.MagazineType 'RocketAmmo';
		BIO_Weapon.PickupMessages
			"$BIO_ROCKETAUTOLAUNCHER_PKUP",
			"$BIO_ROCKETAUTOLAUNCHER_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_RLAUNCHER;
	}

	States
	{
	Spawn:
		LAUN A 0;
		LAUN A 0 A_BIO_Spawn;
		Stop;
	Deselect:
		MISG A 0 A_BIO_Deselect;
		Stop;
	Select:
		MISG A 0 A_BIO_Select;
		Stop;
	Ready:
		MISG A 1 A_WeaponReady;
		Loop;
	Flash:
		MISF A 1 Bright A_Light(1);
		MISF B 2 Bright;
		MISF CD 2 Bright A_Light(2);
		Goto LightDone;
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
			A_BIO_Fire();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_RocketLauncher');
		}
		MISG B 0 A_ReFire;
		TNT1 A 0 A_BIO_AutoReload(single: true);
		Goto Ready;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Projectile('BIO_Rocket')
				.X1D3Damage(50)
				.Spread(0.4, 0.4)
				.Splash(128, 128)
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
	}
}
