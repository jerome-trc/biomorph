// Acts as a more specialised alternative to `give all`.
class BIO_All : Inventory
{
	Default
	{
		-COUNTITEM
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.AUTOACTIVATE

		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
	}

	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		bioPlayer.GiveInventory('BIO_Backpack', 1);

		uint mwh = bioPlayer.MaxWeaponsHeld;
		bioPlayer.MaxWeaponsHeld = uint.MAX;

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let t = (Class<Inventory>)(AllActorClasses[i]);

			if (t is 'BIO_Weapon' && !t.IsAbstract())
			{
				if (t == 'BIO_Fist') continue;
				if (bioPlayer.FindInventory(t)) continue;

				bioPlayer.GiveInventory(t, 1);
			}
			else if (t is 'BIO_Mutagen' && !t.IsAbstract())
			{
				bioPlayer.GiveInventory(t, GetDefaultByType(t).MaxAmount);
			}
			else if (t is 'Ammo' && !t.IsAbstract())
			{
				let defs = GetDefaultByType(t);
				if (defs.bIgnoreSkill) continue; // Skip magazines
				bioPlayer.GiveInventory(t, defs.MaxAmount);
			}
		}

		bioPlayer.MaxWeaponsHeld = mwh;
		return true;
	}
}

// For stress-testing the memory footprint of weapon data structures.
class BIO_WeaponFountain : Actor
{
	private Array<Class<BIO_Weapon> > WeaponTypes;

	Default
	{
		-SOLID
		+DONTGIB
		+NEVERRESPAWN
		+NOBLOOD
		+NOTELEPORT
		+SHOOTABLE
	
		Health 10;
		Scale 0.75;
		Tag "Weapon Fountain!";
	}

	States
	{
	Spawn:
		SUPB A 2
		{
			Actor weap = null; bool spawned = false;
			[spawned, weap] = A_SpawnItemEx(
				WeaponTypes[Random(0, WeaponTypes.Size() - 1)],
				xVel: FRandom(-3.0, 3.0), FRandom(-3.0, 3.0), FRandom(18.0, 24.0),
				FRandom(0.0, 360.0), SXF_NOCHECKPOSITION);

			if (spawned && Random(1, 4) == 1)
			{
				let bioWeap = BIO_Weapon(weap);
				bioWeap.RandomizeAffixes();
				bioWeap.OnWeaponChange();
			}
		}
		Loop;
	}

	override void BeginPlay()
	{
		super.BeginPlay();

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			Class<Actor> t = (Class<BIO_Weapon>)(AllActorClasses[i]);
			if (t != null && !t.IsAbstract())
				WeaponTypes.Push(t);
		}
	}
}

// For testing weapon loot weights.
class BIO_WeaponLootFountain : Actor
{
	private BIO_GlobalData Globals;

	Default
	{
		-SOLID
		+DONTGIB
		+NEVERRESPAWN
		+NOBLOOD
		+NOTELEPORT
		+SHOOTABLE
	
		Health 10;
		Scale 0.75;
		Tag "Weapon Loot Fountain!";
	}

	States
	{
	Spawn:
		SUPB A 2
		{
			Actor weap = null; bool spawned = false;
			[spawned, weap] = A_SpawnItemEx(Globals.AnyLootWeaponType(),
				xVel: FRandom(-3.0, 3.0), FRandom(-3.0, 3.0), FRandom(18.0, 24.0),
				FRandom(0.0, 360.0), SXF_NOCHECKPOSITION);

			if (spawned && Random(1, 4) == 1)
			{
				let bioWeap = BIO_Weapon(weap);
				bioWeap.RandomizeAffixes();
				bioWeap.OnWeaponChange();
			}
		}
		Loop;
	}

	override void BeginPlay()
	{
		super.BeginPlay();
		Globals = BIO_GlobalData.Get();
	}
}

// Randomises a weapon's affixes 10000 times and then prints the distribution of
// resultant affix counts, for testing the generation algorithm.
class BIO_Muta_RandomDebug : BIO_Muta_Random
{
	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.MaxAffixes < 1)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_MAX0");
			return false;
		}

		Array<uint> results;

		for (uint i = 0; i <= weap.MaxAffixes; i++)
			results.Push(0);
		
		for (uint i = 0; i < 10000; i++)
		{
			weap.RandomizeAffixes();
			results[weap.Affixes.Size()]++;
		}

		for (uint i = 0; i < results.Size(); i++)
		{
			Console.Printf("%d: %d", i, results[i]);
		}

		weap.OnWeaponChange();
		Owner.A_Print("$BIO_MUTA_RANDOM_USE");
		return true;
	}
}
