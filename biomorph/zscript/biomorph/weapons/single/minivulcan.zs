class BIO_Minivulcan : BIO_Weapon
{
	Default
	{
		Tag "$BIO_MINIVULCAN_TAG";

		Inventory.Icon 'MINVZ0';

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
		BIO_Weapon.OperatingMode 'BIO_OpMode_Minivulcan_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_MINIVULCAN_PKUP",
			"$BIO_MINIVULCAN_SCAV";
		BIO_Weapon.Summary "$BIO_MINIVULCAN_SUMM";
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(24, 28)
				.Spread(3.0, 1.5)
				.FireSound("bio/weap/minivulcan/fire")
				.Build()
		);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 3;
	}

	States
	{
	Spawn:
		MINV Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		MINV A 0 A_BIO_Deselect;
		Stop;
	Select:
		MINV A 0 A_BIO_Select;
		Stop;
	Ready:
		MINV A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_Op_Fire;
		Stop;
	}

	protected action void A_BIO_Minivulcan_Fire(statelabel flash)
	{
		A_BIO_Fire();
		A_GunFlash(flash);
		A_BIO_FireSound(CHAN_AUTO);
		A_BIO_Recoil('BIO_Recoil_Autogun', scale: 1.5);
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_Minivulcan_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_Minivulcan';
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

extend class BIO_Minivulcan
{
	States
	{
	Rapid.Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		MINV A 2 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(0);
			A_BIO_Minivulcan_Fire('Rapid.Flash');
		}
		MINV B 1 Offset(0, 32 + 3) Fast A_BIO_SetFireTime(1);
		MINV C 2 Offset(0, 32 + 2) A_BIO_SetFireTime(2);
		MINV D 1 Offset(0, 32 + 1) Fast A_BIO_SetFireTime(3);
		TNT1 A 0 A_JumpIf(!invoker.OpMode.CheckBurst(), 'Rapid.Fire');
		TNT1 A 0 A_BIO_Op_Postfire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Rapid.Flash:
		TNT1 A 0 A_Jump(128, 'Rapid.Flash.Large');
	Rapid.Flash.Small:
		MINV I 1 Bright
		{
			A_BIO_SetFireTime(0);
			A_Light(1);
		}
		MINV F 1 Bright
		{
			A_BIO_SetFireTime(1);
			A_Light(2);
		}
		TNT1 A 0 A_Jump(128, 'Rapid.Flash.GH');
		Goto Rapid.Flash.JH;
	Rapid.Flash.Large:
		MINV E 1 Bright
		{
			A_BIO_SetFireTime(0);
			A_Light(1);
		}
		MINV F 1 Bright
		{
			A_BIO_SetFireTime(1);
			A_Light(2);
		}
		TNT1 A 0 A_Jump(128, 'Rapid.Flash.GH');
		Goto Rapid.Flash.JH;
	Rapid.Flash.GH:
		MINV G 1 Bright A_BIO_SetFireTime(2);
		MINV H 1 Bright
		{
			A_BIO_SetFireTime(3);
			A_Light(1);
		}
		Goto LightDone;
	Rapid.Flash.JH:
		MINV J 1 Bright A_BIO_SetFireTime(2);
		MINV H 1 Bright
		{
			A_BIO_SetFireTime(3);
			A_Light(1);
		}
		Goto LightDone;
	}
}

class BIO_OpMode_Minivulcan_BinarySpool : BIO_OpMode_BinarySpool
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_Minivulcan';
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
				flags: BIO_STGF_AUXILIARY
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

	final override statelabel FireState() const
	{
		return 'BSpool.Check';
	}
}

