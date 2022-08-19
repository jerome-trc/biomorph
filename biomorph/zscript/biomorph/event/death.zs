// Death handling.
extend class BIO_EventHandler
{
	const GENE_CHANCE_DENOM = 8;

	// Assigned in `OnRegister()`
	// (will be null if LegenDoom or its Lite version isn't loaded).
	private class<Inventory> LDToken;

	clearscope uint MapTotalMonsterValue() const
	{
		let iter = ThinkerIterator.Create('Actor');
		uint ret = 0;

		while (true)
		{
			let mons = Actor(iter.Next());

			if (mons == null)
				break;

			if (!mons.bIsMonster)
				continue;

			ret += Globals.GetMonsterValue(mons);
		}

		return ret;
	}

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster)
			return;

		let pawn = BIO_Player(event.Thing.Target);

		if (pawn != null)
			pawn.OnKill(event.Thing, event.Inflictor);

		if (event.Thing.FindInventory(LDToken))
		{
			switch (BIO_ldl)
			{
			case BIO_CV_LDL_WEAP:
				SpawnLegendaryLootWeapon(event.Thing);
				break;
			case BIO_CV_LDL_GENE:
				SpawnLootGene(event.Thing);

				if (event.Thing.bBoss)
					SpawnLootGene(event.Thing);
				break;
			default:
				break;
			}
		}

		for (uint i = 0; i < Globals.MonsterLoot.Size(); i++)
		{
			if (Globals.MonsterLoot[i].Exact)
			{
				if (event.Thing.GetClass() != Globals.MonsterLoot[i].MonsterType)
					continue;
			}
			else
			{
				if (!(event.Thing is Globals.MonsterLoot[i].MonsterType))
					continue;
			}

			bool success = false;
			Actor spawned = null;

			let spawner_t = Globals.MonsterLoot[i].SpawnerType;

			[success, spawned] = event.Thing.A_SpawnItemEx(
				spawner_t,
				0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0)
			);

			if (success && spawned != null)
			{
				BIO_LootSpawner(spawned).Target = event.Thing;
			}
			else
			{
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"Failed to create loot spawner of type `%s` "
					"upon death of monster of type `%s`.",
					spawner_t.GetClassName(), event.Thing.GetClassName()
				);
			}
		}

		Globals.LootValueBuffer += Globals.GetMonsterValue(event.Thing);

		while (Globals.DrainLootValueBuffer())
		{
			if (Random[BIO_Loot](1, GENE_CHANCE_DENOM) == 1)
			{
				SpawnLootGene(event.Thing);
			}
			else
			{
				let muta_t = Globals.RandomMutagenType();
				BIO_Mutagen.PlayRaritySound(GetDefaultByType(muta_t).LootWeight);

				event.Thing.A_SpawnItemEx(
					muta_t,
					0.0, 0.0, 32.0,
					FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
					FRandom(0.0, 360.0)
				);
			}
		}
	}

	private void SpawnLootGene(Actor mons)
	{
		let gene_t = Globals.RandomGeneType();
		BIO_Gene.PlayRaritySound(GetDefaultByType(gene_t).LootWeight);

		mons.A_SpawnItemEx(
			gene_t,
			0.0, 0.0, 32.0,
			FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
			FRandom(0.0, 360.0)
		);
	}

	private void SpawnLegendaryLootWeapon(Actor mons)
	{
		bool success = false;
		Actor spawned = null;

		[success, spawned] = mons.A_SpawnItemEx(
			Globals.AnyLootWeaponType(),
			0.0, 0.0, 32.0,
			FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
			FRandom(0.0, 360.0)
		);

		if (!success || spawned == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Failed to spawn a weapon loot drop from a dead Legendary."
			);
			return;
		}

		let weap = BIO_Weapon(spawned);

		uint gcf = 1, gcc = 1;

		if (mons.bBoss)
			gcf++;

		if (BIO_Utils.DoomRLMonsterPack())
			gcc++;

		weap.SpecialLootMutate(
			extraNodes: mons.bBoss ? 1 : 0,
			geneCount: uint(Random[BIO_Loot](gcf, gcc)),
			noDuplicateGenes: true,
			raritySound: true
		);
	}
}
