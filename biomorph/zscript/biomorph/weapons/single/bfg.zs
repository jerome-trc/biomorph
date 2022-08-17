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
		BIO_Weapon.MagazineFlags BIO_MAGF_RECHARGING_1;
		BIO_Weapon.MagazineType 'BIO_RechargingMagazine';
		BIO_Weapon.MagazineSize 200;
		BIO_Weapon.ReloadRatio 2, 2; // Speeds up recharging
		BIO_Weapon.OperatingMode 'BIO_OpMode_BFG_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_BFG_PKUP",
			"$BIO_BFG_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_BFG9000;
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
		BFGG A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
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
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_BFG_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_BFG';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(weap.StateTimeGroupFrom('Rapid.Fire'));
	}

	final override statelabel FireState() const
	{
		return 'Rapid.Fire';
	}
}

extend class BIO_BFG
{
	States
	{
	Rapid.Fire:
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
		BFGG B 20 A_BIO_SetFireTime(3);
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'Rapid.Fire');
		TNT1 A 0 A_BIO_Op_PostFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	}
}
