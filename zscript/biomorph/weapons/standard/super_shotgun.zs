class BIO_SuperShotgun : BIO_Weapon
{
	Default
	{
		Obituary "$OB_MPSSHOTGUN";
		Tag "$TAG_SUPERSHOTGUN";

		Inventory.Icon 'SGN2A0';
		Inventory.PickupMessage "$BIO_SUPERSHOTGUN_PKUP";

		Weapon.AmmoGive 8;
		Weapon.AmmoType1 'Shell';
		Weapon.AmmoUse1 1; // Per barrel
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Flags BIO_WF_SHOTGUN;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 2;
		BIO_Weapon.MagazineType 'BIO_MAG_SuperShotgun';
		BIO_Weapon.PlayerVisual BIO_PVIS_SSG;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_ShotPellet', 7, 5, 15, 12.0, 7.5)
			.FireSound("bio/weap/ssg/fire")
			.AssociateFirstFireTime()
			.AppendToFireFunctorString(" \c[Yellow]" ..
				StringTable.Localize("$BIO_PER_BARREL"))
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire.Single'));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Reload'));
	}

	States
	{
	Ready:
		SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		SHT2 A 0 A_BIO_Deselect;
		Stop;
	Select:
		SHT2 A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0
		{
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Double');
			else
				return ResolveState('Fire.Single');
		}
	AltFire:
		TNT1 A 0
		{
			invoker.bAltFire = false;
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Single');
			else
				return ResolveState('Fire.Double');
		}
	Fire.Single:
		TNT1 A 0 A_BIO_CheckAmmo;
		SHT2 A 3 A_SetFireTime(0);
		SHT2 A 7 Bright
		{
			A_SetFireTime(1);
			A_BIO_Fire(spreadFactor: 0.5);
			A_PresetRecoil('BIO_Recoil_Shotgun');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_FireSound(CHAN_AUTO);
		}
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Fire.Double:
		TNT1 A 0 A_BIO_CheckAmmo(multi: 2, single: true);
		SHT2 A 3 A_SetFireTime(0);
		SHT2 A 7 Bright
		{
			A_SetFireTime(1);
			A_BIO_Fire(fireFactor: 2);
			A_PresetRecoil('BIO_Recoil_SuperShotgun');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_FireSound(CHAN_AUTO);
			A_FireSound(CHAN_AUTO);
		}
		TNT1 A 0 A_AutoReload(multi: 2, single: true);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		SHT2 B 7 A_SetReloadTime(0);
		SHT2 C 7 A_SetReloadTime(1);
		SHT2 D 7
		{
			A_SetReloadTime(2);
			A_StartSound("weapons/sshoto", CHAN_AUTO);
			A_PresetRecoil('BIO_Recoil_ReloadSSG');
		}
		SHT2 E 7 A_SetTics(3);
		SHT2 F 7
		{
			A_SetReloadTime(4);
			A_LoadMag();
			A_StartSound("weapons/sshotl", CHAN_AUTO); 
		}
		SHT2 G 6 A_SetTics(5);
		SHT2 H 6
		{
			A_SetReloadTime(6);
			A_StartSound("weapons/sshotc", CHAN_AUTO);
			A_PresetRecoil('BIO_Recoil_ReloadSSG', invert: true);
			A_ReFire();
		}
		SHT2 A 5
		{
			A_SetReloadTime(7);
			A_ReFire();
		}
		Goto Ready;
	Flash:
		SHT2 I 4 Bright A_Light(1);
		SHT2 J 3 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		SGN2 A 0;
		SGN2 A 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_MAG_SuperShotgun : Ammo { mixin BIO_Magazine; }