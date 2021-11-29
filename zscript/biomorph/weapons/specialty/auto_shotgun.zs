class BIO_AutoShotgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_WEAP_TAG_AUTOSHOTGUN";

		Inventory.Icon 'AUSGX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_AUTOSHOTGUN";

		Weapon.AmmoGive 15;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN_SPEC;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Flags BIO_WF_SHOTGUN;
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineType 'BIO_MAG_AutoShotgun';
		BIO_Weapon.MagazineSize 15;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create(GetClass())
			.BasicProjectilePipeline('BIO_ShotPellet', 8, 6, 16, 3.8, 1.9)
			.FireSound("bio/weap/autoshotgun/fire")
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
		AUSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		AUSG A 0 A_BIO_Deselect;
		Stop;
	Select:
		AUSG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		AUSG B 1 Bright Offset(0, 32 + 2)
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_FireSound();
			A_PresetRecoil('BIO_Recoil_Shotgun', scale: 1.2);
		}
		AUSG C 2 Bright Offset(0, 32 + 6) A_SetFireTime(1);
		AUSG D 3 Offset(0, 32 + 12) A_SetFireTime(2);
		AUSG A 3 Fast Offset(0, 32 + 2) A_SetFireTime(3);
		AUSG A 7 Offset(0, 32)
		{
			A_SetFireTime(4);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		AUSG A 1 A_WeaponReady(WRF_NOFIRE);
		AUSG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		AUSG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		AUSG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		AUSG A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		AUSG A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		AUSG A 40 Offset(0, 32 + 30) A_SetReloadTime(6);
		AUSG A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		AUSG A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		AUSG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		AUSG A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		AUSG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		AUSG A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		AUSG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light(1);
		TNT1 A 2 Bright A_SetFireTime(0);
		TNT1 A 3 Bright
		{
			A_SetFireTime(0, modifier: 1);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		AUSG X 0;
		AUSG X 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_AutoShotgun : Ammo { mixin BIO_Magazine; }
