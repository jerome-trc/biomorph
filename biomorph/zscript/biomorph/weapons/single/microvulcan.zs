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
		BIO_Weapon.PickupMessages
			"$BIO_MICROVULCAN_PKUP",
			"$BIO_MICROVULCAN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINGUN;
		BIO_Weapon.Summary "$BIO_MICROVULCAN_SUMM";
	}

	override void SetDefaults()
	{
		FireTimeGroups.Push(
			StateTimeGroupFromRange(
				'Spool.Up', 'Spool.Fire',
				"$BIO_SPOOLUP",
				flags: BIO_STGF_AUXILIARY
			)
		);
		FireTimeGroups.Push(
			StateTimeGroupFrom(
				'Spool.Fire',
				"$BIO_PER2ROUNDS"
			)
		);
		FireTimeGroups.Push(
			StateTimeGroupFromRange(
				'Spool.Down', 'Spool.Down.Tail',
				"$BIO_SPOOLDOWN",
				flags: BIO_STGF_AUXILIARY
			)
		);

		Pipelines.Push(
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
		TNT1 A 0 A_BIO_CheckAmmo;
	Spool.Up:
		TNT1 A 0 A_StartSound("bio/weap/spoolup", CHAN_7);
		CHGG A 2 A_BIO_SetFireTime(0);
		CHGG B 2 A_BIO_SetFireTime(1);
		CHGG A 1 A_BIO_SetFireTime(2);
		CHGG B 1 A_BIO_SetFireTime(3);
		TNT1 A 0 A_StopSound(CHAN_7);
	Spool.Fire:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('Spool.Down');
			else
				return state(null);
		}
		CHGG A 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(0, 1);
			A_BIO_Microvulcan_Fire('Flash', 0);
		}
		CHGG A 2 Fast A_BIO_SetFireTime(1, 1);
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('Spool.Down');
			else
				return state(null);
		}
		CHGG B 1 Offset(0, 32 + 1)
		{
			A_BIO_SetFireTime(2, 1);
			A_BIO_Microvulcan_Fire('Flash', 1);
		}
		CHGG B 2 Fast A_BIO_SetFireTime(3, 1);
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'Spool.Down');
		Loop;
	Spool.Down:
		TNT1 A 0 A_StartSound("bio/weap/spooldown", CHAN_7);
		CHGG A 1 A_BIO_SetFireTime(0, 2);
		CHGG B 1 A_BIO_SetFireTime(1, 2);
		CHGG A 2 A_BIO_SetFireTime(2, 2);
		CHGG B 2 A_BIO_SetFireTime(3, 2);
		CHGG A 3 A_BIO_SetFireTime(4, 2);
		CHGG B 3 A_BIO_SetFireTime(5, 2);
	Spool.Down.Tail:
		TNT1 A 0 A_Refire;
		CHGG A 4;
		CHGG B 4;
		TNT1 A 0 A_Refire;
		CHGG A 5 A_WeaponReady(WRF_NOFIRE);
		CHGG B 5 A_WeaponReady(WRF_NOFIRE);
		TNT1 A 0 A_Refire;
		CHGG A 6 A_WeaponReady(WRF_NOFIRE);
		CHGG B 6 A_WeaponReady(WRF_NOFIRE);
		TNT1 A 0 A_StopSound(CHAN_7);
		Goto Ready;
	Flash:
		CHGF A 5 Bright
		{
			A_SetTics(
				invoker.FireTimeGroups[1].Times[0] +
				invoker.FireTimeGroups[1].Times[1] +
				1
			);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 1 Bright
		{
			A_SetTics(
				invoker.FireTimeGroups[1].Times[2] +
				invoker.FireTimeGroups[1].Times[3] +
				1
			);
			A_Light(2);
		}
		Goto LightDone;
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
		A_BIO_DepleteAmmo();
		A_BIO_Fire();
		Player.SetSafeFlash(invoker, ResolveState(flash), flashOffset);
		A_BIO_FireSound(CHAN_AUTO);
		A_BIO_Recoil('BIO_Recoil_Autogun');
	}
}
