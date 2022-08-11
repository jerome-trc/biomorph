class BIO_PumpShotgun : BIO_Weapon
{
	protected bool Overloaded;

	Default
	{
		Tag "$BIO_PUMPSHOTGUN_TAG";

		Inventory.Icon 'SHOTB0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_LOW;
		Weapon.UpSound "bio/weap/gunswap/0";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.PickupMessages
			"$BIO_PUMPSHOTGUN_PKUP",
			"$BIO_PUMPSHOTGUN_SCAV";
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType 'BIO_Mag_PumpShotgun';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_PumpShotgun';
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_SHOTGUN;
	}

	States
	{
	Spawn:
		PASG Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		PASG A 0 A_BIO_Deselect;
		Stop;
	Select:
		PASG A 0 A_BIO_Select;
		Stop;
	Ready:
		PASG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo(single: true);
		PASG A 3 Fast A_BIO_SetFireTime(0);
		PASG A 1 Offset(0 + 7, 32 + 7)
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound();
			A_BIO_Recoil('BIO_Recoil_Shotgun');
		}
		PASG A 1 Offset(0 + 5, 32 + 5) Fast A_BIO_SetFireTime(2);
		PASG A 1 Offset(0 + 2, 32 + 2) Fast A_BIO_SetFireTime(3);
		PASG A 1 Offset(0 + 1, 32 + 1) Fast A_BIO_SetFireTime(4);
		PASG A 1 Fast
		{
			A_BIO_SetFireTime(5);
			// This is the only way I've found to prevent
			// last X offset from being preserved
			A_WeaponOffset(0.0, 32.0);
		}
		TNT1 A 0 A_BIO_AutoReload(single: true);
		TNT1 A 0 A_ReFire;
		TNT1 A 0 A_JumpIf(
			!invoker.MagazineFull() && invoker.CanReload(),
			'Reload.Prep.Refires'
		);
		Goto Ready;
	Dryfire:
		PASG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		PASG Y 4 Bright
		{
			A_BIO_SetFireTime(1);
			A_Light(1);
		}
		TNT1 A 3 Bright
		{
			A_BIO_SetFireTime(2);
			A_Light(2);
		}
		Goto LightDone;
	Reload.Prep.Refires:
		PASG A 5 A_Refire;
		Goto Reload.Repeat;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		TNT1 A 0 { if (invoker.MagazineEmpty()) invoker.Overloaded = true; }
		PASG A 1 Fast A_BIO_SetReloadTime(0);
		PASG B 5 A_BIO_SetReloadTime(1);
	Reload.Repeat:
		PASG B 2 A_BIO_SetReloadTime(2);
		PASG C 4
		{
			A_BIO_SetReloadTime(3);
			A_StartSound("bio/weap/pumpshotgun/pumpback", CHAN_AUTO, volume: 0.7);
			A_BIO_LoadMag(1);
			A_BIO_Recoil('BIO_Recoil_ShotgunPump');
		}
		PASG B 2
		{
			A_BIO_SetReloadTime(4);
			A_StartSound("bio/weap/pumpshotgun/pumpforward", CHAN_AUTO, volume: 0.7);
		}
		PASG A 0 A_JumpIf(invoker.Overloaded, 2);
		PASG A 0 A_ReFire('Reload.End');
		PASG A 0
		{
			if (!invoker.CanReload())
				return state(null);
			else
				return ResolveState('Reload.Repeat');
		}
	Reload.End:
		TNT1 A 0 { invoker.Overloaded = false; }
		PASG B 5 A_BIO_SetReloadTime(5);
		PASG A 3 A_BIO_SetReloadTime(6);
		PASG A 0 A_ReFire;
		Goto Ready;
	Refire.Early:
		PASG A 2;
	Refire.Late:
		PASG B 2;
		PASG A 2;
		Goto Fire;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 7)
				.RandomDamage(10, 15)
				.Spread(3.0, 3.0)
				.FireSound("bio/weap/pumpshotgun/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));
	}
}

class BIO_Mag_PumpShotgun : BIO_Magazine {}

class BIO_MagETM_PumpShotgun : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_PumpShotgun';
	}
}

class BIO_ETM_PumpShotgun : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -1;
	}
}
