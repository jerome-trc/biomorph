class BIO_WMod_ShellToSlug : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].Payload is 'BIO_ShotPellet')
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_NOSHELLPAYLOAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!(weap.Pipelines[i].Payload is 'BIO_ShotPellet'))
				continue;

			if (!weap.Pipelines[i].CanFirePuffs())
				weap.Pipelines[i].FireFunctor = new('BIO_FireFunc_Bullet').Setup();

			weap.Pipelines[i].Payload = 'BIO_Slug';
			let fc = float(weap.Pipelines[i].ShotCount);
			weap.Pipelines[i].ShotCount = 1;
			weap.Pipelines[i].MultiplyAllDamage(fc);
			weap.Pipelines[i].HSpread = 0.4;
			weap.Pipelines[i].VSpread = 0.4;
		}

		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_PAYLOAD_NEW;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ShellToSlug';
	}
}
