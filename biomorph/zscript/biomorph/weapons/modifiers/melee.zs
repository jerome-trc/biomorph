class BIO_WMod_Lifesteal : BIO_WeaponModifier
{
	private Array<float> AddPercents; // One per pipeline (might be 0.0)

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (context.Weap.GetPipeline(i).IsMelee())
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOMELEEDAMAGE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		let ppl_c = weap.PipelineCount();

		AddPercents.Clear();
		AddPercents.Resize(ppl_c);

		for (uint i = 0; i < ppl_c; i++)
		{
			let ppl = weap.GetPipeline(i);

			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (!ppl.IsMelee())
					continue;

				let ls = 0.1;
				let md = ppl.GetMinDamage(); // Before berserk

				if (md > 100)
					ls = 0.01;
				else if (md > 50)
					ls = 0.05;

				let ff = BIO_FireFunc_Melee(ppl.FireFunctor);
				ff.Lifesteal += ls;
				AddPercents[i] += ls;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < AddPercents.Size(); i++)
		{
			if (AddPercents[i] == 0.0)
				continue;

			string qual = "";

			if (AddPercents.Size() > 1)
				qual = " " .. context.Weap.GetPipeline(i).GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_LIFESTEAL_DESC"),
				int(AddPercents[i] * 100.0), qual
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

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Lifesteal';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_Lifesteal');
		ret.AddPercents.Copy(AddPercents);
		return ret;
	}
}
