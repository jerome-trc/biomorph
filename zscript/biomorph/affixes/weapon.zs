// Damage ======================================================================

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

			Modifiers.Push(Random[BIO_Afx](vals[0] / 2, vals[0] * 2));
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

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

// Only compatible with pistol-type weapons, to give them an edge.
class BIO_WAfx_Crit : BIO_WeaponAffix
{
	uint Chance;
	float DamageMulti; // Percentage of rolled damage added to outgoing damage

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Chance = Random[BIO_Afx](15, 30);
		DamageMulti = FRandom[BIO_Afx](1.0, 2.0);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.BIOFlags & BIO_WF_PISTOL;
	}

	final override void BeforeAllFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		if (Random(0, 100) < Chance)
		{
			fireData.Critical = true;
			weap.Owner.A_StartSound("bio/weap/crit", CHAN_AUTO);
			weap.OnCriticalShot(fireData);
		}
	}

	final override void BeforeEachFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		if (fireData.Critical)
			fireData.Damage += (fireData.Damage * DamageMulti);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(StringTable.Localize("$BIO_WAFX_CRIT_TOSTR"),
			Chance, DamageMulti > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			DamageMulti > 0.0 ? "+" : "", int(DamageMulti * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_CRIT_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE | BIO_WAF_CRIT;
	}
}

// All splash damage on the fired thing is converted into direct hit damage.
class BIO_WAfx_SplashForDamage : BIO_WeaponAffix
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
			"$BIO_WAFX_SPLASHFORDAMAGE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPLASHFORDAMAGE_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE | BIO_WAF_SPLASH;
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
		if (puff.Target != null)
		{
			int dmg = puff.Target.Health * Factor;
			puff.Target.DamageMObj(puff, null, dmg, puff.DamageType);
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
		if (puff.Target == null) return;

		if (BIO_Utils.TryFindInv(puff.Target, "LDLegendaryMonsterToken"))
		{
			puff.Target.DamageMObj(puff, null, puff.Damage * 3, 'DemonSlayer');
			puff.DamageMultiply = 4.0;
		}
	}
	
	override void ToString(in out Array<string> _) const
	{
		// Nothing needed here; the affix to-string tells all
	}
}

// New fire type ===============================================================

class BIO_WAfx_Plasma : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_PlasmaBall'))
				return false;
			if (!weap.Pipelines[i].CanFireProjectiles() &&
				!weap.Pipelines[i].FireFunctorMutable())
				return false;

			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_PlasmaBall'))
				continue;

			bool cfp = weap.Pipelines[i].CanFireProjectiles();
			
			if (!cfp)
			{
				if (!weap.Pipelines[i].FireFunctorMutable())
					continue;
				else
					weap.Pipelines[i].SetFireFunctor(new('BIO_FireFunc_Projectile'));
			}

			weap.Pipelines[i].SetFireType('BIO_PlasmaBall');
			weap.Pipelines[i].MultiplyAllDamage(1.25);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PLASMA_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PLASMA_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRETYPE | BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_Slug : BIO_WeaponAffix
{
	// Weapon must be firing shot pellets for this affix to be applicable.	
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableFrom('BIO_ShotPellet'))
				return false;
			if (!weap.Pipelines[i].DamageMutable() ||
				!weap.Pipelines[i].SpreadMutable())
				return false;
			if (!weap.Pipelines[i].CanFirePuffs() &&
				!weap.Pipelines[i].FireFunctorMutable())
				return false;

			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableFrom('BIO_ShotPellet'))
				continue;

			bool cfp = weap.Pipelines[i].CanFirePuffs();
			
			if (!cfp)
			{
				if (!weap.Pipelines[i].FireFunctorMutable())
					continue;
				else
					weap.Pipelines[i].SetFireFunctor(new('BIO_FireFunc_Bullet'));
			}

			weap.Pipelines[i].SetFireType('BIO_Slug');
			uint fc = weap.Pipelines[i].GetFireCount();
			weap.Pipelines[i].SetFireCount(fc / fc);
			weap.Pipelines[i].MultiplyAllDamage(float(fc));
			weap.Pipelines[i].SetSpread(0.5, 0.5);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_SLUG_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SLUG_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRETYPE | BIO_WAF_FIRECOUNT | BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_MiniMissile : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_MiniMissile'))
				return false;
			if (!weap.Pipelines[i].SplashMutable())
				return false;
			if (!weap.Pipelines[i].CanFireProjectiles() &&
				!weap.Pipelines[i].FireFunctorMutable())
				return false;
			
			return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FireTypeMutableTo('BIO_MiniMissile') ||
				!weap.Pipelines[i].SplashMutable())
				continue;

			bool cfp = weap.Pipelines[i].CanFireProjectiles();
			
			if (!cfp)
			{
				if (!weap.Pipelines[i].FireFunctorMutable())
					continue;
				else
					weap.Pipelines[i].SetFireFunctor(new('BIO_FireFunc_Projectile'));
			}

			weap.Pipelines[i].SetFireType('BIO_MiniMissile');
			let defs = GetDefaultByType('BIO_MiniMissile');
			weap.Pipelines[i].SetSplash(48, 48);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_MINIMISSILE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MINIMISSILE_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRETYPE;
	}
}

