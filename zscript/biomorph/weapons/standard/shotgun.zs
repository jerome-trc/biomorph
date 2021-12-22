class BIO_Shotgun : BIO_Weapon replaces Shotgun
{
	Default
	{
		Obituary "$OB_MPSHOTGUN";
		Tag "$TAG_SHOTGUN";

		Inventory.Icon 'SHOTA0';
		Inventory.PickupMessage "$BIO_SHOTGUN_PKUP";

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Flags BIO_WF_SHOTGUN;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType 'BIO_MAG_Shotgun';
		BIO_Weapon.PlayerVisual BIO_PVIS_SHOTGUN;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_ShotPellet', 7, 5, 15, 4.0, 2.0)
			.FireSound("weapons/shotgf")
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
		SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		SHTG A 0 A_BIO_Deselect;
		Stop;
	Select:
		SHTG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload(single: true);
		SHTG A 3 A_SetFireTime(0);
		SHTG A 4 Bright
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_GunFlash();
			A_FireSound();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		SHTG A 3 Bright A_SetFireTime(2);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		SHTG BC 5 A_SetReloadTime(0);
		SHTG D 4
		{
			A_SetReloadTime(1);
			A_LoadMag();
			A_PresetRecoil('BIO_Recoil_ShotgunPump');
		}
		SHTG CB 5 A_SetReloadTime(2);
		SHTG A 3 A_SetReloadTime(3);
		SHTG A 7
		{
			A_SetReloadTime(4);
			A_ReFire();
		}
		Goto Ready;
	Flash:
		SHTF A 4 Bright
		{
			A_SetFireTime(1);
			A_Light(1);
		}
		SHTF B 3 Bright
		{
			A_SetFireTime(2);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		SHOT B 0;
		SHOT B 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_Shotgun : Ammo { mixin BIO_Magazine; }