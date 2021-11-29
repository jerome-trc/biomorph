class BIO_Chainsaw : BIO_Weapon replaces Chainsaw
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPCHAINSAW";
		Tag "$TAG_CHAINSAW";
	
		Inventory.Icon 'CSAWA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_CHAINSAW";
		
		Weapon.Kickback 0;
		Weapon.ReadySound "weapons/sawidle";
		Weapon.SelectionOrder SELORDER_CHAINSAW;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority SLOTPRIO_MIN;
		Weapon.UpSound "weapons/sawup";

		BIO_Weapon.AffixMask BIO_WAM_MAGAZINELESS;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create(GetClass())
			.SawPipeline('BIO_MeleeHit', 1, 2, 20)
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(BIO_StateTimeGroup.FromState(ResolveState('Fire')));
	}

	States
	{
	Ready:
		SAWG CD 4 A_WeaponReady;
		Loop;
	Deselect:
		SAWG C 0 A_BIO_Deselect;
		Stop;
	Select:
		SAWG C 0 A_BIO_Select;
		Stop;
	Fire:
		SAWG A 4
		{
			A_SetFireTime(0);
			A_BIO_Fire();
		}	
		SAWG B 4
		{
			A_SetFireTime(1);
			A_BIO_Fire();
		}
		SAWG B 0 A_ReFire;
		Goto Ready;
	Spawn:
		CSAW A 0;
		CSAW A 0 A_BIO_Spawn;
		Stop;
	}
}