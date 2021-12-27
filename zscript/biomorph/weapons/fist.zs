class BIO_Fist : BIO_Weapon replaces Fist
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPFIST";
		Tag "$BIO_FIST_TAG";

		Inventory.Icon 'PUNGA0';
		
		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority 1.0;

		BIO_Weapon.AffixMask BIO_WAM_MAGAZINELESS;
		BIO_Weapon.PlayerVisual BIO_PVIS_UNARMED;
	}

	final override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Punch()
			.BasicDamage(2, 20)
			.Alert(-1.0, 0)
			.Build());
	}

	final override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire'));
	}

	final override void InitImplicitAffixes(in out Array<BIO_WeaponAffix> affixes) const
	{
		let berserkDmg = new('BIO_WAfx_BerserkDamage');
		berserkDmg.Multiplier = 10.0;
		affixes.Push(berserkDmg);
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