// Modify fired thing ==========================================================

class BIO_WAfx_ForcePain : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const { return true; }

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForcePain = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForcePain = true;
	}

	final override void OnPuffFired(BIO_Weapon weap, BIO_Puff puff) const
	{
		if (puff.Target != null)
			puff.Target.TriggerPainChance(puff.DamageType, true);
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_FORCEPAIN_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FORCEPAIN_TAG");
	}
	
	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED;
	}
}

class BIO_WAfx_ForceRadiusDmg : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresProjectile();
	}

	final override void OnTrueProjectileFired(
		BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForceRadiusDmg = true;
	}

	final override void OnFastProjectileFired(
		BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForceRadiusDmg = true;
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_FORCERADIUSDMG_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FORCERADIUSDMG_TAG");
	}

	final override bool CanGenerate() const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED;
	}
}

class BIO_WAfx_ProjSeek : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresTrueProjectile();
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bSeekerMissile = true;
		proj.SeekAngle = 4;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PROJSEEK_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJSEEK_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED;
	}
}

class BIO_WAfx_ProjGravity : BIO_WeaponAffix
{
	float Multi;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Multi = FRandom[BIO_Afx](0.5, 1.0);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresTrueProjectile();
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].FiresTrueProjectile()) continue;
			weap.Pipelines[i].MultiplyAllDamage(1.0 + Multi);
		}
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bNoGravity = false;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(StringTable.Localize("$BIO_WAFX_PROJGRAVITY_TOSTR"),
			Multi >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Multi >= 0 ? "+" : "", int(Multi * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJGRAVITY_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED | BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_ProjBounce : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FiresTrueProjectile();
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bBounceOnWalls = true;
		proj.bBounceOnFloors = true;
		proj.bBounceOnCeilings = true;
		proj.bAllowBounceOnActors = true;
		proj.bBounceAutoOff = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bBounceOnWalls = true;
		proj.bBounceOnFloors = true;
		proj.bBounceOnCeilings = true;
		proj.bAllowBounceOnActors = true;
		proj.bBounceAutoOff = true;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PROJBOUNCE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJBOUNCE_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONPROJFIRED;
	}
}

// Timing ======================================================================

class BIO_WAfx_FireTime : BIO_WeaponAffix
{
	// One per state time group. Negative number = faster firing
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.FireTimesMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.FireTimeGroups.Size(); i++)
		{
			int poss = weap.FireTimeGroups[i].PossibleReduction();

			if (poss < 1)
				Modifiers.Push(0);
			else
				Modifiers.Push(-Random[BIO_Afx](1, poss));
		}
	}

	final override void Apply(BIO_Weapon weap)
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;
			weap.ModifyFireTime(i, Modifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			let grpTag = StringTable.Localize(weap.FireTimeGroups[i].Tag);
			if (grpTag.Length() > 1)
				grpTag = " (" .. grpTag .. ") ";

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRETIME_TOSTR"), grpTag,
				BIO_Utils.StatFontColor(Modifiers[i], 0, true),
				Modifiers[i] >= 0 ? "+" : "", float(Modifiers[i]) / 35.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FIRETIME_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_FIRETIME;
	}
}

