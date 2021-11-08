// Damage ======================================================================

class BIO_WAFX_Damage : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	override void Init(BIO_Weapon weap)
	{
		Modifier1 = Random(weap.MinDamage1, weap.MaxDamage1) * 0.4;
		Modifier2 = Random(weap.MinDamage2, weap.MaxDamage2) * 0.4;
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return !weap.AfxMask_AllDamage();
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_MINDAMAGE))
			weap.MinDamage1 += Modifier1;
		if (!(weap.AffixMask1 & BIO_WAM_MAXDAMAGE))
			weap.MaxDamage1 += Modifier1;

		if (!(weap.AffixMask2 & BIO_WAM_MINDAMAGE))
			weap.MinDamage2 += Modifier2;
		if (!(weap.AffixMask2 & BIO_WAM_MAXDAMAGE))
			weap.MaxDamage2 += Modifier2;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if ((weap.AffixMask2 & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG1"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1));
		}
		else if ((weap.AffixMask1 & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG2"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMG"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1,
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_WEAPDMG");
	}
}

class BIO_WAFX_DamagePercent : BIO_WeaponAffix
{
	float Multi1, Multi2;

	override void Init(BIO_Weapon weap)
	{
		Multi1 = FRandom(0.25, 0.75);
		Multi2 = FRandom(0.25, 0.75);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return !(PrimaryIncompatible(weap) && SecondaryIncompatible(weap));
	}

	private bool PrimaryIncompatible(BIO_Weapon weap) const
	{
		return
			((weap.AffixMask1 & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE) ||
			weap.MaxDamage1 <= 0;
	}

	private bool SecondaryIncompatible(BIO_Weapon weap) const
	{
		return
			((weap.AffixMask2 & BIO_WAM_DAMAGE) == BIO_WAM_DAMAGE) ||
			weap.MaxDamage2 <= 0;
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_MINDAMAGE))
			weap.MinDamage1 *= (1.0 + Multi1);
		if (!(weap.AffixMask1 & BIO_WAM_MAXDAMAGE))
			weap.MaxDamage1 *= (1.0 + Multi1);

		if (!(weap.AffixMask2 & BIO_WAM_MINDAMAGE))
			weap.MinDamage2 *= (1.0 + Multi2);
		if (!(weap.AffixMask2 & BIO_WAM_MAXDAMAGE))
			weap.MaxDamage2 *= (1.0 + Multi2);
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (SecondaryIncompatible(weap))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMGPERCENT1"),
				Multi1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi1 >= 0 ? "+" : "", int(Multi1 * 100)));
		}
		else if (PrimaryIncompatible(weap))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMGPERCENT2"),
				Multi2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi2 >= 0 ? "+" : "", int(Multi2 * 100)));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_WEAPDMGPERCENT"),
				Multi1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi1 >= 0 ? "+" : "", int(Multi1 * 100),
				Multi2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Multi2 >= 0 ? "+" : "", int(Multi2 * 100)));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_WEAPDMGPERCENT");
	}
}

// n% of the hit enemy's health is given to the projectile's dealt damage.
class BIO_WAFX_EnemyHealthDamage : BIO_WeaponAffix
{
	float Factor;

	override void Init(BIO_Weapon weap)
	{
		Factor = FRandom(0.025, 0.05);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.AffixMask1 & BIO_WAM_PROJDAMAGEFUNCTORS) ||
			!(weap.AffixMask2 & BIO_WAM_PROJDAMAGEFUNCTORS);
	}

	override void Apply(BIO_Weapon weap) const
	{
		uint e = weap.ProjDamageFunctors.Push(new('BIO_ProjDmgFunc_EnemyHealthDamage'));
		let func = BIO_ProjDmgFunc_EnemyHealthDamage(weap.ProjDamageFunctors[e]);
		func.Factor = Factor;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(StringTable.Localize(
			"$BIO_AFFIX_TOSTR_ENEMYHEALTHDAMAGE"),
			Factor > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			Factor * 100.0, Factor > 0.0 ?
				StringTable.Localize("$BIO_ADDED_TO") :
				StringTable.Localize("$BIO_REMOVED_FROM")));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_ENEMYHEALTHDAMAGE");
	}
}

class BIO_ProjDmgFunc_EnemyHealthDamage : BIO_ProjDamageFunctor
{
	float Factor;

	override void InvokeTrue(BIO_Projectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		damage += (target.Health * Factor);
	}

	override void InvokeFast(BIO_FastProjectile proj,
		Actor target, in out int damage, name dmgType) const
	{
		damage += (target.Health * Factor);
	}
}

