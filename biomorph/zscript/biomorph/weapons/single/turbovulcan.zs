class BIO_Turbovulcan : BIO_Weapon
{
	Default
	{
		+BIO_WEAPON.SPOOLING

		Tag "$BIO_TURBOVULCAN_TAG";

		Inventory.Icon 'TRBOZ0';

		Weapon.AmmoGive 100;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 4;
		BIO_Weapon.MagazineType 'Clip';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_Turbovulcan';
		BIO_Weapon.ModCostMultiplier 3;
		BIO_Weapon.PickupMessages
			"$BIO_TURBOVULCAN_PKUP",
			"$BIO_TURBOVULCAN_SCAV";
		BIO_Weapon.Summary "$BIO_TURBOVULCAN_SUMM";
	}

	States
	{
	Ready:
		TRBO A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		TRBO A 0 A_BIO_Deselect;
		Stop;
	Select:
		TRBO A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	SpoolUp:
		TRBO B 1 A_BIO_SetFireTime(0);
		TRBO C 1 A_BIO_SetFireTime(1);
		TRBO D 1 A_BIO_SetFireTime(2);
		TRBO E 1 A_BIO_SetFireTime(3);
		TRBO F 1 A_BIO_SetFireTime(4);
		TRBO G 1 A_BIO_SetFireTime(5);
		TRBO H 1 A_BIO_SetFireTime(6);
	FireSpooled:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SpoolDown');
			else
				return state(null);
		}
		TRBO E 1 Bright
		{
			A_BIO_SetFireTime(0, 1);
			A_GunFlash('Flash.I');
			A_BIO_Fire();
			A_BIO_Recoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_BIO_FireSound(CHAN_AUTO);
		}
		TRBO F 1 Bright
		{
			A_BIO_SetFireTime(1, 1);
			A_GunFlash('Flash.J');
		}
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SpoolDown');
			else
				return state(null);
		}
		TRBO G 1 Bright
		{
			A_BIO_SetFireTime(2, 1);
			A_GunFlash('Flash.K');
			A_BIO_Fire();
			A_BIO_Recoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_BIO_FireSound(CHAN_AUTO);
		}
		TRBO H 1 Bright
		{
			A_BIO_SetFireTime(3, 1);
			A_GunFlash('Flash.L');
		}
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'SpoolDown');
		Loop;
	SpoolDown:
		TRBO E 1 A_BIO_SetFireTime(0, 2);
		TRBO F 1 A_BIO_SetFireTime(1, 2);
		TRBO G 1 A_BIO_SetFireTime(2, 2);
		TRBO H 1 A_BIO_SetFireTime(3, 2);
		TRBO A 1 A_BIO_SetFireTime(4, 2);
		TRBO B 1 A_BIO_SetFireTime(5, 2);
		TRBO C 1 A_BIO_SetFireTime(6, 2);
		TRBO D 1 A_BIO_SetFireTime(7, 2);
		Goto Ready;
	AltFire:
		TNT1 A 0 A_BIO_CheckAmmo;
		TRBO E 3 Bright
		{
			A_BIO_SetFireTime(0, 3);
			A_GunFlash('Flash.I');
			A_BIO_Fire(spreadFactor: 0.75);
			A_BIO_Recoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_BIO_FireSound(CHAN_AUTO);
		}
		TRBO F 3 Bright
		{
			A_BIO_SetFireTime(1, 3);
			A_GunFlash('Flash.J');
		}
		TRBO G 3 Bright
		{
			A_BIO_SetFireTime(2, 3);
			A_GunFlash('Flash.K');
			A_BIO_Fire(spreadFactor: 0.75);
			A_BIO_Recoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_BIO_FireSound(CHAN_AUTO);
		}
		TRBO H 3 Bright
		{
			A_BIO_SetFireTime(3, 3);
			A_GunFlash('Flash.L');
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Flash:
		TNT1 A 0;
		Goto LightDone;
	Flash.I:
		TRBO I 1 Bright
		{
			if (invoker.bAltFire)
				A_BIO_SetFireTime(0, 3, modifier: -2);
			else
				A_BIO_SetFireTime(0, 1);

			A_Light(1);
		}
		Goto LightDone;
	Flash.J:
		TRBO J 1 Bright
		{
			if (invoker.bAltFire)
				A_BIO_SetFireTime(1, 3, modifier: -2);
			else
				A_BIO_SetFireTime(1, 1);

			A_Light(2);
		}
		Goto LightDone;
	Flash.K:
		TRBO K 1 Bright
		{
			if (invoker.bAltFire)
				A_BIO_SetFireTime(2, 3, modifier: -2);
			else
				A_BIO_SetFireTime(2, 1);

			A_Light(1);
		}
		Goto LightDone;
	Flash.L:
		TRBO L 1 Bright
		{
			if (invoker.bAltFire)
				A_BIO_SetFireTime(3, 3, modifier: -2);
			else
				A_BIO_SetFireTime(3, 1);

			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		TRBO Z 0;
		TRBO Z 0 A_BIO_Spawn;
		Loop;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(4.0, 2.0)
				.FireSound("bio/weap/turbovulcan/fire")
				.Build()
		);

		FireTimeGroups.Push(
			StateTimeGroupFromRange(
				'SpoolUp', 'FireSpooled',
				"$BIO_SPOOLUP",
				designation: BIO_STGD_SPOOLUP
			)
		);
		FireTimeGroups.Push(
			StateTimeGroupFrom(
				'FireSpooled',
				"$BIO_PER2ROUNDS",
				designation: BIO_STGD_FIRESPOOLED
			)
		);
		FireTimeGroups.Push(
			StateTimeGroupFrom(
				'SpoolDown',
				"$BIO_SPOOLDOWN",
				designation: BIO_STGD_SPOOLDOWN
			)
		);

		FireTimeGroups.Push(StateTimeGroupFrom('AltFire', "$BIO_SLOW"));
	}
}

class BIO_MagETM_Turbovulcan : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_Turbovulcan';
	}
}

class BIO_ETM_Turbovulcan : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -2;
		BIO_EnergyToMatterPowerup.CellCost 6;
	}
}
