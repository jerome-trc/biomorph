class BIO_Nailgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_NAILGUN_TAG";

		Inventory.Icon 'NLGNZ0';
		Inventory.PickupMessage "$BIO_NAILGUN_PKUP";

		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN - 20;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 100;
		BIO_Weapon.MagazineType 'BIO_MAG_Nailgun';
		BIO_Weapon.PlayerVisual BIO_PVIS_CHAINGUN;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicProjectilePipeline('BIO_Nail', 1, 7, 20, 3.6, 1.8)
			.Shrapnel(2, 4)
			.FireSound("bio/weap/nailgun/fire")
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
		NLGN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		NLGN A 0 A_BIO_Deselect;
		Stop;
	Select:
		NLGN A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		NLGN B 1 Bright Offset(0, 32 + 2)
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_PresetRecoil('BIO_Recoil_Autogun', scale: 1.2);
			A_FireSound(invoker.Magazine1.Amount % 2 == 0 ? CHAN_WEAPON : CHAN_6);
		}
		NLGN C 1 Offset(0, 32) A_SetFireTime(1);
		NLGN D 1 A_SetFireTime(2);
		NLGN E 1 A_SetFireTime(3);
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		NLGN A 1 A_WeaponReady(WRF_NOFIRE);
		NLGN A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		NLGN A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		NLGN A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		NLGN A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		NLGN A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		NLGN A 40 Offset(0, 32 + 30) A_SetReloadTime(6);
		NLGN A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		NLGN A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		NLGN A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		NLGN A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		NLGN A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		NLGN A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		NLGN A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		Goto LightDone;
	Spawn:
		NLGN Z 0;
		NLGN Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_Nailgun : Ammo { mixin BIO_Magazine; }
