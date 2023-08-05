// Actor classes helping for developing, testing, and troubleshooting.

/// When added to one's inventory, has the same effect as touching an infinite
/// number of every kind of weapon pickup at once. Note, however, that it does not
/// set the pawn's found-weapon flags.
class biom_Arsenal : Inventory
{
	override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);
		Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Giving you your whole arsenal.");

		let pawn = biom_Player(other);

		if (pawn == null)
			return;

		let pdat = pawn.GetData();

		for (int i = 0; i < pdat.weapons.Size(); ++i)
		{
			if (pdat.weapons[i] is 'biom_Unarmed')
				continue;

			let defs = GetDefaultByType(pdat.weapons[i]);

			if (pawn.FindInventory(pdat.weapons[i]) != null)
				continue;

			pawn.GiveInventory(pdat.weapons[i], 1);
			defs.PlayPickupSound(other);
			self.PrintPickupMessage(pawn.CheckLocalView(), defs.PickupMessage());
		}
	}
}

/// When added to one's inventory, has the same effect as touching an infinite
/// number of every kind of ammo pickup at once.
class biom_FullAmmo : Inventory
{
	override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);
		Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Giving you full ammo.");

		let pawn = biom_Player(other);

		if (pawn == null)
			return;

		let s3 = pawn.FindInventory('biom_Slot3Ammo');
		s3.amount = s3.maxAmount;
		let s4 = pawn.FindInventory('biom_Slot4Ammo');
		s4.amount = s4.maxAmount;
		let s5 = pawn.FindInventory('biom_Slot5Ammo');
		s5.amount = s5.maxAmount;
		let s67 = pawn.FindInventory('biom_Slot67Ammo');
		s67.amount = s67.maxAmount;
	}
}
