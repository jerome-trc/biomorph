class BIO_PlasmaRifle : BIO_Weapon
{
	Default
	{
		Tag "$TAG_PLASMARIFLE";
		Obituary "$OB_MPPLASMARIFLE";

		Inventory.Icon 'PLASA0';
		Inventory.PickupMessage "$BIO_PLASMARIFLE_PKUP";

		Weapon.AmmoGive 50;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority SLOTPRIO_STANDARD;

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType 'BIO_MAG_PlasmaRifle';
		BIO_Weapon.PlayerVisual BIO_PVIS_PLASMARIFLE;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicProjectilePipeline('BIO_PlasmaBall', 1, 5, 40, 0.4, 0.4)
			.AssociateFirstFireTime()
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFromRange('Fire', 'Cooldown', "$BIO_FIRE"));
		groups.Push(StateTimeGroupFrom('Cooldown', "$BIO_COOLDOWN"));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Reload'));
	}

	States
	{
	Ready:
		PLSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PLSG A 0 A_BIO_Deselect;
		Stop;
	Select:
		PLSG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PLSG A 3
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, ResolveState('Flash'), Random(0, 1));
			A_PresetRecoil('BIO_Recoil_Autogun');
		}
	Cooldown:
		PLSG B 20
		{
			A_SetFireTime(0, 1);
			A_ReFire();
		}
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		PLSG A 1 A_WeaponReady(WRF_NOFIRE);
		PLSG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		PLSG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		PLSG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		PLSG A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		PLSG A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		PLSG A 40 Offset(0, 32 + 30) A_SetReloadTime(6);
		PLSG A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		PLSG A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		PLSG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		PLSG A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		PLSG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		PLSG A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		PLSG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		PLSF A 4 Bright
		{
			A_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		PLSF B 4 Bright
		{
			A_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
	Spawn:
		PLAS A 0;
		PLAS A 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_PlasmaRifle : Ammo { mixin BIO_Magazine; }
