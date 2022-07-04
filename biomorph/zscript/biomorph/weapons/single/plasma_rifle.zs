class BIO_PlasmaRifle : BIO_Weapon
{
	Default
	{
		Tag "$BIO_PLASMARIFLE_TAG";

		Inventory.Icon 'PLASA0';

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.MagazineType 'Cell';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_PlasmaRifle';
		BIO_Weapon.ModCostMultiplier 2;
		BIO_Weapon.PickupMessages
			"$BIO_PLASMARIFLE_PKUP",
			"$BIO_PLASMARIFLE_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_PLASRIFLE;
	}

	States
	{
	Spawn:
		PLAS A 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		PLSG A 0 A_BIO_Deselect;
		Stop;
	Select:
		PLSG A 0 A_BIO_Select;
		Stop;
	Ready:
		PLSG A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PLSG A 3
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_BIO_FireSound();
			Player.SetSafeFlash(invoker, ResolveState('Flash'), Random(0, 1));
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
	Cooldown:
		PLSG B 20
		{
			A_BIO_SetFireTime(0, 1);
			A_ReFire();
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Flash:
		PLSF A 4 Bright
		{
			A_BIO_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		PLSF B 4 Bright
		{
			A_BIO_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
	Zoom:
		TNT1 A 0 A_BIO_WeaponSpecial;
		Goto Ready;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Projectile('BIO_PlasmaBall')
				.X1D8Damage(5)
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFromRange('Fire', 'Cooldown', "$BIO_FIRE"));
		FireTimeGroups.Push(StateTimeGroupFrom('Cooldown', "$BIO_COOLDOWN"));
	}
}

class BIO_MagETM_PlasmaRifle : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_PlasmaRifle';
	}
}

class BIO_ETM_PlasmaRifle : BIO_EnergyToMatterPowerup {}
