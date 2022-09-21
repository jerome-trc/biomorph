class BIORLM_Loot_SpiderOvermind : BIO_LootSpawner
{
	final override void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const
	{
		types.Push(BIO_Utils.TypeFromName('RLCyberneticSpiderMastermind'));
		exact.Push(true);
	}

	final override bool, bool Invoke(Actor victim) const
	{
		if (BIO_Utils.IsLegendary(victim) || Random[BIO_Loot](1, 4) == 4)
		{
			Actor.Spawn('BIORLM_MGene_Overmind', victim.Pos);
			PlayRareSound(victim);
		}

		return false, false;
	}
}

class BIORLM_MGene_Overmind : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GEN1B0';
		BIO_ProceduralGene.Modifier 'BIORLM_WMod_Overmind';
	}

	States
	{
	Spawn:
		GEN1 B 6;
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

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
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

		return afx.Description(context.Weap);
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_SPREAD_INC;
	}

	final override string Tag() const
	{
		return "$BIORLM_WMOD_OVERMIND_TAG";
	}

	final override string Summary() const
	{
		return "$BIORLM_WMOD_OVERMIND_SUMM";
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
			weap.BIO_FireBullet('BIO_PainPuff', 0, 0.0, 0.0);
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
		let mod = BIO_Global.Get().GetWeaponModifierByType('BIORLM_WMod_Overmind');

		let ret = String.Format(
			StringTable.Localize("$BIORLM_WMOD_OVERMIND_DESC"),
			StringTable.Localize(mod.Summary())
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

	final override BIO_WeaponAffix Copy() const
	{
		return new('BIORLM_WAfx_Overmind');
	}
}

class BIORLM_OvermindPlasma : BIO_FastProjectile
{
	Default
	{
		+THRUGHOST
		+SEEKERMISSILE

		Alpha 0.95;
		DeathSound "";
		Height 6;
		Radius 6;
		RenderStyle 'Add';
		Scale 0.15;
		SeeSound "";
		Speed 60;
		Tag "$BIORLM_OVERMINDPLASMA_TAG";
		BIO_FastProjectile.PluralTag "$BIORLM_OVERMINDPLASMA_TAG_PLURAL";
	}

	States
    {
    Spawn:
        TNT1 A 0;
		TNT1 A 0 A_StartSound("spiderovermind/plasma", CHAN_AUTO, attenuation: 0.6);
    SpawnLoop:
        TNT1 A 1;
		TNT1 A 0
		{
			A_SpawnItemEx('RLSpiderOvermindPlasmaTrail',
				(0.01 * Vel.X) / -35.0,
				-(0.01 * Vel.Y) / -35.0,
				2.0 + (0.01 * Vel.Z) / -35.0,
				flags: SXF_ABSOLUTEANGLE | SXF_NOCHECKPOSITION
			);

			static const class<Actor> TRAIL_TYPES[] = {
				'RLSpiderOvermindPlasmaTrail2',
				'RLSpiderOvermindPlasmaTrail3',
				'RLSpiderOvermindPlasmaTrail4',
				'RLSpiderOvermindPlasmaTrail5',
				'RLSpiderOvermindPlasmaTrail6',
				'RLSpiderOvermindPlasmaTrail7',
				'RLSpiderOvermindPlasmaTrail8',
				'RLSpiderOvermindPlasmaTrail9',
				'RLSpiderOvermindPlasmaTrail10',
				'RLSpiderOvermindPlasmaTrail11',
				'RLSpiderOvermindPlasmaTrail12',
				'RLSpiderOvermindPlasmaTrail13',
				'RLSpiderOvermindPlasmaTrail14',
				'RLSpiderOvermindPlasmaTrail15',
				'RLSpiderOvermindPlasmaTrail16',
				'RLSpiderOvermindPlasmaTrail17'
			};

			for (uint i = 1; i < 16; i++)
			{
				A_SpawnItemEx(
					TRAIL_TYPES[i - 1],
					(float(i) * Vel.X) / -35.0,
					-(float(i) * Vel.Y) / -35.0,
					2.0 + (float(i) * Vel.Z) / -35.0,
					flags: SXF_ABSOLUTEANGLE | SXF_NOCHECKPOSITION
				);
			}
		}
		Loop;
    Death:
		TNT1 A 0 A_ProjectileDeath;
		TNT1 A 0 A_Jump(25, 'TimeToBeAnnoying');
		Goto DeathAnimation;
    DeathAnimation:
		TNT1 A 0 A_StartSound("spiderovermind/plasmaimpact", CHAN_AUTO, attenuation: 0.8);
        BBB3 ABCDE 4 Bright;
        Stop;
    TimeToBeAnnoying:
		TNT1 A 0 A_JumpIfTargetInLOS('CanSeeTracer', 0, JLOSF_PROJECTILE, 256);
		TNT1 A 0 A_RearrangePointers(AAPTR_DEFAULT, AAPTR_DEFAULT, AAPTR_NULL);
		TNT1 A 0 A_SeekerMissile(0.0, 0.0, SMF_LOOK, 256, 4);
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_SeekerMissile(0.0, 0.0, SMF_LOOK, 256, 4);
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_JumpIfTargetInLOS('CanSeeTracer', 0, JLOSF_PROJECTILE, 256);
		Goto DeathAnimation;
    TimeToBeAnnoying:
		TNT1 A 0 A_StartSound("rlmonsters/laserhit", CHAN_AUTO, attenuation: 1.5);
		// (Yholl): I would be greatly amused if it jumped more than once
		TNT1 A 0 A_SpawnProjectile('RLSpiderOvermindPlasma2', 0,0,0, CMF_TRACKOWNER, 0, AAPTR_TRACER);
        Stop;
    }
}
