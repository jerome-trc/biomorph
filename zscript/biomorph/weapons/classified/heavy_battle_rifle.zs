class BIO_HeavyBattleRifle : BIO_Weapon
{
	Default
	{
		Decal 'BulletChip';
		Tag "$BIO_HBR_TAG";

		Inventory.PickupMessage "$BIO_HBR_PKUP";

		Weapon.AmmoGive 60;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN_CLSF;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineSize 60;
		BIO_Weapon.MagazineType 'BIO_MAG_HBR';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_Bullet', 1, 25, 75, 0.6, 0.6)
			.FireSound("bio/weap/hbr/fire")
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire'));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Reload'));
	}

	States
	{
	Ready:
		HVBR A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		HVBR A 0 A_BIO_Deselect;
		Stop;
	Select:
		HVBR A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		HVBR A 1 Offset(0, 32 + 3) Bright
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_FireSound();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		HVBR B 4 Offset(0, 32 + 6) Bright A_SetFireTime(1);
		HVBR C 5 Offset(0, 32 + 9) Bright A_SetFireTime(2);
		HVBR B 4 Offset(0, 32 + 6) A_SetFireTime(3);
		HVBR A 8 Offset(0, 32 + 3)
		{
			A_SetFireTime(4);
			A_ReFire();
		}
		Goto Ready;
	Flash:
		HVBR D 1 Bright A_Light(1);
		HVBR E 4 Bright A_Light(2);
		HVBR F 5 Bright A_Light(1);
		Goto LightDone;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		HVBR A 1 A_WeaponReady(WRF_NOFIRE);
		HVBR A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		HVBR A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		HVBR A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		HVBR A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		HVBR A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		HVBR A 40 Offset(0, 32 + 30) A_SetReloadTime(6);
		HVBR A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		HVBR A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		HVBR A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		HVBR A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		HVBR A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		HVBR A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		HVBR A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Spawn:
		HVBR X 0;
		HVBR X 0 A_BIO_Spawn;
		Loop;
	}
}

class BIO_MAG_HBR : Ammo { mixin BIO_Magazine; }
