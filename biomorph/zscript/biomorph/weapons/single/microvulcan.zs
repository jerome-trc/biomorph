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
		BIO_Weapon.MagazineType 'Clip';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_Microvulcan';
		BIO_Weapon.PickupMessages
			"$BIO_MICROVULCAN_PKUP",
			"$BIO_MICROVULCAN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINGUN;
		BIO_Weapon.Summary "$BIO_MICROVULCAN_SUMM";
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
		TNT1 A 0
		{
			if (invoker.bSpooling)
				return ResolveState('SpoolCheck');
			else
				return state(null);
		}
		CHGG A 0 A_BIO_CheckAmmo;
		CHGG A 4
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, ResolveState('Flash'), 0);
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		CHGG B 4
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, ResolveState('Flash'), 1);
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		CHGG B 0 A_ReFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		CHGG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	SpoolCheck:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	SpoolUp:
		CHGG A 3 A_BIO_SetFireTime(0, 1);
		CHGG B 3 A_BIO_SetFireTime(1, 1);
		CHGG A 2 A_BIO_SetFireTime(2, 1);
		CHGG B 2 A_BIO_SetFireTime(3, 1);
		CHGG A 1 A_BIO_SetFireTime(4, 1);
		CHGG B 1 A_BIO_SetFireTime(5, 1);
	FireSpooled:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SpoolDown');
			else
				return state(null);
		}
		CHGG A 4 Bright
		{
			A_BIO_SetFireTime(0, 2);
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, ResolveState('Flash'), 0);
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SpoolDown');
			else
				return state(null);
		}
		CHGG B 4 Bright
		{
			A_BIO_SetFireTime(1, 2);
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, ResolveState('Flash'), 1);
			A_BIO_FireSound(CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_Autogun');
		}
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'SpoolDown');
		Loop;
	SpoolDown:
		CHGG A 1 A_BIO_SetFireTime(0, 3);
		CHGG B 1 A_BIO_SetFireTime(1, 3);
		CHGG A 2 A_BIO_SetFireTime(2, 3);
		CHGG B 2 A_BIO_SetFireTime(3, 3);
		CHGG A 3 A_BIO_SetFireTime(4, 3);
		CHGG B 3 A_BIO_SetFireTime(5, 3);
		Goto Ready;
	Flash:
		CHGF A 5 Bright
		{
			A_BIO_SetFireTime(0, group: invoker.bSpooling ? 2 : 0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 5 Bright
		{
			A_BIO_SetFireTime(1, group: invoker.bSpooling ? 2 : 0, modifier: 1);
			A_Light(2);
		}
		Goto LightDone;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(4.0, 2.0)
				.FireSound("bio/weap/microvulcan/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));

		FireTimeGroups.Push(
			StateTimeGroupFromRange(
				'SpoolUp', 'FireSpooled',
				"$BIO_SPOOLUP",
				designation: BIO_STGD_SPOOLUP,
				flags: BIO_STGF_HIDDEN
			)
		);
		FireTimeGroups.Push(
			StateTimeGroupFrom(
				'FireSpooled',
				"$BIO_PER2ROUNDS",
				designation: BIO_STGD_FIRESPOOLED,
				flags: BIO_STGF_HIDDEN
			)
		);
		FireTimeGroups.Push(
			StateTimeGroupFrom(
				'SpoolDown',
				"$BIO_SPOOLDOWN",
				designation: BIO_STGD_SPOOLDOWN,
				flags: BIO_STGF_HIDDEN
			)
		);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 2;
	}
}

class BIO_MagETM_Microvulcan : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_Microvulcan';
	}
}

class BIO_ETM_Microvulcan : BIO_EnergyToMatterPowerup {}
