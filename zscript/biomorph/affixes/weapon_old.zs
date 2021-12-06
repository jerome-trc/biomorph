// Damage ======================================================================

// n% of the hit enemy's health is given to the projectile's dealt damage.
class BIO_WAFX_EnemyHealthDamage : BIO_WeaponAffix
{
	float Factor;

	final override void Init(BIO_Weapon weap)
	{
		Factor = FRandom(0.025, 0.05);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.AffixMask1 & BIO_WAM_HitDamageFunctors) ||
			!(weap.AffixMask2 & BIO_WAM_HitDamageFunctors);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		uint e = weap.HitDamageFunctors.Push(new('BIO_ProjDmgFunc_EnemyHealthDamage'));
		let func = BIO_ProjDmgFunc_EnemyHealthDamage(weap.HitDamageFunctors[e]);
		func.Factor = Factor;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
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
}

class BIO_ProjDmgFunc_EnemyHealthDamage : BIO_HitDamageFunctor
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

	final override void ToString(in out Array<string> readout) const
	{
		readout.Push(String.Format(
			StringTable.Localize("$BIO_HDF_ENEMYHEALTHDMG"),
			Factor * 100.0));
	}
}

// Only compatible with pistol-type weapons, to give them an edge.
class BIO_WAFX_Crit : BIO_WeaponAffix
{
	uint Chance;
	float DamageMulti; // Percentage of rolled damage added to outgoing damage

	final override void Init(BIO_Weapon weap)
	{
		Chance = Random(15, 30);
		DamageMulti = FRandom(1.0, 2.0);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return weap.BIOFlags & BIO_WF_PISTOL;
	}

	final override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		if (Random(0, 100) < Chance)
		{
			dmg += (dmg * DamageMulti);
			weap.Owner.A_StartSound("bio/weap/crit", CHAN_AUTO);
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(StringTable.Localize("$BIO_WAFX_CRIT_TOSTR"),
			Chance, DamageMulti > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			DamageMulti > 0.0 ? "+" : "", int(DamageMulti * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_CRIT_TAG");
	}
}

// All splash damage on the fired projectile is converted into direct hit damage.
class BIO_WAFX_SplashForDamage : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return PrimaryCompatible(weap) || SecondaryCompatible(weap);
	}

	protected bool PrimaryCompatible(BIO_Weapon weap) const
	{
		return weap.Splashes(false);
	}

	protected bool SecondaryCompatible(BIO_Weapon weap) const
	{
		return weap.Splashes(true);
	}

	final override void ModifySplash(BIO_Weapon weap, in out int dmg, in out int radius,
		in out int baseDmg) const
	{
		baseDmg += Max(dmg, 0);
		dmg = 0;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(CRESC_MIXED .. StringTable.Localize(
			"$BIO_WAFX_SPLASHFORDAMAGE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPLASHFORDAMAGE_TAG");
	}
}

// More damage added to the projectile if the wielder is moving forward.
class BIO_WAFX_ForwardDamage : BIO_WeaponAffix
{
	float Multi;

	final override void Init(BIO_Weapon weap)
	{
		Multi = FRandom(0.25, 0.75);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		if (weap.Owner.Player.Cmd.Buttons & BT_FORWARD)
		{
			dmg += (dmg * Multi);
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
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
}

// More damage added to the projectile if the wielder is strafing.
class BIO_WAFX_StrafeDamage : BIO_WeaponAffix
{
	float Multi;

	final override void Init(BIO_Weapon weap)
	{
		Multi = FRandom(0.25, 0.75);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DealsAnyDamage();
	}

	final override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		if (weap.Owner.Player.Cmd.Buttons & BT_MOVELEFT ||
			weap.Owner.Player.Cmd.Buttons & BT_MOVERIGHT)
		{
			dmg += (dmg * Multi);
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
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
}

// New fire type ===============================================================

class BIO_WAFX_Plasma : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return PrimaryCompatible(weap) || SecondaryCompatible(weap);
	}

	private bool PrimaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo('BIO_PlasmaBall', true, false) &&
			(weap.AffixMask1 & BIO_WAM_DAMAGE) != BIO_WAM_DAMAGE;
	}

