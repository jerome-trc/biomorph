extend class BIO_EventHandler
{
	const LOOT_RNG_THRESHOLD = 200;

	// Assigned in `OnRegister()`, zscript/biomorph/event/core.zs
	// (Will be null if LegenDoom or its Lite version isn't loaded)
	private Class<Inventory> LDToken;

	static int GetMonsterValue(Actor mons)
	{
		int ret = LOOT_RNG_THRESHOLD * (float(mons.Default.Health) / 1000.0);
	
		// More pain resistance means more value
		ret += ((256 - mons.Default.PainChance) / 4);

		// How much faster is it than a ZombieMan?
		ret += (Max(mons.Default.Speed - 8, 0) * 3);

		if (mons.bBoss) ret *= 2;

		if (mons.bNoRadiusDmg) ret *= 1.1;
		if (mons.bNoPain) ret *= 1.1;
		if (mons.bAlwaysFast) ret *= 1.1;
		if (mons.bMissileMore) ret *= 1.1;
		if (mons.bMissileEvenMore) ret *= 1.1;
		if (mons.bQuickToRetaliate) ret *= 1.1;
		if (mons.bNoFear) ret *= 1.02;
		if (mons.bSeeInvisible) ret *= 1.02;

		// Refusing to infight and being unable to draw infighting aggro
		// are small difficulty increases
		if (mons.bNoTarget) ret *= 1.05;
		if (mons.bNoInfighting) ret *= 1.05;

		// JUMPDOWN increases monster aggression and agility
		if (mons.bJumpDown) ret *= 1.01;

		// Slightly better value if the monster was gibbed
		if (mons.Health < mons.GibHealth) ret += 15;

		return ret;
	}

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster) return;

		if (event.Thing.FindInventory(LDToken))
		{
			bool success = false;
			Actor spawned = null;

			// If we made it here, this was a legendary monster from LegenDoom
			// or LegenDoom Lite. Drop some extra-special loot
			[success, spawned] = event.Thing.A_SpawnItemEx(
				Globals.AnyLootWeaponType(), 0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0));

			if (success) 
			{
				let weap = BIO_Weapon(spawned);

				if (weap.Rarity != BIO_RARITY_UNIQUE)
					weap.RandomizeAffixes();
				
				weap.OnWeaponChange();
				weap.SetState(weap.FindState("Spawn"));
			}
		}

		let bioPlayer = BIO_Player(event.Thing.Target);
		if (bioPlayer != null)
			bioPlayer.OnKill(event.Thing, event.Inflictor);

		// There's no way to know if a Lost Soul was a Pain Elemental spawn,
		// so just forbid Lost Souls from giving anything to prevent farming
		if (event.Thing is 'LostSoul') return;

		/*	Every monster has a "value" that determines the XP it gives the party,
			and the chance that it drops a mutagen. This value is derived from its
			relative strength (health, certain properties, flags, etc.).

			This value turns into the chance that the monster drops a mutagen;
			this chance can overflow such that a monster drops multiple
		*/

		int val = GetMonsterValue(event.Thing);
		Globals.AddPartyXP(val);

		// If not even at threshold, maybe push it over
		if (val < LOOT_RNG_THRESHOLD)
			val += Random(0, LOOT_RNG_THRESHOLD - val) + 10;

		for (int i = 0; i < (val / LOOT_RNG_THRESHOLD); i++)
		{
			if (Random(1, 60) == 1)
			{
				event.Thing.A_SpawnItemEx('BIO_Antigen',
					0.0, 0.0, 32.0,
					FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
					FRandom(0.0, 360.0));
			}
			else
			{
				event.Thing.A_SpawnItemEx(Globals.RandomMutagenType(),
					0.0, 0.0, 32.0,
					FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
					FRandom(0.0, 360.0));
			}
		}
	}
}
