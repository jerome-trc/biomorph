class BIO_Shotgun : BIO_Weapon
{
	flagdef RoundPending: DynFlags, 31;

	Default
	{
		Tag "$BIO_SHOTGUN_TAG";

		Inventory.Icon 'KKSGZ0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_LOW;
		Weapon.UpSound "bio/weap/gunswap/0";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.MagazineSize 8;
		BIO_Weapon.EnergyToMatter -1, 5;
		BIO_Weapon.PickupMessages
			"$BIO_SHOTGUN_PKUP",
			"$BIO_SHOTGUN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_SHOTGUN;
		BIO_Weapon.Summary "$BIO_SHOTGUN_SUMM";
	}

	override void SetDefaults()
	{
		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		FireTimeGroups.Push(
			StateTimeGroupFrom(
				'Pump',
				"$BIO_PUMP",
				flags: BIO_STGF_AUXILIARY
			)
		);

		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 7)
				.RandomDamage(10, 15)
				.Spread(3.0, 3.0)
				.FireSound("bio/weap/shotgun/fire")
				.Build()
		);
	}

	States
	{
	Spawn:
		KKSG Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		KKSG A 0 A_BIO_Deselect;
		Stop;
	Select:
		KKSG A 0 A_BIO_Select;
		Stop;
	Ready:
		KKSG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo(single: true);
		KKSG A 3 Fast A_BIO_SetFireTime(0);
		KKSG A 1 Offset(0 + 7, 32 + 7)
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_Shotgun');
			invoker.bRoundPending = !invoker.MagazineEmpty();
		}
		KKSG A 1 Offset(0 + 5, 32 + 5) Fast A_BIO_SetFireTime(2);
		KKSG A 1 Offset(0 + 2, 32 + 2) Fast A_BIO_SetFireTime(3);
		KKSG A 1 Offset(0 + 1, 32 + 1) Fast A_BIO_SetFireTime(4);
		KKSG A 1 Fast
		{
			A_BIO_SetFireTime(5);
			// This is the only way I've found to prevent
			// last X offset from being preserved
			A_WeaponOffset(0.0, 32.0);
		}
		TNT1 A 0 A_BIO_AutoReload(single: true);
		TNT1 A 0
		{
			if (invoker.bRoundPending)
				return ResolveState('Pump');
			else
				return state(null);
		}
		TNT1 A 0 A_ReFire;
		Goto Ready;
	Dryfire:
		KKSG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		KKSG Y 4 Bright
		{
			A_BIO_SetFireTime(1);
			A_Light(1);
		}
		TNT1 A 3 Bright
		{
			A_BIO_SetFireTime(2);
			A_Light(2);
		}
		Goto LightDone;
	Pump:
		TNT1 A 0 A_JumpIf(!invoker.bRoundPending, 'Ready');
		KKSG A 1 Fast A_BIO_SetFireTime(0, 1);
		KKSG B 2 A_BIO_SetFireTime(1, 1);
		KKSG C 4
		{
			A_BIO_SetFireTime(2, 1);
			A_StartSound("bio/weap/shotgun/pumpback", CHAN_AUTO, volume: 0.7);
			A_BIO_Recoil('BIO_Recoil_ShotgunPump');
		}
		KKSG B 2
		{
			A_BIO_SetFireTime(3, 1);
			A_StartSound("bio/weap/shotgun/pumpforward", CHAN_AUTO, volume: 0.7);
		}
		KKSG A 1 Fast A_BIO_SetFireTime(4, 1);
		Goto Ready;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		KKSG A 1 A_WeaponReady(WRF_NOFIRE);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		#### # 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		#### # 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		#### # 20 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
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
		TNT1 A 0
		{
			if (!invoker.bRoundPending)
			{
				invoker.bRoundPending = true;
				return ResolveState('Pump');
			}

			return state(null);
		}
		Goto Ready;
	}
}