// Only compatible with pistol-type weapons, to give them an edge.
class BIO_WAFX_Crit : BIO_WeaponAffix
{
	uint Chance;
	float DamageMulti; // Percentage of rolled damage added to outgoing damage

	override void Init(BIO_Weapon weap)
	{
		Chance = Random(15, 30);
		DamageMulti = FRandom(1.0, 2.0);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.BIOFlags & BIO_WF_PISTOL;
	}

	override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		if (Random(0, 100) < Chance)
		{
			dmg += (dmg * DamageMulti);
			weap.Owner.A_StartSound("weapons/crit", CHAN_AUTO);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(StringTable.Localize("$BIO_AFFIX_TOSTR_CRIT"),
			Chance, DamageMulti > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			DamageMulti > 0.0 ? "+" : "", int(DamageMulti * 100.0)));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_CRIT");
	}
}

// All splash damage on the fired projectile is converted into direct hit damage.
class BIO_WAFX_SplashForDamage : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
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

	override void ModifySplash(BIO_Weapon weap, in out int dmg, in out int radius,
		in out int baseDmg) const
	{
		baseDmg += Max(dmg, 0);
		dmg = 0;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(CRESC_MIXED .. StringTable.Localize(
			"$BIO_AFFIX_TOSTR_SPLASHFORDAMAGE"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_SPLASHFORDAMAGE");
	}
}

class BIO_WAFX_ForwardDamage : BIO_WeaponAffix
{
	float Multi;

	override void Init(BIO_Weapon weap)
	{
		Multi = FRandom(0.25, 0.75);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DealsAnyDamage();
	}

	override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		if (weap.Owner.Player.Cmd.Buttons & BT_FORWARD)
		{
			dmg += (dmg * Multi);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_FORWARDDAMAGE"),
			Multi > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE, Multi * 100,
			StringTable.Localize(Multi > 0.0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_FORWARDDAMAGE");
	}
}

class BIO_WAFX_StrafeDamage : BIO_WeaponAffix
{
	float Multi;

	override void Init(BIO_Weapon weap)
	{
		Multi = FRandom(0.25, 0.75);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return weap.DealsAnyDamage();
	}

	override void ModifyDamage(BIO_Weapon weap, in out int dmg) const
	{
		if (weap.Owner.Player.Cmd.Buttons & BT_MOVELEFT ||
			weap.Owner.Player.Cmd.Buttons & BT_MOVERIGHT)
		{
			dmg += (dmg * Multi);
		}
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_STRAFEDAMAGE"),
			Multi > 0.0 ? CRESC_POSITIVE : CRESC_NEGATIVE, Multi * 100,
			StringTable.Localize(Multi > 0.0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_STRAFEDAMAGE");
	}
}

// Fire type ===================================================================

class BIO_WAFX_Plasma : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
	{
		return PrimaryCompatible(weap) || SecondaryCompatible(weap);
	}

	private bool PrimaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo('BIO_PlasmaBall', false) &&
			(weap.AffixMask1 & BIO_WAM_DAMAGE) != BIO_WAM_DAMAGE;
	}

	private bool SecondaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo('BIO_PlasmaBall', true) &&
			(weap.AffixMask1 & BIO_WAM_DAMAGE) != BIO_WAM_DAMAGE;
	}

	override void Apply(BIO_Weapon weap) const
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

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_PLASMA"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_PLASMA");
	}
}

class BIO_WAFX_Slug : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	// Weapon must be firing shot pellets for this affix to be applicable.
	override bool Compatible(BIO_Weapon weap) const
	{
		return PrimaryCompatible(weap) || SecondaryCompatible(weap);
	}
	
	private bool PrimaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableFrom('BIO_ShotPellet', false) &&
			!(weap.AffixMask1 & BIO_WAM_SPREAD) &&
			!(weap.AffixMask1 & BIO_WAM_DAMAGE);
	}

	private bool SecondaryCompatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableFrom('BIO_ShotPellet', true) &&
			!(weap.AffixMask2 & BIO_WAM_SPREAD) &&
			!(weap.AffixMask2 & BIO_WAM_DAMAGE);
	}

	override void Apply(BIO_Weapon weap) const
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

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_SLUG"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_SLUG");
	}
}

class BIO_WAFX_MiniMissile : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			weap.FireTypeMutableTo('BIO_MiniMissile', false) ||
			weap.FireTypeMutableTo('BIO_MiniMissile', true);
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (weap.FireTypeMutableTo('BIO_MiniMissile', false))
			weap.FireType1 = 'BIO_MiniMissile';
		
		if (weap.FireTypeMutableTo('BIO_MiniMissile', true))
			weap.FireType2 = 'BIO_MiniMissile';
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_MINIMISSILE"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_MINIMISSILE");
	}
}

