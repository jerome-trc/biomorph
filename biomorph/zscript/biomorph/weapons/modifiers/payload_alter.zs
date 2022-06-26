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

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		let afx = context.Weap.GetAffixByType('BIO_WAfx_ForcePain');

		return String.Format(
			StringTable.Localize("$BIO_WMOD_FORCEPAIN_DESC"),
			context.NodeCount * FORCEPAIN_MULTI
		);
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_PAYLOAD_ALTER;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ForcePain';
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
}