class BIO_WAfx_ReloadTime : BIO_WeaponAffix
{
	// One per state time group. Negative number = faster reloading
	Array<int> Modifiers;

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.ReloadTimesMutable();
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
		{
			int poss = weap.ReloadTimeGroups[i].PossibleReduction();

			if (poss < 1)
				Modifiers.Push(0);
			else
				Modifiers.Push(-Random[BIO_Afx](1, poss));
		}
	}

	final override void Apply(BIO_Weapon weap)
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;
			weap.ModifyReloadTime(i, Modifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings, readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] == 0) continue;

			let grpTag = StringTable.Localize(weap.ReloadTimeGroups[i].Tag);
			if (grpTag.Length() > 1)
				grpTag = " (" .. grpTag .. ") ";

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_RELOADTIME_TOSTR"), grpTag,
				BIO_Utils.StatFontColor(Modifiers[i], 0, true),
				Modifiers[i] >= 0 ? "+" : "", float(Modifiers[i]) / 35.0));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_RELOADTIME_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_RELOADTIME;
	}
}

// On-kill effects =============================================================

class BIO_WAfx_InfiniteAmmoOnKill : BIO_WeaponAffix
{
	// % chance out of 100 and duration in seconds
	int Chance, Duration;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Chance = Random[BIO_Afx](3, 6);
		Duration = Random[BIO_Afx](5, 10);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const { return true; }

	final override void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const
	{
		if (!weap.Switching() && Random(0, 100) < Chance)
		{
			let giver = PowerupGiver(Actor.Spawn('PowerupGiver', weap.Owner.Pos));

			if (giver != null)
			{
				weap.Owner.A_StartSound("bio/weap/rampage", CHAN_BODY);
				giver.PowerupType = 'BIO_PowerInfiniteAmmo';
				giver.EffectTics = GameTicRate * Duration;
				giver.AttachToOwner(weap.Owner);
				giver.Use(false);
			}
			else
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Failed to grant an infinite ammo powerup after a kill.");
			}
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_INFINITEAMMOONKILL_TOSTR"),
			Chance, Duration));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_INFINITEAMMOONKILL_TAG");	
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ONKILL;
	}
}

// Melee-only ==================================================================

// Comes implicitly with the fist at a 10.0 multiplier, but can generate
// as an explicit affix from mutation with a significantly smaller multiplier.
class BIO_WAfx_BerserkDamage : BIO_WeaponAffix
{
	float Multiplier;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Multiplier = FRandom[BIO_Afx](1.5, 3.5);
	}

	// This can't generate on weapons with implicit berserk damage.
	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return weap.HasMeleePipeline() && !weap.HasAffixOfType(GetClass(), true);
	}

	final override void BeforeEachFire(BIO_Weapon weap,
		in out BIO_FireData fireData) const
	{
		if (fireData.FireType is 'BIO_MeleeHit' &&
			weap.Owner.FindInventory('PowerStrength', true))
			fireData.Damage *= Multiplier;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_BERSERKDMG_TOSTR"),
			BIO_Utils.StatFontColorF(Multiplier, 1.0),
			int(Multiplier * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_BERSERKDMG_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}

class BIO_WAfx_Lifesteal : BIO_WeaponAffix
{
	Array<float> AddPercents; // One per pipeline (might be 0.0)

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].IsMelee() &&
				weap.Pipelines[i].FireFunctorMutable())
				return true;
		}

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].IsMelee() ||
				!weap.Pipelines[i].FireFunctorMutable())
			{
				AddPercents.Push(0.0);
				continue;
			}

			AddPercents.Push(FRandom[BIO_Afx](0.2, 0.8));
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (AddPercents[i] ~== 0.0) continue;
			let ff = BIO_FireFunc_Melee(weap.Pipelines[i].GetFireFunctor());
			ff.Lifesteal += AddPercents[i];
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < AddPercents.Size(); i++)
		{
			if (AddPercents[i] ~== 0.0) continue;

			string qual = "";

			if (AddPercents.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_LIFESTEAL_TOSTR"),
				int(AddPercents[i] * 100.0), qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_LIFESTEAL_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_LIFESTEAL;
	}
}

