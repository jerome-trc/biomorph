class BIO_WMod_Damage : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];
			let dmg = DamageIncrease(ppl.AsConst());
			ppl.AddToAllDamageValues(dmg);
		}
	}

	private static int DamageIncrease(readOnly<BIO_WeaponPipeline> ppl)
	{
		return Max(0, int(Floor(float(ppl.GetMinDamage()) * 0.2)));
	}

	final override bool AllowMultiple() const
	{
		return true;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_DAMAGE_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_DAMAGE_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let dmg = DamageIncrease(weap.Pipelines[i].AsConst());

			if (dmg == 0)
				continue;

			let qual = weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_DAMAGE_DESC"),
					qual.Length() > 0 ? " " .. qual : "",
					dmg
				)
			);
		}
	}
}

// LegenDoom(Lite) exclusive. 400% damage to Legendary enemies.
class BIO_WMod_DemonSlayer : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			weap.Pipelines[i].HitDamageFunctors.Push(new('BIO_HDF_DemonSlayer'));
	}

	final override bool CanGenerate() const
	{
		return BIO_Utils.LegenDoom();
	}

	final override bool AllowMultiple() const
	{
		return true;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_DEMONSLAYER_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_DEMONSLAYER_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> _) const
	{
		strings.Push("$BIO_WMOD_DEMONSLAYER_SUMM");
	}
}

class BIO_HDF_DemonSlayer : BIO_HitDamageFunctor
{
	final override void InvokeSlow(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null) return;

		if (BIO_Utils.TryFindInv(target, "LDLegendaryMonsterToken"))
		{
			damage *= 4;
			proj.DamageType = 'DemonSlayer';
			proj.DamageMultiply = 4.0;
		}
	}

	final override void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null) return;

		if (BIO_Utils.TryFindInv(target, "LDLegendaryMonsterToken"))
		{
			damage *= 4;
			proj.DamageType = 'DemonSlayer';
			proj.DamageMultiply = 4.0;
		}
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		if (puff.Tracer == null) return;

		if (BIO_Utils.TryFindInv(puff.Tracer, "LDLegendaryMonsterToken"))
		{
			puff.Tracer.DamageMObj(puff, null, puff.Damage * 3, 'DemonSlayer');
			puff.DamageMultiply = 4.0;
		}
	}

	final override BIO_HitDamageFunctor Copy() const
	{
		return new('BIO_HDF_DemonSlayer');
	}

	final override void Summary(in out Array<string> _) const
	{
		// Nothing needed here; the affix to-string tells all
	}
}
