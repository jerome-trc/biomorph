class BIO_ArmorAffix_SaveAmount : BIO_EquipmentAffix
{
	int Modifier;

	final override void Init(BIO_Equipment equip)
	{
		let armor = BIO_Armor(equip);
		let statDefs = GetDefaultByType(armor.StatClass);
		Modifier = Random(statDefs.SaveAmount * 0.1, statDefs.SaveAmount * 0.2);
	}

	final override void PreArmorApply(BIO_Armor armor, BIO_ArmorStats stats) const
	{
		stats.SaveAmount += Modifier;
	}

	final override bool Compatible(BIO_Equipment equip) const
	{
		return equip is 'BIO_Armor';
	}

	final override void ToString(in out Array<string> strings, BIO_Equipment equip) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_EAFX_TOSTR_SAVEAMOUNT"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "", Modifier));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_EAFX_TAG_SAVEAMOUNT");
	}
}

class BIO_ArmorAffix_SavePercent : BIO_EquipmentAffix
{
	int Modifier;

	final override void Init(BIO_Equipment equip)
	{
		let armor = BIO_Armor(equip);
		let statDefs = GetDefaultByType(armor.StatClass);
		Modifier = Random(statDefs.SavePercent * 0.1, statDefs.SavePercent * 0.2);
	}

	final override void PreArmorApply(BIO_Armor armor, BIO_ArmorStats stats) const
	{
		stats.SavePercent += Modifier;
	}

	final override bool Compatible(BIO_Equipment equip) const
	{
		let armor = BIO_Armor(equip);
		if (armor == null) return false;
		let statDefs = GetDefaultByType(armor.StatClass);
		return statDefs.SavePercent < 100;		
	}

	final override void ToString(in out Array<string> strings, BIO_Equipment equip) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_EAFX_TOSTR_SAVEPERCENT"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "", Modifier));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_EAFX_TAG_SAVEPERCENT");
	}
}
