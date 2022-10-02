class BIO_SupplyBox : Actor
{
	private bool Opened;

	Default
	{
		+DONTGIB
		+NOBLOCKMONST

		Height 8;
		Radius 16;
		Scale 0.75;
		Tag "$BIO_SUPPLYBOX_TAG";
	}

	States
	{
	Spawn:
		SUPP A 5 A_JumpIf(invoker.Opened, 'Spawn.Opened');
		Loop;
	Spawn.Opened:
		SUPP B -1;
		Stop;
	}

	final override bool Used(Actor user)
	{
		if (Opened)
			return false;

		if (!(user is 'BIO_Player'))
			return false;

		let perk_t = BIO_Global.Get().RandomPerkType();
		BIO_Perk.PlayRaritySound(GetDefaultByType(perk_t).LootWeight);

		A_SpawnItemEx(
			perk_t,
			0.0, 0.0, 32.0,
			FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
			FRandom(0.0, 360.0)
		);

		Opened = true;
		return true;
	}
}
