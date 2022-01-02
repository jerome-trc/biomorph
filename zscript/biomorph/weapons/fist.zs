class BIO_Fist : BIO_Weapon replaces Fist
{
	private bool LeftPunch;

	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPFIST";
		Tag "$BIO_FIST_TAG";

		Inventory.Icon 'FISTP0';

		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority 1.0;

		BIO_Weapon.AffixMask BIO_WAM_AMMOLESS;
		BIO_Weapon.PlayerVisual BIO_PVIS_UNARMED;
	}

	final override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Punch()
			.BasicDamage(2, 20)
			.Alert(-1.0, 0)
			.Tag(BIO_Utils.Capitalize(StringTable.Localize("$BIO_PUNCH")))
			.Build());

		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.FireFunctor(new('BIO_FireFunc_Kick'))
			.FireType('BIO_MeleeHit')
			.BasicDamage(4, 40)
			.Alert(-1.0, 0)
			.Tag(BIO_Utils.Capitalize(StringTable.Localize("$BIO_KICK")))
			.Build());
	}

	final override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('RightPunch', "$BIO_PUNCH", melee: true));
		groups.Push(StateTimeGroupFrom('Altfire', "$BIO_KICK", melee: true));
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
		PUCH A 1 A_WeaponReady;
		Loop;
	Deselect:
		PUCH A 0 A_BIO_Deselect;
		Loop;
	Select:
		PUCH A 0 A_BIO_Select;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.LeftPunch, 'LeftPunch');
	RightPunch:
		PUCH A 3 A_SetFireTime(0);
		PUCH B 2 A_SetFireTime(1);
		PUCH L 2
		{
			A_StartSound("bio/weap/whoosh", CHAN_WEAPON);
			A_SetFireTime(2);
			A_BIO_Fire();
		}
		PUCH C 2 A_SetFireTime(3);
		PUCH M 2 A_SetFireTime(4);
		PUCH D 2 A_SetFireTime(5);
		PUCH N 2 A_SetFireTime(6);
		PUCH E 2 A_SetFireTime(7);
		PUCH R 2 A_SetFireTime(8);
		PUCH K 0 { invoker.LeftPunch = true; }
		PUCH K 3
		{
			A_SetFireTime(9);
			A_ReFire();
		}
		Goto Ready;
	LeftPunch:
		PUCH F 3 A_SetFireTime(0);
		PUCH G 2 A_SetFireTime(1);
		PUCH O 2
		{
			A_StartSound("bio/weap/whoosh", CHAN_WEAPON);
			A_SetFireTime(2);
			A_BIO_Fire();
		}
		PUCH H 2 A_SetFireTime(3);
		PUCH P 2 A_SetFireTime(4);
		PUCH I 2 A_SetFireTime(5);
		PUCH Q 2 A_SetFireTime(6);
		PUCH J 2 A_SetFireTime(7);
		PUCH K 0 { invoker.LeftPunch = false; } 
		PUCH K 3
		{
			A_SetFireTime(8);
			A_ReFire();
		}
		Goto Ready;
	Altfire:
		PUCH K 2
		{
			A_SetFireTime(0, 1);
			A_StartSound("bio/weap/whoosh", CHAN_WEAPON);
		}
		MLEG A 2 A_SetFireTime(1, 1);
		MLEG B 2 A_SetFireTime(2, 1);
		MLEG C 2
		{
			A_SetFireTime(3, 1);
			A_BIO_Fire(pipeline: 1);
		}
		MLEG D 2 A_SetFireTime(4, 1);
		MLEG E 2 A_SetFireTime(5, 1);
		MLEG F 2 A_SetFireTime(6, 1);
		MLEG G 2 A_SetFireTime(7, 1);
		MLEG H 2 A_SetFireTime(8, 1);
		PUCH K 4
		{
			A_SetFireTime(9, 1);
			A_ReFire();
		}
		Goto Ready;
	}
}

class BIO_FireFunc_Kick : BIO_FireFunc_Punch
{
	override void ToString(
		in out Array<string> readout,
		readOnly<BIO_WeaponPipeline> ppl,
		readOnly<BIO_WeaponPipeline> pplDef) const
	{
		readout.Push(StringTable.Localize("$BIO_FIREFUNC_KICK"));
	}
}
