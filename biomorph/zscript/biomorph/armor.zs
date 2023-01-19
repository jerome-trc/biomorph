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
		KVLR EFGHGF 6;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		let armor = BasicArmor(self.owner.FindInventory('BasicArmor'));
		let spct = Clamp(self.savePercent, 0.0, 100.0) / 100.0;

		// No null check here. I'd prefer to catch VM aborts early in testing

		if (armor.SavePercent < spct)
		{
			armor.armorType = self.GetClassName();
			armor.icon = self.icon;
			armor.maxAbsorb = self.maxAbsorb;
			armor.maxFullAbsorb = self.maxFullAbsorb;
			armor.savePercent = spct;
			armor.actualSaveAmount = self.maxSaveAmount;
		}

		if (armor.amount < self.maxSaveAmount)
		{
			armor.maxAmount = Max(armor.MaxAmount, self.maxSaveAmount);
			armor.amount++;
			return true;
		}

		if (self.bCountItem)
		{
			if (self.pickupFlash != null)
				Actor.Spawn(self.pickupFlash, self.pos, ALLOW_REPLACE);

			self.MarkAsCollected(self.owner);
		}

		return false;
	}
}

mixin class BIO_Armor
{
	final override bool Use(bool pickup)
	{
		let armor = BasicArmor(self.owner.FindInventory('BasicArmor'));
		let spct = Clamp(self.savePercent, 0.0, 100.0) / 100.0;
		int defSaveAmount = 0;
		class<BasicArmorPickup> armor_t = armor.ArmorType;

		if (armor_t != null)
		{
			let defs = GetDefaultByType((class<BasicArmorPickup>)(armor.ArmorType));
			defSaveAmount = defs.SaveAmount;
		}
		else if ((class<Armor>)(armor.ArmorType) is 'BasicArmorBonus')
		{
			defSaveAmount = 100;
		}

		if (armor.SavePercent >= spct && armor.Amount < defSaveAmount)
		{
			let missing = armor.MaxAmount - armor.Amount;

			if (missing <= 0)
				return false;

			int change = 0;

			if (armor.SavePercent ~== spct)
			{
				change = Min(missing, self.saveAmount);
				self.saveAmount -= change;
			}
			else
			{
				change = Min(missing, int(float(self.saveAmount) / 2.0));
				self.saveAmount -= change * 2;
			}

			if (self.bIgnoreSkill)
				armor.Amount += change;
			else
				armor.Amount += int(change * G_SkillPropertyFloat(SKILLP_ArmorFactor));

			if (self.saveAmount <= 0)
				return true;
			else
				self.OnPartialPickup(Owner);
		}
		else if (armor.SavePercent < spct)
		{
			armor.SavePercent = spct;
			armor.Amount = self.saveAmount + armor.BonusCount;
			armor.MaxAmount = self.saveAmount;
			armor.Icon = self.icon;
			armor.MaxAbsorb = self.maxAbsorb;
			armor.MaxFullAbsorb = self.maxFullAbsorb;
			// (Rat) Why isn't this variable of type `class<T>`...?
			armor.ArmorType = self.GetClassName();
			armor.ActualSaveAmount = self.saveAmount;
			return true;
		}

		if (self.bCountItem)
			self.MarkAsCollected(Owner);

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

	States
	{
	Spawn:
		KVLR A 6;
		KVLR B 6 Bright;
		Loop;
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

	States
	{
	Spawn:
		KVLR C 6;
		KVLR D 6 Bright;
		Loop;
	}
}
