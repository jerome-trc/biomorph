class BIO_IncursionShotgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_INCURSIONSHOTGUN_TAG";

		Inventory.Icon 'INCUZ0';
		Inventory.PickupMessage "$BIO_INCURSIONSHOTGUN_PKUP";

		Weapon.AmmoGive 4;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG_CLSF;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineSize 4;
		BIO_Weapon.MagazineType 'BIO_MAG_IncursionShotgun';
		BIO_Weapon.PlayerVisual BIO_PVIS_SHOTGUN;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_ShotPellet', 9, 7, 17, 4.0, 2.0)
			.FireSound("bio/weap/incursion/fire")
			.AssociateFirstFireTime()
			.CustomReadout(StringTable.Localize(
				"$BIO_INCURSIONSHOTGUN_ALT"))
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
		INCU A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		INCU A 0 A_BIO_Deselect;
		Stop;
	Select:
		INCU A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		INCU B 3 Bright
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_FireSound();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		INCU C 4 Bright A_SetFireTime(1);
		INCU D 2 A_SetFireTime(2);
		INCU E 2 A_SetFireTime(3);
		INCU F 2
		{
			A_SetFireTime(4);
			A_ReFire();
		}
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	AltFire:
		TNT1 A 0 A_BIO_CheckAmmo(multi: 2, single: true);
		INCU B 3 Bright
		{
			A_SetFireTime(0);
			invoker.bAltFire = false;
			A_BIO_Fire(fireFactor: Min(invoker.Magazine1.Amount, 2),
				spreadFactor: 2.0);
			A_GunFlash();
			// TODO: Mix a fatter sound for this
			A_FireSound(CHAN_WEAPON);
			A_FireSound(CHAN_7);
			A_Pushback(2.5, 2.5);
			A_PresetRecoil('BIO_Recoil_VolleyGun');
		}
		INCU C 4 Bright A_SetFireTime(1);
		INCU D 2 A_SetFireTime(2);
		INCU E 2 A_SetFireTime(3);
		INCU F 2
		{
			A_SetFireTime(4);
			A_ReFire();
		}
		TNT1 A 0 A_AutoReload(multi: 2, single: true);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		INCU A 3 Offset(0, 32 + 3) A_SetReloadTime(0);
		INCU A 3 Offset(0, 32 + 6) A_SetReloadTime(1);
		INCU A 2 Offset(0, 32 + 9) A_SetReloadTime(2);
		INCU A 3 Offset(0, 32 + 6)
		{
			A_SetReloadTime(3);
			A_LoadMag();
			A_StartSound("bio/weap/incursion/reload", CHAN_7);
			A_PresetRecoil('BIO_Recoil_ShotgunPump');
		}
		INCU A 3 Offset(0, 32 + 3) A_SetReloadTime(4);
		Goto Ready;
	Flash:
		TNT1 A 3
		{
			A_SetFireTime(0);
			A_Light(1);
		}
		TNT1 A 4 
		{
			A_SetFireTime(1);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		INCU Z 0;
		INCU Z 0 A_BIO_Spawn;
		Loop;
	}
}

class BIO_MAG_IncursionShotgun : Ammo { mixin BIO_Magazine; }
