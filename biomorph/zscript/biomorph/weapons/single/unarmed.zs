class BIO_Unarmed : BIO_Weapon
{
	flagdef LeftHand: DynFlags, 31;

	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_UNARMED_TAG";

		Inventory.Icon 'H2HCZ0';

		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;

		BIO_Weapon.Family BIO_WEAPFAM_UNARMED;
		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.SwitchSpeeds 14, 14;
	}

	States
	{
	Ready:
		H2HC A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		H2HC A 0 A_BIO_Deselect;
		Stop;
	Select:
		H2HC A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.bLeftHand, 'Jab.Left');
	Jab.Right:
		TNT1 A 0 { invoker.bLeftHand = true; }
		JABR A 1 A_BIO_SetFireTime(0);
		JABR B 1 A_BIO_SetFireTime(1);
		JABR C 1
		{
			A_BIO_SetFireTime(2);
			A_BIO_Jab();
		}
		JABR B 2 A_BIO_SetFireTime(3);
		JABR A 4 A_BIO_SetFireTime(4);
		H2HC A 3 A_BIO_SetFireTime(5);
		Goto Ready;
	Jab.Left:
		TNT1 A 0 { invoker.bLeftHand = false; }
		JABL A 1 A_BIO_SetFireTime(0);
		JABL B 1 A_BIO_SetFireTime(1);
		JABL C 1
		{
			A_BIO_SetFireTime(2);
			A_BIO_Jab();
		}
		JABL B 2 A_BIO_SetFireTime(3);
		JABL A 4 A_BIO_SetFireTime(4);
		H2HC A 3 A_BIO_SetFireTime(5);
		Goto Ready;
	Reload:
		NOPE B 4 A_WeaponReady(WRF_ALLOWZOOM);
		NOPE C 4 A_WeaponReady(WRF_ALLOWZOOM);
		NOPE D 4 A_WeaponReady(WRF_ALLOWZOOM);
		NOPE E 30 A_WeaponReady(WRF_ALLOWZOOM);
		NOPE D 4 A_WeaponReady(WRF_ALLOWZOOM);
		NOPE C 4 A_WeaponReady(WRF_ALLOWZOOM);
		NOPE B 4 A_WeaponReady(WRF_ALLOWZOOM);
		Goto Ready;
	}

	protected action void A_BIO_Jab()
	{
		A_BIO_Fire();
		A_BIO_FireSound();
		A_BIO_Recoil('BIO_Recoil_Punch');

		if (BIO_quake)
			A_Quake(1, 5, 0, 5);
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Punch()
				.RandomDamage(2, 20)
				.Alert(-1.0, 0)
				.FireSound("bio/weap/whoosh")
				.Tag(BIO_Utils.Capitalize(StringTable.Localize("$BIO_PUNCH")))
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Jab.Right'));
	}

	override void IntrinsicModGraph(bool onMutate)
	{
		if (ModGraph != null || onMutate == true) // Should never happen
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"`%s` called `IntrinsicModGraph()` in an illegal context.",
				GetClassName()
			);
			return;
		}

		ModGraph = BIO_WeaponModGraph.Create(GraphQuality);
		let sim = BIO_WeaponModSimulator.Create(self);

		for (uint i = 0; i < 4; i++)
		{
			let r = sim.RandomNode(accessible: true, unoccupied: true);
			sim.InsertNewGene('BIO_MGene_BerserkDamage', r);
			sim.Nodes[r].Basis.Lock();
		}

		sim.RunAndClose();
	}
}
