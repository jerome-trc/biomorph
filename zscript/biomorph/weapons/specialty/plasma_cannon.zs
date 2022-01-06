class BIO_PlasmaCannon : BIO_Weapon
{
	Default
	{
		Tag "$BIO_PLASMACANNON_TAG";

		Inventory.Icon 'PLSCZ0';
		Inventory.PickupMessage "$BIO_PLASMACANNON_PKUP";

		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 2;
		Weapon.SelectionOrder SELORDER_PLASRIFLE_SPEC;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/plascannon/raise";

		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType 'BIO_MAG_PlasmaCannon';
		BIO_Weapon.PlayerVisual BIO_PVIS_PLASMARIFLE;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicProjectilePipeline('BIO_PlasmaGlobule', 1, 10, 80, 0.4, 0.4)
			.Splash(48, 48)
			.AssociateFirstFireTime()
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
		PLSC A 1
		{
			A_WeaponReady(WRF_ALLOWRELOAD);
			A_StartSound("bio/weap/plascannon/idle", CHAN_7, CHANF_DEFAULT, 0.6, 0.2);
		}
		PLSC B 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC C 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC D 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC E 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC F 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC G 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC H 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC I 1 A_WeaponReady(WRF_ALLOWRELOAD);
		PLSC J 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PLSC W 0 A_BIO_Deselect;
		Stop;
	Select:
		PLSC W 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PLSC K 1 A_SetFireTime(0);
		PLSC L 1 A_SetFireTime(1);
		PLSC M 1 A_SetFireTime(2);
		PLSC N 1 A_SetFireTime(3);
		PLSC O 1 A_SetFireTime(4);
		PLSC P 1
		{
			A_SetFireTime(5);
			A_BIO_Fire();
		}
		PLSC L 1
		{
			A_SetFireTime(6);
			A_ReFire();
		}
		PLSC K 1 A_SetFireTime(7);
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		PLSC W 1 A_WeaponReady(WRF_NOFIRE);
		PLSC W 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		PLSC W 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		PLSC W 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		PLSC W 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		PLSC W 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		PLSC W 40 Offset(0, 32 + 30) A_SetReloadTime(6);
		PLSC W 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		PLSC W 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		PLSC W 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		PLSC W 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		PLSC W 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		PLSC W 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		PLSC W 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Spawn:
		PLSC Z 0;
		PLSC Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_PlasmaCannon : Ammo { mixin BIO_Magazine; }
