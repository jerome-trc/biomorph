enum BIO_WeaponAffixFlags : uint16
{
	BIO_WAF_NONE = 0,
	BIO_WAF_FIREFUNC = 1 << 0,
	BIO_WAF_FIRETYPE = 1 << 1,
	BIO_WAF_FIRECOUNT = 1 << 2,
	BIO_WAF_DAMAGE = 1 << 3,
	BIO_WAF_ACCURACY = 1 << 4,
	BIO_WAF_FIRETIME = 1 << 5,
	BIO_WAF_RELOADTIME = 1 << 6,
	BIO_WAF_MAGSIZE = 1 << 7,
	BIO_WAF_ALERT = 1 << 8,
	BIO_WAF_ALL = uint16.MAX
}

class BIO_WAfx_Damage : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0
	Array<int> Modifiers;

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DamageMutable();
	}

	override void Init(BIO_Weapon weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DamageMutable())
			{
				Modifiers.Push(0);
				continue;
			}

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);
			
			if (vals.Size() < 1)
			{
				Modifiers.Push(0);
				continue;
			}

			Modifiers.Push(Random(vals[0] / 2, vals[0] * 2));
		}
	}

	override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				vals[j] += Modifiers[i];
			
			weap.Pipelines[i].SetDamageValues(vals);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_TOSTR_DAMAGE"),
				BIO_Utils.RankString(i, "$BIO_FIRE_MODE"),
				BIO_Utils.StatFontColor(Modifiers[i], 0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i]));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_TAG_DAMAGE");
	}

	override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_DamageMulti : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0.0
	Array<float> Modifiers;

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DamageMutable() && weap.DealsAnyDamage();
	}

	override void Init(BIO_Weapon weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DamageMutable())
			{
				Modifiers.Push(0.0);
				continue;
			}

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);
			if (!weap.Pipelines[i].ExportsDamageValues())
			{
				Modifiers.Push(0.0);
				continue;
			}

			Modifiers.Push(FRandom(0.25, 0.75));
		}
	}

	override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				vals[j] *= (1.0 + Modifiers[i]);
			
			weap.Pipelines[i].SetDamageValues(vals);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_TOSTR_DMGMULTI"),
				BIO_Utils.RankString(i, "$BIO_FIRE_MODE"),
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i] * 100.0));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_TAG_DMGMULTI");
	}

	override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}
