// Weapons with Shotgun spread or more gain fire count with no strings attached.
class BIO_WAfx_HighSpreadFireCount : BIO_WeaponAffix
{
	Array<uint> Modifiers;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
			{
				Modifiers.Push(0);
				continue;
			}

			uint b = weap.Pipelines[i].GetFireCount(), m = 0;
			
			switch (b)
			{
			case 1:
			case 2:
				m = 1;
				break;
			case 3:
			case 4:
				m = Random[BIO_Afx](1, 2);
				break;
			default:
				m = Ceil(float(b) * FRandom[BIO_Afx](0.33, 0.55));
				break;
			}

			Modifiers.Push(m);
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;

		return false;
	}
	
	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		if (!ppl.FireCountMutable())
			return false;

		if (ppl.IsMelee())
			return false;

		if (ppl.GetCombinedSpread() >= 5.99)
			return true;
		else
			return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
			weap.Pipelines[i].ModifyFireCount(Modifiers[i]);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			string qual = "";

			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			Class<Actor> ft = weap.Pipelines[i].GetFireType();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_HIGHSPREADFIRECOUNT_TOSTR"),
				BIO_Utils.StatFontColor(Modifiers[i], 0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i],
				BIO_FireFunctor.FireTypeTag(ft, Modifiers[i]), qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_HIGHSPREADFIRECOUNT_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRECOUNT;
	}
}

// Weapons with much less spread than the Shotgun gain fire count but also spread.
class BIO_WAfx_LowSpreadFireCount : BIO_WeaponAffix
{
	Array<uint> Modifiers;
	Array<float> Spreads;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
			{
				Modifiers.Push(0);
				Spreads.Push(0.0);
				continue;
			}

			uint b = weap.Pipelines[i].GetFireCount(), m = 0;
			
			switch (b)
			{
			case 1:
			case 2:
				m = 1;
				break;
			case 3:
			case 4:
				m = Random[BIO_Afx](1, 2);
				break;
			default:
				m = Ceil(float(b) * FRandom[BIO_Afx](0.33, 0.55));
				break;
			}

			Modifiers.Push(m);
			Spreads.Push(FRandom[BIO_Afx](1.6, 2.4));
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;

		return false;
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		if (!ppl.FireCountMutable())
			return false;

		if (!ppl.SpreadMutable())
			return false;

		if (ppl.IsMelee())
			return false;

		if (ppl.GetCombinedSpread() < 5.0)
			return true;
		else
			return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			weap.Pipelines[i].ModifyFireCount(Modifiers[i]);
			weap.Pipelines[i].ModifySpread(Spreads[i], Spreads[i]);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			string qual = "";

			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			Class<Actor> ft = weap.Pipelines[i].GetFireType();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_LOWSPREADFIRECOUNT_TOSTR"),
				BIO_Utils.StatFontColor(Modifiers[i], 0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i],
				BIO_FireFunctor.FireTypeTag(ft, Modifiers[i]), Spreads[i], qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_LOWSPREADFIRECOUNT_TAG");
	}

	// Low priority so as not to clobber `WAfx_Slug` effects and the like
	final override int OrderPriority() const { return -256; }

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRECOUNT | BIO_WAF_SPREAD;
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

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_Spread : BIO_WeaponAffix
{
	Array<float> HorizModifiers, VertModifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;
		}

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
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

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		if (!ppl.SpreadMutable())
			return false;

		if (!ppl.NonTrivialSpread())
			return false;

		if (ppl.IsMelee())
			return false;

		return true;
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

	final override int OrderPriority() const { return -512; }

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

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
		Modifier = Random[BIO_Afx](10, 18);
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

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
