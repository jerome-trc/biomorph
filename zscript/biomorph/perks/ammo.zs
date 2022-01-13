class BIO_Perk_ClipCapacity_Minor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Clip').MaxAmount +=
			GetDefaultByType('Clip').BackpackAmount;
	}
}

class BIO_Perk_ShellCapacity_Minor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Shell').MaxAmount +=
			GetDefaultByType('Shell').BackpackAmount;
	}
}

class BIO_Perk_RocketAmmoCapacity_Minor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('RocketAmmo').MaxAmount +=
			GetDefaultByType('RocketAmmo').BackpackAmount;
	}
}

class BIO_Perk_CellCapacity_Minor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Cell').MaxAmount +=
			GetDefaultByType('Cell').BackpackAmount;
	}
}

class BIO_Perk_ClipCapacity_Major : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Clip').MaxAmount +=
			GetDefaultByType('Clip').BackpackAmount * 5;
	}
}

class BIO_Perk_ShellCapacity_Major : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Shell').MaxAmount +=
			GetDefaultByType('Shell').BackpackAmount * 5;
	}
}

class BIO_Perk_RocketAmmoCapacity_Major : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('RocketAmmo').MaxAmount +=
			GetDefaultByType('RocketAmmo').BackpackAmount * 5;
	}
}

class BIO_Perk_CellCapacity_Major : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Cell').MaxAmount +=
			GetDefaultByType('Cell').BackpackAmount * 5;
	}
}

// Large ammo pickups also grant a small pickup ================================

class BIO_Perk_LargeAmmoBonus : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_LargeAmmoBonus');
	}
}

class BIO_PkupFunc_LargeAmmoBonus : BIO_ItemPickupFunctor
{
	final override void OnAmmoPickup(BIO_Player bioPlayer, Inventory item) const
	{
		let ammoItem = Ammo(item);

		// Hopelessly un-sophisticated (but still dynamic) check
		if (ammoItem.Default.Amount > ammoItem.Default.BackpackAmount)
		{
			for (uint i = 0; i < Count; i++)
			{
				bioPlayer.GiveInventory(ammoItem.GetClass(),
					ammoItem.Default.BackpackAmount);
			}
		}
	}
}

// =============================================================================
// Every backpack after the first adds `BackpackAmount` to all capacities

class BIO_Perk_AdditiveBackpacks : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.PushFunctor('BIO_PkupFunc_AdditiveBackpacks');
	}
}

class BIO_PkupFunc_AdditiveBackpacks : BIO_ItemPickupFunctor
{
	final override void OnSubsequentBackpackPickup(
		BIO_Player bioPlayer, BIO_Backpack bkpk) const
	{
		for (uint i = 0; i < BIO_Backpack.DOOM_AMMO_TYPES.Size(); i++)
		{
			let ammo_t = BIO_Backpack.DOOM_AMMO_TYPES[i];
			let defs = GetDefaultByType(ammo_t);
			let ammoItem = bioPlayer.FindInventory(ammo_t);

			for (uint i = 0; i < Count; i++)
				ammoItem.MaxAmount += defs.BackpackAmount;
		}
	}
}
