class BIO_WAfx_Damage : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DamageMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DamageMutable())
			{
				Modifiers.Push(0);
				continue;
			}

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);
			
			if (vals.Size() < 1)
			{
				Modifiers.Push(0);
				continue;
			}

			int
				minRand = int(Ceil(float(vals[0]) * 0.4)),
				maxRand = int(Ceil(float(vals[0]) * 1.6));
			Modifiers.Push(Max(0, Random[BIO_Afx](minRand, maxRand)));
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				vals[j] += Modifiers[i];
			
			weap.Pipelines[i].SetDamageValues(vals);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			string qual = "";

			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_DAMAGE_TOSTR"), qual,
				BIO_Utils.StatFontColor(Modifiers[i], 0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i]));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DAMAGE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }
	final override bool CanGenerate() const { return false; }
	final override bool CanGenerateImplicit() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_DamageMulti : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0.0
	Array<float> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DamageMutable() && weap.DealsAnyDamage();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DamageMutable())
			{
				Modifiers.Push(0.0);
				continue;
			}

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);
			if (!weap.Pipelines[i].ExportsDamageValues())
			{
				Modifiers.Push(0.0);
				continue;
			}

			Modifiers.Push(FRandom[BIO_Afx](0.25, 0.75));
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				vals[j] *= (1.0 + Modifiers[i]);
			
			weap.Pipelines[i].SetDamageValues(vals);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			string qual = "";

			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_DMGMULTI_TOSTR"), qual,
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i] * 100.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DMGMULTI_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }
	final override bool CanGenerate() const { return false; }
	final override bool CanGenerateImplicit() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// All splash damage on the fired thing is converted into direct hit damage.
