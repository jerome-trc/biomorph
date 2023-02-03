class BIOM_Slot3Ammo : Ammo
{
	Default
	{
		Tag "$BIOM_SLOT3AMMO_TAG";
		Inventory.Icon 'SHELA0';
		Inventory.MaxAmount 50;
		Ammo.BackpackAmount 4;
		Ammo.BackpackMaxAmount 100;
	}
}

class BIOM_Slot4Ammo : Ammo
{
	Default
	{
		Tag "$BIOM_SLOT4AMMO_TAG";
		Inventory.Icon 'CLIPA0';
		Inventory.MaxAmount 200;
		Ammo.BackpackAmount 10;
		Ammo.BackpackMaxAmount 400;
	}
}

class BIOM_Slot5Ammo : Ammo
{
	Default
	{
		Tag "$BIOM_SLOT5AMMO_TAG";
		Inventory.Icon 'ROCKA0';
		Inventory.MaxAmount 50;
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 100;
	}
}

class BIOM_Slot67Ammo : Ammo
{
	Default
	{
		Tag "$BIOM_SLOT67AMMO_TAG";
		Inventory.Icon 'CELLA0';
		Inventory.MaxAmount 300;
		Ammo.BackpackAmount 20;
		Ammo.BackpackMaxAmount 600;
	}
}

// Pickups, small //////////////////////////////////////////////////////////////

class BIOM_Slot3Ammo_Small : BIOM_Slot3Ammo replaces Shell
{
	Default
	{
		Tag "$BIOM_SLOT3AMMO_SMALL_TAG";
		Inventory.Amount 4;
		Inventory.PickupMessage "$BIOM_SLOT3AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		SHEL A -1;
		Stop;
	}
}

class BIOM_Slot4Ammo_Small : BIOM_Slot4Ammo replaces Clip
{
	Default
	{
		Tag "$BIOM_SLOT4AMMO_SMALL_TAG";
		Inventory.Amount 10;
		Inventory.PickupMessage "$BIOM_SLOT4AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		CLIP A -1;
		Stop;
	}
}

class BIOM_Slot5Ammo_Small : BIOM_Slot5Ammo replaces RocketAmmo
{
	Default
	{
		Tag "$BIOM_SLOT5AMMO_SMALL_TAG";
		Inventory.Amount 1;
		Inventory.PickupMessage "$BIOM_SLOT5AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		ROCK A -1;
		Stop;
	}
}

class BIOM_Slot67Ammo_Small : BIOM_Slot67Ammo replaces Cell
{
	Default
	{
		Tag "$BIOM_SLOT67AMMO_SMALL_TAG";
		Inventory.Amount 20;
		Inventory.PickupMessage "$BIOM_SLOT67AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		CELL A -1;
		Stop;
	}
}

// Pickups, big ////////////////////////////////////////////////////////////////

class BIOM_Slot3Ammo_Big : BIOM_Slot3Ammo replaces ShellBox
{
	Default
	{
		Tag "$BIOM_SLOT3AMMO_BIG_TAG";
		Inventory.Amount 20;
		Inventory.PickupMessage "$BIOM_SLOT3AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		SBOX A -1;
		Stop;
	}
}

class BIOM_Slot4Ammo_Big : BIOM_Slot4Ammo replaces ClipBox
{
	Default
	{
		Tag "$BIOM_SLOT4AMMO_BIG_TAG";
		Inventory.Amount 50;
		Inventory.PickupMessage "$BIOM_SLOT4AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		AMMO A -1;
		Stop;
	}
}

class BIOM_Slot5Ammo_Big : BIOM_Slot5Ammo replaces RocketBox
{
	Default
	{
		Tag "$BIOM_SLOT5AMMO_BIG_TAG";
		Inventory.Amount 5;
		Inventory.PickupMessage "$BIOM_SLOT5AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		BROK A -1;
		Stop;
	}
}

class BIOM_Slot67Ammo_Big : BIOM_Slot67Ammo replaces CellPack
{
	Default
	{
		Tag "$BIOM_SLOT67AMMO_BIG_TAG";
		Inventory.Amount 100;
		Inventory.PickupMessage "$BIOM_SLOT67AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		CELP A -1;
		Stop;
	}
}

// Backpack ////////////////////////////////////////////////////////////////////

class BIOM_Backpack : BackpackItem replaces Backpack
{
	Default
	{
		Height 26;
		Tag "$BIOM_BACKPACK_TAG";
		Inventory.PickupMessage "$BIOM_BACKPACK_PKUP";
	}

	States
	{
	Spawn:
		RUCK A -1;
		Stop;
	}

	final override void Touch(Actor toucher)
	{
		let preexisting = toucher.FindInventory(self.GetClass()) != null;

		super.Touch(toucher);

		if (!preexisting)
			self.PrintPickupMessage(toucher.CheckLocalView(), "$BIOM_BACKPACK_FIRSTPKUP");
	}
}
