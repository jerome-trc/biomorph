class BIO_WAfx_ExtraBullet : BIO_WeaponAffix
{
	Array<int> Damage; // One value per pipeline (0 if inapplicable)

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
			{
				Damage.Push(0);
				continue;
			}

			Damage.Push(Max(weap.Pipelines[i].GetAverageDamage(), 1));
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;

		return false;
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		return !ppl.IsMelee() && !(ppl.GetFireType() is 'BIO_Bullet');
	}

	final override void BeforeAllFire(BIO_Weapon weap, in out BIO_FireData fireData)
	{
		uint lpf = weap.LastPipelineFiredIndex();

		if (Damage[lpf] == 0) return;

		weap.BIO_FireBullet(4.0, 2.0, BULLET_ALWAYS_SPREAD, Damage[lpf], 'BIO_Bullet');
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Damage.Size(); i++)
		{
			if (Damage[i] == 0) continue;

			string qual = "";

			if (Damage.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_EXTRABULLET_TOSTR"),
				Damage[i], qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_EXTRABULLET_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_ExtraShotPellets : BIO_WeaponAffix
{
	// Parallel arrays; one value per pipeline (0 if inapplicable)
	Array<uint> Count;
	Array<int> Damage;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
			{
				Damage.Push(0);
				Count.Push(0);
				continue;
			}

			Count.Push(Random[BIO_Afx](6, 8));
			Damage.Push(Max(weap.Pipelines[i].GetAverageDamage() / Count[i], 1));
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;

		return false;
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		return !ppl.IsMelee() && !(ppl.GetFireType() is 'BIO_ShotPellet');
	}

	final override void BeforeAllFire(BIO_Weapon weap, in out BIO_FireData fireData)
	{
		uint lpf = weap.LastPipelineFiredIndex();

		if (Damage[lpf] == 0) return;

		for (uint i = 0; i < Count[lpf]; i++)
		{
			weap.BIO_FireBullet(4.0, 2.0, BULLET_ALWAYS_SPREAD,
				Damage[lpf], 'BIO_ShotPellet');
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Damage.Size(); i++)
		{
			if (Damage[i] == 0) continue;

			string qual = "";

			if (Damage.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_EXTRASHOTPELLETS_TOSTR"),
				Count[i], Damage[i], qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_EXTRASHOTPELLETS_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}

class BIO_WAfx_ExtraBlast : BIO_WeaponAffix
{
	Array<int> Damage; // One value per pipeline (0 if inapplicable)

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
			{
				Damage.Push(0);
				continue;
			}

			Damage.Push(Max(weap.Pipelines[i].GetAverageDamage(), 1));
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;

		return false;
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		return ppl.DealsAnyDamage();
	}

	final override void BeforeAllFire(BIO_Weapon weap, in out BIO_FireData fireData)
	{
		uint lpf = weap.LastPipelineFiredIndex();

		if (Damage[lpf] == 0) return;

		weap.BIO_FireBullet(0.0, 0.0, BULLET_ALWAYS_SPREAD,
			Damage[lpf], 'BIO_ForceBlast', range: 96.0);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Damage.Size(); i++)
		{
			if (Damage[i] == 0) continue;

			string qual = "";

			if (Damage.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_EXTRABLAST_TOSTR"),
				Damage[i], qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_EXTRABLAST_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
