class BIO_HeavyBattleRifle : BIO_Weapon
{
	Default
	{
		Tag "$BIO_HBR_TAG";

		Inventory.PickupMessage "$BIO_HBR_PKUP";

		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN_CLSF;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType 'BIO_MAG_HBR';
		BIO_Weapon.PlayerVisual BIO_PVIS_RIFLE;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Bullet('BIO_Bullet', 1)
			.BasicDamage(60, 80)
			.Spread(0.6, 0.6)
			.FireSound("bio/weap/hbr/fire")
			.CustomReadout(StringTable.Localize("$BIO_HBR_INFO"))
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
		HVBR A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		HVBR A 0 A_BIO_Deselect;
		Stop;
	Select:
		HVBR A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		HVBR B 1 Bright Offset(0, 33)
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_FireSound(CHAN_AUTO);
		}
		HVBR C 1 Bright Offset(0, 35) A_SetFireTime(1);
		HVBR B 1 Bright Offset(0, 33) A_SetFireTime(2);
		TNT1 A 0 A_BIO_CheckAmmo;
		HVBR B 1 Bright Offset(0, 33)
		{
			A_SetFireTime(3);
			A_BIO_Fire();
			A_GunFlash();
			A_FireSound(CHAN_AUTO);
			A_PresetRecoil('BIO_Recoil_SuperShotgun');
		}
		HVBR C 1 Bright Offset(0, 35) A_SetFireTime(4);
		HVBR B 1 Bright Offset(0, 33) A_SetFireTime(5);
		HVBR A 10 Fast A_SetFireTime(6);
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Flash:
		HVBR D 1 Bright A_Light(1);
		HVBR E 1 Bright A_Light(2);
		HVBR F 1 Bright A_Light(1);
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
		HVBR A 28 Offset(0, 32 + 30) A_SetReloadTime(6);
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
		HVBR Z 0;
		HVBR Z 0 A_BIO_Spawn;
		Loop;
	}
}

class BIO_MAG_HBR : Ammo { mixin BIO_Magazine; }
