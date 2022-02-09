mixin class BIO_Powerup
{
	final override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);
		let bioPlayer = BIO_Player(other);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupAttach(self);
	}

	final override void DetachFromOwner()
	{
		super.DetachFromOwner();
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupDetach(self);
	}
}

// This subclass only exists so that `TakeInventory()` is guaranteed to only
// remove items of exactly this class and no other `PowerupGiver` items.
class BIO_PowerupGiver : PowerupGiver {}

// Berserk =====================================================================

class BIO_Berserk : Berserk replaces Berserk
{
	States
	{
	Pickup:
		TNT1 A 0;
		Stop;
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		toucher.GiveBody(100, toucher.GetMaxHealth());

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		
		let bsks = BIO_CVar.BerserkSwitch(bioPlayer.Player);

		if (bsks == BIO_CV_BSKS_MELEE ||
			(bsks == BIO_CV_BSKS_ONLYFIRST &&
			!bioPlayer.FindInventory('PowerStrength', true)))
		{
			bioPlayer.A_SelectWeapon('BIO_Fist');
		}

		bioPlayer.GiveInventory('BIO_PowerStrength', 1);
		bioPlayer.OnPowerupPickup(self);
	}
}

class BIO_PowerStrength : PowerStrength
{
	mixin BIO_Powerup;
}

// Partial invisibility ========================================================

class BIO_BlurSphere : BlurSphere replaces BlurSphere
{
	Default
	{
		Inventory.PickupMessage "$BIO_BLURSPHERE_PKUP";
		Powerup.Type 'BIO_PowerInvisibility';
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupPickup(self);
	}
}

class BIO_PowerInvisibility : PowerInvisibility
{
	mixin BIO_Powerup;

	Default
	{
		Inventory.Icon 'PINSA0';
	}
}

// Light amplification goggles =================================================

class BIO_Infrared : Infrared replaces Infrared
{
	Default
	{
		Inventory.PickupMessage "$BIO_LIGHTAMP_PKUP";
		Powerup.Type 'BIO_PowerLightAmp';
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupPickup(self);
	}
}

class BIO_PowerLightAmp : PowerLightAmp
{
	mixin BIO_Powerup;

	Default
	{
		Inventory.Icon 'PVISA0';
	}
}

// Invulnerability =============================================================

class BIO_Invulnerability : InvulnerabilitySphere replaces InvulnerabilitySphere
{
	Default
	{
		Powerup.Type 'BIO_PowerInvulnerable';
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupPickup(self);
	}

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (BIO_Utils.Eviternity())
			BlendColor = Color(0, 182, 0, 3);
	}
}

class BIO_PowerInvulnerable : PowerInvulnerable
{
	mixin BIO_Powerup;

	Default
	{
		Inventory.Icon 'PINVA0';
	}
}

// Anti-radiation suit =========================================================

class BIO_RadSuit : RadSuit replaces RadSuit
{
	Default
	{
		Inventory.PickupMessage "$BIO_RADSUIT_PKUP";
		Powerup.Type 'BIO_PowerIronFeet';
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupPickup(self);
	}
}

class BIO_PowerIronFeet : PowerIronFeet
{
	mixin BIO_Powerup;

	Default
	{
		Inventory.Icon 'SUITX0';
	}
}

// Miscellaneous ===============================================================

class BIO_Allmap : Allmap replaces Allmap
{
	Default
	{
		Inventory.PickupMessage "$BIO_ALLMAP_PKUP";
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;

		bioPlayer.OnMapPickup(self);
	}
}

// Provides an infinitely-lasting variant of `PowerScanner` for perks.
class BIO_PowerScanner : PowerScanner
{
	Default
	{
		Powerup.Duration -0x7FFFFFFF;
	}
}

class BIO_PowerInfiniteAmmo : PowerInfiniteAmmo
{
	mixin BIO_Powerup;

	Default
	{
		Inventory.Icon 'INAMA0';
		Powerup.Duration 120;
	}
}

class BIO_Megasphere : Megasphere replaces Megasphere
{
	Default
	{
		Inventory.PickupMessage "$BIO_MEGASPHERE_PKUP";
	}

	States
	{
	Pickup:
		TNT1 A 0;
		Stop;
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		toucher.GiveBody(-200);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		
		if (bioPlayer.EquippedArmor != null && bioPlayer.EquippedArmor.Reparable())
		{
			BIO_ArmorBonus.TryRepairArmor(bioPlayer, 0);

			PrintPickupMessage(toucher.CheckLocalView(), String.Format(
				StringTable.Localize("$BIO_MEGASPHERE_ARMORREPAIR"),
				bioPlayer.EquippedArmor.GetTag()));
		}

		bioPlayer.OnPowerupPickup(self);
	}
}