	private bool SecondaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo('BIO_PlasmaBall', true, true) &&
			(weap.AffixMask1 & BIO_WAM_DAMAGE) != BIO_WAM_DAMAGE;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (PrimaryCompatible(weap))
		{
			weap.FireType1 = 'BIO_PlasmaBall';
			weap.MinDamage1 *= 0.5;
			weap.MaxDamage1 *= 2.0;
		}
		
		if (SecondaryCompatible(weap))
		{
			weap.FireType2 = 'BIO_PlasmaBall';
			weap.MinDamage2 *= 0.5;
			weap.MaxDamage2 *= 2.0;
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PLASMA_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PLASMA_TAG");
	}
}

class BIO_WAFX_Slug : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	// Weapon must be firing shot pellets for this affix to be applicable.
	final override bool Compatible(BIO_Weapon weap) const
	{
		return PrimaryCompatible(weap) || SecondaryCompatible(weap);
	}
	
	private bool PrimaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableFrom('BIO_ShotPellet', true, false) &&
			!(weap.AffixMask1 & BIO_WAM_SPREAD) &&
			!(weap.AffixMask1 & BIO_WAM_DAMAGE);
	}

	private bool SecondaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableFrom('BIO_ShotPellet', true, true) &&
			!(weap.AffixMask2 & BIO_WAM_SPREAD) &&
			!(weap.AffixMask2 & BIO_WAM_DAMAGE);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		weap.UpdateDictionary();

		if (PrimaryCompatible(weap))
		{
			bool valid = false;
			string val = "";
			[val, valid] = weap.TryGetDictValue(BIO_Weapon.DICTKEY_PELLETCOUNT_1);

			if (!valid)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"%s is a shotgun with no %s dictionary value.",
					weap.GetClassName(), BIO_Weapon.DICTKEY_PELLETCOUNT_1);
			}
			else
			{
				int pc1 = val.ToInt();
				weap.FireType1 = 'BIO_Slug';
				weap.FireCount1 /= pc1;
				weap.MinDamage1 *= pc1;
				weap.MaxDamage1 *= pc1;
				weap.HSpread1 = 0.1;
				weap.VSpread1 = 0.1;
			}
		}
		
		if (SecondaryCompatible(weap))
		{
			bool valid = false;
			string val = "";
			[val, valid] = weap.TryGetDictValue(BIO_Weapon.DICTKEY_PELLETCOUNT_2);

			if (!valid)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"%s is a shotgun with no %s dictionary value.",
					weap.GetClassName(), BIO_Weapon.DICTKEY_PELLETCOUNT_2);
			}
			else
			{
				int pc2 = val.ToInt();
				weap.FireType2 = 'BIO_Slug';
				weap.FireCount2 /= pc2;
				weap.MinDamage2 *= pc2;
				weap.MaxDamage2 *= pc2;
				weap.HSpread2 = 0.1;
				weap.VSpread2 = 0.1;
			}
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_SLUG_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SLUG_TAG");
	}
}

class BIO_WAFX_MiniMissile : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo('BIO_MiniMissile', true, false) ||
			weap.FireTypeMutableTo('BIO_MiniMissile', true, true);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (weap.FireTypeMutableTo('BIO_MiniMissile', true, false))
			weap.FireType1 = 'BIO_MiniMissile';
		
		if (weap.FireTypeMutableTo('BIO_MiniMissile', true, true))
			weap.FireType2 = 'BIO_MiniMissile';
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_MINIMISSILE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MINIMISSILE_TAG");
	}
}

// Modify fired thing ==========================================================

class BIO_WAFX_ForcePain : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.bMeleeWeapon)
			return false;
		else
			return (weap.AffixMask1 & BIO_WAM_ONPROJFIRED) != BIO_WAM_ONPROJFIRED;
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForcePain = true;
	}

	final override void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForcePain = true;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_FORCEPAIN_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FORCEPAIN_TAG");
	}
}

