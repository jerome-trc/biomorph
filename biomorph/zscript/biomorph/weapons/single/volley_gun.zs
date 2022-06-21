class BIO_VolleyGun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_VOLLEYGUN_TAG";

		Inventory.Icon 'VOLLZ0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1; // Per barrel
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.MagazineSize 4;
		BIO_Weapon.MagazineType 'BIO_Mag_VolleyGun';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_VolleyGun';
		BIO_Weapon.PickupMessages
			"$BIO_VOLLEYGUN_PKUP",
			"$BIO_VOLLEYGUN_SCAV";
	}

	States
	{
	Spawn:
		VOLL Z 0;
		VOLL Z 0 A_BIO_Spawn;
		Stop;
	Ready:
		VOLL A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		VOLL A 0 A_BIO_Deselect;
		Stop;
	Select:
		VOLL A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0
		{
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Quad');
			else
				return ResolveState('Fire.Double');
		}
	AltFire:
		TNT1 A 0
		{
			invoker.bAltFire = false;

			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Double');
			else
				return ResolveState('Fire.Quad');
		}
	Fire.Quad:
		TNT1 A 0 A_BIO_CheckAmmo(multi: 4, single: true);
		VOLL A 3;
		VOLL A 7 Bright
		{
			A_BIO_Fire(fireFactor: 4);
			A_BIO_Recoil('BIO_Recoil_DoubleShotgun', scale: 2.0);
			A_GunFlash('Flash.Quad');
			A_BIO_FireSound(CHAN_AUTO, attenuation: ATTN_NORM / 2.0);
			A_BIO_FireSound(CHAN_AUTO, attenuation: ATTN_NORM / 2.0);
		}
		TNT1 A 0 A_BIO_AutoReload(multi: 4, single: true);
		Goto Ready;
	Fire.Double:
		TNT1 A 0 A_BIO_CheckAmmo(multi: 2);
		VOLL A 3;
		VOLL A 7 Bright
		{
			A_BIO_Fire(fireFactor: 2);
			A_BIO_Recoil('BIO_Recoil_DoubleShotgun');
			A_GunFlash('Flash.Double');
			A_BIO_FireSound();
		}
		TNT1 A 0 A_BIO_AutoReload(multi: 2);
		Goto Ready;
	Dryfire:
		VOLL A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Reload:
		TNT1 A 0
		{
			if (!invoker.CanReload())
				return ResolveState('Ready');
			else if ((invoker.Magazine1.Amount >= invoker.Default.MagazineSize1 / 2) ||
					CountInv(invoker.AmmoType1) < invoker.Default.MagazineSize1 / 2)
				return ResolveState('Reload.Two');
			else
				return state(null);
		}
		Goto Reload.Four;
	Reload.Four:
		VOLL H 7 A_BIO_SetReloadTime(0);
		VOLL K 7 A_BIO_SetReloadTime(1);
		VOLL T 6
		{
			A_BIO_SetReloadTime(2);
			A_StartSound("weapons/sshoto", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG');
		}
		VOLL U 5 A_BIO_SetReloadTime(3);
		VOLL V 4 A_BIO_SetReloadTime(4);
		VOLL W 3 A_BIO_SetReloadTime(5);
		VOLL X 4
		{
			A_BIO_SetReloadTime(6);
			A_StartSound("weapons/sshotl", CHAN_AUTO); 
			A_BIO_LoadMag();
		}
		VOLL Y 5 A_BIO_SetReloadTime(7);
		VOLL K 6 A_BIO_SetReloadTime(8);
		VOLL H 7
		{
			A_BIO_SetReloadTime(9);
			A_StartSound("weapons/sshotc", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG', invert: true);
		}
		Goto Ready;
	Reload.Two:
		VOLL H 7 A_BIO_SetReloadTime(0, 1);
		VOLL K 7 A_BIO_SetReloadTime(1, 1);
		VOLL N 6
		{
			A_BIO_SetReloadTime(2, 1);
			A_StartSound("weapons/sshoto", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG');
		}
		VOLL O 5 A_BIO_SetReloadTime(3, 1);
		VOLL P 4 A_BIO_SetReloadTime(4, 1);
		VOLL Q 3
		{
			A_BIO_SetReloadTime(5, 1);
			A_StartSound("weapons/sshotl", CHAN_AUTO); 
			A_BIO_LoadMag();
		}
		VOLL R 4 A_BIO_SetReloadTime(6, 1);
		VOLL K 5 A_BIO_SetReloadTime(7, 1);
		VOLL H 6
		{
			A_BIO_SetReloadTime(8, 1);
			A_StartSound("weapons/sshotc", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG', invert: true);
		}
		Goto Ready;
	Flash.Quad:
		VOLL F 4 Bright A_Light(2);
		VOLL G 3 Bright A_Light(4);
		Goto LightDone;
	Flash.Double:
		VOLL B 4 Bright A_Light(1);
		VOLL C 3 Bright A_Light(2);
		Goto LightDone;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_Shotpellet', 7) // Per barrel
				.RandomDamage(10, 15)
				.Spread(12.0, 7.5)
				.FireSound("bio/weap/volleygun/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire.Quad'));

		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload.Four', "$BIO_ALL_4"));
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload.Two', "$BIO_2"));
	}
}

class BIO_Mag_VolleyGun : BIO_Magazine {}

class BIO_MagETM_VolleyGun : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_VolleyGun';
	}
}

class BIO_ETM_VolleyGun : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -1;
		BIO_EnergyToMatterPowerup.CellCost 20;
	}
}
