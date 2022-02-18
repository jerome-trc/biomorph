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
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.AssociateFirstFireTime()
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom());
	}

	States
	{
	Ready:
		BRAX A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		BRAX A 0 A_BIO_Deselect;
		Stop;
	Select:
		BRAX A 0 A_BIO_Select;
		Stop;
	Fire:
	Spawn:
		BRAX Z 0;
		BRAX Z 0 A_BIO_Spawn;
		Stop;
	}
}
