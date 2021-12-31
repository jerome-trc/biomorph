class BIO_WAfx_Spread : BIO_WeaponAffix
{
	Array<float> HorizModifiers, VertModifiers;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].SpreadMutable() ||
				!weap.Pipelines[i].NonTrivialSpread())
			{
				HorizModifiers.Push(0.0);
				VertModifiers.Push(0.0);	
			}
			else
			{
				float hSpread = 0.0, vSpread = 0.0;
				[hSpread, vSpread] = weap.Pipelines[i].GetSpread();
				HorizModifiers.Push(-FRandom[BIO_Afx](
					Min(0.1, hSpread), hSpread));
				VertModifiers.Push(-FRandom[BIO_Afx](
					Min(0.1, vSpread), vSpread));
			}
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].SpreadMutable() &&
				weap.Pipelines[i].NonTrivialSpread())
				return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (HorizModifiers[i] == 0.0 && VertModifiers[i] == 0.0)
				continue;

			weap.Pipelines[i].SetSpread(
				weap.Pipelines[i].GetHSpread() + HorizModifiers[i],
				weap.Pipelines[i].GetVSpread() + VertModifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < HorizModifiers.Size(); i++)
		{
			if (HorizModifiers[i] == 0.0 && VertModifiers[i] == 0.0)
				continue;
			
			string qual = "";

			if (HorizModifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			if (HorizModifiers[i] != 0.0)
			{
				strings.Push(String.Format(
					StringTable.Localize("$BIO_WAFX_SPREAD_TOSTR_H"), qual,
					BIO_Utils.StatFontColorF(HorizModifiers[i], 0.0, true),
					HorizModifiers[i] > 0.0 ? "+" : "", HorizModifiers[i]));
			}

			if (VertModifiers[i] != 0.0)
			{
				strings.Push(String.Format(
					StringTable.Localize("$BIO_WAFX_SPREAD_TOSTR_V"), qual,
					BIO_Utils.StatFontColorF(VertModifiers[i], 0.0, true),
					VertModifiers[i] > 0.0 ? "+" : "", VertModifiers[i]));
			}
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPREAD_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_SPREAD;
	}
}

class BIO_WAfx_SwitchSpeed : BIO_WeaponAffix
{
	int Modifier;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Modifier = Random[BIO_Afx](5, 9);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return
			!(weap.AffixMask & BIO_WAM_LOWERSPEED) ||
			!(weap.AffixMask & BIO_WAM_RAISESPEED);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask & BIO_WAM_LOWERSPEED))
			weap.LowerSpeed += Modifier;
		if (!(weap.AffixMask & BIO_WAM_RAISESPEED))
			weap.RaiseSpeed += Modifier;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		if (!(weap.AffixMask & BIO_WAM_LOWERSPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TOSTR_LOWER"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.LowerSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));	
		}

		if (!(weap.AffixMask & BIO_WAM_RAISESPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TOSTR_RAISE"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.RaiseSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_Kickback : BIO_WeaponAffix
{
	int Modifier;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Modifier = Random[BIO_Afx](200, 400);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return !(weap.AffixMask & BIO_WAM_KICKBACK);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		weap.Kickback += Modifier;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_KICKBACK_TOSTR"),
			Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			(float(Modifier) / float(weap.Kickback)) * 100.0,
			StringTable.Localize(Modifier > 0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_KICKBACK_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
