class BIO_WMod_BerserkDamage : BIO_WeaponModifier
{
	const DAMAGE_MULTI = 2.5;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (context.Weap.GetPipeline(i).IsMelee() &&
				context.Weap.GetPipeline(i).DealsAnyHitDamage())
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

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_DAMAGE_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_BerserkDamage';
	}
}

class BIO_WAfx_BerserkDamage : BIO_WeaponAffix
{
	uint Count;

	final override void BeforeEachShot(
		BIO_Weapon weap,
		in out BIO_ShotData shotData
	)
	{
		if (weap.Owner.FindInventory('PowerStrength', true) == null)
			return;

		if (weap.GetCurPipeline(shotData.Pipeline).IsMelee())
			shotData.Damage *= (BIO_WMod_BerserkDamage.DAMAGE_MULTI * Count);
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WMOD_BERSERKDAMAGE_DESC"),
			Count * int(BIO_WMod_BerserkDamage.DAMAGE_MULTI * 100)
		);
	}

	final override BIO_WeaponAffix Copy() const
	{
		let ret = new('BIO_WAfx_BerserkDamage');
		ret.Count = Count;
		return ret;
	}
}

class BIO_WMod_DamageAdd : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.DealsAnyHitDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			weap.GetPipeline(i).DamageEffects.Push(
				BIO_DmgFx_Multi.Create(1.0 + (float(context.NodeCount) * 0.1))
			);
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
		{
			let qual = context.Weap.GetPipeline(i).GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_DAMAGEADD_DESC"),
				qual.Length() > 0 ? " " .. qual : "",
				10 * context.NodeCount
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_DAMAGE_INC;
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
		return context.Weap.DealsAnyHitDamage(), "$BIO_WMOD_INCOMPAT_NODAMAGE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			let func = weap.GetPipeline(i).GetHitDamageFunctor('BIO_HDF_DemonSlayer');

			if (func != null)
			{
				BIO_HDF_DemonSlayer(func).Count++;
			}	
			else
			{
				func = new('BIO_HDF_DemonSlayer');
				BIO_HDF_DemonSlayer(func).Count = 1;
				weap.GetPipeline(i).PayloadFunctors.HitDamage.Push(func);
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WMOD_DEMONSLAYER_DESC"),
			context.NodeCount * 100
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_DAMAGE_INC;
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
		if (target == null)
			return;

		if (BIO_Utils.TryFindInv(target, 'LDLegendaryMonsterTransformed'))
			damage *= (Count + 1);
	}

	final override void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null)
			return;

		if (BIO_Utils.TryFindInv(target, 'LDLegendaryMonsterTransformed'))
			damage *= (Count + 1);
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		if (puff.Tracer == null)
			return;

		if (BIO_Utils.TryFindInv(puff.Tracer, 'LDLegendaryMonsterTransformed'))
			puff.Tracer.DamageMObj(puff, null, puff.Damage * Count, puff.DamageType);
	}

	final override BIO_HitDamageFunctor Copy() const
	{
		return new('BIO_HDF_DemonSlayer');
	}

	final override string Summary() const
	{
		return String.Format(
			StringTable.Localize("$BIO_HDF_DEMONSLAYER"), Count * 100
		);
	}
}

class BIO_WMod_MagSizeToDamage : BIO_WeaponModifier
{
	private uint ChangeCounts[2];

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (context.Weap.Magazineless())
			return false, "$BIO_WMOD_INCOMPAT_NOMAGAZINES";

		if (!context.Weap.DealsAnyHitDamage())
			return false, "$BIO_WMOD_INCOMPAT_NODAMAGE";

