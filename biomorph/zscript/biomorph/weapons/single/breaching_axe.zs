class BIO_BreachingAxe : BIO_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_BREACHINGAXE_TAG";

		Inventory.Icon 'BRAXZ0';
		Inventory.PickupMessage "$BIO_BREACHINGAXE_PKUP";

		Weapon.SelectionOrder SELORDER_CHAINSAW;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority SLOTPRIO_HIGH;

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.PickupMessages
			"$BIO_BREACHINGAXE_PKUP",
			"";
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINSAW;
	}

	States
	{
	Ready:
		BRAX A 1 A_WeaponReady;
		Loop;
	Deselect:
		BRAX A 0 A_BIO_Deselect;
		Stop;
	Select:
		BRAX A 0 A_BIO_Select;
		Stop;
	Fire:
		BRAX A 2 A_BIO_SetFireTime(0);
		BRAX B 2 A_BIO_SetFireTime(1);
		BRAX C 2 A_BIO_SetFireTime(2);
		TNT1 A 5 A_BIO_SetFireTime(3);
		Goto Hold;
	Hold:
		TNT1 A 1;
		TNT1 A 0 A_ReFire;
		Goto Swing;
	Swing:
		BRAX I 2 A_BIO_SetFireTime(0, 1);
		BRAX H 2 A_BIO_SetFireTime(1, 1);
		BRAX G 2 A_BIO_SetFireTime(2, 1);
		BRAX F 2 A_BIO_SetFireTime(3, 1);
		BRAX E 2
		{
			A_BIO_SetFireTime(4, 1);
			A_BIO_Fire();
			A_BIO_FireSound();

			if (BIO_quake)
				A_Quake(1, 5, 0, 5);
		}
		TNT1 A 4 A_BIO_SetFireTime(5, 1);
		BRAX E 4 A_BIO_SetFireTime(6, 1);
		BRAX D 4 Offset(0 + 20, 32 + 15) A_BIO_SetFireTime(7, 1);
		Goto Ready;
	Spawn:
		BRAX Z 0;
		BRAX Z 0 A_BIO_Spawn;
		Stop;
	}

	override void SetDefaults()
	{
		let fireFunc = new('BIO_FireFunc_Axe');
		fireFunc.MissSound = "bio/weap/whoosh";
		fireFunc.HitSound = "*fist";
		fireFunc.Range = DEFMELEERANGE * 1.5;

		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.FireFunctor(fireFunc)
				.Payload('BIO_MeleeHit')
				.ShotCount(1)
				.RandomDamage(60, 65)
				.Alert(256.0)
				.Build()
		);

		FireTimeGroups.Push(
			StateTimeGroupFrom('Fire', "$BIO_CHARGE", flags: BIO_STGF_MELEE)
		);
		FireTimeGroups.Push(
			StateTimeGroupFrom('Swing', "$BIO_SWING", flags: BIO_STGF_MELEE)
		);

		let afx = new('BIO_WAfx_BerserkDamage');
		afx.Count = 1;
		Affixes.Push(afx);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 2;
	}
}

class BIO_FireFunc_Axe : BIO_FireFunc_Punch
{
	final override string Summary(
		readOnly<BIO_WeaponPipeline> ppl,
		readOnly<BIO_WeaponPipeline> pplDef
	) const
	{
		return StringTable.Localize("$BIO_FIREFUNC_AXE");
	}
}
