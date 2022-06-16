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
		PUNG A 1 A_WeaponReady;
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

	override BIO_WeaponModGraph CustomModGraph() const
	{
		return BIO_WeaponModGraph.Create(GraphQuality);
	}
}