// Miscellaneous ===============================================================

class BIO_WAFX_FireCount : BIO_WeaponAffix
{
	int Modifier1, Modifier2;

	override void Init(BIO_Weapon weap)
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

	override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.bMeleeWeapon) return false;

		bool ret = false;

		if (weap.FireCount1 != 0 && !(weap.AffixMask1 & BIO_WAM_FIRECOUNT))
			ret = true;
		if (weap.FireCount2 != 0 && !(weap.AffixMask2 & BIO_WAM_FIRECOUNT))
			ret = true;

		return ret;
	}

	override void Apply(BIO_Weapon weap) const
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

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (weap.AffixMask2 & BIO_WAM_FIRECOUNT)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_FIRECOUNT1"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1, weap.GetFireTypeTag(false)));
		}
		else if (weap.AffixMask1 & BIO_WAM_FIRECOUNT)
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_FIRECOUNT2"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2, weap.GetFireTypeTag(true)));
		}
		else
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_FIRECOUNT"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1, weap.GetFireTypeTag(false),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2, weap.GetFireTypeTag(true)));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_FIRECOUNT");
	}
}

class BIO_WAFX_FireRate : BIO_WeaponAffix
{
	int Modifier;

	override void Init(BIO_Weapon weap)
	{
		int rft = weap.ReducibleFireTime();

		if (rft == 1)
			Modifier = -1;
		else if (rft > 1)
			Modifier = -Random(1, rft);
		else
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegally initialized %s against reducible fire time of %d.",
				GetClassName(), rft);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.AffixMask1 & BIO_WAM_FIRETIME) &&
			weap.ReducibleFireTime() > 0;
	}

	override void Apply(BIO_Weapon weap)
	{
		weap.ModifyFireTime(Modifier);
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_FIRERATE"),
			Modifier >= 0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			Modifier >= 0 ? "+" : "", float(Modifier) / 35.0));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_FIRERATE");
	}
}

class BIO_WAFX_Spread : BIO_WeaponAffix
{
	float HSpread1, VSpread1, HSpread2, VSpread2;

	override void Init(BIO_Weapon weap)
	{
		HSpread1 = -(FRandom(0.1, weap.HSpread1) / 2.0);
		VSpread1 = -(FRandom(0.1, weap.VSpread1) / 2.0);
		HSpread2 = -(FRandom(0.1, weap.HSpread2) / 2.0);
		VSpread2 = -(FRandom(0.1, weap.VSpread2) / 2.0);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			weap.HasAnySpread() &&
			!((weap.AffixMask1 & BIO_WAM_SPREAD) == BIO_WAM_SPREAD) ||
			!((weap.AffixMask2 & BIO_WAM_SPREAD) == BIO_WAM_SPREAD);
	}

	override void Apply(BIO_Weapon weap)
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

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		string output = StringTable.Localize("$BIO_AFFIX_TOSTR_SPREAD");

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

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_SPREAD");
	}
}

class BIO_WAFX_Kickback : BIO_WeaponAffix
{
	int Modifier;

	override void Init(BIO_Weapon weap)
	{
		Modifier = Random(200, 400);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return !(weap.MiscAffixMask & BIO_WAM_KICKBACK);
	}

	override void Apply(BIO_Weapon weap) const
	{
		weap.Kickback += Modifier;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_KICKBACK"),
			Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
			(float(Modifier) / float(weap.Kickback)) * 100.0,
			StringTable.Localize(Modifier > 0 ? "$BIO_MORE" : "$BIO_LESS")));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_KICKBACK");
	}
}

class BIO_WAFX_ReloadSpeed : BIO_WeaponAffix
{
	int Modifier;

	override void Init(BIO_Weapon weap)
	{
		int rrt = weap.ReducibleReloadTime();

		if (rrt == 1)
			Modifier = -1;
		else if (rrt > 1)
			Modifier = -Random(1, rrt);
		else
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegally initialized %s against reducible reload time of %d.",
				GetClassName(), rrt);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.AffixMask1 & BIO_WAM_RELOADTIME) &&
			weap.ReducibleReloadTime() > 0;
	}

	override void Apply(BIO_Weapon weap)
	{
		weap.ModifyReloadTime(Modifier);
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(String.Format(
			StringTable.Localize("$BIO_AFFIX_TOSTR_RELOADSPEED"),
			Modifier >= 0 ? CRESC_NEGATIVE : CRESC_POSITIVE,
			Modifier >= 0 ? "+" : "", float(Modifier) / 35.0));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_RELOADSPEED");
	}
}

