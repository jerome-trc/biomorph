class BIO_WMod_CanisterShot : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (CompatibleWithPipeline(context.Weap.GetPipeline(i).AsConst()))
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
		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			let ppl = weap.GetPipeline(i);

			if (!CompatibleWithPipeline(ppl.AsConst()))
				continue;

			let fromSplash = ppl.CombinedSplashDamage();
			ppl.DeletePayloadDeathFunctors('BIO_PLDF_Explode');

			ppl.FireFunctor = BIO_FireFunc_Bullet.Create();
			ppl.Payload = 'BIO_ShotPellet';
			ppl.ShotCount *= 9;
			ppl.DamageEffects.Push(BIO_DmgFx_Modify.Create(fromSplash));
			ppl.DamageEffects.Push(BIO_DmgFx_Multi.Create(1.0 / 9.0));
			ppl.HSpread = 5.0;
			ppl.VSpread = 3.0;
			ppl.FireSound = "bio/puff/canistershot/fire";
		}

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return
			BIO_WCMF_NONE,
			BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_SHOTCOUNT_INC | BIO_WPMF_SPLASHREMOVE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_CANISTERSHOT_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_CANISTERSHOT_SUMM";
	}
}

class BIO_WMod_ProxMine : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.PipelineCount(); i++)
			if (CompatibleWithPipeline(context.Weap.GetPipeline(i).AsConst()))
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
		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			let ppl = weap.GetPipeline(i);

			if (!CompatibleWithPipeline(ppl.AsConst()))
				continue;

			ppl.Payload = 'BIO_ProxMineProj';
			ppl.FireSound = "bio/proj/proxmine/fire";
		}

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_PAYLOAD_NEW;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_PROXMINE_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_PROXMINE_SUMM";
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
		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			let ppl = weap.GetPipeline(i);

			if (!(ppl.Payload is 'BIO_ShotPellet'))
				continue;

			if (!ppl.CanFirePuffs())
				ppl.FireFunctor = new('BIO_FireFunc_Bullet');

			ppl.Payload = 'BIO_Slug';
			let fc = float(ppl.ShotCount);
			ppl.ShotCount = 1;
			ppl.DamageEffects.Push(BIO_DmgFx_Multi.Create(fc));
			ppl.HSpread = 0.4;
			ppl.VSpread = 0.4;
		}

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return
			BIO_WCMF_NONE,
			BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_SPREAD_DEC | BIO_WPMF_SHOTCOUNT_DEC;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_SHELLTOSLUG_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SHELLTOSLUG_SUMM";
	}
}
