
class BIO_Magazine : Ammo
{
	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.IGNORESKILL

		Inventory.MaxAmount uint16.MAX;
		Inventory.PickupMessage
			"If you see this message, please report a bug to RatCircus.";
	}

	// This class can't be abstract because it would cause a VM abort if the
	// player invoked the `give all` CCMD
	// Why doesn't this command check for abstract classes?
	// I assume there's an underlying technical reason
	// To work around this, just pretend the base class doesn't exist

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (GetClass() == 'BIO_Magazine')
			Destroy();
	}

	final override void AttachToOwner(Actor other)
	{
		if (GetClass() == 'BIO_Magazine')
			return;
		else
			super.AttachToOwner(other);
	}

	final override bool CanPickup(Actor _)
	{
		return GetClass() != 'BIO_Magazine';
	}
}

class BIO_MagazineETM : BIO_Magazine
{
	meta class<BIO_EnergyToMatterPowerup> PowerupType;
	property PowerupType: PowerupType;

	Default
	{
		Inventory.MaxAmount 0;
	}
}

class BIO_EnergyToMatterPowerup : Powerup abstract
{
	meta int CellCost;
	property CellCost: CellCost;

	Default
	{
		+INVENTORY.UNTOSSABLE
		Powerup.Duration -3;
		BIO_EnergyToMatterPowerup.CellCost 5;
	}
}