extend class BIO_Minivulcan
{
	States
	{
	BSpool.Check:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	BSpool.Up:
		TNT1 A 0 A_StartSound("bio/weap/spoolup", CHAN_7);
		MINV A 3 A_BIO_SetFireTime(0);
		MINV B 3 A_BIO_SetFireTime(1);
		MINV C 3 A_BIO_SetFireTime(2);
		MINV D 3 A_BIO_SetFireTime(3);
		MINV A 2 A_BIO_SetFireTime(4);
		MINV B 2 A_BIO_SetFireTime(5);
		MINV C 2 A_BIO_SetFireTime(6);
	BSpool.Up.CP1:
		MINV D 2 A_BIO_SetFireTime(7);
	BSpool.Up.CP2:
		MINV A 1 A_BIO_SetFireTime(8);
		MINV B 1 A_BIO_SetFireTime(9);
		MINV C 1 A_BIO_SetFireTime(10);
		MINV D 1 A_BIO_SetFireTime(11);
	BSpool.Fire:
		TNT1 A 0
		{
			A_StopSound(CHAN_7);

			if (!invoker.SufficientAmmo())
				return ResolveState('BSpool.Down');
			else
				return state(null);
		}
		MINV A 1
		{
			A_BIO_SetFireTime(0, 1);
			A_BIO_Minivulcan_Fire('BSpool.Flash');
		}
		MINV B 1 Fast A_BIO_SetFireTime(1, 1);
		MINV C 1 A_BIO_SetFireTime(2, 1);
		MINV D 1 Fast A_BIO_SetFireTime(3, 1);
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'BSpool.Down');
		Loop;
	BSpool.Down:
		TNT1 A 0 A_StartSound("bio/weap/spooldown", CHAN_7);
		MINV A 1 A_BIO_SetFireTime(0, 2);
		MINV B 1 A_BIO_SetFireTime(1, 2);
		MINV C 1 A_BIO_SetFireTime(2, 2);
		MINV D 1 A_BIO_SetFireTime(3, 2);
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ATTACK, 'Fire.Spooled');
		MINV A 2 A_BIO_SetFireTime(4, 2);
		MINV B 2 A_BIO_SetFireTime(5, 2);
		MINV C 2 A_BIO_SetFireTime(6, 2);
		MINV D 2 A_BIO_SetFireTime(7, 2);
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ATTACK, 'BSpool.Up.CP2');
		MINV A 3 A_BIO_SetFireTime(8, 2);
		MINV B 3 A_BIO_SetFireTime(9, 2);
		MINV C 3 A_BIO_SetFireTime(10, 2);
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ATTACK, 'BSpool.Up.CP1');
		MINV D 3 A_BIO_SetFireTime(11, 2);
	BSpool.Down.Tail:
		TNT1 A 0 A_Refire;
		MINV A 4;
		MINV B 4;
		MINV C 4;
		TNT1 A 0 A_Refire;
		MINV A 5;
		MINV B 5;
		MINV C 5;
		TNT1 A 0 A_Refire;
		MINV A 6;
		MINV B 6;
		MINV C 6;
		TNT1 A 0 A_StopSound(CHAN_7);
		Goto Ready;
	BSpool.Flash:
		TNT1 A 0 A_Jump(128, 'BSpool.Flash.Large');
	BSpool.Flash.Small:
		MINV I 1 Bright
		{
			A_BIO_SetFireTime(0, 1);
			A_Light(1);
		}
		MINV F 1 Bright
		{
			A_BIO_SetFireTime(1, 1);
			A_Light(2);
		}
		TNT1 A 0 A_Jump(128, 'BSpool.Flash.GH');
		Goto BSpool.Flash.JH;
	BSpool.Flash.Large:
		MINV E 1 Bright
		{
			A_BIO_SetFireTime(0, 1);
			A_Light(1);
		}
		MINV F 1 Bright
		{
			A_BIO_SetFireTime(1, 1);
			A_Light(2);
		}
		TNT1 A 0 A_Jump(128, 'BSpool.Flash.GH');
		Goto BSpool.Flash.JH;
	BSpool.Flash.GH:
		MINV G 1 Bright A_BIO_SetFireTime(2, 1);
		MINV H 1 Bright
		{
			A_BIO_SetFireTime(3, 1);
			A_Light(1);
		}
		Goto LightDone;
	BSpool.Flash.JH:
		MINV J 1 Bright A_BIO_SetFireTime(2, 1);
		MINV H 1 Bright
		{
			A_BIO_SetFireTime(3, 1);
			A_Light(1);
		}
		Goto LightDone;
	}
}
