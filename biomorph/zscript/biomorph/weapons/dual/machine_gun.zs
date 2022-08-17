class BIO_DualMachineGun : BIO_DualWieldWeapon
{
	Default
	{
		+BIO_DUALWIELDWEAPON.AKIMBORELOAD

		Tag "$BIO_DUALMACHINEGUN_TAG";

		Inventory.Icon 'GPMGZ0';

		Weapon.AmmoGive1 20;
		Weapon.AmmoType1 'Clip';
		Weapon.AmmoUse1 1;
		Weapon.AmmoGive2 20;
		Weapon.AmmoType2 'Clip';
		Weapon.AmmoUse2 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.EnergyToMatters
			BIO_MachineGun.ETMF_DURATION, BIO_MachineGun.ETMF_COST,
			BIO_MachineGun.ETMF_DURATION, BIO_MachineGun.ETMF_COST;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC;
		BIO_Weapon.MagazineTypes 'BIO_NormalMagazine', 'BIO_NormalMagazine';
		BIO_Weapon.MagazineSizes
			BIO_MachineGun.BASE_MAGSIZE,
			BIO_MachineGun.BASE_MAGSIZE;
		BIO_Weapon.OperatingMode 'BIO_OpMode_MachineGunDual_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_DUALMACHINEGUN_PKUP",
			"$BIO_DUALMACHINEGUN_SCAV";
	}

	override void SetDefaults()
	{
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload.Left'));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(2.0, 1.0)
				.FireSound("bio/weap/machinegun/fire")
				.UsePrimaryAmmo()
				.Build()
		);

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(2.0, 1.0)
				.FireSound("bio/weap/machinegun/fire")
				.UseSecondaryAmmo()
				.Build()
		);
	}

	States
	{
	Spawn:
		GPMG Z 0;
		GPMG Z 0 A_BIO_Spawn;
		Stop;
	Ready.Right:
		TNT1 A 0 A_SetOverlayOffset_X(64.0);
	Ready.Right.Loop:
		GPMG A 1 A_WeaponReady_R;
		Loop;
	Ready.Left:
		TNT1 A 0
		{
			A_SetOverlayOffset_X(64.0);
			A_BIO_OverlayFlags_L();
		}
	Ready.Left.Loop:
		GPMG A 1 A_WeaponReady_L;
		Loop;
	Deselect.Right:
		TNT1 A 0 A_SetOverlayOffset_X(64.0);
	Deselect.Right.Loop:
		GPMG A 1;
		Loop;
	Deselect.Left:
		TNT1 A 0
		{
			A_SetOverlayOffset_X(64.0);
			A_BIO_OverlayFlags_L();
		}
	Deselect.Left.Loop:
		GPMG A 1;
		Loop;
	Select.Right:
		TNT1 A 0 A_SetOverlayOffset_X(64.0);
	Select.Right.Loop:
		GPMG A 1 A_Raise_R;
		Loop;
	Select.Left:
		TNT1 A 0
		{
			A_SetOverlayOffset_X(64.0);
			A_BIO_OverlayFlags_L();
		}
	Select.Left.Loop:
		GPMG A 1 A_Raise_L;
		Loop;
	Fire.Right:
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
	Fire.Left:
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
	Flash.Left:
	Flash.Right:
		GPMG D 1 Bright
		{
			A_AddOverlayOffset_Y(1.0);
			A_Light(1);
		}
		GPMG E 1 Bright
		{
			A_AddOverlayOffset_Y(1.0);
			A_Light(2);
		}
		GPMG F 1 Bright
		{
			A_AddOverlayOffset_Y(-1.0);
			A_Light(1);
		}
		// TNT1 A 0 A_AddOverlayOffset_Y(-1.0);
		Goto LightDone;
	Dryfire.Right:
		GPMG A 1 A_AddOverlayOffset_Y(1.0);
		#### # 1 A_AddOverlayOffset_Y(1.0);
		#### # 1
		{
			A_AddOverlayOffset_Y(1.0);
			A_StartSound("bio/weap/dryfire/ballistic");
		}
		#### # 1 A_AddOverlayOffset_Y(-1.0);
		#### # 1 A_AddOverlayOffset_Y(-1.0);
		TNT1 A 0 A_AddOverlayOffset_Y(-1.0);
		Goto Ready.Right;
	Dryfire.Left:
		GPMG A 1 A_AddOverlayOffset_Y(1.0);
		#### # 1 A_AddOverlayOffset_Y(1.0);
		#### # 1
		{
			A_AddOverlayOffset_Y(1.0);
			A_StartSound("bio/weap/dryfire/ballistic");
		}
		#### # 1 A_AddOverlayOffset_Y(-1.0);
		#### # 1 A_AddOverlayOffset_Y(-1.0);
		TNT1 A 0 A_AddOverlayOffset_Y(-1.0);
		Goto Ready.Left;
	Reload.Right:
		// TODO: Reload sounds
		TNT1 A 0 A_BIO_CheckReload_L;
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(0);
			A_AddOverlayOffset_Y(1.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(1);
			A_AddOverlayOffset_Y(2.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(2);
			A_AddOverlayOffset_Y(4.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(3);
			A_AddOverlayOffset_Y(8.0);
		}
		GPMG A 1
		{
			A_BIO_SetReloadTime(4);
			A_AddOverlayOffset_Y(15.0);
		}
		GPMG A 30 A_BIO_SetReloadTime(5);
		GPMG A 1
		{
			A_BIO_SetReloadTime(6);
			A_AddOverlayOffset_Y(-15.0);
			A_BIO_LoadMag(secondary: false);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(7);
			A_AddOverlayOffset_Y(-4.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(8);
			A_AddOverlayOffset_Y(-4.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(9);
			A_AddOverlayOffset_Y(-2.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(10);
			A_AddOverlayOffset_Y(-2.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(11);
			A_AddOverlayOffset_Y(-1.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(12);
			A_AddOverlayOffset_Y(-1.0);
		}
		TNT1 A 0 A_AddOverlayOffset_Y(-1.0);
		Goto Ready.Right;
	Reload.Left:
		// TODO: Reload sounds
		TNT1 A 0 A_BIO_CheckReload_L;
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(0);
			A_AddOverlayOffset_Y(1.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(1);
			A_AddOverlayOffset_Y(2.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(2);
			A_AddOverlayOffset_Y(4.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(3);
			A_AddOverlayOffset_Y(8.0);
		}
		GPMG A 1
		{
			A_BIO_SetReloadTime(4);
			A_AddOverlayOffset_Y(15.0);
		}
		GPMG A 30 A_BIO_SetReloadTime(5);
		GPMG A 1
		{
			A_BIO_SetReloadTime(6);
			A_AddOverlayOffset_Y(-15.0);
			A_BIO_LoadMag(secondary: true);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(7);
			A_AddOverlayOffset_Y(-4.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(8);
			A_AddOverlayOffset_Y(-4.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(9);
			A_AddOverlayOffset_Y(-2.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(10);
			A_AddOverlayOffset_Y(-2.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(11);
			A_AddOverlayOffset_Y(-1.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetReloadTime(12);
			A_AddOverlayOffset_Y(-1.0);
		}
		TNT1 A 0 A_AddOverlayOffset_Y(-1.0);
		Goto Ready.Left;
	}
}

class BIO_OpMode_MachineGunDual_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const { return 'BIO_DualMachineGun'; }

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(weap.StateTimeGroupFrom('Rapid.Fire.Right'));
	}

	final override statelabel FireState() const
	{
		return 'Rapid.Fire';
	}
}

extend class BIO_DualMachineGun
{
	States
	{
	Rapid.Fire:
		TNT1 A 0
		{
			switch (OverlayID())
			{
			case PSP_LEFTWEAP: return ResolveState('Rapid.Fire.Left');
			case PSP_RIGHTWEAP: return ResolveState('Rapid.Fire.Right');
			default:
				Biomorph.Unreachable("Illegal dual-wield overlay ID.");
				return ResolveState('Null');
			}
		}
	Rapid.Fire.Left:
		TNT1 A 0 A_BIO_CheckAmmo_L;
		GPMG B 1 Bright
		{
			A_BIO_SetFireTime(0);
			A_AddOverlayOffset_Y(1.0);
			A_BIO_Fire(1);
			A_GunFlash_L();
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		GPMG C 1 Bright
		{
			A_BIO_SetFireTime(1);
			A_AddOverlayOffset_Y(1.0);
		}
		GPMG B 1 Bright
		{
			A_BIO_SetFireTime(2);
			A_AddOverlayOffset_Y(-1.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetFireTime(3);
			A_AddOverlayOffset_Y(-1.0);
		}
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'Rapid.Fire.Left');
		TNT1 A 0 A_BIO_AutoReload_L;
		TNT1 A 0 A_BIO_Op_PostFire;
		Goto Ready.Left;
	Rapid.Fire.Right:
		TNT1 A 0 A_BIO_CheckAmmo_R;
		GPMG B 1 Bright
		{
			A_BIO_SetFireTime(0);
			A_AddOverlayOffset_Y(1.0);
			A_BIO_Fire(0);
			A_GunFlash_R();
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		GPMG C 1 Bright
		{
			A_BIO_SetFireTime(1);
			A_AddOverlayOffset_Y(1.0);
		}
		GPMG B 1 Bright
		{
			A_BIO_SetFireTime(2);
			A_AddOverlayOffset_Y(-1.0);
		}
		GPMG A 1 Fast
		{
			A_BIO_SetFireTime(3);
			A_AddOverlayOffset_Y(-1.0);
		}
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'Rapid.Fire.Right');
		TNT1 A 0 A_BIO_AutoReload_R;
		TNT1 A 0 A_BIO_Op_PostFire;
		Goto Ready.Right;
	}
}
