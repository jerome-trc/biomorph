mixin class BIO_Powerup
{
	override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);
		let bioPlayer = BIO_Player(other);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupAttach(self);
	}

	override void DetachFromOwner()
	{
		super.DetachFromOwner();
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupDetach(self);
	}
}

// Berserk =====================================================================

class BIO_Berserk : Berserk replaces Berserk
{
	States
	{
	Pickup:
		TNT1 A 0;
		Stop;
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		HealThing(100, 0);

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
		Powerup.Type 'BIO_PowerInvisibility';
	}

	override void DoPickupSpecial(Actor toucher)
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
}

// Light amplification goggles =================================================

class BIO_Infrared : Infrared replaces Infrared
{
	Default
	{
		Powerup.Type 'BIO_PowerLightAmp';
	}

	override void DoPickupSpecial(Actor toucher)
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
}

// Invulnerability =============================================================

class BIO_Invulnerability : InvulnerabilitySphere replaces InvulnerabilitySphere
{
	Default
	{
		Powerup.Type 'BIO_PowerInvulnerable';
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupPickup(self);
	}
}

class BIO_PowerInvulnerable : PowerInvulnerable
{
	mixin BIO_Powerup;
}

// Anti-radiation suit =========================================================

class BIO_RadSuit : RadSuit replaces RadSuit
{
	Default
	{
		Powerup.Type 'BIO_PowerIronFeet';
	}

	override void DoPickupSpecial(Actor toucher)
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
}

// Miscellaneous ===============================================================

class BIO_Allmap : Allmap replaces Allmap
{
	override void DoPickupSpecial(Actor toucher)
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

class BIO_Megasphere : Megasphere replaces Megasphere
{
	States
	{
	Pickup:
		TNT1 A 0;
		Stop;
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		toucher.GiveBody(-200);

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return;
		
		if (bioPlayer.EquippedArmor != null && bioPlayer.EquippedArmor.Reparable())
		{
			let armor = BasicArmor(bioPlayer.FindInventory('BasicArmor'));
			armor.Amount = armor.MaxAmount;
			PrintPickupMessage(toucher.CheckLocalView(), String.Format(
				StringTable.Localize("$BIO_MEGASPHERE_ARMORREPAIR"),
				bioPlayer.EquippedArmor.GetTag()));
		}

		bioPlayer.OnPowerupPickup(self);
	}
}
