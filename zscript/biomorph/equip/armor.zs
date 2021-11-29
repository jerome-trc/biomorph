class BIO_ArmorBonus : Inventory replaces ArmorBonus
{
	Default
	{
		-COUNTITEM
		+INVENTORY.AUTOACTIVATE

		Height 16;
		Radius 20;
		Tag "$BIO_ARMORBONUS_TAG";

		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
		Inventory.PickupSound "bio/item/armorshard/pkup";
	}

	States
	{
	Spawn:
		ARSD ABCDCB 6;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		// Nothing to repair if the player isn't wearing armor
		if (bioPlayer.EquippedArmor == null) return false;
		if (!bioPlayer.EquippedArmor.Reparable()) return false;

		// Is the currently-equipped armor already in perfect condition?
		let armor = BasicArmor(bioPlayer.FindInventory('BasicArmor'));
		if (armor.Amount >= armor.MaxAmount)
			return false;

		armor.Amount = Min(armor.Amount + 1, armor.MaxAmount);
		PrintPickupMessage(Owner.CheckLocalView(), String.Format(
			StringTable.Localize("$BIO_ARMORBONUS_PICKUP"),
			bioPlayer.EquippedArmor.GetTag()));
		return true;
	}
}

class BIO_StandardArmor : BIO_Armor
{
	Default
	{
		Tag "$BIO_ARMOR_TAG_STD";
		Inventory.Icon 'ARM1A0';
		Inventory.PickupMessage "$BIO_PKUP_TEMPLATE_ARMORDEFAULT";
		BIO_Equipment.Grade BIO_GRADE_STANDARD;
		BIO_Armor.StatClass "BIO_StandardArmorStats";
	}

	States
	{
	Spawn:
		ARM1 A 6;
		ARM1 B 7 Bright;
		Loop;
	}
}

class BIO_StandardArmorStats : BIO_ArmorStats
{
	Default
	{
		Inventory.Icon "ARM1A0";
		Armor.SavePercent 33.335;
		Armor.SaveAmount 100;
	}
}

class BIO_SpecialtyArmor : BIO_Armor
{
	Default
	{
		Tag "$BIO_ARMOR_TAG_SPEC";
		Inventory.Icon "ARM2A0";
		Inventory.PickupMessage "$BIO_PKUP_TEMPLATE_ARMORDEFAULT";
		BIO_Equipment.Grade BIO_GRADE_SPECIALTY;
		BIO_Armor.StatClass 'BIO_SpecialtyArmorStats';
	}

	States
	{
	Spawn:
		ARM2 A 6;
		ARM2 B 6 Bright;
		Loop;
	}
}

class BIO_SpecialtyArmorStats : BIO_ArmorStats
{
	Default
	{
		Inventory.Icon 'ARM2A0';
		Armor.SavePercent 50;
		Armor.SaveAmount 200;
	}
}

class BIO_ClassifiedArmor : BIO_Armor
{
	Default
	{
		Tag "$BIO_ARMOR_TAG_CLSF";
		Inventory.Icon 'ARM3A0';
		Inventory.PickupMessage "$BIO_PKUP_TEMPLATE_ARMORDEFAULT";
		Inventory.UseSound "bio/armor/classified/use";
		BIO_Equipment.Grade BIO_GRADE_CLASSIFIED;
		BIO_Armor.StatClass 'BIO_ClassifiedArmorStats';
	}

	States
	{
	Spawn:
		ARM3 A 6;
		ARM3 A 6 Bright;
		Loop;
	}
}

class BIO_ClassifiedArmorStats : BIO_ArmorStats
{
	Default
	{
		Inventory.Icon 'ARM3A0';
		Armor.SavePercent 65;
		Armor.SaveAmount 250;
	}
}
