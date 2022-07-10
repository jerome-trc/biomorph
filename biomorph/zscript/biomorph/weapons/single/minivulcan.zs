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
		BIO_Weapon.MagazineType 'Clip';
		BIO_Weapon.MagazineTypeETM 'BIO_MagETM_Minivulcan';
		BIO_Weapon.ModCostMultiplier 3;
		BIO_Weapon.PickupMessages
			"$BIO_MINIVULCAN_PKUP",
			"$BIO_MINIVULCAN_SCAV";
		BIO_Weapon.Summary "$BIO_MINIVULCAN_SUMM";
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
		TNT1 A 0
		{
			if (invoker.bSpooling)
				return ResolveState('SpoolCheck');
			else
				return state(null);
		}
		TNT1 A 0 A_BIO_CheckAmmo;
		MINV A 2
		{
			A_BIO_SetFireTime(0);
			A_Minivulcan_Fire();
		}
		MINV B 1 Fast A_BIO_SetFireTime(1);
		MINV C 2 A_BIO_SetFireTime(2);
		MINV D 1 Fast A_BIO_SetFireTime(3);
		TNT1 A 0 A_ReFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	SpoolCheck:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	SpoolUp:
		MINV A 3 A_BIO_SetFireTime(0, 1);
		MINV B 3 A_BIO_SetFireTime(1, 1);
		MINV C 3 A_BIO_SetFireTime(2, 1);
		MINV D 3 A_BIO_SetFireTime(3, 1);
		MINV A 2 A_BIO_SetFireTime(4, 1);
		MINV B 2 A_BIO_SetFireTime(5, 1);
		MINV C 2 A_BIO_SetFireTime(6, 1);
	SpoolUp.CP1:
		MINV D 2 A_BIO_SetFireTime(7, 1);
	SpoolUp.CP2:
		MINV A 1 A_BIO_SetFireTime(8, 1);
		MINV B 1 A_BIO_SetFireTime(9, 1);
		MINV C 1 A_BIO_SetFireTime(10, 1);
		MINV D 1 A_BIO_SetFireTime(11, 1);
	FireSpooled:
		TNT1 A 0
		{
			if (!invoker.SufficientAmmo())
				return ResolveState('SpoolDown');
			else
				return state(null);
		}
		MINV A 2
		{
			A_BIO_SetFireTime(0, 2);
			A_Minivulcan_Fire();
		}
		MINV B 1 Fast A_BIO_SetFireTime(1, 2);
		MINV C 2 A_BIO_SetFireTime(2, 2);
		MINV D 1 Fast A_BIO_SetFireTime(3, 2);
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'SpoolDown');
		Loop;
	SpoolDown:
		MINV A 1 A_BIO_SetFireTime(0, 3);
		MINV B 1 A_BIO_SetFireTime(1, 3);
		MINV C 1 A_BIO_SetFireTime(2, 3);
		MINV D 1 A_BIO_SetFireTime(3, 3);
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ATTACK, 'Fire.Spooled');
		MINV A 2 A_BIO_SetFireTime(4, 3);
		MINV B 2 A_BIO_SetFireTime(5, 3);
		MINV C 2 A_BIO_SetFireTime(6, 3);
		MINV D 2 A_BIO_SetFireTime(7, 3);
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ATTACK, 'SpoolUp.CP2');
		MINV A 3 A_BIO_SetFireTime(8, 3);
		MINV B 3 A_BIO_SetFireTime(9, 3);
		MINV C 3 A_BIO_SetFireTime(10, 3);
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ATTACK, 'SpoolUp.CP1');
		MINV D 3 A_BIO_SetFireTime(11, 3);
		Goto Ready;
	Flash:
		TNT1 A 0 A_Jump(128, 'Flash.Large');
	Flash.Small:
		MINV I 1 Bright
		{
			A_BIO_SetFireTime(0, invoker.bSpooling ? 2 : 0);
			A_Light(1);
		}
		MINV F 1 Bright
		{
			A_BIO_SetFireTime(1, invoker.bSpooling ? 2 : 0);
			A_Light(2);
		}
		TNT1 A 0 A_Jump(128, 'Flash.GH');
		Goto Flash.JH;
	Flash.Large:
		MINV E 1 Bright
		{
			A_BIO_SetFireTime(0, invoker.bSpooling ? 2 : 0);
			A_Light(1);
		}
		MINV F 1 Bright
		{
			A_BIO_SetFireTime(1, invoker.bSpooling ? 2 : 0);
			A_Light(2);
		}
		TNT1 A 0 A_Jump(128, 'Flash.GH');
		Goto Flash.JH;
	Flash.GH:
		MINV G 1 Bright A_BIO_SetFireTime(2, invoker.bSpooling ? 2 : 0);
		MINV H 1 Bright
		{
			A_BIO_SetFireTime(3, invoker.bSpooling ? 2 : 0);
			A_Light(1);
		}
		Goto LightDone;
	Flash.JH:
		MINV J 1 Bright A_BIO_SetFireTime(2, invoker.bSpooling ? 2 : 0);
		MINV H 1 Bright
		{
			A_BIO_SetFireTime(3, invoker.bSpooling ? 2 : 0);
			A_Light(1);
		}
		Goto LightDone;
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
				"$BIO_SPOOLED",
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

	protected action void A_Minivulcan_Fire()
	{
		A_BIO_Fire();
		A_GunFlash();
		A_BIO_FireSound(CHAN_AUTO);
		A_BIO_Recoil('BIO_Recoil_Autogun', scale: 1.5);
	}
}

class BIO_MagETM_Minivulcan : BIO_MagazineETM
{
	Default
	{
		BIO_MagazineETM.PowerupType 'BIO_ETM_Minivulcan';
	}
}

class BIO_ETM_Minivulcan : BIO_EnergyToMatterPowerup
{
	Default
	{
		Powerup.Duration -2;
		BIO_EnergyToMatterPowerup.CellCost 6;
	}
}
