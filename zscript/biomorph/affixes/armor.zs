class BIO_ArmorAffix_SaveAmount : BIO_EquipmentAffix
{
	int Modifier;

	override void Init(BIO_Armor armor)
	{
		let statDefs = GetDefaultByType(armor.StatClass);
		Modifier = Random(statDefs.SaveAmount * 0.1, statDefs.SaveAmount * 0.2);
	}

	override void OnArmorEquip(BIO_Armor armor, BIO_ArmorStats stats) const
	{
		stats.SaveAmount += Modifier;
	}

	override bool Compatible(BIO_Armor armor) const { return true; }

	override string ToString() const
	{
		return String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_ARMORSAVEAMOUNT"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "-", Modifier);
	}
}

class BIO_ArmorAffix_SavePercent : BIO_EquipmentAffix
{
	int Modifier;

	override void Init(BIO_Armor armor)
	{
		let statDefs = GetDefaultByType(armor.StatClass);
		Modifier = Random(statDefs.SavePercent * 0.1, statDefs.SavePercent * 0.2);
	}

	override void OnArmorEquip(BIO_Armor armor, BIO_ArmorStats stats) const
	{
		stats.SavePercent += Modifier;
	}

	override bool Compatible(BIO_Armor armor) const
	{
		let statDefs = GetDefaultByType(armor.StatClass);
		return statDefs.SavePercent < 100;		
	}

	override string ToString() const
	{
		return String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_ARMORSAVEPERCENT"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "-", Modifier);
	}
}
