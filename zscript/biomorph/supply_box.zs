class BIO_SupplyBox : Actor
{
    Default
    {
        +DONTGIB
        +NOBLOCKMONST
        +USESPECIAL
    
        Activation
			THINGSPEC_ThingActs | THINGSPEC_ThingTargets | THINGSPEC_Switch;

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
    
    final override void Activate(Actor activator)
	{
		super.Activate(activator);
        
        if (!(activator is 'BIO_Player')) return;

        bool success = false;
        Actor spawned = null;

        [success, spawned] = A_SpawnItemEx(
            BIO_GlobalData.Get().AnyLootWeaponType(), 0.0, 0.0, 32.0,
            FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
            FRandom(0.0, 360.0));

        if (success) 
        {
            let weap = BIO_Weapon(spawned);
            weap.RandomizeAffixes();
            weap.OnWeaponChange();
            weap.SetState(weap.FindState("Spawn"));
        }

		Die(activator, null);
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