		return
			MagazineCompatible(context, false) || MagazineCompatible(context, true),
			"$BIO_WMOD_INCOMPAT_MAGSIZETODAMAGE";
	}

	private static bool MagazineCompatible(BIO_GeneContext context, bool secondary)
	{
		let mag = !secondary ? context.Weap.Magazine1 : context.Weap.Magazine2;

		let magsize = !secondary ?
			context.Weap.MagazineSize1 :
			context.Weap.MagazineSize2;

		if (mag == null || magsize <= 0)
			return false;

		let reduced = int(Floor(float(magsize) * 0.8));

		if (reduced == magsize || reduced <= 0)
			return false;

		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
		{
			let ppl = context.Weap.GetPipeline(i);

			if (secondary && !ppl.UsesSecondaryAmmo())
				continue;
			else if (!secondary && ppl.UsesSecondaryAmmo())
				continue;

			if (!ppl.DealsAnyHitDamage())
				continue;

			return true;
		}

		return false;
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		ChangeCounts[0] = ChangeCounts[1] = 0;

		if (MagazineCompatible(context, false))
		{
			int reduced = int.MIN;
			float dmgf = 1.0, mszf = 1.0;

			for (uint i = 0; i < context.NodeCount; i++)
			{
				mszf -= 0.2;
				dmgf += 0.2;
				reduced = int(Floor(float(weap.MagazineSize1) * mszf));

				if (reduced == weap.MagazineSize1 || reduced <= 0)
					break;

				if (ChangeCounts[0]++ >= 4)
					break;
			}

			weap.MagazineSize1 = reduced;

			for (uint j = 0; j < weap.PipelineCount(); j++)
			{
				let ppl = weap.GetPipeline(j);

				if (ppl.UsesSecondaryAmmo())
					continue;

				ppl.DamageEffects.Push(BIO_DmgFx_Multi.Create(dmgf));
			}
		}

		if (MagazineCompatible(context, true))
		{
			int reduced = int.MIN;
			float dmgf = 1.0, mszf = 1.0;

			for (uint i = 0; i < context.NodeCount; i++)
			{
				mszf -= 0.2;
				dmgf += 0.2;
				reduced = int(Floor(float(weap.MagazineSize2) * mszf));

				if (reduced == weap.MagazineSize2 || reduced <= 0)
					break;

				if (ChangeCounts[1]++ >= 4)
					break;
			}

			weap.MagazineSize2 = reduced;

			for (uint j = 0; j < weap.PipelineCount(); j++)
			{
				let ppl = weap.GetPipeline(j);

				if (!ppl.UsesSecondaryAmmo())
					continue;

				ppl.DamageEffects.Push(BIO_DmgFx_Multi.Create(dmgf));
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		if (ChangeCounts[0] > 0)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_MAGSIZETODAMAGE_DESC_1"),
				ChangeCounts[0] * 20, ChangeCounts[0] * 20
			);
		}

		if (ChangeCounts[1] > 0)
		{
			if (ChangeCounts[0] > 0)
				ret = ret .."\n";

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_MAGSIZETODAMAGE_DESC_2"),
				ChangeCounts[1] * 20, ChangeCounts[1] * 20
			);
		}

		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_MAGSIZE_DEC, BIO_WPMF_DAMAGE_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_MagSizeToDamage';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_MagSizeToDamage');
		ret.ChangeCounts[0] = ChangeCounts[0];
		ret.ChangeCounts[1] = ChangeCounts[1];
		return ret;
	}
}

class BIO_WMod_RechamberUp : BIO_WeaponModifier
{
	private Array<uint> PipelineDoubles;
	private uint PrimaryDoubles, SecondaryDoubles;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		uint invalidDamage = 0, invalidSPM = 0;

		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
		{
			let ppl = context.Weap.GetPipeline(i).AsConst();

			switch (PipelineCompatibility(context.Weap, ppl))
			{
			case 0: break;
			case -1: invalidDamage++; break;
			case 1: invalidSPM++; break;
			}
		}

