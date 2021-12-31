// In the baseline mod, critical shots are a mechanic only applicable to pistols,
// to give them a unique identity and special edge.

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
		return weap.BIOFlags & BIO_WF_PISTOL && weap.DealsAnyDamage();
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

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_DAMAGE;
	}
}
