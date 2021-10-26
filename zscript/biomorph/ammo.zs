/* 	Ammo pickups run relevant player pawn callbacks.

	If Zhs2's Intelligent Supplies is installed, these behaviors are only invoked
	after these items have been fully drained.
*/

// Small pickups ===============================================================

class BIO_Clip : Clip
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_CLIP";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		
		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

class BIO_Shell : Shell
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_SHELL";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

class BIO_RocketAmmo : RocketAmmo
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_ROCKETAMMO";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

class BIO_Cell : Cell
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_CELL";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

// Large pickups ===============================================================

class BIO_ClipBox : ClipBox
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_CLIPBOX";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

class BIO_ShellBox : ShellBox
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_SHELLBOX";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

class BIO_RocketBox : RocketBox
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_ROCKETBOX";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

class BIO_CellPack : CellPack
{
	Default
	{
		Inventory.PickupMessage "$BIO_AMMO_PICKUP_CELLPACK";
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bool zhs2IS = BIO_Utils.IntelligentSupplies();

		if (!zhs2IS || Amount <= 0)
			bioPlayer.OnAmmoPickup(self);
	}
}

// Backpack ====================================================================

class BIO_Backpack : BackpackItem replaces Backpack
{
	static const Class<Ammo> DOOM_AMMO_TYPES[] =
		{ "Clip", "Shell", "RocketAmmo", "Cell" };

	Default
	{
		Height 26;
		Inventory.PickupMessage "$BIO_BACKPACK_PICKUP";
	}

	States
	{
	Spawn:
		BPAK A -1;
		Stop;
	}

	override Inventory CreateCopy(Actor other)
	{
		let bioPlayer = BIO_Player(other);
		
		if (bioPlayer != null)
		{
			// Assume that all of these ammo items are non-null
			for (uint i = 0; i < DOOM_AMMO_TYPES.Size(); i++)
			{
				let ammo_t = DOOM_AMMO_TYPES[i];
				let defs = GetDefaultByType(ammo_t);
				let ammoItem = bioPlayer.FindInventory(ammo_t);
				ammoItem.MaxAmount = defs.BackpackMaxAmount;
				bioPlayer.GiveInventory(ammo_t, defs.BackpackAmount);
			}
			bioPlayer.OnBackpackPickup(self);
		}

		return Inventory.CreateCopy(other);
	}
}
