// This subclass only exists so that `TakeInventory()` is guaranteed to only
// remove items of exactly this class and no other `PowerupGiver` items.
class BIO_PowerupGiver : PowerupGiver {}

class BIO_Berserk : Health replaces Berserk
{
	mixin BIO_Pickup;
	mixin BIO_Health;

	Default
	{
		+COUNTITEM

		Tag "$BIO_BERSERK_TAG";
		Inventory.Amount 100;
		Inventory.MaxAmount 100;
		Inventory.PickupMessage "$BIO_BERSERK_PKUP";
		Inventory.PickupSound "misc/p_pkup";
		Health.LowMessage 25, "$BIO_BERSERK_PKUPLOW";
		BIO_Berserk.CollectedMessage "$BIO_BERSERK_COLLECTED";
		BIO_Berserk.PartialPickupMessage "$BIO_BERSERK_PARTIAL";
	}

	States
	{
	Spawn:
		PSTR A -1 Bright;
		Stop;
	}
}

class BIO_BlurSphere : BlurSphere replaces BlurSphere
{
	Default
	{
		+DONTGIB
		Tag "$BIO_BLURSPHERE_TAG";
		Inventory.PickupMessage "$BIO_BLURSPHERE_PKUP";
		Powerup.Type 'BIO_PowerInvisibility';
	}
}

class BIO_Megasphere : Megasphere replaces Megasphere
{
	Default
	{
		+DONTGIB
		Tag "$BIO_MEGASPHERE_TAG";
		Inventory.PickupMessage "$BIO_MEGASPHERE_PKUP";
	}
}

class BIO_InvulnSphere : InvulnerabilitySphere replaces InvulnerabilitySphere
{
	Default
	{
		+DONTGIB
		Tag "$BIO_INVULNSPHERE_TAG";
		Inventory.PickupMessage "$BIO_INVULNSPHERE_PKUP";
		Powerup.Type 'BIO_PowerInvulnerable';
	}

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (BIO_Utils.Eviternity())
			BlendColor = Color(0, 182, 0, 3);
	}
}

class BIO_RadSuit : RadSuit replaces RadSuit
{
	Default
	{
		+DONTGIB
		Tag "$BIO_RADSUIT_TAG";
		Inventory.PickupMessage "$BIO_RADSUIT_PKUP";
		Powerup.Type 'BIO_PowerIronFeet';
	}
}

class BIO_Infrared : Infrared replaces Infrared
{
	Default
	{
		+DONTGIB
		Tag "$BIO_INFRARED_TAG";
		Inventory.PickupMessage "$BIO_INFRARED_PKUP";
		Powerup.Type 'BIO_PowerLightAmp';
	}
}

class BIO_Allmap : Allmap replaces Allmap
{
	Default
	{
		+DONTGIB
		Tag "$BIO_ALLMAP_TAG";
		Inventory.PickupMessage "$BIO_ALLMAP_PKUP";
	}
}

// Powerup replacements ////////////////////////////////////////////////////////

class BIO_PowerInfiniteAmmo : PowerInfiniteAmmo
{
	Default
	{
		Inventory.Icon "graphics/powup_infiniteammo.png";
		Powerup.Duration 120;
	}
}

class BIO_PowerInvisibility : PowerInvisibility
{
	Default
	{
		Inventory.Icon 'PINSA0';
	}
}

class BIO_PowerInvulnerable : PowerInvulnerable
{
	Default
	{
		Inventory.Icon 'PINVA0';
	}
}

class BIO_PowerIronFeet : PowerIronFeet
{
	Default
	{
		Inventory.Icon "graphics/powup_radsuit.png";
	}
}

class BIO_PowerLightAmp : PowerLightAmp
{
	Default
	{
		Inventory.Icon 'PVISA0';
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