		if (invalidDamage == context.Weap.PipelineCount())
			return false, "$BIO_WMOD_INCOMPAT_NODAMAGE";
		else if (invalidSPM == context.Weap.PipelineCount())
			return false, "$BIO_WMOD_INCOMPAT_SPMOVERRUN";
		else
			return true, "";
	}

	private static int PipelineCompatibility(
		readOnly<BIO_Weapon> weap,
		readOnly<BIO_WeaponPipeline> ppl)
	{
		if (!ppl.DealsAnyHitDamage())
			return -1;

		if (ppl.UsesPrimaryAmmo() && weap.ShotsPerMagazine(false) < 2)
			return 1;
		if (ppl.UsesSecondaryAmmo() && weap.ShotsPerMagazine(true) < 2)
			return 1;

		return 0;
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		PipelineDoubles.Clear();
		PipelineDoubles.Resize(weap.PipelineCount());
		PrimaryDoubles = SecondaryDoubles = 0;

		for (uint i = 0; i < context.NodeCount; i++)
		{
			bool a1 = false, a2 = false;

			for (uint j = 0; j < weap.PipelineCount(); j++)
			{
				let ppl = weap.GetPipeline(j);

				if (PipelineCompatibility(weap.AsConst(), ppl.AsConst()) != 0)
					continue;

				if (!ppl.UsesSecondaryAmmo())
					a1 = true;
				else
					a2 = true;

				ppl.DamageEffects.Push(BIO_DmgFx_Multi.Create(2.0));
				PipelineDoubles[j]++;
			}

			if (a1)
			{
				weap.AmmoUse1 *= 2;
				PrimaryDoubles++;
			}

			if (a2)
			{
				weap.AmmoUse2 *= 2;
				SecondaryDoubles++;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		if (PrimaryDoubles > 0)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_RECHAMBERUP_DESC_AMMO1"),
				100 * 2 ** (PrimaryDoubles - 1)
			);
			ret = ret .. "\n";
		}

		if (SecondaryDoubles > 0)
		{
			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_RECHAMBERUP_DESC_AMMO2"),
				100 * 2 ** (SecondaryDoubles - 1)
			);
			ret = ret .. "\n";
		}

		for (uint i = 0; i < PipelineDoubles.Size(); i++)
		{
			if (PipelineDoubles[i] < 1)
				continue;

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_RECHAMBERUP_DESC_PIPELINE"),
				100 * 2 ** (PipelineDoubles[i] - 1)
			);

			let qual = context.Weap.GetPipeline(i).GetTagAsQualifier();

			if (qual.Length() > 0 && PipelineDoubles.Size() > 1)
				ret.AppendFormat(" %s", qual);

			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_AMMOUSE_INC, BIO_WPMF_DAMAGE_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_RechamberUp';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_RechamberUp');
		ret.PipelineDoubles.Copy(PipelineDoubles);
		ret.PrimaryDoubles = PrimaryDoubles;
		ret.SecondaryDoubles = SecondaryDoubles;
		return ret;
	}
}

class BIO_WMod_SplashToHit : BIO_WeaponModifier
{
	// One element per pipeline, always positive
	private Array<int> DamageChanges, RadiusChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (CompatibleWithPipeline(context.Weap.GetPipeline(i).AsConst()))
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_SPLASHTOHIT";
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		return ppl.DealsAnySplashDamage();
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		DamageChanges.Clear(); DamageChanges.Resize(weap.PipelineCount());
		RadiusChanges.Clear(); RadiusChanges.Resize(weap.PipelineCount());

		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			if (!CompatibleWithPipeline(weap.GetPipeline(i).AsConst()))
				continue;

			let func = weap.GetPipeline(i).GetSplashFunctor();

			let dmg = func.Damage / 2;
			weap.GetPipeline(i).DamageEffects.Push(BIO_DmgFx_Modify.Create(dmg, true));
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

			let qual = context.Weap.GetPipeline(i).GetTagAsQualifier();

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

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE,
			BIO_WPMF_DAMAGE_INC |
			BIO_WPMF_SPLASHDAMAGE_DEC | BIO_WPMF_SPLASHRADIUS_DEC;
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
