/// The currency with which new mutators can be applied.
class BIOM_Mutagen : Inventory
{
	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR

		Tag "$BIOM_MUTAGEN_TAG";
		Height 16.0;
		Radius 20.0;

		Inventory.Amount 1;
		Inventory.MaxAmount 99;
		Inventory.PickupMessage "$BIOM_MUTAGEN_PKUP";
	}

	States
	{
	Spawn:
		MUTA G 6;
		#### # 6 bright light("BIOM_Mutagen");
		Loop;
	}
}

/// Usable by a player to completely reset their mutation tree.
class BIOM_Antigen : Inventory
{
	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR

		Tag "$BIOM_ANTIGEN_TAG";
		Height 16.0;
		Radius 20.0;

		Inventory.Amount 1;
		Inventory.MaxAmount 99;
		Inventory.PickupMessage "$BIOM_ANTIGEN_PKUP";
	}

	States
	{
	Spawn:
		ANTG A 6;
		#### B 6 bright light("BIOM_Antigen");
		Loop;
	}
}
