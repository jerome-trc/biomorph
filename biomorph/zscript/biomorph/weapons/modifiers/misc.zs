class BIO_WMod_Kickback : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.Pipelines.Size() > 0, "$BIO_WMOD_INCOMPAT_NOPIPELINES";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		weap.Kickback += (weap.Default.Kickback * 2);
		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WMOD_KICKBACK_DESC"),
			context.NodeCount * 200
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_KICKBACK_INC, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Kickback';
	}
}

class BIO_WMod_SmartAim : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		if (context.Weap.HasAffixOfType('BIO_WAfx_SmartAim'))
			return false, "$BIO_WMOD_INCOMPAT_ALREADYSMARTAIMING";

		return context.Weap.Pipelines.Size() > 0, "$BIO_WMOD_INCOMPAT_NOPIPELINES";
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		if (ppl.IsMelee())
			return false;

		if (!ppl.CanFirePuffs())
			return false;
		
		if (!(ppl.Payload is 'BIO_Puff'))
			return false;

		return true;
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		let wafx = new('BIO_WAfx_SmartAim');
		wafx.Init(weap);
		weap.Affixes.Push(wafx);

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			if (!CompatibleWithPipeline(ppl.AsConst()))
				continue;

			let ff = new('BIO_FireFunc_SmartAim');
			ff.Setup();
			ff.Init(wafx);
			ppl.FireFunctor = ff;
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SmartAim';
	}
}

class BIO_FireFunc_SmartAim : BIO_FireFunc_Bullet
{
	private BIO_WAfx_SmartAim Affix;

	void Init(BIO_WAfx_SmartAim affix)
	{
		self.Affix = affix;
	}

	final override Actor Invoke(BIO_Weapon weap, in out BIO_ShotData shotData) const
	{
		if (Affix.HasTarget())
		{
			let tgt = Affix.Target();

			let spawnPos = tgt.Vec3Offset(
				FRandom(-shotData.HSpread, shotData.HSpread), 
				FRandom(-shotData.VSpread, shotData.VSpread),
				tgt.Height * 0.5
			);

			Actor ret = null;
			let pldefs = GetDefaultByType(shotData.Payload);

			if (pldefs.bPuffOnActors)
				ret = Actor.Spawn(shotData.Payload, spawnPos);
			else
				ret = Actor.Spawn('BIO_NullPuff', spawnPos);

			ret.Tracer = tgt;
			ret.Target = weap.Owner;

			if (tgt.Health > 0)
			{
				let admg = tgt.DamageMObj(
					ret,
					weap.Owner,
					shotData.Damage,
					pldefs.DamageType,
					DMG_USEANGLE | DMG_INFLICTOR_IS_PUFF,
					weap.Owner.Angle
				);

				tgt.SpawnLineAttackBlood(
					weap.Owner,
					spawnPos,
					weap.Owner.Angle,
					shotData.Damage,
					admg
				);
			}

			return ret;
		}
		else
		{
			return super.Invoke(weap, shotData);
		}
	}
}

class BIO_WAfx_SmartAim : BIO_WeaponAffix
{
	private textureID ReticleTexture;
	private BIO_SmartAim SmartAim;

	void Init(BIO_Weapon weap)
	{
		if (weap.Owner == null)
			return;

		SmartAim.Begin(
			weap.Owner.Player,
			horizontal_fov: 38.0,
			vertical_fov: 16.0
		);

		ReticleTexture = TexMan.CheckForTexture(
			"graphics/smartaim_reticle.png",
			TexMan.TYPE_ANY
		);
	}

	bool HasTarget() const { return SmartAim.HasTarget(); }
	Actor Target() const { return SmartAim.Target(); }

	final override void OnTick(BIO_Weapon weap)
	{
		if (weap.Owner == null)
			return;

		SmartAim.Next(PlayerPawn(weap.Owner));
	}

	final override void OnSlowProjectileFired(BIO_Weapon weap, BIO_Projectile proj)
	{
		let tgt = Target();

		if (tgt == null)
			return;

		proj.bSeekerMissile = true;
		proj.bBounceOnWalls = true;
		proj.bBounceOnCeilings = true;
		proj.bBounceOnFloors = true;
		proj.bBounceAutoOffFloorOnly = true;
		proj.BounceCount = 16;
		proj.BounceFactor = 1.0;
		proj.WallBounceFactor = 1.0;
		proj.Tracer = tgt;
		proj.Functors.Travel.Push(new('BIO_PTF_Smart'));
	}

	final override void RenderOverlay(BIO_RenderContext context) const
	{
		if (AutomapActive)
			return;

		let res = (Screen.GetWidth(), Screen.GetHeight());

		// Draw the meta-crosshair over the screen centre
		if (!HasTarget())
		{
			Screen.DrawTexture(
				ReticleTexture, false,
				res.X / 2, res.Y / 2, DTA_CENTEROFFSET, true
			);
			return;
		}

		let tgt = SmartAim.Target();

		context.Projector.ProjectActorPos(
			tgt, (0.0, 0.0, tgt.Height / 2.0), context.Event.FracTic
		);
		let norm = context.Projector.ProjectToNormal();
		let drawPos = context.Viewport.SceneToWindow(norm);

		Screen.DrawTexture(
			ReticleTexture, false,
			drawPos.X, drawPos.Y, DTA_CENTEROFFSET, true
		);
	}