class BIO_WAFX_ProjGravity : BIO_WeaponAffix
{
	float Multi;

	final override void Init(BIO_Weapon weap)
	{
		Multi = FRandom(0.5, 1.0);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return weap.FiresTrueProjectile(false) || weap.FiresTrueProjectile(true);
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bNoGravity = false;
	}

	final override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		dmg += (dmg * Multi);
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(StringTable.Localize("$BIO_WAFX_PROJGRAVITY_TOSTR"),
			Multi >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Multi >= 0 ? "+" : "", int(Multi * 100.0)));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJGRAVITY_TAG");
	}
}

class BIO_WAFX_ProjBounce : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return weap.FiresTrueProjectile(false) || weap.FiresTrueProjectile(true);
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

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PROJBOUNCE_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJBOUNCE_TAG");
	}
}

class BIO_WAFX_ProjSeek : BIO_WeaponAffix
{
	final override void Init(BIO_Weapon weap) {}

	final override bool Compatible(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 == BIO_WAM_ALL) && weap.FiresTrueProjectile(false))
			return true;
		else if (!(weap.AffixMask2 == BIO_WAM_ALL) && weap.FiresTrueProjectile(true))
			return true;
		else
			return false;
	}

	final override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.Seek = true;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_PROJSEEK_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_PROJSEEK_TAG");
	}
}

// Miscellaneous ===============================================================

class BIO_WAFX_FireCount : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	final override void Init(BIO_Weapon weap)
	{
		if (weap.FireCount1 <= 1)
			Modifier1 = Random(1, 2);
		else
			Modifier1 = Random(1, weap.FireCount1);

		if (weap.FireCount2 <= 1)
			Modifier2 = Random(1, 2);
		else
			Modifier2 = Random(1, weap.FireCount2);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.bMeleeWeapon) return false;

		bool ret = false;

		if (weap.FireCount1 != 0 && !(weap.AffixMask1 & BIO_WAM_FIRECOUNT))
			ret = true;
		if (weap.FireCount2 != 0 && !(weap.AffixMask2 & BIO_WAM_FIRECOUNT))
			ret = true;

		return ret;
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_FIRECOUNT))
		{
			if (weap.FireCount1 == -1) weap.FireCount1 = 1;
			weap.FireCount1 += Modifier1;
		}
		
		if (!(weap.AffixMask2 & BIO_WAM_FIRECOUNT))
		{
			if (weap.FireCount2 == -1) weap.FireCount2 = 1;
			weap.FireCount2 += Modifier2;
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (weap.AffixMask2 & BIO_WAM_FIRECOUNT)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRECOUNT1_TOSTR"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1, weap.GetFireTypeTag(false)));
		}
		else if (weap.AffixMask1 & BIO_WAM_FIRECOUNT)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRECOUNT2_TOSTR"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2, weap.GetFireTypeTag(true)));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_FIRECOUNT_TOSTR"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1, weap.GetFireTypeTag(false),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2, weap.GetFireTypeTag(true)));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_FIRECOUNT_TAG");
	}
}

class BIO_WAFX_Spread : BIO_WeaponAffix
{
	float HSpread1, VSpread1, HSpread2, VSpread2;

	final override void Init(BIO_Weapon weap)
	{
		HSpread1 = -(FRandom(0.1, weap.HSpread1) / 2.0);
		VSpread1 = -(FRandom(0.1, weap.VSpread1) / 2.0);
		HSpread2 = -(FRandom(0.1, weap.HSpread2) / 2.0);
		VSpread2 = -(FRandom(0.1, weap.VSpread2) / 2.0);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return
			weap.HasAnySpread() &&
			!((weap.AffixMask1 & BIO_WAM_SPREAD) == BIO_WAM_SPREAD) ||
			!((weap.AffixMask2 & BIO_WAM_SPREAD) == BIO_WAM_SPREAD);
	}

