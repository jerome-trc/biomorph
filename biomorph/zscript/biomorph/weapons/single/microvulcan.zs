class BIO_Microvulcan : BIO_Weapon
{
	Default
	{
		Tag "$BIO_MICROVULCAN_TAG";

		Inventory.Icon 'MGUNB0';

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.EnergyToMatter -3, 5;
		BIO_Weapon.OperatingMode 'BIO_OpMode_Microvulcan_BinarySpool';
		BIO_Weapon.PickupMessages
			"$BIO_MICROVULCAN_PKUP",
			"$BIO_MICROVULCAN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINGUN;
		BIO_Weapon.Summary "$BIO_MICROVULCAN_SUMM";
	}

	override void SetDefaults()
	{
		OpModes[0].Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(4.0, 2.0)
				.FireSound("bio/weap/microvulcan/fire")
				.Build()
		);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 2;
	}

	States
	{
	Spawn:
		MGUN B 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		CHGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		CHGG A 0 A_BIO_Select;
		Stop;
	Ready:
		CHGG A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_Op_Primary;
		Stop;
	AltFire:
		TNT1 A 0 A_BIO_Op_Secondary;
		Stop;
	Dryfire:
		CHGG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	}

	protected action void A_BIO_Microvulcan_Fire(statelabel flash, int flashOffset)
	{
		A_BIO_Fire();
		Player.SetSafeFlash(invoker, ResolveState(flash), flashOffset);
		A_BIO_FireSound(CHAN_AUTO);
		A_BIO_Recoil('BIO_Recoil_Autogun');
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_Microvulcan_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const { return 'BIO_Microvulcan'; }

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom('Rapid.Fire', "$BIO_PER2ROUNDS")
		);
	}

	final override statelabel EntryState() const
	{
		return 'Rapid.Fire';
	}
}

extend class BIO_Microvulcan
{
	States
	{
	Rapid.Fire:
		CHGG A 0 A_BIO_CheckAmmo;
		CHGG A 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(0);
			A_BIO_Microvulcan_Fire('Rapid.Flash', 0);
		}
		CHGG A 1 Offset(0, 32 + 2) Fast A_BIO_SetFireTime(1);
		CHGG A 1 Offset(0, 32 + 2) Fast A_BIO_SetFireTime(2);
		CHGG A 1 Offset(0, 32 + 1) Fast A_BIO_SetFireTime(3);
		CHGG B 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(4);
			A_BIO_Microvulcan_Fire('Rapid.Flash', 1);
		}
		CHGG B 1 Offset(0, 32 + 2) Fast A_BIO_SetFireTime(5);
		CHGG B 1 Offset(0, 32 + 2) Fast A_BIO_SetFireTime(6);
		CHGG B 1 Offset(0, 32 + 1) Fast A_BIO_SetFireTime(7);
		TNT1 A 0 A_BIO_Op_CheckBurst('Rapid.Fire');
		TNT1 A 0 A_BIO_Op_PostFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Rapid.Flash:
		CHGF A 5 Bright
		{
			let opm = invoker.CurOpMode();

			A_SetTics(
				opm.FireTimeGroups[0].Times[0] +
				opm.FireTimeGroups[0].Times[1] +
				opm.FireTimeGroups[0].Times[2] +
				opm.FireTimeGroups[0].Times[3] +
				1
			);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 5 Bright
		{
			let opm = invoker.CurOpMode();

			A_SetTics(
				opm.FireTimeGroups[0].Times[4] +
				opm.FireTimeGroups[0].Times[5] +
				opm.FireTimeGroups[0].Times[6] +
				opm.FireTimeGroups[0].Times[7] +
				1
			);
			A_Light(2);
		}
		Goto LightDone;
	}
}

class BIO_OpMode_Microvulcan_BinarySpool : BIO_OpMode_BinarySpool
{
	final override class<BIO_Weapon> WeaponType() const
	{ 
		return 'BIO_Microvulcan';
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
	}

	final override statelabel EntryState() const
	{
		return 'BSpool.Check';
	}
}

extend class BIO_Microvulcan
{
	States
	{
	BSpool.Check:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	BSpool.Up:
		TNT1 A 0 A_StartSound("bio/weap/spoolup", CHAN_7);
		CHGG A 2 A_BIO_SetFireTime(0);
		CHGG B 2 A_BIO_SetFireTime(1);
		CHGG A 1 A_BIO_SetFireTime(2);
		CHGG B 1 A_BIO_SetFireTime(3);
		TNT1 A 0 A_StopSound(CHAN_7);
	BSpool.Fire:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('BSpool.Down');
			else
				return state(null);
		}
		CHGG A 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(0, 1);
			A_BIO_Microvulcan_Fire('BSpool.Flash', 0);
		}
		CHGG A 2 Fast A_BIO_SetFireTime(1, 1);
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('BSpool.Down');
			else
				return state(null);
		}
		CHGG B 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(2, 1);
			A_BIO_Microvulcan_Fire('BSpool.Flash', 1);
		}
		CHGG B 2 Fast A_BIO_SetFireTime(3, 1);
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'BSpool.Down');
		Loop;
	BSpool.Down:
		TNT1 A 0 A_StartSound("bio/weap/spooldown", CHAN_7);
		CHGG A 1 A_BIO_SetFireTime(0, 2);
		CHGG B 1 A_BIO_SetFireTime(1, 2);
		CHGG A 2 A_BIO_SetFireTime(2, 2);
		CHGG B 2 A_BIO_SetFireTime(3, 2);
		CHGG A 3 A_BIO_SetFireTime(4, 2);
		CHGG B 3 A_BIO_SetFireTime(5, 2);
	BSpool.Down.Tail:
		TNT1 A 0 A_Refire;
		CHGG A 4;
		CHGG B 4;
		TNT1 A 0 A_Refire;
		CHGG A 5 A_WeaponReady(WRF_NOFIRE);
		CHGG B 5 A_WeaponReady(WRF_NOFIRE);
		TNT1 A 0 A_Refire;
		CHGG A 6 A_WeaponReady(WRF_NOFIRE);
		CHGG B 6 A_WeaponReady(WRF_NOFIRE);
		TNT1 A 0
		{
			A_StopSound(CHAN_7);
			return A_BIO_Op_PostFire();
		}
		Goto Ready;
	BSpool.Flash:
		CHGF A 5 Bright
		{
			let opm = invoker.CurOpMode();

			A_SetTics(
				opm.FireTimeGroups[1].Times[0] +
				opm.FireTimeGroups[1].Times[1] +
				1
			);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 1 Bright
		{
			let opm = invoker.CurOpMode();

			A_SetTics(
				opm.FireTimeGroups[1].Times[2] +
				opm.FireTimeGroups[1].Times[3] +
				1
			);
			A_Light(2);
		}
		Goto LightDone;
	}
}

