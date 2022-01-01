class BIO_ImpactorGauntlet : BIO_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_IMPACTORGAUNTLET_TAG";
		
		Inventory.Icon 'IMPAZ0';
		Inventory.PickupMessage "$BIO_IMPACTORGAUNTLET_PKUP";
	
		Weapon.SelectionOrder SELORDER_CHAINSAW_CLSF;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;
		Weapon.UpSound "bio/weap/impgaunt/raise";

		BIO_Weapon.AffixMask BIO_WAM_AMMOLESS;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.PlayerVisual BIO_PVIS_UNARMED;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Punch('BIO_ImpactorPuff', range: 92.0, CPF_NOTURN,
				"bio/weap/impgaunt/hit", "bio/weap/impgaunt/miss")
			.XTimesRandomDamage(10, 10, 55)
			.Build());

		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Punch('BIO_ImpactorPuff', range: 92.0, CPF_NOTURN, 0, "")
			.X1D3Damage(8)
			.CustomReadout(StringTable.Localize("$BIO_IMPACTORGAUNTLET_THRUST"))
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire', "$BIO_CHARGE"));
		groups.Push(StateTimeGroupFrom('Cooldown', "$BIO_COOLDOWN"));
		groups.Push(StateTimeGroupFrom('AltCooldown', "$BIO_COOLDOWN_ALT"));
	}

	States
	{
	Ready:
		IMPA A 1 A_WeaponReady;
		Loop;
	Deselect:
		IMPA A 0 A_BIO_Deselect;
		Stop;
	Select:
		IMPA A 0 A_BIO_Select;
		Stop;
	Fire:
		IMPA A 2 A_SetFireTime(0);
		IMPA B 2 A_SetFireTime(1);
		IMPA C 2
		{
			A_SetFireTime(2);
			A_StartSound("bio/weap/impgaunt/prep");
		}
		IMPA D 2 A_SetFireTime(3);
		IMPA E 2 A_SetFireTime(4);
		TNT1 A 5 A_SetFireTime(5);
		Goto Hold;
	Hold:
		TNT1 A 1;
		TNT1 A 0 A_ReFire;
		IMPA FGHI 1;
		IMPA J 1
		{
			A_BIO_Fire();

			A_Blast(BF_DONTWARN | BF_NOIMPACTDAMAGE | BF_AFFECTBOSSES,
				25.0, 60.0, 20.0, 'BIO_ImpactorGauntletBlast');

			if (BIO_quake) A_Quake(3, 10, 0, 10);
		}
	Cooldown:
		IMPA K 1 A_SetFireTime(0, 1);
		IMPA L 1 A_SetFireTime(1, 1);
		IMPA M 1 A_SetFireTime(2, 1);
		IMPA N 1 A_SetFireTime(3, 1);
		IMPA N 5 A_SetFireTime(4, 1);
		IMPA O 3 A_SetFireTime(5, 1);
		IMPA P 3 A_SetFireTime(6, 1);
		IMPA Q 3 A_SetFireTime(7, 1);
		IMPA R 3 A_SetFireTime(8, 1);
		IMPA S 3 A_SetFireTime(9, 1);
		TNT1 A 5 A_SetFireTime(10, 1);
		IMPA E 2 A_SetFireTime(11, 1);
		IMPA D 2 A_SetFireTime(12, 1);
		IMPA C 2 A_SetFireTime(13, 1);
		IMPA B 2 A_SetFireTime(14, 1);
		IMPA A 2 A_SetFireTime(15, 1);
		Goto Ready;
	AltFire:
		IMPA A 2 A_SetFireTime(0);
		IMPA B 2 A_SetFireTime(1);
		IMPA C 2
		{
			A_SetFireTime(2);
			A_StartSound("bio/weap/impgaunt/prep");
		}
		IMPA D 2 A_SetFireTime(3);
		IMPA E 2 A_SetFireTime(4);
		TNT1 A 5 A_SetFireTime(5);
		Goto Hold;
	AltHold:
		TNT1 A 1;
		TNT1 A 0 A_ReFire;
		IMPA FGHI 1;
		IMPA J 1
		{
			ThrustThing(Angle * 256.0 / 360.0, 30, 1, 0);
			A_StartSound("bio/weap/impgaunt/thrust", CHAN_AUTO);
			A_BIO_Fire(pipeline: 1);
		}
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
		IMPA J 1 A_BIO_Fire(pipeline: 1);
	AltCooldown:
		IMPA O 2 A_SetFireTime(0, 2);
		IMPA P 2 A_SetFireTime(1, 2);
		IMPA Q 2 A_SetFireTime(2, 2);
		IMPA R 2 A_SetFireTime(3, 2);
		IMPA S 2 A_SetFireTime(4, 2);
		TNT1 A 5 A_SetFireTime(5, 2);
		IMPA E 2 A_SetFireTime(6, 2);
		IMPA D 2 A_SetFireTime(7, 2);
		IMPA C 2 A_SetFireTime(8, 2);
		IMPA B 2 A_SetFireTime(9, 2);
		IMPA A 2 A_SetFireTime(10, 2);
		Goto Ready;
	Spawn:
		IMPA Z 0;
		IMPA Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_ImpactorPuff : BIO_MeleeHit
{
	Default
	{
		+PUFFONACTORS
	}

	States
	{
	Spawn:
		PUFF ABCD 4;
		Stop;
	}
}  

class BIO_ImpactorGauntletBlast : BlastEffect
{
	Default
	{
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOTELEPORT
	}

	States
	{
	Spawn:
		TNT1 A 0;
		Stop;
	}
}
