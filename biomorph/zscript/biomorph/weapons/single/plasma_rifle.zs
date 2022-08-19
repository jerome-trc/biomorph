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
		BIO_Weapon.MagazineFlags BIO_MAGF_PLASMA_1;
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType 'BIO_RechargingMagazine';
		BIO_Weapon.OperatingMode 'BIO_OpMode_PlasmaRifle_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_PLASMARIFLE_PKUP",
			"$BIO_PLASMARIFLE_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_PLASRIFLE;
	}

	override void SetDefaults()
	{
		ReloadTimeGroups.Push(BIO_StateTimeGroup.RechargeTime(4));

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Projectile('BIO_PlasmaBall')
				.X1D8Damage(5)
				.Build()
		);
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
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
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
	}

	protected action void A_BIO_PlasmaRifle_Fire()
	{
		A_BIO_Fire();
		A_BIO_FireSound();
		Player.SetSafeFlash(invoker, ResolveState('Flash'), Random(0, 1));
		A_BIO_Recoil('BIO_Recoil_Autogun');
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_PlasmaRifle_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_PlasmaRifle';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom('Rapid.Fire', "$BIO_FIRE")
		);
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom('Rapid.Cooldown', "$BIO_COOLDOWN")
		);
	}

	final override statelabel FireState() const
	{
		return 'Rapid.Fire';
	}

	final override statelabel PostFireState() const
	{
		return 'Rapid.Cooldown';
	}
}

extend class BIO_PlasmaRifle
{
	States
	{
	Rapid.Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PLSG A 3
		{
			A_BIO_SetFireTime(0);
			A_BIO_PlasmaRifle_Fire();
		}
		TNT1 A 0 A_BIO_Op_PostFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Rapid.Cooldown:
		PLSG B 20
		{
			A_BIO_SetFireTime(0, 1);
			A_ReFire();
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	}
}

class BIO_OpMode_PlasmaRifle_HybridBurst : BIO_OpMode_HybridBurst
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_PlasmaRifle';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		BurstCount = 3;

		FireTimeGroups.Push(
			weap.StateTimeGroupFrom('HybridBurst.Fire', "$BIO_BURST")	
		);
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom('HybridBurst.Fire.FAuto', "$BIO_FULLAUTO")
		);

		FireTimeGroups.Push(
			weap.StateTimeGroupFrom(
				'HybridBurst.Cooldown',
				"$BIO_COOLDOWN",
				flags: BIO_STGF_AUXILIARY
			)
		);
	}

	final override statelabel FireState() const
	{
		return 'HybridBurst.Fire';
	}

	final override statelabel PostFireState() const
	{
		return 'HybridBurst.Cooldown';
	}
}

extend class BIO_PlasmaRifle
{
	States
	{
	HybridBurst.Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		PLSG A 1
		{
			A_BIO_SetFireTime(0);
			A_BIO_PlasmaRifle_Fire();
		}
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'HybridBurst.Fire');
		TNT1 A 0 A_BIO_AutoReload;
		Goto HybridBurst.Fire.Interlude;
	HybridBurst.Fire.Interlude:
		PLSG A 1;
		TNT1 A 0 A_JumpIf(
			invoker.OpMode.CheckInterlude(),
			'HybridBurst.Fire.FAuto.Start'
		);
		TNT1 A 0 A_ReFire('HybridBurst.Fire.Interlude');
		TNT1 A 0 { invoker.OpMode.ResetInterlude(); }
		PLSG A 7;
		PLSG AAAAAA 1 A_WeaponReady(WRF_NOBOB);
		// Post-fire gets omitted if only bursting
		Goto Ready;
	HybridBurst.Fire.FAuto.Start:
		PLSG A 1 { invoker.OpMode.ResetInterlude(); }
		Goto HybridBurst.Fire.FAuto;
	HybridBurst.Fire.FAuto:
		PLSG A 2 A_BIO_SetFireTime(0, 1);
		TNT1 A 0 A_BIO_CheckAmmo;
		PLSG A 4
		{
			A_BIO_SetFireTime(1, 1);
			A_BIO_PlasmaRifle_Fire();
		}
		Goto HybridBurst.Fire.FAuto.End;
	HybridBurst.Fire.FAuto.End:
		PLSG A 1 A_ReFire('HybridBurst.Fire.FAuto');
		PLSG A 1;
		TNT1 A 0 A_BIO_Op_PostFire;
		Goto Ready;
	HybridBurst.Cooldown:
		PLSG B 20
		{
			A_BIO_SetFireTime(0, 2);
			A_ReFire();
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	}
}
