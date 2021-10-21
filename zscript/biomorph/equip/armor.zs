class BIO_StandardArmor : BIO_Armor
{
	Default
	{
		Tag "$BIO_ARMOR_TAG_GREEN";
		Inventory.Icon "ARM1A0";
		Inventory.PickupMessage "$BIO_PICKUP_TEMPLATE_ARMORDEFAULT";
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
		Tag "$BIO_ARMOR_TAG_BLUE";
		Inventory.Icon "ARM2A0";
		Inventory.PickupMessage "$BIO_PICKUP_TEMPLATE_ARMORDEFAULT";
		BIO_Equipment.Grade BIO_GRADE_SPECIALTY;
		BIO_Armor.StatClass "BIO_SpecialtyArmorStats";
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
		Inventory.Icon "ARM2A0";
		Armor.SavePercent 50;
		Armor.SaveAmount 200;
	}
}
