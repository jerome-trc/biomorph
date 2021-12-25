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
