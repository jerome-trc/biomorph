extend class BIO_EventHandler
{
	const LOOT_RNG_THRESHOLD = 200;

	// Assigned in `OnRegister()`, zscript/biomorph/event/core.zs
	// (Will be null if LegenDoom or its Lite version isn't loaded)
	private Class<Inventory> LDToken;

	override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster) return;

		if (event.Thing.FindInventory(LDToken))
		{
			bool success = false;
			Actor spawned = null;

			// If we made it here, this was a legendary monster from LegenDoom
			// or LegenDoom Lite. Drop some extra-special loot
			[success, spawned] = event.Thing.A_SpawnItemEx(
				Globals.LootWeaponType(), 0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0));

			if (success) 
			{
				let weap = BIO_Weapon(spawned);
				weap.RandomizeAffixes();
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

		// Killing a Baron guarantees one mutagen
		int val = LOOT_RNG_THRESHOLD * (float(event.Thing.Default.Health) / 1000.0);

		// More pain resistance means more value
		val += ((256 - event.Thing.Default.PainChance) / 4);

		// How much faster is it than a ZombieMan?
		val += (Max(event.Thing.Default.Speed - 8, 0) * 3);

		if (event.Thing.bBoss) val *= 2;

		if (event.Thing.bNoRadiusDmg) val *= 1.1;
		if (event.Thing.bNoPain) val *= 1.1;
		if (event.Thing.bAlwaysFast) val *= 1.1;
		if (event.Thing.bMissileMore) val *= 1.1;
		if (event.Thing.bMissileEvenMore) val *= 1.1;
		if (event.Thing.bQuickToRetaliate) val *= 1.1;
		if (event.Thing.bNoFear) val *= 1.02;
		if (event.Thing.bSeeInvisible) val *= 1.02;

		// Refusing to infight and being unable to draw infighting aggro
		// are small difficulty increases
		if (event.Thing.bNoTarget) val *= 1.05;
		if (event.Thing.bNoInfighting) val *= 1.05;

		// JUMPDOWN increases monster aggression and agility
		if (event.Thing.bJumpDown) val *= 1.01;

		// Slightly better value if the monster was gibbed
		if (event.Thing.Health < event.Thing.GibHealth) val += 15;

		Globals.AddPartyXP(val);

		// If not even at threshold, maybe push it over
		if (val < LOOT_RNG_THRESHOLD)
			val += Random(0, LOOT_RNG_THRESHOLD - val) + 5;

		for (int i = 0; i < (val / LOOT_RNG_THRESHOLD); i++)
		{
			event.Thing.A_SpawnItemEx(Globals.RandomMutagenType(),
				0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0));
		}
	}
}
