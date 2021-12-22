class BIO_BFG9000 : BIO_Weapon replaces BFG9000
{
	Default
	{
		+WEAPON.BFG
		+WEAPON.NOAUTOFIRE;

		Height 20;
		Tag "$TAG_BFG9000";

		Inventory.Icon 'BFUGA0';
		Inventory.PickupMessage "$BIO_BFG_PKUP90000";

		Weapon.AmmoGive 80;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 40;
		Weapon.MinSelectionAmmo1 40;
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 80;
		BIO_Weapon.MagazineType 'BIO_MAG_BFG9000';
		BIO_Weapon.PlayerVisual BIO_PVIS_BFG9K;
		BIO_Weapon.SwitchSpeeds 5, 5;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BFGPipeline()
			.FireSound("weapons/bfgf")
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
		BFGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		BFGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		BFGG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		BFGG A 20
		{
			A_SetFireTime(0);
			A_FireSound();
		}
		BFGG B 10
		{
			A_SetFireTime(1);
			A_GunFlash();
		}
		BFGG B 10
		{
			A_SetFireTime(2);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_BFG');
		}
		BFGG B 20
		{
			A_SetFireTime(3);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		BFGG A 1 A_WeaponReady(WRF_NOFIRE);
		BFGG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		BFGG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		BFGG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		BFGG A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		BFGG A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		// TODO: Reload sounds
		BFGG A 50 Offset(0, 32 + 20)
		{
			A_SetReloadTime(6);
			A_PresetRecoil('BIO_Recoil_HeavyReload');
		}
		BFGG A 1 Offset(0, 32 + 18)
		{
			A_SetReloadTime(7);
			A_PresetRecoil('BIO_Recoil_HeavyReload', invert: true);
			A_LoadMag();
		}
		BFGG A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		BFGG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		BFGG A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		BFGG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		BFGG A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		BFGG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		BFGF A 11 Bright
		{
			A_SetFireTime(1, modifier: 1);
			A_Light(1);
		}
		BFGF B 6 Bright
		{
			A_SetFireTime(2, modifier: -3);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		BFUG A 0;
		BFUG A 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_BFG9000 : Ammo { mixin BIO_Magazine; }
