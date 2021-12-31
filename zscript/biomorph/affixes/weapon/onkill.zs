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
		if (!weap.Switching() && Random(0, 100) < Chance)
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

	final override bool SupportsReroll() const { return true; }

	final override BIO_WeaponAffixFlags GetFlags() const
	{
		return BIO_WAF_NONE;
	}
}