class BIO_WAFX_ProjSeek : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 == BIO_WAM_ALL) && weap.FiresTrueProjectile(false))
			return true;
		else if (!(weap.AffixMask2 == BIO_WAM_ALL) && weap.FiresTrueProjectile(true))
			return true;
		else
			return false;
	}

	override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.Seek = true;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_PROJSEEK"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_PROJSEEK");
	}
}

class BIO_WAFX_ForcePain : BIO_WeaponAffix
{
	override void Init(BIO_Weapon weap) {}

	override bool Compatible(BIO_Weapon weap) const
	{
		if (weap.bMeleeWeapon)
			return false;
		else
			return (weap.AffixMask1 & BIO_WAM_ONPROJFIRED) != BIO_WAM_ONPROJFIRED;
	}

	override void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const
	{
		proj.bForcePain = true;
	}

	override void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const
	{
		proj.bForcePain = true;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		strings.Push(StringTable.Localize("$BIO_AFFIX_TOSTR_FORCEPAIN"));
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_FORCEPAIN");
	}
}

class BIO_WAFX_MeleeRange : BIO_WeaponAffix
{
	float Modifier1, Modifier2;

	override void Init(BIO_Weapon weap)
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

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			(weap is 'BIO_MeleeWeapon' || weap is 'BIO_DualMeleeWeapon') &&
			!(
				(weap.AffixMask1 & BIO_WAM_MELEERANGE) &&
				(weap.AffixMask2 & BIO_WAM_MELEERANGE)
			);
	}

	override void Apply(BIO_Weapon weap) const
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

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_MELEERANGE))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_MELEERANGE1"),
				Modifier1 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier1 >= 0 ? "+" : "", Modifier1));
		}
		
		if (!(weap.AffixMask2 & BIO_WAM_MELEERANGE))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_MELEERANGE2"),
				Modifier2 >= 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				Modifier2 >= 0 ? "+" : "", Modifier2));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_MELEERANGE");
	}
}

class BIO_WAFX_LifeSteal : BIO_WeaponAffix
{
	float AddPercent;
	
	override void Init(BIO_Weapon weap) { AddPercent = FRandom(0.2, 0.8); }

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			(weap is 'BIO_MeleeWeapon' || weap is 'BIO_DualMeleeWeapon') &&
			!(
				(weap.AffixMask1 & BIO_WAM_LIFESTEAL) &&
				(weap.AffixMask2 & BIO_WAM_LIFESTEAL)
			);
	}

	override void Apply(BIO_Weapon weap) const
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

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (!(weap.AffixMask1 & BIO_WAM_MELEERANGE))
		{
			strings.Push(CRESC_POSITIVE .. String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_LIFESTEAL1"),
				int(AddPercent * 100.0)));
		}
		
		if (!(weap.AffixMask2 & BIO_WAM_MELEERANGE))
		{
			strings.Push(CRESC_POSITIVE .. String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_LIFESTEAL2"),
				int(AddPercent * 100.0)));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_LIFESTEAL");
	}
}

class BIO_WAFX_SwitchSpeed : BIO_WeaponAffix
{
	int Modifier;

	override void Init(BIO_Weapon weap)
	{
		Modifier = Random(5, 9);
	}

	override bool Compatible(BIO_Weapon weap) const
	{
		return
			!(weap.MiscAffixMask & BIO_WAM_LOWERSPEED) ||
			!(weap.MiscAffixMask & BIO_WAM_RAISESPEED);
	}

	override void Apply(BIO_Weapon weap) const
	{
		if (!(weap.MiscAffixMask & BIO_WAM_LOWERSPEED))
			weap.LowerSpeed += Modifier;
		if (!(weap.MiscAffixMask & BIO_WAM_RAISESPEED))
			weap.RaiseSpeed += Modifier;
	}

	override void ToString(in out Array<string> strings, BIO_Weapon weap) const
	{
		if (!(weap.MiscAffixMask & BIO_WAM_LOWERSPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_SWITCHSPEED_LOWER"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.LowerSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));	
		}

		if (!(weap.MiscAffixMask & BIO_WAM_RAISESPEED))
		{
			strings.Push(String.Format(
				StringTable.Localize("$BIO_AFFIX_TOSTR_SWITCHSPEED_RAISE"),
				Modifier > 0 ? CRESC_POSITIVE : CRESC_NEGATIVE,
				(float(Modifier) / float(weap.RaiseSpeed)) * 100.0,
				StringTable.Localize(Modifier > 0 ? "$BIO_FASTER" : "$BIO_SLOWER")));
		}
	}

	override string GetTag() const
	{
		return StringTable.Localize("$BIO_AFFIX_TAG_SWITCHSPEED");
	}
}
