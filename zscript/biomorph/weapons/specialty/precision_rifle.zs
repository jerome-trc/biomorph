class BIO_PrecisionRifle : BIO_NewWeapon
{
	Default
	{
		Decal 'BulletChip';
		Tag "$BIO_WEAP_TAG_PRECISIONRIFLE";

		Inventory.Icon 'PRECX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_PRECISIONRIFLE";

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_NewWeapon.Grade BIO_GRADE_SPECIALTY;
		BIO_NewWeapon.MagazineSize 20;
		BIO_NewWeapon.MagazineType 'BIO_MAG_PrecisionRifle';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create(GetClass())
			.BasicProjectilePipeline('BIO_Bullet', 1, 55, 75, 0.6, 0.6)
			.FireSound("bio/weap/precrifle/fire")
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
		PREC A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PREC A 0 A_BIO_Deselect;
		Stop;
	Select:
		PREC A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		PREC B 3
		{
			A_SetFireTime(0);
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_Shotgun');
			A_BIO_Fire();
		}
		PREC C 2 A_SetFireTime(1);
		PREC A 15 Fast A_SetFireTime(2);
		Goto Ready;
	AltFire:
	Zoom:
		Goto Ready;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		PREC A 1 A_WeaponReady(WRF_NOFIRE);
		PREC A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		PREC A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		PREC A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		PREC A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		PREC A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		PREC A 35 Offset(0, 32 + 30) A_SetReloadTime(6);
		PREC A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		PREC A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		PREC A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		PREC A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		PREC A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		PREC A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		PREC A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		TNT1 A 3 A_Light(2);
		TNT1 A 2 A_Light(1);
		Goto LightDone;
	Spawn:
		PREC X 0;
		PREC X 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_PrecisionRifle : Ammo { mixin BIO_Magazine; }
