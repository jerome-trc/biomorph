class BIO_PrecisionRifle : BIO_Weapon
{
	Default
	{
		Tag "$BIO_PRECISIONRIFLE_TAG";

		Inventory.Icon 'PRECZ0';
		Inventory.PickupMessage "$BIO_PRECISIONRIFLE_PKUP";

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY - 0.05;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 20;
		BIO_Weapon.MagazineType 'BIO_MAG_PrecisionRifle';
		BIO_Weapon.PlayerVisual BIO_PVIS_RIFLE;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Bullet()
			.BasicDamage(60, 65)
			.Spread(0.8, 0.8)
			.FireSound("bio/weap/precrifle/fire")
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
		PREC A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PREC A 0 A_BIO_Deselect;
		Stop;
	Select:
		PREC A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PREC B 3
		{
			A_SetFireTime(0);
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_Shotgun');
			A_FireSound();
			A_BIO_Fire();
		}
		PREC C 2 A_SetFireTime(1);
		PREC A 15 Fast A_SetFireTime(2);
		TNT1 A 0 A_AutoReload;
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
		PREC Z 0;
		PREC Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_PrecisionRifle : Ammo { mixin BIO_Magazine; }
