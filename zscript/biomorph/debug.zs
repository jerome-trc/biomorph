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
			if (spawned) BIO_Weapon(weap).RandomizeAffixes();
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
