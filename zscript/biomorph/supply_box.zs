class BIO_SupplyBox : Actor
{
    Default
    {
        +DONTGIB
        +NOBLOCKMONST

        Height 8;
        Scale 0.75;
		Radius 16;
    }

    States
    {
    Spawn:
        SUPB A -1;
        Stop;
    }
    
    final override bool Used(Actor user)
	{
        if (!(user is 'BIO_Player')) return false;

        bool success = false;
        Actor spawned = null;

        [success, spawned] = A_SpawnItemEx(
            BIO_GlobalData.Get().AnyLootWeaponType(), 0.0, 0.0, 32.0,
            FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
            FRandom(0.0, 360.0));

        if (success) 
        {
            let weap = BIO_Weapon(spawned);

            if (weap.Rarity != BIO_RARITY_UNIQUE)
            {
                weap.Init();
                weap.RandomizeAffixes();
            }

            weap.OnChange();
            weap.SetState(weap.FindState("Spawn"));
        }

		Die(user, null);
        return true;
	}
}

class BIO_SupplyBoxSpawner : Actor
{
    Default
	{
		-SOLID
		+DONTSPLASH
		+NOBLOCKMAP
		+NOTELEPORT
		+NOTIMEFREEZE
		+NOTONAUTOMAP

		Radius 16;
		Height 8;
		Speed 15;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 1
		{
			for (uint i = 0; i < 40; i++)
				A_Wander();
			Actor.Spawn('BIO_SupplyBox', Pos);
		}
		Stop;
	}
}
