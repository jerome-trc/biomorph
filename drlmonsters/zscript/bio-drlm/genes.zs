// Spider Overmind /////////////////////////////////////////////////////////////

class BIORLM_MGene_Overmind : BIO_ModifierGene
{
	Default
	{
		Tag "$BIORLM_MGENE_OVERMIND_TAG";
		Inventory.Icon 'GEN5B0';
		Inventory.PickupMessage "$BIORLM_MGENE_OVERMIND_PKUP";
		BIO_Gene.Limit 1;
		BIO_Gene.LockOnCommit true;
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
		if (context.Weap.Pipelines.Size() < 1)
			return false, "$BIO_WMOD_INCOMPAT_NOPIPELINES";

		return context.IsLastNode(), "$BIO_WMOD_INCOMPAT_NOTLASTNODE";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		let afx = weap.GetAffixByType('BIORLM_WAfx_Overmind');

		if (afx == null)
		{
			afx = new('BIORLM_WAfx_Overmind');
			BIORLM_WAfx_Overmind(afx).Init(weap);
			weap.Affixes.Push(afx);
		}

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			if (!ppl.CanFireProjectiles())
				ppl.FireFunctor = new('BIO_FireFunc_Projectile').Init();

			ppl.Payload = 'BIORLM_OvermindPlasma';

			if (ppl.HSpread < 3.0)
				ppl.HSpread = 3.0;
			if (ppl.VSpread < 1.5)
				ppl.VSpread = 1.5;

			ppl.HSpread *= 1.5;
			ppl.VSpread *= 1.5;

			ppl.FireSound = 0;
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		let afx = context.Weap.GetAffixByType('BIORLM_WAfx_Overmind');
		return afx.Description(context.Weap);
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

class BIORLM_WAfx_Overmind : BIO_WeaponAffix
{
	private BIO_TempEffect Tracker;

	void Init(BIO_Weapon weap)
	{
		Tracker = BIO_TempEffect.GetOrCreate(weap, 400);
	}

	final override void OnTick(BIO_Weapon weap)
	{
		if (Random(0, 20) == 0)
			weap.BIO_FireBullet(0.0, 0.0, 1, (0), 'BIO_PainPuff');
	}

	final override void BeforeAllShots(BIO_Weapon weap, in out BIO_ShotData shotData)
	{
		uint dec = PayloadCost(shotData.Payload) * shotData.Count;

		if (Tracker.CountDown(dec))
		{
			let sim = BIO_WeaponModSimulator.Create(weap);
			sim.GraphUnlockByType('BIORLM_MGene_Overmind');
			sim.GraphRemoveByType('BIORLM_MGene_Overmind');
			sim.CommitAndClose();
			return;
		}
	}

	final override string Description(readOnly<BIO_Weapon> weap) const
	{
		let ret = String.Format(
			StringTable.Localize("$BIORLM_WMOD_OVERMIND_DESC"),
			StringTable.Localize(GetDefaultByType('BIORLM_MGene_Overmind').Summary)
		);

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			uint dec = PayloadCost(ppl.Payload) * ppl.ShotCount;
			let shotsLeft = Tracker.Remaining() / dec;

			let append = String.Format(
				StringTable.Localize("$BIO_NUMBER_PLURALNOUN"),
				shotsLeft,
				BIO_Utils.PayloadTag(ppl.Payload, shotsLeft)
			);

			ret.AppendFormat("- %s\n", append);
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	private static uint PayloadCost(class<Actor> payload_t)
	{
		switch (BIO_Utils.PayloadSizeClass(payload_t))
		{
		default:
		case BIO_PLSC_NONE:
		case BIO_PLSC_XSMALL:
		case BIO_PLSC_SMALL:
			return 1;
		case BIO_PLSC_MEDIUM:
			return 10;
		case BIO_PLSC_LARGE:
			return 20;
		case BIO_PLSC_XLARGE:
			return 40;
		}
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
			ppl.HSpread = 15.0;

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
			let ang = shotData.HSpread;
			let h = shotData.Count / 2;
			if (shotData.Number - h >= 0) shotData.Number++;
			shotData.Angle += ((ang / float(h)) * (shotData.Number - h));
		}
		else // Odd fire count
		{
			let ang = shotData.HSpread * 2.0;
			let h = shotData.Count - 1;
			shotData.Angle += (shotData.Number - (h / 2)) * (ang / float(h));
		}

		shotData.HSpread = 0.0;
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
