class BIO_Fists : BIO_DualWieldWeapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIO_FISTS_TAG";

		Inventory.Icon 'PUNGA0';

		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;

		BIO_Weapon.Family BIO_WEAPFAM_FIST;
		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.SwitchSpeeds 14, 14;
	}

	States
	{
	Ready:
		PUNG A 1 A_WeaponReady(WRF_ALLOWZOOM);
		Loop;
	Deselect:
		PUNG A 0 A_BIO_Deselect;
		Stop;
	Select:
		PUNG A 0 A_BIO_Select;
		Stop;
	Fire:
		PUNG B 4;
		PUNG C 4 A_BIO_Fire;
		PUNG D 5;
		PUNG C 4;
		PUNG B 5 A_ReFire;
		Goto Ready;
	Zoom:
		TNT1 A 0 A_BIO_WeaponSpecial;
		Goto Ready;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Punch()
				.RandomDamage(2, 20)
				.Alert(-1.0, 0)
				.Tag(BIO_Utils.Capitalize(StringTable.Localize("$BIO_PUNCH")))
				.Build()
		);
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
		}

		sim.RunAndClose();
	}
}
