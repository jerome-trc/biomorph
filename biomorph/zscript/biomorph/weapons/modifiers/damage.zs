class BIO_WMod_DamageAdd : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.DealsAnyDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];
			let dmg = DamageIncrease(ppl.AsConst());

			for (uint i = 0; i < context.NodeCount; i++)
				ppl.AddToAllDamageValues(dmg);
		}

		return "";
	}

	private static int DamageIncrease(readOnly<BIO_WeaponPipeline> ppl)
	{
		return Max(0, int(Floor(float(ppl.GetMinDamage()) * 0.2)));
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			let dmg = DamageIncrease(context.Weap.Pipelines[i].AsConst());

			if (dmg == 0)
				continue;

			let qual = context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_DAMAGEADD_DESC"),
				qual.Length() > 0 ? " " .. qual : "",
				dmg * context.NodeCount
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_DAMAGE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_DamageAdd';
	}
}

// LegenDoom(Lite) exclusive. 400% damage to Legendary enemies.
class BIO_WMod_DemonSlayer : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.DealsAnyDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
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

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WMOD_DEMONSLAYER_DESC"),
			400 * context.NodeCount
		);
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_DAMAGE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_DemonSlayer';
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
