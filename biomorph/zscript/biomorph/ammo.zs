mixin class biom_Ammo
{
	final override bool TryPickup(in out Actor other)
	{
		// If this returns null, either GZDoom or `biom_Player` is very broken.
		let tgt = other.FindInventory(self.GetParentAmmo());
		let prev = tgt.amount;
		let cap = tgt.maxAmount - tgt.amount;
		let amt = Min(amount, cap);
		tgt.amount = Clamp(tgt.amount + amt, 0, tgt.maxAmount);
		self.amount -= amt;

		// If the player previously had this ammo but ran out, possibly switch
		// to a weapon that uses it, but only if the player doesn't already
		// have a weapon pending.
		if (prev == 0 && other.player != null)
		{
			PlayerPawn(other).CheckWeaponSwitch(self.GetClass());
		}

		if (self.amount <= 0)
		{
			self.GoAwayAndDie();
			return true;
		}

		if (amt > 0)
			self.OnPartialPickup(other);

		if (bCountItem)
		{
			PrintPickupMessage(other.CheckLocalView(), self.collectedMessage);
			self.bCountItem = false;
			self.level.found_Items++;
			self.A_SetTranslation('BIO_Pkup_Counted');
		}

		return false;
	}
}

class biom_Slot3Ammo : Ammo
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

class biom_Slot4Ammo : Ammo
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

class biom_Slot5Ammo : Ammo
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

class biom_Slot67Ammo : Ammo
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

class biom_Slot3AmmoSmall : biom_Slot3Ammo replaces Shell
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT3AMMOSMALL_TAG";
		Inventory.Amount 4;
		Inventory.PickupMessage "$BIOM_SLOT3AMMOSMALL_PKUP";
		biom_Slot3AmmoSmall.PartialPickupMessage "$BIOM_SLOT3AMMOSMALL_PARTIAL";
	}

	States
	{
	Spawn:
		SHEL A -1;
		stop;
	}
}

class biom_Slot4AmmoSmall : biom_Slot4Ammo replaces Clip
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT4AMMOSMALL_TAG";
		Inventory.Amount 10;
		Inventory.PickupMessage "$BIOM_SLOT4AMMOSMALL_PKUP";
		biom_Slot4AmmoSmall.PartialPickupMessage "$BIOM_SLOT4AMMOSMALL_PARTIAL";
	}

	States
	{
	Spawn:
		CLIP A -1;
		stop;
	}
}

class biom_Slot5AmmoSmall : biom_Slot5Ammo replaces RocketAmmo
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT5AMMOSMALL_TAG";
		Inventory.Amount 1;
		Inventory.PickupMessage "$BIOM_SLOT5AMMOSMALL_PKUP";
		biom_Slot5AmmoSmall.PartialPickupMessage "$BIOM_SLOT5AMMOSMALL_PARTIAL";
	}

	States
	{
	Spawn:
		ROCK A -1;
		stop;
	}
}

class biom_Slot67AmmoSmall : biom_Slot67Ammo replaces Cell
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT67AMMOSMALL_TAG";
		Inventory.Amount 20;
		Inventory.PickupMessage "$BIOM_SLOT67AMMOSMALL_PKUP";
		biom_Slot67AmmoSmall.PartialPickupMessage "$BIOM_SLOT67AMMOSMALL_PARTIAL";
	}

	States
	{
	Spawn:
		CELL A -1;
		stop;
	}
}

// Pickups, big ////////////////////////////////////////////////////////////////

class biom_Slot3AmmoBig : biom_Slot3Ammo replaces ShellBox
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT3AMMOBIG_TAG";
		Inventory.Amount 20;
		Inventory.PickupMessage "$BIOM_SLOT3AMMOBIG_PKUP";
		biom_Slot3AmmoBig.PartialPickupMessage "$BIOM_SLOT3AMMOBIG_PARTIAL";
	}

	States
	{
	Spawn:
		SBOX A -1;
		stop;
	}
}

class biom_Slot4AmmoBig : biom_Slot4Ammo replaces ClipBox
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT4AMMOBIG_TAG";
		Inventory.Amount 50;
		Inventory.PickupMessage "$BIOM_SLOT4AMMOBIG_PKUP";
		biom_Slot4AmmoBig.PartialPickupMessage "$BIOM_SLOT4AMMOBIG_PARTIAL";
	}

	States
	{
	Spawn:
		AMMO A -1;
		stop;
	}
}

class biom_Slot5AmmoBig : biom_Slot5Ammo replaces RocketBox
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT5AMMOBIG_TAG";
		Inventory.Amount 5;
		Inventory.PickupMessage "$BIOM_SLOT5AMMOBIG_PKUP";
		biom_Slot5AmmoBig.PartialPickupMessage "$BIOM_SLOT5AMMOBIG_PARTIAL";
	}

	States
	{
	Spawn:
		BROK A -1;
		stop;
	}
}

class biom_Slot67AmmoBig : biom_Slot67Ammo replaces CellPack
{
	mixin biom_Pickup;
	mixin biom_Ammo;

	Default
	{
		Tag "$BIOM_SLOT67AMMOBIG_TAG";
		Inventory.Amount 100;
		Inventory.PickupMessage "$BIOM_SLOT67AMMOBIG_PKUP";
		biom_Slot67AmmoBig.PartialPickupMessage "$BIOM_SLOT67AMMOBIG_PARTIAL";
	}

	States
	{
	Spawn:
		CELP A -1;
		stop;
	}
}

// Backpack ////////////////////////////////////////////////////////////////////

class biom_Backpack : BackpackItem replaces Backpack
{
	Default
	{
		Height 26;
		Tag "$BIOM_BACKPACK_TAG";
		Inventory.PickupMessage "$BIOM_BACKPACK_PKUP";
		Inventory.PickupSound "biom/backpack/pkup";
	}

	States
	{
	Spawn:
		RUCK A -1;
		stop;
	}

	final override void Touch(Actor toucher)
	{
		let preexisting = toucher.FindInventory(self.GetClass()) != null;

		super.Touch(toucher);

		if (!preexisting)
			self.PrintPickupMessage(toucher.CheckLocalView(), "$BIOM_BACKPACK_FIRSTPKUP");
	}
}
