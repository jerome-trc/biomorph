class BIO_ProximityLauncher : BIO_Weapon
{
	Default
	{
		Tag "$BIO_PROXIMITYLAUNCHER_TAG";
		
		Inventory.Icon 'PRXLZ0';
		Inventory.PickupMessage "$BIO_PROXIMITYLAUNCHER_PKUP";
	
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.KickBack 200;
		Weapon.SelectionOrder SELORDER_RLAUNCHER_SPEC;
		Weapon.SlotNumber 5;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;

		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 3;
		BIO_Weapon.MagazineType 'BIO_Mag_ProximityLauncher';
		BIO_Weapon.PlayerVisual BIO_PVIS_GRENADELAUNCHER;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Projectile('BIO_ProxMineProj', 1)
			.SingleDamage(0)
			.Splash(176, 176, XF_HURTSOURCE)
			.FireSound("bio/weap/proxlauncher/fire")
			.CustomReadout(StringTable.Localize("$BIO_PROXLAUNCHER_DETONATE"))
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
		PRXL A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PRXL A 0 A_BIO_Deselect;
		Stop;
	Select:
		PRXL A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PRXL B 4 Bright
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_FireSound();
			A_PresetRecoil('BIO_Recoil_RocketLauncher');
		}
		PRXL C 5 A_SetFireTime(1);
		PRXL D 5 A_SetFireTime(2);
		PRXL E 4 A_SetFireTime(3);
		PRXL A 24 A_SetFireTime(4);
		PRXL A 1 A_ReFire;
		TNT1 A 0 A_AutoReload;
		Goto Ready;
	AltFire:
		TNT1 A 0
		{
			let iter = ThinkerIterator.Create('BIO_ProxMine');

			while (true)
			{
				let mine = BIO_ProxMine(iter.Next());
				if (mine == null) break;
				if (mine.Target != invoker.Owner) continue;
				mine.TouchOff = true;
			}
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		PRXL A 1 A_WeaponReady(WRF_NOFIRE);
		PRXL A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		PRXL A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		PRXL A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		PRXL A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		PRXL A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		PRXL A 45 Offset(0, 32 + 30) 
		{
			A_SetReloadTime(6);
			A_PresetRecoil('BIO_Recoil_HeavyReload');
		}
		PRXL A 1 Offset(0, 32 + 18)
		{
			A_SetReloadTime(7);
			A_LoadMag();
			A_PresetRecoil('BIO_Recoil_HeavyReload', invert: true);
		}
		PRXL A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		PRXL A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		PRXL A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		PRXL A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		PRXL A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		PRXL A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Spawn:
		PRXL Z 0;
		PRXL Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_Mag_ProximityLauncher : Ammo { mixin BIO_Magazine; }
