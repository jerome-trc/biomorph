class BIO_IncursionShotgun : BIO_Weapon
{
	Default
	{
		Decal 'BulletChip';
		Tag "$BIO_WEAP_TAG_INCURSIONSHOTGUN";

		Inventory.Icon 'INCUX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_INCURSIONSHOTGUN";

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG_CLSF;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.Flags BIO_WF_SHOTGUN;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineSize 4;
		BIO_Weapon.MagazineType 'BIO_MAG_IncursionShotgun';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_ShotPellet', 9, 7, 17, 4.0, 2.0)
			.FireSound("bio/weap/incursion/fire")
			.CustomReadout(StringTable.Localize(
				"$BIO_WEAP_STAT_INCURSIONSHOTGUN_QUAD"))
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
		TNT1 A 0 A_AutoReload;
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
		Goto Ready;
	AltFire:
		TNT1 A 0 A_AutoReload;
		INCU B 3 Bright
		{
			A_SetFireTime(0);
			invoker.bAltFire = false;
			A_BIO_Fire(fireFactor: Min(invoker.Magazine1.Amount, 4),
				spreadFactor: 4.0);
			A_GunFlash();
			// TODO: Mix a fatter sound for quad-shot
			A_FireSound(CHAN_WEAPON);
			A_FireSound(CHAN_BODY);
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
		INCU X 0;
		INCU X 0 A_BIO_Spawn;
		Loop;
	}
}

class BIO_MAG_IncursionShotgun : Ammo { mixin BIO_Magazine; }
