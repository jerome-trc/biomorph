class BIORLM_Loot_EliteCaptainTristarBlaster : BIO_LootSpawner
{
	final override void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const
	{
		types.Push(BIO_Utils.TypeFromName('RLEliteCaptainTristarBlaster'));
		exact.Push(true);
	}

	final override void SpawnLoot() const
	{
		Actor.Spawn('BIORLM_MGene_Tristar', Pos);
	}
}

class BIORLM_MGene_Tristar : BIO_ModifierGene
{
	Default
	{
		Tag "$BIORLM_MGENE_TRISTAR_TAG";
		Inventory.Icon 'GEN1A0';
		Inventory.PickupMessage "$BIORLM_MGENE_TRISTAR_PKUP";
		BIO_ModifierGene.ModType 'BIORLM_WMod_Tristar';
	}

	States
	{
	Spawn:
		GEN1 A 6;
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

		for (uint i = 0; i < weap.OpModes[0].FireTimeGroups.Size(); i++)
		{
			let ftg = weap.OpModes[0].FireTimeGroups[i];

			if (ftg.IsAuxiliary())
				continue;
			if (ftg.TotalTime() > 36)
				ftg.SetTotalTime(36);
		}

		for (uint i = 0; i < weap.PipelineCount(); i++)
		{
			let ppl = weap.GetPipeline(i);

			ppl.FireFunctor = new('BIORLM_FireFunc_Tristar').Init();
			let dmg = new('BIO_DmgBase_XTimesRand');
			dmg.Multiplier = 8;
			dmg.MinRandom = 1;
			dmg.MaxRandom = 8;
			ppl.DamageBase = dmg;
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

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override string Summary() const
	{
		return "$BIORLM_WMOD_TRISTAR_SUMM";
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return
			BIO_WCMF_AMMOUSE_DEC | BIO_WCMF_FIRETIME_DEC,
			BIO_WPMF_PAYLOAD_NEW | BIO_WPMF_DAMAGE_DEC | BIO_WPMF_SHOTCOUNT_INC |
			BIO_WPMF_SPLASHRADIUS_INC | BIO_WPMF_SPLASHDAMAGE_INC;
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

	final override string Description(
		readOnly<BIO_WeaponPipeline> ppl,
		readOnly<BIO_WeaponPipeline> pplDef
	) const
	{
		return String.Format(
			StringTable.Localize("$BIORLM_FIREFUNC_TRISTAR"),
			BIO_Utils.StatFontColor(ppl.ShotCount, pplDef.ShotCount),
			ppl.ShotCount,
			ppl.Payload != pplDef.Payload ?
				Biomorph.CRESC_STATMODIFIED :
				Biomorph.CRESC_STATDEFAULT,
			BIO_Utils.PayloadTag(ppl.Payload, ppl.ShotCount)
		);
	}
}

class BIORLM_TristarBall : BIO_Projectile
{
	Default
	{
		+NOTIMEFREEZE
		+THRUGHOST
		+BLOODSPLATTER

		Alpha 0.85;
		DeathSound "";
		DeathType "PlasmaExplosion";
		Decal "EnemyBlueBFGLightning";
		Height 8;
		PainType "PlasmaExplosion";
		Radius 13;
		Scale 0.25;
		SeeSound "";
		Speed 20;
		Tag "$BIORLM_TRISTARBALL_TAG";
		BIO_Projectile.PluralTag "$BIORLM_TRISTARBALL_TAG_PLURAL";
	}

	States
	{
	Spawn:
		PULS CDEFED 2 Bright A_Travel;
		Goto Spawn;
	Death:
		TNT1 A 0
		{
			A_ProjectileDeath();

			if (CallACS("DRLA_MonsterQuake") == 0)
			{
				A_Quake(1, 8, 0, 512, "");
				A_Quake(5, 8, 0, 256, "");
			}

			A_StartSound(
				"rlmonsters/tristarblasterhit", CHANF_DEFAULT, CHAN_AUTO, 1, 0.6
			);
			A_StartSound(
				"rlmonsters/tristarblasterhit", CHANF_DEFAULT, CHAN_AUTO, 0.05, 0.15
			);
			A_SetScale(1);
		}
		PEXP AB 4 Bright;
		PEXP CD 3 Bright;
		PEXP EF 2 Bright;
		Stop;
	}
}
