class BIO_BreachingAxe : BIO_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_BREACHINGAXE_TAG";

		Inventory.Icon 'BRAXZ0';
		Inventory.PickupMessage "$BIO_BREACHINGAXE_PKUP";

		Weapon.SelectionOrder SELORDER_CHAINSAW_SPEC;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;

		BIO_Weapon.AffixMask BIO_WAM_AMMOLESS;
		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.PlayerVisual BIO_PVIS_CHAINSAW;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		let fireFunc = new('BIO_FireFunc_Axe');
		fireFunc.Range = DEFMELEERANGE * 1.5;

		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.FireFunctor(fireFunc)
			.FireType('BIO_MeleeHit')
			.FireCount(1)
			.BasicDamage(75, 100)
			.Alert(256.0)
			.Associate2FireTimes(0, 1)
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire', "$BIO_CHARGE", melee: true));
		groups.Push(StateTimeGroupFrom('Swing', "$BIO_SWING", melee: true));
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
		BRAX A 2 A_SetFireTime(0);
		BRAX B 2 A_SetFireTime(1);
		BRAX C 2 A_SetFireTime(2);
		TNT1 A 5 A_SetFireTime(3);
		Goto Hold;
	Hold:
		TNT1 A 1;
		TNT1 A 0 A_ReFire;
		Goto Swing;
	Swing:
		BRAX I 2 A_SetFireTime(0, 1);
		BRAX H 2 A_SetFireTime(1, 1);
		BRAX G 2 A_SetFireTime(2, 1);
		BRAX F 2 A_SetFireTime(3, 1);
		BRAX E 2
		{
			A_SetFireTime(4, 1);
			A_BIO_Fire();
			A_FireSound();
			if (BIO_quake) A_Quake(3, 10, 0, 10);
		}
		TNT1 A 8 A_SetFireTime(5, 1);
		BRAX E 6 A_SetFireTime(6, 1);
		BRAX D 6 Offset(0 + 20, 32 + 15) A_SetFireTime(7, 1);
		Goto Ready;
	Spawn:
		BRAX Z 0;
		BRAX Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_FireFunc_Axe : BIO_FireFunc_Punch
{
	final override void ToString(
		in out Array<string> readout,
		readOnly<BIO_WeaponPipeline> ppl,
		readOnly<BIO_WeaponPipeline> pplDef) const
	{
		readout.Push(StringTable.Localize("$BIO_FIREFUNC_AXE"));
	}
}
