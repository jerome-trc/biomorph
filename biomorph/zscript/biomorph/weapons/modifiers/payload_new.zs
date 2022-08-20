class BIO_WMod_CanisterShot : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(context.Weap.Pipelines[i].AsConst()))
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_PAYLOADTOOSMALL";
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		let proj = (class<BIO_Projectile>)(ppl.Payload);

		if (proj == null)
			return false;

		if (GetDefaultByType(proj).SizeClass < BIO_PLSC_LARGE)
			return false;

		return true;
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				continue;

			let fromSplash = weap.Pipelines[i].CombinedSplashDamage();
			weap.Pipelines[i].DeletePayloadDeathFunctors('BIO_PLDF_Explode');

			weap.Pipelines[i].FireFunctor = BIO_FireFunc_Bullet.Create();
			weap.Pipelines[i].Payload = 'BIO_ShotPellet';
			weap.Pipelines[i].ShotCount *= 9;
			weap.Pipelines[i].DamageEffects.Push(BIO_DmgFx_Modify.Create(fromSplash));
			weap.Pipelines[i].DamageEffects.Push(BIO_DmgFx_Multi.Create(1.0 / 9.0));
			weap.Pipelines[i].HSpread = 5.0;
			weap.Pipelines[i].VSpread = 3.0;
			weap.Pipelines[i].FireSound = "bio/puff/canistershot/fire";
		}

		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return
			BIO_WCMF_NONE,
			BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_SHOTCOUNT_INC | BIO_WPMF_SPLASHREMOVE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_CanisterShot';
	}
}

class BIO_WMod_ProxMine : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(context.Weap.Pipelines[i].AsConst()))
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_PAYLOADTOOSMALL";
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		let proj = (class<BIO_Projectile>)(ppl.Payload);

		if (proj == null)
			return false;

		if (GetDefaultByType(proj).SizeClass < BIO_PLSC_LARGE)
			return false;

		return true;
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				continue;

			weap.Pipelines[i].Payload = 'BIO_ProxMineProj';
			weap.Pipelines[i].FireSound = "bio/proj/proxmine/fire";
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
		return 'BIO_MGene_ProxMine';
	}
}

class BIO_WMod_ShellToSlug : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return
			context.Weap.AnyPipelineFiresPayload('BIO_ShotPellet', true),
			"$BIO_WMOD_INCOMPAT_NOPAYLOAD_SHOTPELLETS";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!(weap.Pipelines[i].Payload is 'BIO_ShotPellet'))
				continue;

			if (!weap.Pipelines[i].CanFirePuffs())
				weap.Pipelines[i].FireFunctor = new('BIO_FireFunc_Bullet');

			weap.Pipelines[i].Payload = 'BIO_Slug';
			let fc = float(weap.Pipelines[i].ShotCount);
			weap.Pipelines[i].ShotCount = 1;
			weap.Pipelines[i].DamageEffects.Push(BIO_DmgFx_Multi.Create(fc));
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
		return
			BIO_WCMF_NONE,
			BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_SPREAD_DEC | BIO_WPMF_SHOTCOUNT_DEC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_ShellToSlug';
	}
}
