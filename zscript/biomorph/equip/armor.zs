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
		Inventory.PickupSound "pickup/armorshard";
	}

	States
	{
	Spawn:
		ARSD ABCDCB 6;
		Loop;
	}

	override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		// Nothing to repair if the player isn't wearing armor
		if (bioPlayer.EquippedArmor == null) return false;

		// TODO: Armor grade, intrinsic properties, affixes decide if it
		// can be repaired

		// Is the currently-equipped armor already in perfect condition?
		let armor = BasicArmor(bioPlayer.FindInventory("BasicArmor"));
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
		Tag "$BIO_ARMOR_TAG_SPEC";
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

class BIO_ExperimentalArmor : BIO_Armor
{
	Default
	{
		Tag "$BIO_ARMOR_TAG_EXP";
		Inventory.Icon "ARM3A0";
		Inventory.PickupMessage "$BIO_PICKUP_TEMPLATE_ARMORDEFAULT";
		BIO_Equipment.Grade BIO_GRADE_EXPERIMENTAL;
		BIO_Armor.StatClass "BIO_ExperimentalArmorStats";
	}

	States
	{
	Spawn:
		ARM3 A 6;
		ARM3 A 6 Bright;
		Loop;
	}
}

class BIO_ExperimentalArmorStats : BIO_ArmorStats
{
	Default
	{
		Inventory.Icon "ARM3A0";
		Armor.SavePercent 65;
		Armor.SaveAmount 250;
	}
}
