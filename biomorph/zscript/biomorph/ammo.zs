mixin class BIO_Ammo
{
	final override bool TryPickup(in out Actor other)
	{
		// If this returns null, either GZDoom or `BIO_Player` is really broken
		let tgt = other.FindInventory(GetParentAmmo());
		let prev = tgt.Amount;
		let cap = tgt.MaxAmount - tgt.Amount;
		let amt = Min(Amount, cap);
		tgt.Amount = Clamp(tgt.Amount + amt, 0, tgt.MaxAmount);
		Amount -= amt;

		// If the player previously had this ammo but ran out, possibly switch
		// to a weapon that uses it, but only if the player doesn't already
		// have a weapon pending
		if (prev == 0 && other.Player != null)
		{
			PlayerPawn(other).CheckWeaponSwitch(GetClass());
		}

		if (Amount <= 0)
		{
			GoAwayAndDie();
			return true;
		}

		if (amt > 0)
			OnPartialPickup(other);

		if (bCountItem)
		{
			PrintPickupMessage(other.CheckLocalView(), CollectedMessage);
			bCountItem = false;
			Level.Found_Items++;
			A_SetTranslation('BIO_Pkup_Counted');
		}

		return false;
	}
}

// Small pickups ///////////////////////////////////////////////////////////////

class BIO_Clip : Clip
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_CLIP_TAG";
		Inventory.PickupMessage "$BIO_CLIP_PKUP";
		BIO_Clip.PartialPickupMessage "$BIO_CLIP_PARTIAL";
	}
}

class BIO_Shell : Shell
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_SHELL_TAG";
		Inventory.PickupMessage "$BIO_SHELL_PKUP";
		BIO_Shell.PartialPickupMessage "$BIO_SHELL_PARTIAL";
	}
}

class BIO_RocketAmmo : RocketAmmo
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_ROCKETAMMO_TAG";
		Inventory.PickupMessage "$BIO_ROCKETAMMO_PKUP";
		BIO_RocketAmmo.PartialPickupMessage "$BIO_ROCKETAMMO_PARTIAL";
	}
}

class BIO_Cell : Cell
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_CELL_TAG";
		Inventory.PickupMessage "$BIO_CELL_PKUP";
		BIO_Cell.PartialPickupMessage "$BIO_CELL_PARTIAL";
	}
}

// Large pickups ///////////////////////////////////////////////////////////////

class BIO_ClipBox : ClipBox
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_CLIPBOX_TAG";
		Inventory.PickupMessage "$BIO_CLIPBOX_PKUP";
		BIO_ClipBox.PartialPickupMessage "$BIO_CLIPBOX_PARTIAL";
	}
}

class BIO_ShellBox : ShellBox
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_SHELLBOX_TAG";
		Inventory.PickupMessage "$BIO_SHELLBOX_PKUP";
		BIO_ShellBox.PartialPickupMessage "$BIO_SHELLBOX_PARTIAL";
	}
}

class BIO_RocketBox : RocketBox
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_ROCKETBOX_TAG";
		Inventory.PickupMessage "$BIO_ROCKETBOX_PKUP";
		BIO_RocketBox.PartialPickupMessage "$BIO_ROCKETBOX_PARTIAL";
	}
}

class BIO_CellPack : CellPack
{
	mixin BIO_Pickup;
	mixin BIO_Ammo;

	Default
	{
		Tag "$BIO_CELLPACK_TAG";
		Inventory.PickupMessage "$BIO_CELLPACK_PKUP";
		BIO_CellPack.PartialPickupMessage "$BIO_CELLPACK_PARTIAL";
	}
}

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
		BPAK A -1;
		Stop;
	}

	// LATER: Maybe waste-proof this; not as big a deal as with the others
}
