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

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.EnergyToMatter -1, 10;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.MagazineSize 8;
		BIO_Weapon.OperatingMode 'BIO_OpMode_AutoShotgun_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_AUTOSHOTGUN_PKUP",
			"$BIO_AUTOSHOTGUN_SCAV";
		BIO_Weapon.Summary
			"$BIO_AUTOSHOTGUN_SUMM";
	}

	override void SetDefaults()
	{
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 7)
				.RandomDamage(10, 15)
				.Spread(4.0, 4.0)
				.FireSound("bio/weap/autoshotgun/fire")
				.Build()
		);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 3;
	}
}

// States: core.
extend class BIO_AutoShotgun
{
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
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
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
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_AutoShotgun_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_AutoShotgun';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(weap.StateTimeGroupFrom('Rapid.Fire'));
	}

	final override statelabel FireState() const
	{
		return 'Rapid.Fire';
	}
}

extend class BIO_AutoShotgun
{
	States
	{
	Rapid.Fire:
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
		AUSG F 2 A_BIO_SetFireTime(4);
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'Rapid.Fire');
		TNT1 A 0 A_BIO_Op_PostFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	}
}
