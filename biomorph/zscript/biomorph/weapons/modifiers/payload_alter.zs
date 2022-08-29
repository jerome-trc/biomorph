class BIO_WMod_ForcePain : BIO_WeaponModifier
{
	const FORCEPAIN_MULTI = 20;

	final override bool, string Compatible(BIO_GeneContext _) const
	{
		return true, "";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		let afx = weap.GetAffixByType('BIO_WAfx_ForcePain');

		if (afx == null)
		{
			afx = new('BIO_WAfx_ForcePain');
			weap.Affixes.Push(afx);
		}

		for (uint i = 0; i < context.NodeCount; i++)
			BIO_WAfx_ForcePain(afx).Count++;

		return String.Format(
			StringTable.Localize("$BIO_WMOD_FORCEPAIN_DESC"),
			context.NodeCount * FORCEPAIN_MULTI
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_PAYLOAD_ALTER;
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_FORCEPAIN_SUMM";
	}
}

class BIO_WAfx_ForcePain : BIO_WeaponAffix
{
	uint Count;

	final override void OnSlowProjectileFired(BIO_Weapon _, BIO_Projectile proj)
	{
		if (Random(0, 100) > (BIO_WMod_ForcePain.FORCEPAIN_MULTI * Count))
			return;

		proj.bForcePain = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon _, BIO_FastProjectile proj)
	{
		if (Random(0, 100) > (BIO_WMod_ForcePain.FORCEPAIN_MULTI * Count))
			return;

		proj.bForcePain = true;
	}

	final override void OnPuffFired(BIO_Weapon _, BIO_Puff puff)
	{
		if (Random(0, 100) > (BIO_WMod_ForcePain.FORCEPAIN_MULTI * Count))
			return;

		if (puff.Tracer != null)
			puff.Tracer.TriggerPainChance(puff.DamageType, true);
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WAFX_FORCEPAIN_DESC"),
			Count * BIO_WMod_ForcePain.FORCEPAIN_MULTI
		);
	}

	final override BIO_WeaponAffix Copy() const
	{
		let ret = new('BIO_WAfx_ForcePain');
		ret.Count = Count;
		return ret;
	}
}

class BIO_WMod_ForceRadiusDmg : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.DealsAnySplashDamage(), "$BIO_WMOD_INCOMPAT_NOSPLASH";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		if (!weap.HasAffixOfType('BIO_WAfx_ForceRadiusDmg'))
			weap.Affixes.Push(new('BIO_WAfx_ForceRadiusDmg'));

		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_PAYLOAD_ALTER;
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_FORCERADIUSDMG_SUMM";
	}
}

class BIO_WAfx_ForceRadiusDmg : BIO_WeaponAffix
{
	final override void OnPuffFired(BIO_Weapon _, BIO_Puff puff)
	{
		puff.bForceRadiusDmg = true;
	}

	final override void OnSlowProjectileFired(BIO_Weapon _, BIO_Projectile proj)
	{
		proj.bForceRadiusDmg = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon _, BIO_FastProjectile proj)
	{
		proj.bForceRadiusDmg = true;
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return "$BIO_WMOD_FORCERADIUSDMG_SUMM";
	}

	final override BIO_WeaponAffix Copy() const
	{
		return new('BIO_WAfx_ForceRadiusDmg');
	}
}

class BIO_WMod_ProjGravity : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (context.Sim.HasModifierWithPipelineFlags(BIO_WPMF_GRAVITY_ADD))
			return false, "$BIO_WMOD_INCOMPAT_PROJGRAVITYMOD";

		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (CompatibleWithPipeline(context.Weap.GetPipeline(i).AsConst()))
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_PROJGRAVITY";
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		let defs = GetDefaultByType(ppl.Payload);
		return ppl.Payload is 'BIO_Projectile' && defs.bNoGravity;
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		weap.Affixes.Push(new('BIO_WAfx_ProjGravity'));

		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
		{
			let ppl = context.Weap.GetPipeline(i);
			let compat = CompatibleWithPipeline(ppl.AsConst());

			if (compat)
				ppl.DamageEffects.Push(BIO_DmgFx_Multi.Create(1.2));
		}

		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE,
			BIO_WPMF_PAYLOAD_ALTER |
			BIO_WPMF_BOUNCE_ADD |
			BIO_WPMF_DAMAGE_INC;
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_PROJGRAVITY_SUMM";
	}
}

class BIO_WAfx_ProjGravity : BIO_WeaponAffix
{
	final override void OnSlowProjectileFired(BIO_Weapon _, BIO_Projectile proj)
	{
		proj.bNoGravity = false;
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return GetDefaultByType('BIO_MGene_ProjGravity').Summary();
	}

	final override BIO_WeaponAffix Copy() const
	{
		return new('BIO_Wafx_ProjGravity');
	}
}
