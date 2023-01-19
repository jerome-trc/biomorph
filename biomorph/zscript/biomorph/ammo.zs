class BIO_Slot3Ammo : Ammo
{
	Default
	{
		Tag "$BIO_SLOT3AMMO_TAG";
		Inventory.Icon 'SHELA0';
		Inventory.MaxAmount 50;
		Ammo.BackpackAmount 4;
		Ammo.BackpackMaxAmount 100;
	}
}

class BIO_Slot4Ammo : Ammo
{
	Default
	{
		Tag "$BIO_SLOT4AMMO_TAG";
		Inventory.Icon 'CLIPA0';
		Inventory.MaxAmount 200;
		Ammo.BackpackAmount 10;
		Ammo.BackpackMaxAmount 400;
	}
}

class BIO_Slot5Ammo : Ammo
{
	Default
	{
		Tag "$BIO_SLOT5AMMO_TAG";
		Inventory.Icon 'ROCKA0';
		Inventory.MaxAmount 50;
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 100;
	}
}

class BIO_Slot67Ammo : Ammo
{
	Default
	{
		Tag "$BIO_SLOT67AMMO_TAG";
		Inventory.Icon 'CELLA0';
		Inventory.MaxAmount 300;
		Ammo.BackpackAmount 20;
		Ammo.BackpackMaxAmount 600;
	}
}

// Pickups, small //////////////////////////////////////////////////////////////

class BIO_Slot3Ammo_Small : BIO_Slot3Ammo replaces Shell
{
	Default
	{
		Tag "$BIO_SLOT3AMMO_SMALL_TAG";
		Inventory.Amount 4;
		Inventory.PickupMessage "$BIO_SLOT3AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		SHEL A -1;
		Stop;
	}
}

class BIO_Slot4Ammo_Small : BIO_Slot4Ammo replaces Clip
{
	Default
	{
		Tag "$BIO_SLOT4AMMO_SMALL_TAG";
		Inventory.Amount 10;
		Inventory.PickupMessage "$BIO_SLOT4AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		CLIP A -1;
		Stop;
	}
}

class BIO_Slot5Ammo_Small : BIO_Slot5Ammo replaces RocketAmmo
{
	Default
	{
		Tag "$BIO_SLOT5AMMO_SMALL_TAG";
		Inventory.Amount 1;
		Inventory.PickupMessage "$BIO_SLOT5AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		ROCK A -1;
		Stop;
	}
}

class BIO_Slot67Ammo_Small : BIO_Slot67Ammo replaces Cell
{
	Default
	{
		Tag "$BIO_SLOT67AMMO_SMALL_TAG";
		Inventory.Amount 20;
		Inventory.PickupMessage "$BIO_SLOT67AMMO_SMALL_PKUP";
	}

	States
	{
	Spawn:
		CELL A -1;
		Stop;
	}
}

// Pickups, big ////////////////////////////////////////////////////////////////

class BIO_Slot3Ammo_Big : BIO_Slot3Ammo replaces ShellBox
{
	Default
	{
		Tag "$BIO_SLOT3AMMO_BIG_TAG";
		Inventory.Amount 20;
		Inventory.PickupMessage "$BIO_SLOT3AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		SBOX A -1;
		Stop;
	}
}

class BIO_Slot4Ammo_Big : BIO_Slot4Ammo replaces ClipBox
{
	Default
	{
		Tag "$BIO_SLOT4AMMO_BIG_TAG";
		Inventory.Amount 50;
		Inventory.PickupMessage "$BIO_SLOT4AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		AMMO A -1;
		Stop;
	}
}

class BIO_Slot5Ammo_Big : BIO_Slot5Ammo replaces RocketBox
{
	Default
	{
		Tag "$BIO_SLOT5AMMO_BIG_TAG";
		Inventory.Amount 5;
		Inventory.PickupMessage "$BIO_SLOT5AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		BROK A -1;
		Stop;
	}
}

class BIO_Slot67Ammo_Big : BIO_Slot67Ammo replaces CellPack
{
	Default
	{
		Tag "$BIO_SLOT67AMMO_BIG_TAG";
		Inventory.Amount 100;
		Inventory.PickupMessage "$BIO_SLOT67AMMO_BIG_PKUP";
	}

	States
	{
	Spawn:
		CELP A -1;
		Stop;
	}
}

// Backpack ////////////////////////////////////////////////////////////////////

class BIO_Backpack : BackpackItem replaces Backpack
{
	Default
	{
		Height 26;
		Tag "$BIO_BACKPACK_TAG";
		Inventory.PickupMessage "$BIO_BACKPACK_PKUP";
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
			self.PrintPickupMessage(toucher.CheckLocalView(), "$BIO_BACKPACK_FIRSTPKUP");
	}
}