class BIO_OpMode_Microvulcan_StagedSpool : BIO_OpMode_StagedSpool
{
	final override class<BIO_Weapon> WeaponType() const
	{ 
		return 'BIO_Microvulcan';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(
			weap.StateTimeGroupFromRange(
				'SSpool.Up', 'SSpool.Fire',
				"$BIO_SPOOLUP",
				flags: BIO_STGF_AUXILIARY
			)
		);
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom(
				'SSpool.Fire',
				"$BIO_PER2ROUNDS"
			)
		);
		FireTimeGroups.Push(
			weap.StateTimeGroupFromRange(
				'SSpool.Down', 'SSpool.Down.Tail',
				"$BIO_SPOOLDOWN",
				flags: BIO_STGF_AUXILIARY
			)
		);
	}

	final override statelabel EntryState() const
	{
		return 'SSpool.Check';
	}
}

extend class BIO_Microvulcan
{
	States
	{
	SSpool.Check:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	SSpool.Up:
		TNT1 A 0 A_StartSound("bio/weap/spoolup", CHAN_7);
		CHGG A 3
		{
			A_BIO_SetFireTime(0);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 0);
		}
		CHGG B 3
		{
			A_BIO_SetFireTime(1);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 1);
		}
		CHGG A 2
		{
			A_BIO_SetFireTime(2);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 2);
		}
		CHGG B 2
		{
			A_BIO_SetFireTime(3);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 3);
		}
		CHGG A 1
		{
			A_BIO_SetFireTime(4);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 4);
		}
		CHGG B 1 A_BIO_SetFireTime(5);
		TNT1 A 0 A_StopSound(CHAN_7);
	SSpool.Fire:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SSpool.Down');
			else
				return state(null);
		}
		CHGG A 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(0, 1);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 5);
		}
		CHGG A 1 Fast A_BIO_SetFireTime(1, 1);
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SSpool.Down');
			else
				return state(null);
		}
		CHGG B 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(2, 1);
			A_BIO_Microvulcan_Fire('SSpool.Flash', 6);
		}
		CHGG B 1 Fast A_BIO_SetFireTime(3, 1);
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'SSpool.Down');
		Loop;
	SSpool.Down:
		TNT1 A 0 A_StartSound("bio/weap/spooldown", CHAN_7);
		CHGG A 1 A_BIO_SetFireTime(0, 2);
		CHGG B 1 A_BIO_SetFireTime(1, 2);
		CHGG A 2 A_BIO_SetFireTime(2, 2);
		CHGG B 2 A_BIO_SetFireTime(3, 2);
		CHGG A 3 A_BIO_SetFireTime(4, 2);
		CHGG B 3 A_BIO_SetFireTime(5, 2);
	SSpool.Down.Tail:
		TNT1 A 0 A_Refire;
		CHGG A 4;
		CHGG B 4;
		TNT1 A 0 A_Refire;
		CHGG A 5;
		CHGG B 5;
		TNT1 A 0 A_Refire;
		CHGG A 6;
		CHGG B 6;
		TNT1 A 0
		{
			A_StopSound(CHAN_7);
			return A_BIO_Op_PostFire();
		}
		Goto Ready;
	SSpool.Flash:
		CHGF A 4 Bright
		{
			A_BIO_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 4 Bright
		{
			A_BIO_SetFireTime(1, modifier: 1);
			A_Light(2);
		}
		Goto LightDone;
		CHGF A 3 Bright
		{
			A_BIO_SetFireTime(2, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 3 Bright
		{
			A_BIO_SetFireTime(3, modifier: 1);
			A_Light(2);
		}
		Goto LightDone;
		CHGF A 2 Bright
		{
			A_BIO_SetFireTime(4, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		Goto LightDone;
		// Fire, state offset start: 5
		CHGF A 5 Bright
		{
			let opm = invoker.CurOpMode();

			A_SetTics(
				opm.FireTimeGroups[1].Times[0] +
				opm.FireTimeGroups[1].Times[1] +
				1
			);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 5 Bright
		{
			let opm = invoker.CurOpMode();

			A_SetTics(
				opm.FireTimeGroups[1].Times[2] +
				opm.FireTimeGroups[1].Times[3] +
				1
			);
			A_Light(2);
		}
		Goto LightDone;
	}
}
