// Common member definitions and default assignments.
class BIO_Turbovulcan : BIO_Weapon
{
	Default
	{
		Tag "$BIO_TURBOVULCAN_TAG";

		Inventory.Icon 'TRBOZ0';

		Weapon.AmmoGive 100;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.EnergyToMatter -2, 6;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.OperatingMode 'BIO_OpMode_Turbovulcan_BinarySpooled';
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
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
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
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 3;
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_Turbovulcan_BinarySpooled : BIO_OpMode_BinarySpool
{
	final override class<BIO_Weapon> WeaponType() const 
	{
		return 'BIO_Turbovulcan';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(
			weap.StateTimeGroupFromRange(
				'BSpool.Up', 'BSpool.Fire',
				"$BIO_SPOOLUP",
				flags: BIO_STGF_AUXILIARY
			)
		);
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom(
				'BSpool.Fire',
				"$BIO_PER2ROUNDS"
			)
		);
		FireTimeGroups.Push(
			weap.StateTimeGroupFromRange(
				'BSpool.Down', 'BSpool.Down.Tail',
				"$BIO_SPOOLDOWN",
				flags: BIO_STGF_AUXILIARY
			)
		);

		FireTimeGroups.Push(weap.StateTimeGroupFrom('AltFire', "$BIO_SLOW"));
	}

	final override statelabel FireState() const
	{
		return 'BSpool.Check';
	}
}

extend class BIO_Turbovulcan
{
	States
	{
	BSpool.Check:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	BSpool.Up:
		TNT1 A 0 A_StartSound("bio/weap/spoolup", CHAN_7);
		TRBO B 1 A_BIO_SetFireTime(0);
		TRBO C 1 A_BIO_SetFireTime(1);
		TRBO D 1 A_BIO_SetFireTime(2);
		TRBO E 1 A_BIO_SetFireTime(3);
		TRBO F 1 A_BIO_SetFireTime(4);
		TRBO G 1 A_BIO_SetFireTime(5);
		TRBO H 1 A_BIO_SetFireTime(6);
		TNT1 A 0 A_StopSound(CHAN_7);
	BSpool.Fire:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('BSpool.Down');
			else
				return state(null);
		}
		TRBO E 1 Offset(0, 32 + 2) Bright
		{
			A_BIO_SetFireTime(0, 1);
			A_GunFlash('Flash.I');
			A_BIO_Fire();
			A_BIO_Recoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_BIO_FireSound(CHAN_AUTO);
		}
		TRBO F 1 Offset(0, 32 + 1) Bright
		{
			A_BIO_SetFireTime(1, 1);
			A_GunFlash('Flash.J');
		}
		TNT1 A 0
		{
			A_WeaponOffset(0.0, 32.0);

			if (!invoker.SufficientAmmo())
				return ResolveState('BSpool.Down');
			else
				return state(null);
		}
		TRBO G 1 Offset(0, 32 + 2) Bright
		{
			A_BIO_SetFireTime(2, 1);
			A_GunFlash('Flash.K');
			A_BIO_Fire();
			A_BIO_Recoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_BIO_FireSound(CHAN_AUTO);
		}
		TRBO H 1 Offset(0, 32 + 1) Bright
		{
			A_BIO_SetFireTime(3, 1);
			A_GunFlash('Flash.L');
		}
		TNT1 A 0
		{
			A_WeaponOffset(0.0, 32.0);
			return A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'BSpool.Down');
		}
		Loop;
	BSpool.Down:
		TNT1 A 0 A_StartSound("bio/weap/spooldown", CHAN_7);
		TRBO E 1 A_BIO_SetFireTime(0, 2);
		TRBO F 1 A_BIO_SetFireTime(1, 2);
		TRBO G 1 A_BIO_SetFireTime(2, 2);
		TRBO H 1 A_BIO_SetFireTime(3, 2);
		TRBO A 1 A_BIO_SetFireTime(4, 2);
		TRBO B 1 A_BIO_SetFireTime(5, 2);
		TRBO C 1 A_BIO_SetFireTime(6, 2);
		TRBO D 1 A_BIO_SetFireTime(7, 2);
	BSpool.Down.Tail:
		TNT1 A 0 A_Refire;
		TRBO A 2;
		TRBO B 2;
		TRBO C 2;
		TRBO D 2;
		TNT1 A 0 A_Refire;
		TRBO A 3;
		TRBO B 3;
		TRBO C 3;
		TRBO D 3;
		TNT1 A 0 A_Refire;
		TRBO A 4;
		TRBO B 4;
		TRBO C 4;
		TRBO D 4;
		TNT1 A 0 A_Refire;
		TRBO A 5;
		TRBO B 5;
		TRBO C 5;
		TRBO D 5;
		TNT1 A 0 A_Refire;
		TRBO A 6;
		TRBO B 6;
		TRBO C 6;
		TRBO D 6;
		TNT1 A 0 A_StopSound(CHAN_7);
		Goto Ready;
	}
}
