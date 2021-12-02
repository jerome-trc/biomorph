class BIO_Fist : BIO_Weapon replaces Fist
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPFIST";
		Tag "$BIO_WEAP_TAG_FIST";

		Inventory.Icon 'PUNGA0';
		
		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority 1.0;

		BIO_Weapon.AffixMask BIO_WAM_MAGAZINELESS;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.PunchPipeline('BIO_MeleeHit', 1, 2, 20)
			.CustomReadout(String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_BERSERKMULTI"), 900))
			.Alert(-1.0, 0)
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire'));
	}

	States
	{
	Ready:
		PUNG A 1 A_WeaponReady;
		Loop;
	Deselect:
		PUNG A 0 A_BIO_Deselect;
		Loop;
	Select:
		PUNG A 0 A_BIO_Select;
		Loop;
	Fire:
		PUNG B 4 A_SetFireTime(0);
		PUNG C 4
		{
			A_SetFireTime(1);
			A_BIO_Fire();
		}
		PUNG D 5 A_SetFireTime(2);
		PUNG C 4 A_SetFireTime(3);
		PUNG B 5
		{
			A_SetFireTime(4);
			A_ReFire();
		}
		Goto Ready;
	}
}
