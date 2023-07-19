/// This subclass only exists so that `TakeInventory()` is guaranteed to only
/// remove items of exactly this class and no other `PowerupGiver` items.
class BIOM_PowerupGiver : PowerupGiver {}

class BIOM_Berserk : Health replaces Berserk
{
	mixin BIOM_Pickup;
	mixin BIOM_Health;

	Default
	{
		+COUNTITEM

		Tag "$BIOM_BERSERK_TAG";
		Inventory.Amount 100;
		Inventory.MaxAmount 100;
		Inventory.PickupMessage "$BIOM_BERSERK_PKUP";
		Inventory.PickupSound "misc/p_pkup";
		Health.LowMessage 25, "$BIOM_BERSERK_PKUPLOW";
		BIOM_Berserk.CollectedMessage "$BIOM_BERSERK_COLLECTED";
		BIOM_Berserk.PartialPickupMessage "$BIOM_BERSERK_PARTIAL";
	}

	States
	{
	Spawn:
		RKIT A -1;
		Stop;
	}
}

class BIOM_BlurSphere : BlurSphere replaces BlurSphere
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_BLURSPHERE_TAG";
		Inventory.PickupMessage "$BIOM_BLURSPHERE_PKUP";
		Powerup.Type 'BIOM_PowerInvisibility';
	}
}

class BIOM_Megasphere : Megasphere replaces Megasphere
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_MEGASPHERE_TAG";
		Inventory.PickupMessage "$BIOM_MEGASPHERE_PKUP";
	}
}

class BIOM_InvulnSphere : InvulnerabilitySphere replaces InvulnerabilitySphere
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_INVULNSPHERE_TAG";
		Inventory.PickupMessage "$BIOM_INVULNSPHERE_PKUP";
		Powerup.Type 'BIOM_PowerInvulnerable';
	}

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (BIOM_Utils.Eviternity())
			BlendColor = Color(0, 182, 0, 3);
	}
}

class BIOM_RadSuit : RadSuit replaces RadSuit
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_RADSUIT_TAG";
		Inventory.PickupMessage "$BIOM_RADSUIT_PKUP";
		Powerup.Type 'BIOM_PowerIronFeet';
	}

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 {
			switch (RandomPick[biom_RadSuitState](0, 1, 2, 3, 4))
			{
			case 0:
				return ResolveState('Spawn.A');
			case 1:
				return ResolveState('Spawn.D');
			case 2:
				return ResolveState('Spawn.C');
			case 3:
				return ResolveState('Spawn.D');
			case 4:
				return ResolveState('Spawn.E');
			default:
				Biomorph.Unreachable();
				return ResolveState('Null');
			}
		}
		Stop;
	Spawn.A:
		CBRN A -1;
		Stop;
	Spawn.B:
		CBRN B -1;
		Stop;
	Spawn.C:
		CBRN C -1;
		Stop;
	Spawn.D:
		CBRN D -1;
		Stop;
	Spawn.E:
		CBRN E -1;
		Stop;
	}
}

class BIOM_Infrared : Infrared replaces Infrared
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_INFRARED_TAG";
		Inventory.PickupMessage "$BIOM_INFRARED_PKUP";
		Powerup.Type 'BIOM_PowerLightAmp';
	}
}

class BIOM_Allmap : Allmap replaces Allmap
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_ALLMAP_TAG";
		Inventory.PickupMessage "$BIOM_ALLMAP_PKUP";
	}
}

// Powerup replacements ////////////////////////////////////////////////////////

class BIOM_PowerInfiniteAmmo : PowerInfiniteAmmo
{
	Default
	{
		Inventory.Icon "graphics/powup_infiniteammo.png";
		Powerup.Duration 120;
	}
}

class BIOM_PowerInvisibility : PowerInvisibility
{
	Default
	{
		Inventory.Icon 'PINSA0';
	}
}

class BIOM_PowerInvulnerable : PowerInvulnerable
{
	Default
	{
		Inventory.Icon 'PINVA0';
	}
}

class BIOM_PowerIronFeet : PowerIronFeet
{
	Default
	{
		Inventory.Icon "graphics/powup_radsuit.png";
	}
}

class BIOM_PowerLightAmp : PowerLightAmp
{
	Default
	{
		Inventory.Icon 'PVISA0';
	}
}

/// Provides an infinitely-lasting variant of `PowerScanner`.
class BIOM_PowerScanner : PowerScanner
{
	Default
	{
		Powerup.Duration -0x7FFFFFFF;
	}
}
