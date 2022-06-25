class BIO_BFG : BIO_Weapon
{
	Default
	{
		+WEAPON.BFG
		+WEAPON.NOAUTOFIRE

		Tag "$BIO_BFG_TAG";

		Inventory.Icon 'BFUGA0';

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 40;
		Weapon.MinSelectionAmmo1 40;
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.MagazineType 'Cell';
		BIO_Weapon.ModCostMultiplier 2;
		BIO_Weapon.PickupMessages
			"$BIO_BFG_PKUP",
			"$BIO_BFG_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_BFG9000;
	}

	States
	{
	Spawn:
		BFUG A 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		BFGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		BFGG A 0 A_BIO_Select;
		Stop;
	Ready:
		BFGG A 1 A_WeaponReady;
		Loop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		BFGG A 20
		{
			A_BIO_SetFireTime(0);
			A_BIO_FireSound();
		}
		BFGG B 10
		{
			A_BIO_SetFireTime(1);
			A_GunFlash();
		}
		BFGG B 10
		{
			A_BIO_SetFireTime(2);
			A_BIO_Fire();
			A_BIO_Recoil('BIO_Recoil_BFG');
		}
		BFGG B 20
		{
			A_BIO_SetFireTime(3);
			A_ReFire();
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Flash:
		BFGF A 11 Bright
		{
			A_BIO_SetFireTime(1, modifier: 1);
			A_Light(1);
		}
		BFGF B 6 Bright
		{
			A_BIO_SetFireTime(2, modifier: -3);
			A_Light(2);
		}
		Goto LightDone;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Projectile('BIO_BFGBall')
				.AddBFGSpray()
				.X1D8Damage(100)
				.FireSound("weapons/bfgf")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
	}
}
