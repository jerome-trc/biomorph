class BIO_RocketLauncher : BIO_Weapon replaces RocketLauncher
{
	Default
	{
		+WEAPON.EXPLOSIVE
		+WEAPON.NOAUTOFIRE

		Decal 'BulletChip';
		Tag "$TAG_ROCKETLAUNCHER";
		
		Inventory.Icon 'LAUNA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_ROCKETLAUNCHER";

		Weapon.AmmoGive 2;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;
		Weapon.SlotPriority SLOTPRIO_STANDARD;

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType 'BIO_MAG_RocketLauncher';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create(GetClass())
			.BasicProjectilePipeline('BIO_Rocket', 1, 20, 160, 0.4, 0.4)
			.Splash(128, 128)
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
		MISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		MISG A 0 A_BIO_Deselect;
		Stop;
	Select:
		MISG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		MISG B 8
		{
			A_SetFireTime(0);
			A_GunFlash();
		}
		MISG B 12
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_RocketLauncher');
		}
		MISG B 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		MISG A 1 A_WeaponReady(WRF_NOFIRE);
		MISG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		MISG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		MISG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		MISG A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		MISG A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		MISG A 45 Offset(0, 32 + 30) 
		{
			A_SetReloadTime(6);
			A_PresetRecoil('BIO_Recoil_HeavyReload');
		}
		MISG A 1 Offset(0, 32 + 18)
		{
			A_SetReloadTime(7);
			A_LoadMag();
			A_PresetRecoil('BIO_Recoil_HeavyReload', invert: true);
		}
		MISG A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		MISG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		MISG A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		MISG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		MISG A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		MISG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		MISF A 3 Bright A_Light1;
		MISF B 4 Bright;
		MISF CD 4 Bright A_Light2;
		Goto LightDone;
	Spawn:
		LAUN A 0;
		LAUN A 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_RocketLauncher : Ammo { mixin BIO_Magazine; }
