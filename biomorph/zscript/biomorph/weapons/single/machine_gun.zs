class BIO_MachineGun : BIO_Weapon
{
	// Constants also referenced by the dual-wield counterpart
	const BASE_MAGSIZE = 100;
	const ETMF_DURATION = -3;
	const ETMF_COST = 5;

	Default
	{
		Tag "$BIO_MACHINEGUN_TAG";

		Inventory.Icon 'GPMGZ0';

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.GroundHitSound "bio/weap/groundhit/small/0";
		BIO_Weapon.EnergyToMatter ETMF_DURATION, ETMF_COST;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.MagazineSize BASE_MAGSIZE;
		BIO_Weapon.EnergyToMatter -3, 5;
		BIO_Weapon.OperatingMode 'BIO_OpMode_MachineGun_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_MACHINEGUN_PKUP",
			"$BIO_MACHINEGUN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINGUN;
		BIO_Weapon.Summary "$BIO_MACHINEGUN_SUMM";
	}

	override void SetDefaults()
	{
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));

		OpModes[0].Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(2.0, 1.0)
				.FireSound("bio/weap/machinegun/fire")
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
		GPMG Z 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Ready:
		GPMG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		GPMG A 0 A_BIO_Deselect;
		Stop;
	Select:
		GPMG A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_Op_Primary;
		Stop;
	AltFire:
		TNT1 A 0 A_BIO_Op_Secondary;
		Stop;
	Dryfire:
		GPMG A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		GPMG D 1 Bright A_Light(1);
		GPMG E 1 Bright A_Light(2);
		GPMG F 1 Bright A_Light(1);
		Goto LightDone;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		GPMG A 1 A_WeaponReady(WRF_NOFIRE);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		#### # 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		#### # 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		#### # 30 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
		#### # 1 Offset(0, 32 + 15)
		{
			A_BIO_SetReloadTime(7);
			A_BIO_LoadMag();
		}
		#### # 1 Fast Offset(0, 32 + 11) A_BIO_SetReloadTime(8);
		#### # 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(9);
		#### # 1 Fast Offset(0, 32 + 5) A_BIO_SetReloadTime(10);
		#### # 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(11);
		#### # 1 Fast Offset(0, 32 + 2) A_BIO_SetReloadTime(12);
		#### # 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(13);
		Goto Ready;
	}

	protected action void A_BIO_MachineGun_Fire()
	{
		A_BIO_Fire();
		A_GunFlash();
		A_BIO_FireSound(CHAN_AUTO);
		A_BIO_Recoil('BIO_Recoil_Autogun');
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_MachineGun_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const { return 'BIO_MachineGun'; }

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(weap.StateTimeGroupFrom('Rapid.Fire'));
	}

	final override statelabel EntryState() const
	{
		return 'Rapid.Fire';
	}
}

extend class BIO_MachineGun
{
	States
	{
	Rapid.Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		GPMG B 1 Bright Offset(0, 33)
		{
			A_BIO_SetFireTime(0);
			A_BIO_MachineGun_Fire();
		}
		GPMG C 1 Bright Offset(0, 34) A_BIO_SetFireTime(1);
		GPMG B 1 Bright Offset(0, 33) A_BIO_SetFireTime(2);
		GPMG A 1 Fast A_BIO_SetFireTime(3);
		TNT1 A 0 A_BIO_Op_CheckBurst('Rapid.Fire');
		TNT1 A 0 A_BIO_Op_PostFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	}
}
