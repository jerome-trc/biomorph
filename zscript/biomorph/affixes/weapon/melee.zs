// Comes implicitly with the fist at a 10.0 multiplier, but can generate
// as an explicit affix from mutation with a significantly smaller multiplier.
class BIO_WAfx_BerserkDamage : BIO_WeaponAffix
{
	float Multiplier;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Multiplier = FRandom[BIO_Afx](1.5, 3.5);
	}

	// This can't generate on weapons with implicit berserk damage.
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.HasMeleePipeline() && !weap.HasAffixOfType(GetClass(), true);
	}

	final override void BeforeEachFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		if (fireData.FireType is 'BIO_MeleeHit' &&
			weap.Owner.FindInventory('PowerStrength', true))
			fireData.Damage *= Multiplier;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_BERSERKDMG_TOSTR"),
			BIO_Utils.StatFontColorF(Multiplier, 1.0),
			int(Multiplier * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_BERSERKDMG_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_Lifesteal : BIO_WeaponAffix
{
	Array<float> AddPercents; // One per pipeline (might be 0.0)

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].IsMelee() &&
				weap.Pipelines[i].FireFunctorMutable())
				return true;
		}

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].IsMelee() ||
				!weap.Pipelines[i].FireFunctorMutable())
			{
				AddPercents.Push(0.0);
				continue;
			}

			AddPercents.Push(FRandom[BIO_Afx](0.15, 0.3));
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (AddPercents[i] == 0.0) continue;
			let ff = BIO_FireFunc_Melee(weap.Pipelines[i].GetFireFunctor());
			ff.Lifesteal += AddPercents[i];
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < AddPercents.Size(); i++)
		{
			if (AddPercents[i] ~== 0.0) continue;

			string qual = "";

			if (AddPercents.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_LIFESTEAL_TOSTR"),
				int(AddPercents[i] * 100.0), qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_LIFESTEAL_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_MeleeRange : BIO_WeaponAffix
{
	Array<float> Modifiers; // One per pipeline (0.0 if not applicable)

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].IsMelee() &&
				weap.Pipelines[i].FireFunctorMutable())
				return true;
		}

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].IsMelee() ||
				!weap.Pipelines[i].FireFunctorMutable())
			{
				Modifiers.Push(0.0);
				continue;
			}

			let ff = BIO_FireFunc_Melee(weap.Pipelines[i].GetFireFunctor());
			Modifiers.Push(FRandom[BIO_Afx](ff.Range * 0.25, ff.Range * 0.5));
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;
			let ff = BIO_FireFunc_Melee(weap.Pipelines[i].GetFireFunctor());
			ff.Range += Modifiers[i];
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			string qual = "";
			
			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MELEERANGE_TOSTR"),
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i], qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MELEERANGE_TAG");
	}

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
