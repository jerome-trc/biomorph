// Spider Overmind /////////////////////////////////////////////////////////////

class BIORLM_MGene_Overmind : BIO_ModifierGene
{
	Default
	{
		Tag "$BIORLM_MGENE_OVERMIND_TAG";
		Inventory.Icon 'GEN5B0';
		Inventory.PickupMessage "$BIORLM_MGENE_OVERMIND_PKUP";
		BIO_Gene.Limit 1;
		BIO_Gene.Summary "$BIORLM_WMOD_OVERMIND_SUMM";
		BIO_ModifierGene.ModType 'BIORLM_WMod_Overmind';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_NONE;
	}

	States
	{
	Spawn:
		GEN5 B 6;
		#### # 6 Bright Light("BIO_MutaGene_Cyan");
		Loop;
	}

	final override bool CanGenerate() const { return false; }
}

class BIORLM_WMod_Overmind : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return
			context.Weap.GetClass() is 'BIO_PlasmaRifle',
			"$BIO_WMOD_INCOMPAT_NOTPLASMARIFLE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			if (!ppl.CanFireProjectiles())
				ppl.FireFunctor = new('BIO_FireFunc_Projectile').Init();

			ppl.Payload = 'BIORLM_OvermindPlasma';
			ppl.Damage = new('BIO_DmgFunc_XTimesRand').Init(5, 4, 6);

			if (ppl.HSpread < 3.0)
				ppl.HSpread = 3.0;
			if (ppl.VSpread < 1.5)
				ppl.VSpread = 1.5;

			ppl.HSpread *= 1.5;
			ppl.VSpread *= 1.5;
		}

		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_SPREAD_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIORLM_MGene_Overmind';
	}
}

// Tristar /////////////////////////////////////////////////////////////////////

class BIORLM_MGene_Tristar : BIO_ModifierGene
{
	Default
	{
		Tag "$BIORLM_MGENE_TRISTAR_TAG";
		Inventory.Icon 'GEN5A0';
		Inventory.PickupMessage "$BIORLM_MGENE_TRISTAR_PKUP";
		BIO_Gene.Limit 1;
		BIO_Gene.Summary "$BIORLM_WMOD_TRISTAR_SUMM";
		BIO_ModifierGene.ModType 'BIORLM_WMod_Tristar';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_NONE;
	}

	States
	{
	Spawn:
		GEN5 A 6;
		#### # 6 Bright Light("BIO_MutaGene_Blue");
		Loop;
	}

	final override bool CanGenerate() const { return false; }
}

class BIORLM_WMod_Tristar : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return	
			context.Weap.GetClass() is 'BIO_BFG',
			"$BIO_WMOD_INCOMPAT_NOTBFG";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		weap.AmmoUse1 *= 0.375; // e.g. 40 becomes 15

		let ftg = weap.FireTimeGroups[0];

		if (ftg.TotalTime() > 36)
			ftg.SetTotalTime(36);

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			ppl.FireFunctor = new('BIORLM_FireFunc_Tristar').Init();
			ppl.Damage = new('BIO_DmgFunc_XTimesRand').Init(8, 1, 8);
			ppl.Payload = 'BIORLM_TristarBall';
			ppl.ShotCount = 3;

			let func = ppl.GetSplashFunctor();

			if (func != null)
			{
				func.Damage += 32;
				func.Radius += 96;
			}
			else
			{
				ppl.SetSplash(32, 96);
			}

			for (uint j = ppl.PayloadFunctors.OnDeath.Size() - 1; j >= 0; j--)
			{
				if (ppl.PayloadFunctors.OnDeath[j] is 'BIO_PLDF_BFGSpray')
					ppl.PayloadFunctors.OnDeath.Delete(j);
			}
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
			BIO_WCMF_AMMOUSE_DEC | BIO_WCMF_FIRETIME_DEC,
			BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_DAMAGE_DEC | BIO_WPMF_SHOTCOUNT_INC |
			BIO_WPMF_SPLASHRADIUS_INC | BIO_WPMF_SPLASHDAMAGE_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIORLM_MGene_Tristar';
	}
}

class BIORLM_FireFunc_Tristar : BIO_FireFunc_Projectile
{
	final override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		if (shotData.Count % 2 == 0) // Even fire count
		{
			let h = shotData.Count / 2;
			if (shotData.Number - h >= 0) shotData.Number++;
			shotData.Angle += ((15.0 / float(h)) * (shotData.Number - h));
		}
		else // Odd fire count
		{
			let h = shotData.Count - 1;
			shotData.Angle += (shotData.Number - (h / 2)) * (30.0 / float(h));
		}

		return super.Invoke(weap, shotData);
	}

	final override void Summary(
		in out Array<string> readout,
		readOnly<BIO_WeaponPipeline> ppl,
		readOnly<BIO_WeaponPipeline> pplDef) const
	{
		readout.Push(
			String.Format(
				StringTable.Localize("$BIORLM_FIREFUNC_TRISTAR"),
				BIO_Utils.StatFontColor(ppl.ShotCount, pplDef.ShotCount),
				ppl.ShotCount,
				ppl.Payload != pplDef.Payload ?
					Biomorph.CRESC_STATMODIFIED :
					Biomorph.CRESC_STATDEFAULT,
				BIO_Utils.PayloadTag(ppl.Payload, ppl.ShotCount)
			)
		);
	}
}