class BIO_WAfx_MeleeRange : BIO_WeaponAffix
{
	Array<float> Modifiers; // One per pipeline (0.0 if not applicable)

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].IsMelee() &&
				weap.Pipelines[i].FireFunctorMutable())
				return true;
		}

		return false;
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].IsMelee() ||
				!weap.Pipelines[i].FireFunctorMutable())
			{
				Modifiers.Push(0.0);
				continue;
			}

			let ff = BIO_FireFunc_Melee(weap.Pipelines[i].GetFireFunctor());
			Modifiers.Push(FRandom[BIO_Afx](ff.Range * 0.25, ff.Range * 0.5));
		}
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;
			let ff = BIO_FireFunc_Melee(weap.Pipelines[i].GetFireFunctor());
			ff.Range += Modifiers[i];
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i] ~== 0.0) continue;

			string qual = "";
			
			if (Modifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MELEERANGE_TOSTR"),
				BIO_Utils.StatFontColorF(Modifiers[i], 0.0),
				Modifiers[i] >= 0 ? "+" : "", Modifiers[i], qual));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MELEERANGE_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_MELEERANGE;
	}
}

// Miscellaneous ===============================================================

class BIO_WAfx_Spread : BIO_WeaponAffix
{
	Array<float> HorizModifiers, VertModifiers;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (!weap.Pipelines[i].SpreadMutable() ||
				!weap.Pipelines[i].NonTrivialSpread())
			{
				HorizModifiers.Push(0.0);
				VertModifiers.Push(0.0);	
			}
			else
			{
				float hSpread = 0.0, vSpread = 0.0;
				[hSpread, vSpread] = weap.Pipelines[i].GetSpread();
				HorizModifiers.Push(-FRandom[BIO_Afx](
					Min(0.1, hSpread), hSpread));
				VertModifiers.Push(-FRandom[BIO_Afx](
					Min(0.1, vSpread), vSpread));
			}
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (weap.Pipelines[i].SpreadMutable() &&
				weap.Pipelines[i].NonTrivialSpread())
				return true;
		}

		return false;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			if (HorizModifiers[i] == 0.0 && VertModifiers[i] == 0.0)
				continue;

			weap.Pipelines[i].SetSpread(
				weap.Pipelines[i].GetHSpread() + HorizModifiers[i],
				weap.Pipelines[i].GetVSpread() + VertModifiers[i]);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		for (uint i = 0; i < HorizModifiers.Size(); i++)
		{
			if (HorizModifiers[i] == 0.0 && VertModifiers[i] == 0.0)
				continue;
			
			string qual = "";

			if (HorizModifiers.Size() > 1)
				qual = " " .. weap.Pipelines[i].GetTagAsQualifier();

			if (HorizModifiers[i] != 0.0)
			{
				strings.Push(String.Format(
					StringTable.Localize("$BIO_WAFX_SPREAD_TOSTR_H"), qual,
					BIO_Utils.StatFontColorF(HorizModifiers[i], 0.0, true),
					HorizModifiers[i] > 0.0 ? "+" : "", HorizModifiers[i]));
			}

			if (VertModifiers[i] != 0.0)
			{
				strings.Push(String.Format(
					StringTable.Localize("$BIO_WAFX_SPREAD_TOSTR_V"), qual,
					BIO_Utils.StatFontColorF(VertModifiers[i], 0.0, true),
					VertModifiers[i] > 0.0 ? "+" : "", VertModifiers[i]));
			}
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPREAD_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_ACCURACY;
	}
}

class BIO_WAfx_SwitchSpeed : BIO_WeaponAffix
{
	int Modifier;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Modifier = Random[BIO_Afx](5, 9);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return
			!(weap.AffixMask & BIO_WAM_LOWERSPEED) ||
			!(weap.AffixMask & BIO_WAM_RAISESPEED);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask & BIO_WAM_LOWERSPEED))
			weap.LowerSpeed += Modifier;
		if (!(weap.AffixMask & BIO_WAM_RAISESPEED))
			weap.RaiseSpeed += Modifier;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		if (!(weap.AffixMask & BIO_WAM_LOWERSPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TOSTR_LOWER"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.LowerSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));	
		}

		if (!(weap.AffixMask & BIO_WAM_RAISESPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TOSTR_RAISE"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.RaiseSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_SWITCHSPEED;
	}
}

class BIO_WAfx_Kickback : BIO_WeaponAffix
{
	int Modifier;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Modifier = Random[BIO_Afx](200, 400);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return !(weap.AffixMask & BIO_WAM_KICKBACK);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		weap.Kickback += Modifier;
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_KICKBACK_TOSTR"),
			Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			(float(Modifier) / float(weap.Kickback)) * 100.0,
			StringTable.Localize(Modifier > 0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_KICKBACK_TAG");
	}

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_KICKBACK;
	}
}
