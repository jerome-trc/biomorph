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
			!bioPlayer.FindInventory("PowerStrength", true)))
		{
			bioPlayer.A_SelectWeapon("BIO_Fist");
		}

		bioPlayer.GiveInventory("BIO_PowerStrength", 1);
		bioPlayer.OnPowerupPickup(self);
	}
}

class BIO_PowerStrength : PowerStrength
{
	override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);
		let bioPlayer = BIO_Player(other);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupAttach(self);
	}
}

class BIO_Invulnerability : InvulnerabilitySphere replaces InvulnerabilitySphere
{
	Default
	{
		Powerup.Type "BIO_PowerInvulnerable";
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
	override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);
		let bioPlayer = BIO_Player(other);
		if (bioPlayer == null) return;
		bioPlayer.OnPowerupAttach(self);
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
			let armor = BasicArmor(bioPlayer.FindInventory("BasicArmor"));
			armor.Amount = armor.MaxAmount;
			PrintPickupMessage(toucher.CheckLocalView(), String.Format(
				StringTable.Localize("$BIO_MEGASPHERE_ARMORREPAIR"),
				bioPlayer.EquippedArmor.GetTag()));
		}

		bioPlayer.OnPowerupPickup(self);
	}
}
