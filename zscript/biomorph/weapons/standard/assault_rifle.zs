class BIO_AssaultRifle : BIO_Weapon
{
	Default
	{
		Tag "$BIO_ASSAULTRIFLE_TAG";
		
		Inventory.Icon 'ASRFZ0';
		Inventory.PickupMessage "$BIO_ASSAULTRIFLE_PKUP";

		Weapon.AmmoGive 30;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 30;
		BIO_Weapon.MagazineType 'BIO_Mag_AssaultRifle';
		BIO_Weapon.PlayerVisual BIO_PVIS_RIFLE;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Bullet()
			.X1D3Damage(6)
			.Spread(1.0, 1.0)
			.FireSound("bio/weap/assaultrifle/fire")
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
		ASRF A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		ASRF A 0 A_BIO_Deselect;
		Stop;
	Select:
		ASRF A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		ASRF B 2 Bright
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_Autogun');
			A_FireSound();
		}
		ASRF C 2 Bright A_SetFireTime(1);
		ASRF A 1 A_SetFireTime(2);
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		ASRF A 1 A_WeaponReady(WRF_NOFIRE);
		ASRF A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		ASRF A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		ASRF A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		ASRF A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		ASRF A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		ASRF A 30 Offset(0, 32 + 30) A_SetReloadTime(6);
		ASRF A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		ASRF A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		ASRF A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		ASRF A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		ASRF A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		ASRF A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		ASRF A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		TNT1 A 5
		{
			A_SetFireTime(0);
			A_Light(1);
		}
		TNT1 A 5
		{
			A_SetFireTime(1);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		ASRF Z 0;
		ASRF Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_Mag_AssaultRifle : Ammo { mixin BIO_Magazine; }
