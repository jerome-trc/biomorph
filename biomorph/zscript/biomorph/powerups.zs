/// This subclass only exists so that `TakeInventory()` is guaranteed to only
/// remove items of exactly this class and no other `PowerupGiver` items.
class biom_PowerupGiver : PowerupGiver {}

class biom_Berserk : Health replaces Berserk
{
	mixin biom_Pickup;
	mixin biom_Health;

	Default
	{
		+COUNTITEM

		Tag "$BIOM_BERSERK_TAG";
		Inventory.Amount 100;
		Inventory.PickupMessage "$BIOM_BERSERK_PKUP";
		Inventory.PickupSound "misc/p_pkup";
		Health.LowMessage 25, "$BIOM_BERSERK_PKUPLOW";
		biom_Berserk.FoundMessage "$BIOM_BERSERK_FOUND";
		biom_Berserk.PartialPickupMessage "$BIOM_BERSERK_PARTIAL";
	}

	States
	{
	Spawn:
		RKIT A -1;
		stop;
	}
}

class biom_BlurSphere : BlurSphere replaces BlurSphere
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_BLURSPHERE_TAG";
		RenderStyle 'Normal';
		Inventory.PickupMessage "$BIOM_BLURSPHERE_PKUP";
		Powerup.Type 'biom_PowerInvisibility';
	}

	States
	{
	Spawn:
		CAMO ABCD 6 bright;
		loop;
	}
}

class biom_Megasphere : Inventory replaces Megasphere
{
	mixin biom_Pickup;

	Default
	{
		+COUNTITEM
		+DONTGIB
		+INVENTORY.ISARMOR
		+INVENTORY.ISHEALTH

		Tag "$BIOM_MEGASPHERE_TAG";
		Inventory.PickupMessage "$BIOM_MEGASPHERE_PKUP";
		Inventory.PickupSound "misc/p_pkup";
		biom_Megasphere.FoundMessage "$BIOM_MEGASPHERE_FOUND";
	}

	States
	{
	Spawn:
		MKIT ABCD 6 bright light("biom_Megasphere");
		loop;
	}

	final override bool TryPickup(in out Actor other)
	{
		let excess = Actor.Spawn('biom_ExtraMegasphereHealth', self.pos);

		if (excess != null)
		{
			self.PrintPickupMessage(other.CheckLocalView(), "$BIOM_MEGAPSHERE_EXCESS_HEALTH");
			let emh = biom_ExtraMegasphereHealth(excess);

			if (other.player != null)
				emh.amount = other.player.health;
			else
				emh.amount = other.health;
		}

		other.A_GiveInventory('MegasphereHealth', 1);

		let bArmor = BasicArmor(other.FindInventory('BasicArmor'));

		if ((class<Armor>)(bArmor.armorType) is 'biom_HeavyArmor')
		{
			let excess = Actor.Spawn('biom_HeavyArmor', self.pos);
			let ema = biom_HeavyArmor(excess);
			ema.amount = bArmor.amount;
			self.PrintPickupMessage(other.CheckLocalView(), "$BIOM_MEGAPSHERE_EXCESS_ARMOR");
		}
		else
		{
			// TODO: Not using `BlueArmorForMegasphere` might break DeHackEd.
			// Must investigate eventually; need sample data or bug reports.
			other.A_GiveInventory('biom_HeavyArmor', 1);
		}

		self.GoAwayAndDie();
		return true;
	}
}

class biom_ExtraMegasphereHealth : biom_SuperHealth
{
	Default
	{
		-COUNTITEM;
		+INVENTORY.FANCYPICKUPSOUND;

		Tag "$BIOM_EXTRAMEGASPHEREHEALTH_TAG";
		Inventory.Amount int.MIN;
		Inventory.PickupMessage "$BIOM_EXTRAMEGASPHEREHEALTH_PKUP";
		Inventory.PickupSound "misc/p_pkup";
		biom_SuperHealth.PartialPickupMessage "$BIOM_EXTRAMEGASPHEREHEALTH_PARTIAL";
		Health.LowMessage 25, "$BIOM_EXTRAMEGASPHEREHEALTH_PKUPLOW";
	}

	States
	{
	Spawn:
		SOUL ABCDCB 6 bright light("biom_SuperHealth");
		loop;
	}

	/// For ensuring proper initialization.
	final override bool TryPickup(in out Actor other)
	{
		if (self.amount <= 0)
			return false;

		return super.TryPickup(other);
	}
}

class biom_Invuln : InvulnerabilitySphere replaces InvulnerabilitySphere
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_INVULNERABILITY_TAG";
		Inventory.PickupMessage "$BIOM_INVULNERABILITY_PKUP";
		Powerup.Type 'biom_PowerInvulnerable';
	}

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (biom_Utils.Eviternity())
			self.blendColor = Color(0, 182, 0, 3);
	}

	States
	{
	Spawn:
		STYX ABCD 6 bright light("biom_Inulvn");
		loop;
	}
}

class biom_RadSuit : RadSuit replaces RadSuit
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_RADSUIT_TAG";
		Inventory.PickupMessage "$BIOM_RADSUIT_PKUP";
		Powerup.Type 'biom_PowerIronFeet';
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
		stop;
	Spawn.A:
		CBRN A -1;
		stop;
	Spawn.B:
		CBRN B -1;
		stop;
	Spawn.C:
		CBRN C -1;
		stop;
	Spawn.D:
		CBRN D -1;
		stop;
	Spawn.E:
		CBRN E -1;
		stop;
	}
}

class biom_Infrared : Infrared replaces Infrared
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_INFRARED_TAG";
		Inventory.PickupMessage "$BIOM_INFRARED_PKUP";
		Powerup.Type 'biom_PowerLightAmp';
	}

	States
	{
	Spawn:
		PNVG AB 6 bright;
		loop;
	}
}

class biom_Allmap : Allmap replaces Allmap
{
	Default
	{
		+DONTGIB
		Tag "$BIOM_ALLMAP_TAG";
		Inventory.PickupMessage "$BIOM_ALLMAP_PKUP";
	}
}

// Powerup replacements ////////////////////////////////////////////////////////

class biom_PowerInfiniteAmmo : PowerInfiniteAmmo
{
	Default
	{
		Inventory.Icon "graphics/powup_infiniteammo.png";
		Powerup.Duration 120;
	}
}

class biom_PowerInvisibility : PowerInvisibility
{
	Default
	{
		Inventory.Icon 'PINSA0';
		+INVENTORY.ADDITIVETIME
	}
}

class biom_PowerInvulnerable : PowerInvulnerable
{
	Default
	{
		Inventory.Icon 'PINVA0';
		+INVENTORY.ADDITIVETIME
	}
}

class biom_PowerIronFeet : PowerIronFeet
{
	Default
	{
		Inventory.Icon "graphics/powup_radsuit.png";
		+INVENTORY.ADDITIVETIME
	}
}

class biom_PowerLightAmp : PowerLightAmp
{
	Default
	{
		Inventory.Icon 'PVISA0';
		+INVENTORY.ADDITIVETIME
	}
}

/// Provides an infinitely-lasting variant of `PowerScanner`.
class biom_PowerScanner : PowerScanner
{
	Default
	{
		Powerup.Duration -0x7FFFFFFF;
	}
}
