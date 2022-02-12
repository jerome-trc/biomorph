class BIO_BFG10K : BIO_Weapon
{
	Default
	{
		+WEAPON.NOAUTOFIRE

		Tag "$BIO_BFG10K_TAG";
		
		Inventory.Icon 'BFGUZ0';
		Inventory.PickupMessage "$BIO_BFG10K_PKUP";
	
		Weapon.AmmoGive 100;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 15;
		Weapon.SelectionOrder SELORDER_BFG_SPEC;
		Weapon.SlotNumber 7;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;

		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineType 'Cell';
		BIO_Weapon.PlayerVisual BIO_PVIS_BFG10K;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Bullet('BIO_PlasmaBolt', 4)
			.X1D8Damage(40)
			.Spread(6.0, 4.0)
			.AssociateFirstFireTime()
			.FireSound("bio/weap/bfg10k/fire")
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFromRange('Hold', 'Cooldown', "$BIO_PER_ROUND"));
		groups.Push(StateTimeGroupFromRange('Fire', 'Hold', "$BIO_CHARGE"));
		groups.Push(StateTimeGroupFrom('Cooldown', "$BIO_COOLDOWN"));
	}

	States
	{
	Ready:
		TNT1 A 0 A_StartSound("bio/weap/bfg10k/idle");
		BFGU AAABBBCCCDDD 1 A_WeaponReady;
		Loop;
	Deselect:
		BFGU A 0 A_BIO_Deselect;
		Stop;
	Select:
		BFGU A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		BFGU E 20
		{
			A_SetFireTime(0, 1);
			A_FireSound();
		}
		BFGU F 4 A_SetFireTime(1, 1);
		BFGU G 1 A_SetFireTime(2, 1);
		BFGU H 1 A_SetFireTime(3, 1);
		BFGU I 1 A_SetFireTime(4, 1);
		BFGU J 1 A_SetFireTime(5, 1);
	Hold:
		TNT1 A 0 A_BIO_CheckAmmo;
		BFGU K 2
		{
			A_SetFireTime(0);
			A_GunFlash();
		}
		BFGU L 2
		{
			A_SetFireTime(1);
			A_BIO_Fire();
		}
		BFGU M 2 A_SetFireTime(2);
		TNT1 A 0 A_ReFire;
	Cooldown:
		BFGU O 35
		{
			A_SetFireTime(0, 2);
			A_StartSound("bio/weap/bfg10k/cooldown", CHAN_AUTO);
		}
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light(1);
		TNT1 A 3 Bright;
		Goto LightDone;
	Spawn:
		BFGU Z 0;
		BFGU Z 0 A_BIO_Spawn;
		Stop;
	}
}
