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

        bool success = false;
        Actor spawned = null;

        [success, spawned] = A_SpawnItemEx(
            BIO_Global.Get().AnyLootWeaponType(),
			0.0, 0.0, 32.0,
            FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
            FRandom(0.0, 360.0)
		);

		if (!success || spawned == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Failed to spawn a weapon loot drop from a supply box."
			);
			return true;
		}
		else
		{
			let weap = BIO_Weapon(spawned);

			weap.SpecialLootMutate(
				extraNodes: 0,
				geneCount: 2,
				noDuplicateGenes: true,
				raritySound: true
			);
		}

		Opened = true;
        return true;
	}
}