	final override void Apply(BIO_Weapon weap)
	{
		if (!(weap.AffixMask1 & BIO_WAM_HSPREAD))
			weap.HSpread1 += HSpread1;
		if (!(weap.AffixMask1 & BIO_WAM_VSPREAD))
			weap.VSpread1 += VSpread1;

		if (!(weap.AffixMask2 & BIO_WAM_HSPREAD))
			weap.HSpread2 += HSpread2;
		if (!(weap.AffixMask2 & BIO_WAM_VSPREAD))
			weap.VSpread2 += VSpread2;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		string output = StringTable.Localize("$BIO_WAFX_SPREAD_TOSTR");

		if (!(weap.AffixMask1 & BIO_WAM_HSPREAD))
			output.AppendFormat("%s%s%.1f/",
			HSpread1 >= 0.0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			HSpread1 >= 0.0 ? "+" : "", HSpread1);

		if (!(weap.AffixMask1 & BIO_WAM_VSPREAD))
			output.AppendFormat("%s%s%.1f ",
			VSpread1 >= 0.0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			VSpread1 >= 0.0 ? "+" : "", VSpread1);

		if (!(weap.AffixMask2 & BIO_WAM_HSPREAD))
			output.AppendFormat("%s%s%.1f/",
			HSpread2 >= 0.0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			HSpread2 >= 0.0 ? "+" : "", HSpread2);

		if (!(weap.AffixMask2 & BIO_WAM_VSPREAD))
			output.AppendFormat("%s%s%.1f ",
			VSpread2 >= 0.0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			VSpread2 >= 0.0 ? "+" : "", VSpread2);

		output.DeleteLastCharacter();
		strings.Push(output);
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SPREAD_TAG");
	}
}

class BIO_WAFX_Kickback : BIO_WeaponAffix
{
	int Modifier;

	final override void Init(BIO_Weapon weap)
	{
		Modifier = Random(200, 400);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return !(weap.MiscAffixMask & BIO_WAM_KICKBACK);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		weap.Kickback += Modifier;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
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
}

class BIO_WAFX_MeleeRange : BIO_WeaponAffix
{
	float Modifier1, Modifier2;

	final override void Init(BIO_Weapon weap)
	{
		if (weap is 'BIO_MeleeWeapon')
		{
			let mWeap = BIO_MeleeWeapon(weap);

			Modifier1 = FRandom(mWeap.MeleeRange1 * 0.25, mWeap.MeleeRange1 * 0.5);
			Modifier2 = FRandom(mWeap.MeleeRange2 * 0.25, mWeap.MeleeRange2 * 0.5);
		}
		else if (weap is 'BIO_DualMeleeWeapon')
		{
			let mWeap = BIO_DualMeleeWeapon(weap);

			Modifier1 = FRandom(mWeap.MeleeRange1 * 0.25, mWeap.MeleeRange1 * 0.5);
			Modifier2 = FRandom(mWeap.MeleeRange2 * 0.25, mWeap.MeleeRange2 * 0.5);
		}
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return
			(weap is 'BIO_MeleeWeapon' || weap is 'BIO_DualMeleeWeapon') &&
			!(
				(weap.AffixMask1 & BIO_WAM_MELEERANGE) &&
				(weap.AffixMask2 & BIO_WAM_MELEERANGE)
			);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (weap is 'BIO_MeleeWeapon')
		{
			let mWeap = BIO_MeleeWeapon(weap);

			if (!(weap.AffixMask1 & BIO_WAM_MELEERANGE))
				mWeap.MeleeRange1 += Modifier1;
			if (!(weap.AffixMask2 & BIO_WAM_MELEERANGE))
				mWeap.MeleeRange2 += Modifier2;
		}
		else if (weap is 'BIO_DualMeleeWeapon')
		{
			let mWeap = BIO_DualMeleeWeapon(weap);

			if (!(weap.AffixMask1 & BIO_WAM_MELEERANGE))
				mWeap.MeleeRange1 += Modifier1;
			if (!(weap.AffixMask2 & BIO_WAM_MELEERANGE))
				mWeap.MeleeRange2 += Modifier2;
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_MELEERANGE))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MELEERANGE1_TOSTR"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1));
		}
		
