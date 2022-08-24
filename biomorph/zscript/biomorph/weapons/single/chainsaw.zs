class BIO_Chainsaw : BIO_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_CHAINSAW_TAG";

		Inventory.Icon 'CSAWA0';

		Weapon.Kickback 0;
		Weapon.ReadySound "weapons/sawidle";
		Weapon.SelectionOrder SELORDER_CHAINSAW;
		Weapon.SlotNumber 1;
		Weapon.UpSound "weapons/sawup";

		BIO_Weapon.GraphQuality 10;
		BIO_Weapon.OperatingMode 'BIO_OpMode_Chainsaw_Rapid';
		BIO_Weapon.PickupMessages
			"$BIO_CHAINSAW_PKUP",
			"";
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINSAW;
	}

	final override void SetDefaults()
	{
		OpModes[0].Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Saw(range: SAWRANGE * 1.5)
				.RandomDamage(2, 20)
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
		CSAW A 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Ready:
		TNT1 A 0 A_BIO_Recoil('BIO_Recoil_ChainsawIdle');
		SAWG CD 4 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Deselect:
		SAWG C 0 A_BIO_Deselect;
		Stop;
	Select:
		SAWG C 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_Op_Primary;
		Stop;
	AltFire:
		TNT1 A 0 A_BIO_Op_Secondary;
		Stop;
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_Chainsaw_Rapid : BIO_OpMode_Rapid
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_Chainsaw';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(
			weap.StateTimeGroupFrom('Rapid.Fire', flags: BIO_STGF_MELEE)
		);
	}

	final override statelabel EntryState() const
	{
		return 'Rapid.Fire';
	}
}

extend class BIO_Chainsaw
{
	States
	{
	Rapid.Fire:
		SAWG A 2 A_BIO_Fire;
		SAWG B 2 A_BIO_Fire;
		SAWG B 0 A_ReFire;
		TNT1 A 0 A_BIO_Op_PostFire;
		Goto Ready;
	}
}
