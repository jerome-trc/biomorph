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
		BIO_Weapon.PickupMessages
			"$BIO_CHAINSAW_PKUP",
			"";
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINSAW;
	}

	final override void SetDefaults()
	{
		FireTimeGroups.Push(StateTimeGroupFrom('Fire', flags: BIO_STGF_MELEE));

		Pipelines.Push(
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
		SAWG A 2
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
		}
		SAWG B 2
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
		}
		SAWG B 0 A_ReFire;
		Goto Ready;
	}
}
