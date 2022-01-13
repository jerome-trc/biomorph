class BIO_EAfx_SaveAmount : BIO_EquipmentAffix
{
	int Modifier;

	final override void Init(readOnly<BIO_Equipment> equip)
	{
		let armor = BIO_Armor(equip);
		let statDefs = GetDefaultByType(armor.StatClass);
		Modifier = Random(statDefs.SaveAmount * 0.1, statDefs.SaveAmount * 0.2);
	}

	final override void PreArmorApply(BIO_Armor armor,
		in out BIO_ArmorData stats) const
	{
		stats.SaveAmount += Modifier;
	}

	final override bool Compatible(readOnly<BIO_Equipment> equip) const
	{
		return equip.GetClass() is 'BIO_Armor';
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Equipment> equip) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_EAFX_SAVEAMOUNT_TOSTR"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "", Modifier));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_EAFX_SAVEAMOUNT_TAG");
	}
}

class BIO_EAfx_SavePercent : BIO_EquipmentAffix
{
	int Modifier;

	final override void Init(readOnly<BIO_Equipment> equip)
	{
		let armor = BIO_Armor(equip);
		let statDefs = GetDefaultByType(armor.StatClass);
		Modifier = Random(statDefs.SavePercent * 0.1, statDefs.SavePercent * 0.2);
	}

	final override void PreArmorApply(BIO_Armor armor,
		in out BIO_ArmorData stats) const
	{
		stats.SavePercent += Modifier;
	}

	final override bool Compatible(readOnly<BIO_Equipment> equip) const
	{
		let armor = BIO_Armor(equip);
		if (armor == null) return false;
		let statDefs = GetDefaultByType(armor.StatClass);
		return statDefs.SavePercent < 100;		
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Equipment> equip) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_EAFX_SAVEPERCENT_TOSTR"),
			Modifier >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Modifier >= 0 ? "+" : "", Modifier));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_EAFX_SAVEPERCENT_TAG");
	}
}
