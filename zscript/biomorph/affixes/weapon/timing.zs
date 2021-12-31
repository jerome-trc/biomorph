class BIO_WAfx_FireTime : BIO_WeaponAffix
{
	// One per state time group. Negative number = faster firing
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FireTimesMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.FireTimeGroups.Size(); i++)
		{
			int poss = weap.FireTimeGroups[i].PossibleReduction();

			if (poss < 1)
				Modifiers.Push(0);
			else
				Modifiers.Push(-Random[BIO_Afx](1, poss));
		}
	}

	final override void Apply(BIO_Weapon weap)
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;
			weap.ModifyFireTime(i, Modifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			let grpTag = StringTable.Localize(weap.FireTimeGroups[i].Tag);
			if (grpTag.Length() > 1)
				grpTag = " (" .. grpTag .. ") ";

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRETIME_TOSTR"), grpTag,
				BIO_Utils.StatFontColor(Modifiers[i], 0, true),
				Modifiers[i] >= 0 ? "+" : "", float(Modifiers[i]) / 35.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FIRETIME_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRETIME;
	}
}

class BIO_WAfx_ReloadTime : BIO_WeaponAffix
{
	// One per state time group. Negative number = faster reloading
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.ReloadTimesMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
		{
			int poss = weap.ReloadTimeGroups[i].PossibleReduction();

			if (poss < 1)
				Modifiers.Push(0);
			else
				Modifiers.Push(-Random[BIO_Afx](1, poss));
		}
	}

	final override void Apply(BIO_Weapon weap)
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;
			weap.ModifyReloadTime(i, Modifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			let grpTag = StringTable.Localize(weap.ReloadTimeGroups[i].Tag);
			if (grpTag.Length() > 1)
				grpTag = " (" .. grpTag .. ") ";

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_RELOADTIME_TOSTR"), grpTag,
				BIO_Utils.StatFontColor(Modifiers[i], 0, true),
				Modifiers[i] >= 0 ? "+" : "", float(Modifiers[i]) / 35.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_RELOADTIME_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_RELOADTIME;
	}
}
