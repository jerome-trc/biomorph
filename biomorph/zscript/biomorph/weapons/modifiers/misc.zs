class BIO_WMod_Kickback : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.Pipelines.Size() > 0, "$BIO_WMOD_INCOMPAT_NOPIPELINES";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		weap.Kickback += (weap.Default.Kickback * 2 * context.NodeCount);

		return String.Format(
			StringTable.Localize("$BIO_WMOD_KICKBACK_DESC"),
			context.NodeCount * 200
		);
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_KICKBACK_INC, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_KICKBACK_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_KICKBACK_SUMM";
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

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let wafx = new('BIO_WAfx_SmartAim');
		wafx.Init(weap);
		weap.Affixes.Push(wafx);

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];
			ppl.PayloadFunctors.Travel.Push(new('BIO_PTF_Smart'));

			if (!CompatibleWithPipeline(ppl.AsConst()))
				continue;

			let ff = new('BIO_FireFunc_SmartAim');
			ff.Init(wafx);
			ppl.FireFunctor = ff;
		}

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_NONE, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_SMARTAIM_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SMARTAIM_SUMM";
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
		let mod = BIO_Global.Get().GetWeaponModifierByType('BIO_WMod_SmartAim');
		return mod.Summary();
	}

	final override BIO_WeaponAffix Copy() const
	{
		return new('BIO_WAfx_SmartAim');
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

	// Nothing to say here
	final override string Summary() const { return ""; }
}

class BIO_WMod_Spread : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			let ppl = context.Weap.Pipelines[i];

			if (ppl.IsMelee())
				continue;

			if (ppl.CombinedSpread() <= 0.01)
				continue;

			return true, "";
		}

		return false, "$BIO_WMOD_INCOMPAT_NOSPREAD";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let ppl_c = weap.Pipelines.Size();

		Array<float> horizChanges, vertChanges;
		horizChanges.Resize(ppl_c);
		vertChanges.Resize(ppl_c);

		for (uint i = 0; i < ppl_c; i++)
		{
			let ppl = weap.Pipelines[i];

			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (ppl.CombinedSpread() <= 0.01)
					continue;

				float
					h = ppl.HSpread * 0.33,
					v = ppl.VSpread * 0.33;

				horizChanges[i] -= h;
				vertChanges[i] -= v;

				ppl.HSpread -= h;
				ppl.VSpread -= v;
			}
		}

		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (horizChanges[i] >= -0.01 && vertChanges[i] >= -0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREAD_DESC"), qual,
				horizChanges[i], vertChanges[i]
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

	final override string Tag() const
	{
		return "$BIO_WMOD_SPREAD_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SPREAD_SUMM";
	}
}

class BIO_WMod_SpreadNarrow : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].HSpread >= 0.02)
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_TRIVIALHSPREAD";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let ppl_c = weap.Pipelines.Size();

		Array<float> horizChanges, vertChanges;
		horizChanges.Resize(ppl_c);
		vertChanges.Resize(ppl_c);

		for (uint i = 0; i < ppl_c; i++)
		{
			let ppl = weap.Pipelines[i];

			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (ppl.HSpread < 0.02)
					continue;

				float h = ppl.HSpread / 2.0;

				horizChanges[i] -= h;
				vertChanges[i] += h;

				ppl.HSpread -= h;
				ppl.VSpread += h;
			}
		}

		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (horizChanges[i] >= -0.01 && vertChanges[i] <= 0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREADNARROW_DESC"), qual,
				horizChanges[i], vertChanges[i]
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

	final override string Tag() const
	{
		return "$BIO_WMOD_SPREADNARROW_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SPREADNARROW_SUMM";
	}
}

