class BIO_WAfx_InfiniteAmmoOnKill : BIO_WeaponAffix
{
	// % chance out of 100 and duration in seconds
	int Chance, Duration;

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		Chance = Random[BIO_Afx](3, 6);
		Duration = Random[BIO_Afx](5, 10);
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return !weap.Ammoless();
	}

	final override void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const
	{
		if (Random(0, 100) < Chance)
		{
			BIO_Utils.GivePowerup(weap.Owner,
				'BIO_PowerInfiniteAmmo', GameTicRate * Duration);
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

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const { return BIO_WAF_NONE; }
}

class BIO_WAfx_UserRadialStunOnKill : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> _) const { return true; }

	final override void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const
	{
		let bli = BlockThingsIterator.Create(weap.Owner, 256.0);

		while (bli.Next())
		{
			if (bli.Thing.bIsMonster && bli.Thing.Species != 'Player')
				bli.Thing.TriggerPainChance('None', true);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_USERRADIALSTUNONKILL_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_USERRADIALSTUNONKILL_TAG");
	}

	final override bool ImplicitExplicitExclusive() const { return true; }
	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override BIO_WeaponAffixFlags GetFlags() const { return BIO_WAF_NONE; }
}

class BIO_WAfx_VictimRadialStunOnKill : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> _) const { return true; }

	final override void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const
	{
		let bli = BlockThingsIterator.Create(killed, 256.0);

		while (bli.Next())
		{
			if (bli.Thing.bIsMonster && bli.Thing.Species != 'Player')
				bli.Thing.TriggerPainChance('None', true);
		}
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_VICTIMRADIALSTUNONKILL_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_VICTIMRADIALSTUNONKILL_TAG");
	}

	final override bool ImplicitExplicitExclusive() const { return true; }
	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }
	final override BIO_WeaponAffixFlags GetFlags() const { return BIO_WAF_NONE; }
}

class BIO_WAfx_ShrapnelOnKill : BIO_WeaponAffix
{
	final override bool Compatible(readOnly<BIO_Weapon> _) const { return true; }

	const FLAGS =
		XF_HURTSOURCE | XF_NOTMISSILE | XF_EXPLICITDAMAGETYPE | XF_NOSPLASH;

	final override void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const
	{
		int mhp = Max(1, killed.GetMaxHealth() * 0.8), count = Random(8, 12);

		killed.A_Explode(0, 0, FLAGS, true, nails: count, mhp / count, 'BIO_Shrapnel');
	}

	final override void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const
	{
		strings.Push(StringTable.Localize("$BIO_WAFX_SHRAPNELONKILL_TOSTR"));
	}

	final override string GetTag() const
	{
		return StringTable.Localize("$BIO_WAFX_SHRAPNELONKILL_TAG");
	}

	final override bool SupportsReroll(readOnly<BIO_Weapon> _) const { return false; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
