class BIO_Coachgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_COACHGUN_TAG";

		Inventory.Icon 'SGN2A0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.MagazineType 'BIO_Mag_Coachgun';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_Coachgun';
		BIO_Weapon.MagazineSize 2;
		BIO_Weapon.PickupMessages
			"$BIO_COACHGUN_PKUP",
			"$BIO_COACHGUN_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_SSG;
	}

	States
	{
	Spawn:
		SGN2 A 0;
		SGN2 A 0 A_BIO_Spawn;
		Stop;
	Deselect:
		SHT2 A 0 A_BIO_Deselect;
		Stop;
	Select:
		SHT2 A 0 A_BIO_Select;
		Stop;
	Ready:
		SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
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
		SHT2 A 3 A_BIO_SetFireTime(0);
		SHT2 A 7 Bright
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire(spreadFactor: 0.5);
			A_BIO_Recoil('BIO_Recoil_Shotgun');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_BIO_FireSound(CHAN_AUTO);
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Fire.Double:
		TNT1 A 0 A_BIO_CheckAmmo;
		SHT2 A 3 A_BIO_SetFireTime(0);
		SHT2 A 7 Bright
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire(fireFactor: 2);
			A_BIO_Recoil('BIO_Recoil_DoubleShotgun');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_FireSound(CHAN_AUTO);
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		SHT2 A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		SHT2 I 4 Bright A_Light(1);
		SHT2 J 3 Bright A_Light(2);
		Goto LightDone;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		SHT2 B 7 A_BIO_SetReloadTime(0);
		SHT2 C 7 A_BIO_SetReloadTime(1);
		SHT2 D 7
		{
			A_BIO_SetReloadTime(2);
			A_StartSound("weapons/sshoto", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG');
		}
		SHT2 E 7 A_SetTics(3);
		SHT2 F 7
		{
			A_BIO_SetReloadTime(4);
			A_BIO_LoadMag();
			A_StartSound("weapons/sshotl", CHAN_AUTO); 
		}
		SHT2 G 6 A_SetTics(5);
		SHT2 H 6
		{
			A_BIO_SetReloadTime(6);
			A_StartSound("weapons/sshotc", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG', invert: true);
			A_ReFire();
		}
		SHT2 A 5
		{
			A_BIO_SetReloadTime(7);
			A_ReFire();
		}
		Goto Ready;
	}

	override void SetDefaults()
	{
		pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 7) // Per barrel
				.RandomDamage(10, 15)
				.Spread(12.0, 7.5)
				.FireSound("bio/weap/coachgun/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));
	}
}

class BIO_Mag_Coachgun : BIO_Magazine {}

class BIO_MagETM_Coachgun : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_Coachgun';
	}
}

class BIO_ETM_Coachgun : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -1;
		BIO_EnergyToMatterPowerup.CellCost 10;
	}
}
