class BIO_WMod_DamageAdd : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap, uint _) const
	{
		return weap.DealsAnyDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override void Apply(BIO_Weapon weap, uint count) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];
			let dmg = DamageIncrease(ppl.AsConst());

			for (uint i = 0; i < count; i++)
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

	final override BIO_WeapModRepeatRules RepeatRules() const
	{
		return BIO_WMODREPEATRULES_INTERNAL;
	}

	final override string GetTag() const
	{
		return "$BIO_WMOD_DAMAGEADD_TAG";
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_WMOD_DAMAGEADD_SUMM");
	}

	final override void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap, uint count) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let dmg = DamageIncrease(weap.Pipelines[i].AsConst());

			if (dmg == 0)
				continue;

			let qual = weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(
				String.Format(
					StringTable.Localize("$BIO_WMOD_DAMAGEADD_DESC"),
					qual.Length() > 0 ? " " .. qual : "",
					dmg * count
				)
			);
		}
	}
}

// LegenDoom(Lite) exclusive. 400% damage to Legendary enemies.
class BIO_WMod_DemonSlayer : BIO_WeaponModifier
{
	final override bool, string Compatible(readOnly<BIO_Weapon> weap, uint _) const
	{
		return weap.DealsAnyDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override void Apply(BIO_Weapon weap, uint _) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let func = weap.Pipelines[i].GetHitDamageFunctor('BIO_HDF_DemonSlayer');

			if (func != null)
			{
				BIO_HDF_DemonSlayer(func).Count++;
			}	
			else
			{
				func = new('BIO_HDF_DemonSlayer');
				BIO_HDF_DemonSlayer(func).Count = 1;
				weap.Pipelines[i].HitDamageFunctors.Push(func);
			}
		}
	}

	final override bool CanGenerate() const
	{
		return BIO_Utils.LegenDoom();
	}

	final override bool AllowMultiple() const
	{
		return true;
	}

	final override BIO_WeapModRepeatRules RepeatRules() const
	{
		return BIO_WMODREPEATRULES_EXTERNAL;
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
		readOnly<BIO_Weapon> _, uint count) const
	{
		strings.Push(
			String.Format(
				StringTable.Localize("$BIO_WMOD_DEMONSLAYER_DESC"),
				400 * count
			)
		);
	}
}

class BIO_HDF_DemonSlayer : BIO_HitDamageFunctor
{
	uint Count;

	final override void InvokeSlow(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null) return;

		if (BIO_Utils.TryFindInv(target, 'LDLegendaryMonsterToken'))
		{
			damage *= (4 * Count);
			proj.DamageType = 'DemonSlayer';
			proj.DamageMultiply = (4.0 * float(Count));
		}
	}

	final override void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null) return;

		if (BIO_Utils.TryFindInv(target, 'LDLegendaryMonsterToken'))
		{
			damage *= (4 * Count);
			proj.DamageType = 'DemonSlayer';
			proj.DamageMultiply = (4.0 * float(Count));
		}
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		if (puff.Tracer == null) return;

		if (BIO_Utils.TryFindInv(puff.Tracer, 'LDLegendaryMonsterToken'))
		{
			int multi = (Count - 1) * 4;
			multi += 3;
			puff.Tracer.DamageMObj(puff, null, puff.Damage * multi, 'DemonSlayer');
			puff.DamageMultiply = (4.0 * float(Count));
		}
	}

	final override BIO_HitDamageFunctor Copy() const
	{
		return new('BIO_HDF_DemonSlayer');
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_HDF_DEMONSLAYER"),
			Count * 400
		));
	}
}
