class BIO_GammaProjector : BIO_Weapon
{
	Default
	{
		Tag "$BIO_GAMMAPROJECTOR_TAG";

		Inventory.Icon 'GAMMZ0';

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 30;
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.MagazineFlags BIO_MAGF_RECHARGING_1;
		BIO_Weapon.MagazineType 'BIO_RechargingMagazine';
		BIO_Weapon.MagazineSize 200;
		BIO_Weapon.ReloadRatio 2, 2; // Speeds up recharging
		BIO_Weapon.OperatingMode 'BIO_OpMode_GammaProjector_HoldRelease';
		BIO_Weapon.PickupMessages
			"$BIO_GAMMAPROJECTOR_PKUP",
			"$BIO_GAMMAPROJECTOR_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_BFG9000;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.BFGSpray(cone: 60.0)
				.X1D8Damage(13)
				.FireSound("weapons/bfgf")
				.AngleAndPitch(0.0, 32.0)
				.Build()
		);
	}

	States
	{
	Spawn:
		GAMM Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		GAMM A 0 A_BIO_Deselect;
		Stop;
	Select:
		GAMM A 0 A_BIO_Select;
		Stop;
	Ready:
		GAMM A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_GammaProjector_HoldRelease : BIO_OpMode_HoldRelease
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_GammaProjector';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(weap.StateTimeGroupFrom('HoldRel.Fire'));
	}

	final override statelabel FireState() const
	{
		return 'HoldRel.Hold';
	}
}

extend class BIO_GammaProjector
{
	States
	{
	HoldRel.Hold:
		GAMM B 1
		{
			A_StartSound("bio/weap/arccaster/ready", CHAN_AUTO);

			return A_JumpIf(
				!invoker.bAltFire && !(Player.Cmd.Buttons & BT_ATTACK) ||
				invoker.bAltFire && !(Player.Cmd.Buttons & BT_ALTATTACK),
				'HoldRel.Fire'
			);
		}
		Loop;
	HoldRel.Fire:
		GAMM C 10 Bright
		{
			A_BIO_SetFireTime(0);
			A_BIO_FireSound();
		}
		GAMM D 5 Bright
		{
			A_BIO_SetFireTime(1);
			A_GunFlash();
		}
		GAMM E 5 Bright
		{
			A_BIO_SetFireTime(2);
			A_BIO_Fire();
		}
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'HoldRel.Fire');
		TNT1 A 0 A_BIO_Op_PostFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	}
}
