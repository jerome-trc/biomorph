class BIO_WMod_BerserkDamage : BIO_WeaponModifier
{
	const DAMAGE_MULTI = 2.5;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].IsMelee() &&
				context.Weap.Pipelines[i].DealsAnyDamage())
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOMELEEDAMAGE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		let afx = weap.GetAffixByType('BIO_WAfx_BerserkDamage');

		if (afx == null)
		{
			afx = new('BIO_WAfx_BerserkDamage');
			weap.Affixes.Push(afx);
		}

		for (uint i = 0; i < context.NodeCount; i++)
			BIO_WAfx_BerserkDamage(afx).Count++;

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		let afx = context.Weap.GetAffixByType('BIO_WAfx_BerserkDamage');

		return String.Format(
			StringTable.Localize("$BIO_WMOD_BERSERKDAMAGE_DESC"),
			context.NodeCount * int(DAMAGE_MULTI * 100)
		);
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_DAMAGE_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_BerserkDamage';
	}
}

class BIO_WAfx_BerserkDamage : BIO_WeaponAffix
{
	uint Count;

	final override void BeforeEachShot(BIO_Weapon weap,
		in out BIO_ShotData shotData)
	{
		if (weap.Owner.FindInventory('PowerStrength', true) == null)
			return;

		if (weap.Pipelines[shotData.Pipeline].IsMelee())
			shotData.Damage *= (BIO_WMod_BerserkDamage.DAMAGE_MULTI * Count);
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WMOD_BERSERKDAMAGE_DESC"),
			Count * int(BIO_WMod_BerserkDamage.DAMAGE_MULTI * 100)
		);
	}
}

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
		return BIO_WMODF_DAMAGE_INC;
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
		return BIO_WMODF_DAMAGE_INC;
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

class BIO_WMod_SplashToHit : BIO_WeaponModifier
{
	// One element per pipeline, always positive
	Array<int> DamageChanges, RadiusChanges;


	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(context.Weap.Pipelines[i].AsConst()))
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_SPLASHTOHIT";
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		return ppl.DealsAnySplashDamage() && ppl.ExportsDamageValues();
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		DamageChanges.Clear(); DamageChanges.Resize(weap.Pipelines.Size());
		RadiusChanges.Clear(); RadiusChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				continue;

			let func = weap.Pipelines[i].GetSplashFunctor();

			let dmg = func.Damage / 2;
			weap.Pipelines[i].AddToAllDamageValues(dmg);
			func.Damage -= dmg;
			DamageChanges[i] += dmg;
			
			let prevRad = func.Radius;
			func.Radius /= 2;
			RadiusChanges[i] += (prevRad - func.Radius);
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < DamageChanges.Size(); i++)
		{
			if (DamageChanges[i] == 0)
				continue;

			let qual = context.Weap.Pipelines[i].GetTagAsQualifier();

			if (qual.Length() > 1)
				qual = " " .. qual;

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPLASHTOHIT_DESC"),
				DamageChanges[i], RadiusChanges[i], qual
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return
			BIO_WMODF_DAMAGE_INC |
			BIO_WMODF_SPLASHDAMAGE_DEC | BIO_WMODF_SPLASHRADIUS_DEC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SplashToHit';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_SplashToHit');
		ret.DamageChanges.Copy(DamageChanges);
		ret.RadiusChanges.Copy(RadiusChanges);
		return ret;
	}
}