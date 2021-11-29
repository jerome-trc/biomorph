class BIO_HandCannon : BIO_Weapon
{
	Default
	{
		Tag "$BIO_WEAP_TAG_HANDCANNON";

		Inventory.Icon 'HCANX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_HANDCANNON";

		Weapon.AmmoGive 15;
		Weapon.AmmoType 'Clip';
		Weapon.Ammouse 1;
		Weapon.SelectionOrder SELORDER_PISTOL_CLSF;
		Weapon.SlotNumber 2;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;
		Weapon.UpSound "bio/weap/gunswap_0";
		
		BIO_Weapon.Flags BIO_WF_PISTOL | BIO_WF_ONEHANDED;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineSize 7;
		BIO_Weapon.MagazineType 'BIO_MAG_HandCannon';
		BIO_Weapon.SwitchSpeeds 8, 8;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create(GetClass())
			.BasicProjectilePipeline('BIO_Bullet', 1, 50, 70, 1.0, 1.0)
			.FireSound("bio/weap/handcannon/fire")
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(BIO_StateTimeGroup.FromState(ResolveState('Fire')));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(BIO_StateTimeGroup.FromState(ResolveState('Reload')));
	}

	States
	{
	Ready:
		HCAN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		HCAN A 0 A_BIO_Deselect;
		Stop;
	Select:
		HCAN A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		HCAN E 1 Bright
		{
			A_SetFireTime(0);
			A_FireSound();
		}
		HCAN F 1 Bright
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_HandCannon');
		}
		HCAN G 1 A_SetFireTime(2);
		HCAN D 3 A_SetFireTime(3);
		HCAN G 2 A_SetFireTime(4);
		HCAN C 2 A_SetFireTime(5);
		HCAN B 2 A_SetFireTime(6);
		HCAN A 2 A_SetFireTime(7);
		HCAN A 2 A_SetFireTime(8);
		HCAN A 1
		{
			A_SetFireTime(9);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		HCAN A 1 A_WeaponReady(WRF_NOFIRE);
		HCAN A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		HCAN A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		HCAN A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		HCAN A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		HCAN A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		HCAN A 35 Offset(0, 32 + 30) A_SetReloadTime(6);
		HCAN A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		HCAN A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		HCAN A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		HCAN A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		HCAN A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		HCAN A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		HCAN A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light(1);
		TNT1 A 1 Bright A_Light(0);
		Stop;
	Spawn:
		HCAN X 0;
		HCAN X 0 A_BIO_Spawn;
		Loop;
	}
}

class BIO_MAG_HandCannon : Ammo { mixin BIO_Magazine; }
