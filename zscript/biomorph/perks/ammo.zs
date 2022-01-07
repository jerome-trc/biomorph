class BIO_Perk_ClipCapacityMinor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Clip').MaxAmount +=
			GetDefaultByType('Clip').BackpackAmount;
	}
}

class BIO_Perk_ShellCapacityMinor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Shell').MaxAmount +=
			GetDefaultByType('Shell').BackpackAmount;
	}
}

class BIO_Perk_RocketAmmoCapacityMinor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('RocketAmmo').MaxAmount +=
			GetDefaultByType('RocketAmmo').BackpackAmount;
	}
}

class BIO_Perk_CellCapacityMinor : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer) const
	{
		bioPlayer.FindInventory('Cell').MaxAmount +=
			GetDefaultByType('Cell').BackpackAmount;
	}
}

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
			ammoItem.MaxAmount += defs.BackpackAmount;
		}
	}
}