	final override void OnPickup(BIO_Weapon weap) { Init(weap); }

	final override void OnDrop(BIO_Weapon _, BIO_Player __)
	{
		SmartAim.Reset();
	}

	final override string Description(readOnly<BIO_Weapon> _) const
	{
		return GetDefaultByType('BIO_MGene_SmartAim').Summary;
	}
}

class BIO_PTF_Smart : BIO_ProjTravelFunctor
{
	final override void Invoke(BIO_Projectile proj)
	{
		proj.A_FaceTracer();
		proj.A_SeekerMissile(60.0, 75.0, SMF_PRECISE | SMF_LOOK);
	}

	final override BIO_ProjTravelFunctor Copy() const
	{
		return new('BIO_PTF_Smart');
	}

	final override void Summary(in out Array<string> readout) const {}
}

class BIO_WMod_Spread : BIO_WeaponModifier
{
	private Array<float> HorizChanges, VertChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (context.Weap.Pipelines[i].IsMelee())
				continue;

			if (context.Weap.Pipelines[i].CombinedSpread() <= 0.01)
				continue;

			return true, "";
		}

		return false, "$BIO_WMOD_INCOMPAT_NOSPREAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		HorizChanges.Clear(); HorizChanges.Resize(weap.Pipelines.Size());
		VertChanges.Clear(); VertChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (weap.Pipelines[i].CombinedSpread() <= 0.01)
					continue;

				float
					h = weap.Pipelines[i].HSpread * 0.33,
					v = weap.Pipelines[i].VSpread * 0.33;

				HorizChanges[i] -= h;
				VertChanges[i] -= v;

				weap.Pipelines[i].HSpread -= h;
				weap.Pipelines[i].VSpread -= v;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (HorizChanges[i] >= -0.01 && VertChanges[i] >= -0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREAD_DESC"), qual,
				HorizChanges[i], VertChanges[i]
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_SPREAD_DEC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Spread';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_Spread');
		ret.HorizChanges.Copy(HorizChanges);
		ret.VertChanges.Copy(VertChanges);
		return ret;
	}
}

class BIO_WMod_SpreadNarrow : BIO_WeaponModifier
{
	private Array<float> HorizChanges, VertChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].HSpread >= 0.02)
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_TRIVIALHSPREAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		HorizChanges.Clear(); HorizChanges.Resize(weap.Pipelines.Size());
		VertChanges.Clear(); VertChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (weap.Pipelines[i].HSpread < 0.02)
					continue;

				float h = weap.Pipelines[i].HSpread / 2.0;

				HorizChanges[i] -= h;
				VertChanges[i] += h;

				weap.Pipelines[i].HSpread -= h;
				weap.Pipelines[i].VSpread += h;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (HorizChanges[i] >= -0.01 && VertChanges[i] <= 0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREADNARROW_DESC"), qual,
				HorizChanges[i], VertChanges[i]
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_SPREAD_DEC | BIO_WPMF_SPREAD_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SpreadNarrow';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_SpreadNarrow');
		ret.HorizChanges.Copy(HorizChanges);
		ret.VertChanges.Copy(VertChanges);
		return ret;
	}
}

class BIO_WMod_SpreadWiden : BIO_WeaponModifier
{
	private Array<float> HorizChanges, VertChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].VSpread >= 0.02)
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_TRIVIALVSPREAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		HorizChanges.Clear(); HorizChanges.Resize(weap.Pipelines.Size());
		VertChanges.Clear(); VertChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (weap.Pipelines[i].VSpread < 0.02)
					continue;

				float v = weap.Pipelines[i].VSpread / 2.0;

				HorizChanges[i] += v;
				VertChanges[i] -= v;

				weap.Pipelines[i].HSpread += v;
				weap.Pipelines[i].VSpread -= v;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (HorizChanges[i] <= 0.01 && VertChanges[i] >= -0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREADWIDEN_DESC"), qual,
				HorizChanges[i], VertChanges[i]
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_SPREAD_DEC | BIO_WPMF_SPREAD_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SpreadWiden';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_SpreadWiden');
		ret.HorizChanges.Copy(HorizChanges);
		ret.VertChanges.Copy(VertChanges);
		return ret;
	}
}

class BIO_WMod_SwitchSpeed : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return
			context.Weap.RaiseSpeed < BIO_Weapon.SWITCHSPEED_MAX &&
			context.Weap.LowerSpeed < BIO_Weapon.SWITCHSPEED_MAX,
			"$BIO_WMOD_INCOMPAT_SWITCHSPEEDMAX";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		weap.RaiseSpeed = weap.LowerSpeed = BIO_Weapon.SWITCHSPEED_MAX;
		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_SWITCHSPEED_INC, BIO_WPMF_NONE;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SwitchSpeed';
	}
}
