class BIO_ArmorBonus : ArmorBonus replaces ArmorBonus
{
	mixin BIO_Pickup;

	Default
	{
		-INVENTORY.ALWAYSPICKUP
		Tag "$BIO_ARMORBONUS_TAG";
		Inventory.PickupMessage "$BIO_ARMORBONUS_PKUP";
		Inventory.PickupSound "bio/armorbonus/pkup";
		BIO_ArmorBonus.CollectedMessage "$BIO_ARMORBONUS_COLLECTED";
	}

	States
	{
	Spawn:
		ARSD ABCDCB 6;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		let armor = BasicArmor(Owner.FindInventory('BasicArmor'));
		let spct = Clamp(SavePercent, 0.0, 100.0) / 100.0;

		if (armor.SavePercent < spct)
			armor.SavePercent = spct;

		// No null check here. I'd prefer to catch VM aborts early in testing

		if (armor.Amount < MaxSaveAmount)
		{
			armor.MaxAmount = Max(armor.MaxAmount, MaxSaveAmount);
			armor.Amount++;
			return true;
		}

		if (bCountItem)
		{
			if (PickupFlash != null)
				Actor.Spawn(PickupFlash, Pos, ALLOW_REPLACE);

			PlayPickupSound(Owner);
			MarkAsCollected(Owner);
		}

		return false;
	}
}

mixin class BIO_Armor
{
	final override bool Use(bool pickup)
	{
		let armor = BasicArmor(Owner.FindInventory('BasicArmor'));
		let spct = Clamp(SavePercent, 0.0, 100.0) / 100.0;
		int defSaveAmount = 0;
		class<BasicArmorPickup> armor_t = armor.ArmorType;

		if (armor_t != null)
		{
			let defs = GetDefaultByType((class<BasicArmorPickup>)(armor.ArmorType));
			defSaveAmount = defs.SaveAmount;
		}

		if (armor.SavePercent >= spct && armor.Amount < defSaveAmount)
		{
			let missing = armor.MaxAmount - armor.Amount;

			if (missing <= 0)
				return false;

			int change = 0;

			if (armor.SavePercent ~== spct)
			{
				change = Min(missing, SaveAmount);
				SaveAmount -= change;
			}
			else
			{
				change = Min(missing, int(float(SaveAmount) / 2.0));
				SaveAmount -= change * 2;
			}

			if (bIgnoreSkill)
				armor.Amount += change;
			else
				armor.Amount += int(change * G_SkillPropertyFloat(SKILLP_ArmorFactor));

			if (SaveAmount <= 0)
				return true;
			else
				OnPartialPickup(Owner);
		}
		else if (armor.SavePercent < spct)
		{
			armor.SavePercent = spct;
			armor.Amount = SaveAmount + armor.BonusCount;
			armor.MaxAmount = SaveAmount;
			armor.Icon = Icon;
			armor.MaxAbsorb = MaxAbsorb;
			armor.MaxFullAbsorb = MaxFullAbsorb;
			// (Rat) Why isn't this variable of type `class<T>`...?
			armor.ArmorType = GetClassName();
			armor.ActualSaveAmount = SaveAmount;
			return true;
		}

		if (bCountItem)
			MarkAsCollected(Owner);

		return false;
	}

	final override string PickupMessage()
	{
		if (SaveAmount <= 0)
			return PartialPickupMessage;
		else
			return PickupMsg;
	}
}

class BIO_LightArmor : GreenArmor replaces GreenArmor
{
	mixin BIO_Pickup;
	mixin BIO_Armor;

	Default
	{
		Tag "$BIO_LIGHTARMOR_TAG";
		Inventory.PickupMessage "$BIO_LIGHTARMOR_PKUP";
		BIO_LightArmor.PartialPickupMessage "$BIO_LIGHTARMOR_PARTIAL";
		BIO_LightArmor.CollectedMessage "$BIO_LIGHTARMOR_COLLECTED";
	}
}

class BIO_HeavyArmor : BlueArmor replaces BlueArmor
{
	mixin BIO_Pickup;
	mixin BIO_Armor;

	Default
	{
		Tag "$BIO_HEAVYARMOR_TAG";
		Inventory.PickupMessage "$BIO_HEAVYARMOR_PKUP";
		BIO_HeavyArmor.PartialPickupMessage "$BIO_HEAVYARMOR_PARTIAL";
		BIO_HeavyArmor.CollectedMessage "$BIO_HEAVYARMOR_COLLECTED";
	}
}