class BIO_WMod_SpreadWiden : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].VSpread >= 0.02)
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_TRIVIALVSPREAD";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let ppl_c = weap.Pipelines.Size();

		Array<float> horizChanges, vertChanges;
		horizChanges.Resize(ppl_c);
		vertChanges.Resize(ppl_c);

		for (uint i = 0; i < ppl_c; i++)
		{
			let ppl = weap.Pipelines[i];

			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (ppl.VSpread < 0.02)
					continue;

				float v = ppl.VSpread / 2.0;

				horizChanges[i] += v;
				vertChanges[i] -= v;

				ppl.HSpread += v;
				ppl.VSpread -= v;
			}
		}

		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (horizChanges[i] <= 0.01 && vertChanges[i] >= -0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREADWIDEN_DESC"), qual,
				horizChanges[i], vertChanges[i]
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

	final override string Tag() const
	{
		return "$BIO_WMOD_SPREADWIDEN_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SPREADWIDEN_SUMM";
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

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		weap.RaiseSpeed = weap.LowerSpeed = BIO_Weapon.SWITCHSPEED_MAX;
		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_SWITCHSPEED_INC, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_SWITCHSPEED_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_SWITCHSPEED_SUMM";
	}
}

class BIO_WMod_ToggleConnected : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let weap = context.Weap;

		if (weap.SpecialFunc != null)
			return false, "$BIO_WMOD_INCOMPAT_EXISTINGSPECIAL";

		let n = context.Sim.Nodes[context.Node];

		for (uint i = 0; i < n.Basis.Neighbors.Size(); i++)
		{
			let nbi = n.Basis.Neighbors[i];
			let nb = context.Sim.Nodes[nbi];

			if (nb.Basis.Neighbors.Size() == 1)
				return true, "";
		}

		return false, "$BIO_WMOD_INCOMPAT_ALLNEIGHBORSHAVENEIGHBORS";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let func = new('BIO_WSF_NodeToggle');
		weap.SpecialFunc = func;
		let n = context.Sim.Nodes[context.Node];
		
		for (uint i = 0; i < n.Basis.Neighbors.Size(); i++)
		{
			let nbi = n.Basis.Neighbors[i];
			let nb = context.Sim.Nodes[nbi];

			if (nb.Basis.Neighbors.Size() > 1)
				continue;

			if (!nb.IsOccupied())
				continue;

			func.AddNode(nbi, nb.Basis.Flags & BIO_WMGNF_MUTED);
		}

		return Summary();
	}

	final override uint Limit() const
	{
		return 1;
	}

	final override BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const
	{
		return BIO_WCMF_SPECIALFUNC_ADD, BIO_WPMF_NONE;
	}

	final override string Tag() const
	{
		return "$BIO_WMOD_TOGGLECONNECTED_TAG";
	}

	final override string Summary() const
	{
		return "$BIO_WMOD_TOGGLECONNECTED_SUMM";
	}
}

class BIO_WSF_NodeToggle : BIO_WeaponSpecialFunctor
{
	Array<uint> NodesToToggle;
	private Array<bool> NodeState; // `true` if the corresponding node is muted.

	void AddNode(uint uuid, bool alreadyMuted)
	{
		NodesToToggle.Push(uuid);
		NodeState.Push(alreadyMuted);
	}

	final override state Invoke(BIO_Weapon weap) const
	{
		let sim = BIO_WeaponModSimulator.Create(weap);

		for (uint i = 0; i < NodesToToggle.Size(); i++)
		{
			let node = sim.Nodes[NodesToToggle[i]];
			let gene_tag = node.GetTag();

			if (!NodeState[i])
			{
				node.Basis.Flags |= BIO_WMGNF_MUTED;

				weap.PrintPickupMessage(
					weap.Owner.CheckLocalView(),
					String.Format(
						StringTable.Localize("$BIO_WMOD_TOGGLECONNECTED_TOAST_MUTED"),
						gene_tag
					)
				);
			}
			else
			{
				node.Basis.Flags &= ~BIO_WMGNF_MUTED;

				weap.PrintPickupMessage(
					weap.Owner.CheckLocalView(),
					String.Format(
						StringTable.Localize("$BIO_WMOD_TOGGLECONNECTED_TOAST_UNMUTED"),
						gene_tag
					)
				);
			}

			NodeState[i] = node.Basis.Flags & BIO_WMGNF_MUTED;
		}

		sim.RunAndClose();
		weap.Owner.A_StartSound("bio/ui/beep");
		return state(null);
	}

	final override BIO_WeaponSpecialFunctor Copy() const
	{
		let ret = new('BIO_WSF_NodeToggle');
		ret.NodesToToggle.Copy(NodesToToggle);
		ret.NodeState.Copy(NodeState);
		return ret;
	}
}