		if (!(weap.AffixMask2 & BIO_WAM_MELEERANGE))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_MELEERANGE2_TOSTR"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_MELEERANGE_TAG");
	}
}

class BIO_WAFX_LifeSteal : BIO_WeaponAffix
{
	float AddPercent;
	
	final override void Init(BIO_Weapon weap) { AddPercent = FRandom(0.2, 0.8); }

	final override bool Compatible(BIO_Weapon weap) const
	{
		return
			(weap is 'BIO_MeleeWeapon' || weap is 'BIO_DualMeleeWeapon') &&
			!(
				(weap.AffixMask1 & BIO_WAM_LIFESTEAL) &&
				(weap.AffixMask2 & BIO_WAM_LIFESTEAL)
			);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (weap is 'BIO_MeleeWeapon')
		{
			let mWeap = BIO_MeleeWeapon(weap);

			if (!(weap.AffixMask1 & BIO_WAM_LIFESTEAL))
				mWeap.LifeSteal1 += AddPercent;
			if (!(weap.AffixMask2 & BIO_WAM_LIFESTEAL))
				mWeap.LifeSteal2 += AddPercent;
		}
		else if (weap is 'BIO_DualMeleeWeapon')
		{
			let mWeap = BIO_DualMeleeWeapon(weap);

			if (!(weap.AffixMask1 & BIO_WAM_LIFESTEAL))
				mWeap.LifeSteal1 += AddPercent;
			if (!(weap.AffixMask2 & BIO_WAM_LIFESTEAL))
				mWeap.LifeSteal2 += AddPercent;
		}
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_MELEERANGE))
		{
			strings.Push(CRESC_POSITIVE .. String.Format(
				StringTable.Localize("$BIO_WAFX_LIFESTEAL1_TOSTR"),
				int(AddPercent * 100.0)));
		}
		
		if (!(weap.AffixMask2 & BIO_WAM_MELEERANGE))
		{
			strings.Push(CRESC_POSITIVE .. String.Format(
				StringTable.Localize("$BIO_WAFX_LIFESTEAL2_TOSTR"),
				int(AddPercent * 100.0)));
		}
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_LIFESTEAL_TAG");
	}
}

class BIO_WAFX_SwitchSpeed : BIO_WeaponAffix
{
	int Modifier;

	final override void Init(BIO_Weapon weap)
	{
		Modifier = Random(5, 9);
	}

	final override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.MiscAffixMask & BIO_WAM_LOWERSPEED) ||
			!(weap.MiscAffixMask & BIO_WAM_RAISESPEED);
	}

	final override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.MiscAffixMask & BIO_WAM_LOWERSPEED))
			weap.LowerSpeed += Modifier;
		if (!(weap.MiscAffixMask & BIO_WAM_RAISESPEED))
			weap.RaiseSpeed += Modifier;
	}

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (!(weap.MiscAffixMask & BIO_WAM_LOWERSPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_WAFX_SWITCHSPEED_TOSTR_LOWER"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.LowerSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));	
		}

		if (!(weap.MiscAffixMask & BIO_WAM_RAISESPEED))
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
}

class BIO_WAFX_InfiniteAmmoOnKill : BIO_WeaponAffix
{
	// % chance out of 100 and duration in seconds
	int Chance, Duration;

	final override void Init(BIO_Weapon weap)
	{
		Chance = Random(3, 6);
		Duration = Random(5, 10);
	}

	final override bool Compatible(BIO_Weapon weap) const { return true; }

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

	final override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_WAFX_INFINITEAMMOONKILL_TOSTR"),
			Chance, Duration));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_INFINITEAMMOONKILL_TAG");	
	}
}
