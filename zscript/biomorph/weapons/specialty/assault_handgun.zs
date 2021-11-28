class BIO_AssaultHandgun : BIO_Weapon
{
	Default
	{
		Decal 'BulletChip';
		Obituary "$OB_MPPISTOL";
		Tag "$BIO_WEAP_TAG_ASSAULTHANDGUN";

		Inventory.Icon 'ASHGX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_ASSAULTHANDGUN";

		Weapon.AmmoGive 18;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PISTOL_SPEC;
		Weapon.SlotNumber 2;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;
		Weapon.UpSound "bio/weap/gunswap_0";

		BIO_Weapon.Flags BIO_WF_PISTOL | BIO_WF_ONEHANDED;
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 18;
		BIO_Weapon.MagazineType 'BIO_MAG_AssaultHandgun';
		BIO_Weapon.SwitchSpeeds 9, 9;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create(GetClass())
			.BasicProjectilePipeline('BIO_Bullet', 1, 6, 16, 3.6, 1.4)
			.FireSound("bio/weap/assaulthandgun/fire")
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(BIO_StateTimeGroup.FromState(ResolveState('Fire'), "$BIO_BURST"));
		groups.Push(BIO_StateTimeGroup.FromState(ResolveState('AltFire'), "$BIO_SEMI_AUTO"));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(BIO_StateTimeGroup.FromState(ResolveState('Reload')));
	}

	States
	{
	Ready:
		ASHG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		ASHG A 0 A_BIO_Deselect;
		Stop;
	Select:
		ASHG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		ASHG B 2 Fast A_SetFireTime(0);
		ASHG D 1 Bright
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Autogun');
			A_GunFlash();
			A_StartSound("bio/weap/assaulthandgun/fire", CHAN_WEAPON);
		}
		ASHG C 1 Fast A_SetFireTime(2);
		ASHG B 1 Fast A_SetFireTime(3);
		TNT1 A 0 A_AutoReload;
		ASHG E 1 Bright
		{
			A_SetFireTime(4);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Autogun');
			A_GunFlash();
			A_StartSound("bio/weap/assaulthandgun/fire", CHAN_WEAPON);
		}
		ASHG C 2 Fast A_SetFireTime(5);
		ASHG C 1 Fast A_SetFireTime(6);
		TNT1 A 0 A_AutoReload;
		ASHG D 1 Bright
		{
			A_SetFireTime(7);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Autogun');
			A_GunFlash();
			A_StartSound("bio/weap/assaulthandgun/fire", CHAN_WEAPON);
		}
		ASHG C 1 Fast A_SetFireTime(8);
		ASHG B 1 Fast A_SetFireTime(9);
		ASHG B 0 A_ReFire;
		Goto Ready;
	AltFire:
		ASHG B 3 Fast A_SetFireTime(0, 1);
		ASHG D 3 Bright
		{
			A_SetFireTime(1, 1);
			invoker.bAltFire = false;
			A_BIO_Fire(spreadFactor: 0.5);
			A_PresetRecoil('BIO_Recoil_Handgun');
			A_GunFlash();
		}
		ASHG C 3 Fast A_SetFireTime(2, 1);
		ASHG B 3 Fast A_SetFireTime(3, 1);
		ASHG A 1 Fast
		{
			A_SetFireTime(4, 1);
			A_ReFire();
		}
		Goto Ready;
	Reload:
		// TODO: Reload sounds
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		ASHG A 1 A_WeaponReady(WRF_NOFIRE);
		ASHG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		ASHG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		ASHG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		ASHG A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		ASHG A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		ASHG A 30 Offset(0, 32 + 30) A_SetReloadTime(6);
		ASHG A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		ASHG A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		ASHG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		ASHG A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		ASHG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		ASHG A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		ASHG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light(1);
		TNT1 A 1 Bright A_Light(0);
		Stop;
	Spawn:
		ASHG X 0;
		ASHG X 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_AssaultHandgun : Ammo { mixin BIO_Magazine; }
