class BIO_WMod_Lifesteal : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (context.Weap.GetPipeline(i).IsMelee())
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOMELEEDAMAGE";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let ppl_c = weap.PipelineCount();

		Array<float> addPercents; // One per pipeline (might be 0.0)
		addPercents.Resize(ppl_c);

		for (uint i = 0; i < ppl_c; i++)
		{
			let ppl = weap.GetPipeline(i);

			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (!ppl.IsMelee())
					continue;

				let ls = 0.1;
				let md = ppl.GetMinDamage(true); // Before berserk

				if (md > 100)
					ls = 0.01;
				else if (md > 50)
					ls = 0.05;

				let ff = BIO_FireFunc_Melee(ppl.FireFunctor);
				ff.Lifesteal += ls;
				addPercents[i] += ls;
			}
		}

		string ret = "";

		for (uint i = 0; i < addPercents.Size(); i++)
		{
			if (addPercents[i] == 0.0)
				continue;

			string qual = "";

			if (addPercents.Size() > 1)
				qual = " " .. context.Weap.GetPipeline(i).GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_LIFESTEAL_DESC"),
				int(addPercents[i] * 100.0), qual
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_LIFESTEAL_INC;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_LIFESTEAL_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_LIFESTEAL_SUMM";
	}
}
