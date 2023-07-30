class biom_ArmorBonus : ArmorBonus replaces ArmorBonus
{
	mixin biom_Pickup;

	Default
	{
		-INVENTORY.ALWAYSPICKUP
		Tag "$BIOM_ARMORBONUS_TAG";
		Inventory.Icon 'KVLRE0';
		Inventory.PickupMessage "$BIOM_ARMORBONUS_PKUP";
		Inventory.PickupSound "biom/armorbonus/pkup";
		biom_ArmorBonus.CollectedMessage "$BIOM_ARMORBONUS_COLLECTED";
	}

	States
	{
	Spawn:
		KVLR EFGHGF 6;
		loop;
	}

	final override bool Use(bool pickup)
	{
		let armor = BasicArmor(self.owner.FindInventory('BasicArmor'));
		let spct = Clamp(self.savePercent, 0.0, 100.0) / 100.0;

		// No null check here. I'd prefer to catch VM aborts early in testing.

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
			armor.maxAmount = Max(armor.maxAmount, self.maxSaveAmount);
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

mixin class biom_Armor
{
	final override bool Use(bool pickup)
	{
		let armor = BasicArmor(self.owner.FindInventory('BasicArmor'));
		let spct = Clamp(self.savePercent, 0.0, 100.0) / 100.0;
		int defSaveAmount = 0;
		class<BasicArmorPickup> armor_t = armor.armorType;

		if (armor_t != null)
		{
			let defs = GetDefaultByType((class<BasicArmorPickup>)(armor.armorType));
			defSaveAmount = defs.saveAmount;
		}
		else if ((class<Armor>)(armor.armorType) is 'BasicArmorBonus')
		{
			defSaveAmount = 100;
		}

		if (armor.savePercent >= spct && armor.amount < defSaveAmount)
		{
			let missing = armor.maxAmount - armor.amount;

			if (missing <= 0)
				return false;

			int change = 0;

			if (armor.savePercent ~== spct)
			{
				change = Min(missing, self.saveAmount);
				self.saveAmount -= change;
			}
			else
			{
				change = Min(missing, int(Ceil((float(self.saveAmount) / 2.0))));
				self.saveAmount -= change * 2;
			}

			if (self.bIgnoreSkill)
				armor.amount += change;
			else
				armor.amount += int(change * G_SkillPropertyFloat(SKILLP_ARMORFACTOR));

			if (self.saveAmount <= 0)
				return true;
			else
				self.OnPartialPickup(self.owner);
		}
		else if (armor.SavePercent < spct)
		{
			if ((class<Armor>)(armor.armorType) != null)
			{
				self.PrintPickupMessage(
					self.owner.CheckLocalView(),
					"$BIOM_DISCARDEDINFERIORARMOR"
				);

				let s = Actor.Spawn('biom_LightArmor', self.owner.pos);
				let discarded = biom_LightArmor(s);

				discarded.amount = armor.amount;
				discarded.saveAmount = armor.amount;
			}

			armor.savePercent = spct;
			armor.amount = self.saveAmount + armor.BonusCount;
			armor.maxAmount = self.saveAmount;
			armor.icon = self.icon;
			armor.maxAbsorb = self.maxAbsorb;
			armor.maxFullAbsorb = self.maxFullAbsorb;
			// (RAT) Why isn't this variable of type `class<T>`...?
			armor.armorType = self.GetClassName();
			armor.actualSaveAmount = self.saveAmount;
			return true;
		}

		if (self.bCountItem)
			self.MarkAsCollected(self.owner);

		return false;
	}

	final override string PickupMessage()
	{
		if (self.saveAmount <= 0)
			return self.partialPickupMessage;
		else
			return self.pickupMsg;
	}
}

class biom_LightArmor : GreenArmor replaces GreenArmor
{
	mixin biom_Pickup;
	mixin biom_Armor;

	Default
	{
		Tag "$BIOM_LIGHTARMOR_TAG";
		Inventory.Icon 'KVLRA0';
		Inventory.PickupMessage "$BIOM_LIGHTARMOR_PKUP";
		biom_LightArmor.PartialPickupMessage "$BIOM_LIGHTARMOR_PARTIAL";
		biom_LightArmor.CollectedMessage "$BIOM_LIGHTARMOR_COLLECTED";
	}

	States
	{
	Spawn:
		KVLR A 6;
		KVLR B 6 Bright;
		loop;
	}
}

class biom_HeavyArmor : BlueArmor replaces BlueArmor
{
	mixin biom_Pickup;
	mixin biom_Armor;

	Default
	{
		Tag "$BIOM_HEAVYARMOR_TAG";
		Inventory.Icon 'KVLRC0';
		Inventory.PickupMessage "$BIOM_HEAVYARMOR_PKUP";
		biom_HeavyArmor.PartialPickupMessage "$BIOM_HEAVYARMOR_PARTIAL";
		biom_HeavyArmor.CollectedMessage "$BIOM_HEAVYARMOR_COLLECTED";
	}

	States
	{
	Spawn:
		KVLR C 6;
		KVLR D 6 Bright;
		loop;
	}
}