class BIO_WAfx_SplashToDamage : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].Splashes() &&
				weap.Pipelines[i].DealsAnyDamage() &&
				weap.Pipelines[i].ExportsDamageValues())
				return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].Splashes() ||
				!weap.Pipelines[i].DealsAnyDamage() ||
				!weap.Pipelines[i].ExportsDamageValues())
				continue;
			
			let expl = weap.Pipelines[i].GetSplashFunctor();
			let dmg = expl.Damage;
			weap.Pipelines[i].AddToAllDamageValues(dmg);
			expl.Damage = 0;
			expl.Radius = 0;
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(CRESC_MIXED .. StringTable.Localize(
			"$BIO_WAFX_SPLASHTODAMAGE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPLASHTODAMAGE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// Damage gets added if the wielder is moving forward.
class BIO_WAfx_ForwardDamage : BIO_WeaponAffix
{
	float Multi;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Multi = FRandom[BIO_Afx](0.25, 0.75);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void BeforeEachFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		if (weap.Owner.Player.Cmd.Buttons & BT_FORWARD)
			fireData.Damage += (fireData.Damage * Multi);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_FORWARDDAMAGE_TOSTR"),
			Multi > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE, Multi * 100,
			StringTable.Localize(Multi > 0.0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FORWARDDAMAGE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// Damage gets added if the wielder is strafing.
class BIO_WAfx_StrafeDamage : BIO_WeaponAffix
{
	float Multi;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Multi = FRandom[BIO_Afx](0.25, 0.75);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void BeforeEachFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		if (weap.Owner.Player.Cmd.Buttons & BT_MOVELEFT ||
			weap.Owner.Player.Cmd.Buttons & BT_MOVERIGHT)
		{
			fireData.Damage += (fireData.Damage * Multi);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_STRAFEDAMAGE_TOSTR"),
			Multi > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE, Multi * 100,
			StringTable.Localize(Multi > 0.0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_STRAFEDAMAGE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_RandDmgMulti : BIO_WeaponAffix
{
	float MinMulti, MaxMulti;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		MaxMulti = FRandom[BIO_Afx](2.0, 4.0);
		int avgDamage = 0;

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			Array<int> vals;
			weap.Pipelines[i].GetDamageValues(vals);

			for (uint j = 0; j < vals.Size(); j++)
				avgDamage += vals[j];
			
			avgDamage *= weap.Pipelines[i].GetFireCount();
		}

		avgDamage /= int(weap.Pipelines.Size());
		
		// Higher possible maximum roll if weapon is weaker to begin with
		if (avgDamage < 100)
			MaxMulti += 0.5;
		if (avgDamage < 50)
			MaxMulti += 0.5;

		MinMulti = FRandom[BIO_Afx](0.2, 0.4);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void BeforeEachFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		fireData.Damage = Ceil(fireData.Damage * FRandom(MinMulti, MaxMulti));
	}

	final override bool CanGenerate() const { return false; }
	final override bool CanGenerateImplicit() const { return true; }

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_RANDDMGMULTI_TOSTR"),
			MinMulti, MaxMulti));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_RANDDMGMULTI_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// n% of the hit enemy's health is given to the fired thing's dealt damage.
class BIO_WAfx_EnemyHealthDamage : BIO_WeaponAffix
{
	float Factor;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Factor = FRandom[BIO_Afx](0.025, 0.05);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (weap.Pipelines[i].HitDamageFunctorsMutable())
				return true;

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let func = new('BIO_HDF_EnemyHealthDamage');
			func.Factor = Factor;
			weap.Pipelines[i].PushHitDamageFunctor(func);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(StringTable.Localize(
			"$BIO_WAFX_ENEMYHEALTHDAMAGE_TOSTR"),
			Factor > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Factor * 100.0, Factor > 0.0 ?
				StringTable.Localize("$BIO_ADDED_TO") :
				StringTable.Localize("$BIO_REMOVED_FROM")));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_ENEMYHEALTHDAMAGE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_HDF_EnemyHealthDamage : BIO_HitDamageFunctor
{
	float Factor;

	final override void InvokeTrue(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		damage += (target.Health * Factor);
	}

	final override void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		damage += (target.Health * Factor);
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		if (puff.Tracer != null)
		{
			int dmg = puff.Tracer.Health * Factor;
			puff.Tracer.DamageMObj(puff, null, dmg, puff.DamageType);
			puff.SetDamage(puff.Damage + dmg);
		}
	}

	final override void ToString(in out Array<string> readout) const
	{
		readout.Push(String.Format(
			StringTable.Localize("$BIO_HDF_ENEMYHEALTHDMG"),
			Factor * 100.0));
	}
}

class BIO_WAfx_DamageInverseHealth : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void BeforeEachFire(BIO_Weapon weap, in out BIO_FireData fireData) const
	{
		fireData.Damage *= (1.0 + Log(
			float(weap.Owner.GetMaxHealth() /
			float(weap.Owner.Health))));
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_DMGINVERSEHEALTH_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DMGINVERSEHEALTH_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// Constrains pipeline damage to only its maximum possible value.
class BIO_WAfx_MaxDamageOnly : BIO_WeaponAffix
{
	Array<bool> Applicability;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			if (CompatibleWithPipeline(weap.Pipelines[i].AsConst()))
				return true;

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
			Applicability.Push(CompatibleWithPipeline(
				weap.Pipelines[i].AsConst()));
	}

	private static bool CompatibleWithPipeline(readOnly<BIO_WeaponPipeline> ppl)
	{
		let minDmg = float(ppl.GetMinDamage()), maxDmg = float(ppl.GetMaxDamage());
	
		if (minDmg ~== maxDmg)
			return false;

		if (maxDmg > (maxDmg * 4.0))
			return false;

		return true;
	}

	final override void BeforeEachFire(BIO_Weapon weap, in out BIO_FireData fireData) const
	{
		if (Applicability[weap.LastPipelineFiredIndex()])
			fireData.Damage = weap.LastPipelineFired().GetMaxDamage();
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < Applicability.Size(); i++)
		{
			if (!Applicability[i]) continue;

			string qual = "";

			if (Applicability.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MAXDAMAGEONLY_TOSTR"), qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MAXDAMAGEONLY_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override bool ImplicitExplicitExclusive() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// 200% ammo use, but more than double damage.
class BIO_WAfx_DamageForAmmoUse : BIO_WeaponAffix
{
	// One per pipeline; if pipeline is incompatible, value will be 0.0;
	// value + 1.0 is passed to `BIO_WeaponPipeline::MultiplyAllDamage()`
	Array<float> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].DealsAnyDamage())
				continue;

			if (!weap.Pipelines[i].UsesSecondaryAmmo() &&
				weap.ShotsPerMagazine(false) > 1)
				return true;
			else if (weap.Pipelines[i].UsesSecondaryAmmo() &&
				weap.ShotsPerMagazine(true) > 1)
				return true;
		}

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		bool
			prim = weap.ShotsPerMagazine(false) > 1,
			sec = weap.ShotsPerMagazine(true) > 1;

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].UsesSecondaryAmmo() && prim)
				Modifiers.Push(FRandom[BIO_Afx](1.5, 2.0));
			else if (weap.Pipelines[i].UsesSecondaryAmmo() && sec)
				Modifiers.Push(FRandom[BIO_Afx](1.5, 2.0));
			else
				Modifiers.Push(0.0);
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (weap.ShotsPerMagazine(false) > 1)
			weap.AmmoUse1 *= 2;
		if (weap.ShotsPerMagazine(true) > 1)
			weap.AmmoUse2 *= 2;

		for (uint i = 0; i < Modifiers.Size(); i++)
			weap.Pipelines[i].MultiplyAllDamage(1.0 + Modifiers[i]);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0.0) continue;

			string qual = "";

			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_DAMAGEFORAMMOUSE_TOSTR"),
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0.0 ? "+" : "", 1.0 + Modifiers[i] * 100.0, qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DAMAGEFORAMMOUSE_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// LegenDoom(Lite) exclusive. 400% damage to Legendary enemies.
class BIO_WAfx_DemonSlayer : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			weap.Pipelines[i].PushHitDamageFunctor(new('BIO_HDF_DemonSlayer'));
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_DEMONSLAYER_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_DEMONSLAYER_TAG");
	}

	final override bool CanGenerate() const
	{
		name ldToken_tn = 'LDLegendaryMonsterToken';
		Class<Inventory> ldToken_t = ldToken_tn;
		return ldToken_t != null;
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override bool ImplicitExplicitExclusive() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_HDF_DemonSlayer : BIO_HitDamageFunctor
{
	final override void InvokeTrue(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null) return;
		
		if (BIO_Utils.TryFindInv(target, "LDLegendaryMonsterToken"))
		{
			damage *= 4;
			proj.DamageType = 'DemonSlayer';
			proj.DamageMultiply = 4.0;
		}
	}

	final override void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		if (target == null) return;

		if (BIO_Utils.TryFindInv(target, "LDLegendaryMonsterToken"))
		{
			damage *= 4;
			proj.DamageType = 'DemonSlayer';
			proj.DamageMultiply = 4.0;
		}
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		if (puff.Tracer == null) return;

		if (BIO_Utils.TryFindInv(puff.Tracer, "LDLegendaryMonsterToken"))
		{
			puff.Tracer.DamageMObj(puff, null, puff.Damage * 3, 'DemonSlayer');
			puff.DamageMultiply = 4.0;
		}
	}
	
	override void ToString(in out Array<string> _) const
	{
		// Nothing needed here; the affix to-string tells all
	}
}
