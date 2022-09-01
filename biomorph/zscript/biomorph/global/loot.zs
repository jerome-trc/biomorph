class BIO_LootTable : BIO_WeightedRandomTable
{
	final override uint RandomImpl() const
	{
		return Random[BIO_Loot](1, WeightSum);
	}
}

class BIO_MonsterLootPair
{
	class<Actor> MonsterType;
	BIO_LootSpawner Spawner;
	// If `true`, check `GetClass() == MonsterType`.
	// Else, check `Monster is MonsterType`.
	bool Exact;
}

// After being spawned, `Target` will point to the killed monster.
class BIO_LootSpawner play abstract
{
	abstract void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const;

	// The first return value should be true
	// if the monster should not give any loot value.
	// The second return value should be true
	// if the monster should not drop any other loot.
	// Use if the given items are so valuable 
	// that giving mutagen/gene loot in addition would be too much.
	abstract bool, bool Invoke(Actor victim) const;

	// If returning `false`, this type will not be cached at new-game.
	virtual bool CanSpawn() const { return true; }

	protected void PlayRareSound(Actor victim) const
	{
		victim.A_StartSound("bio/loot/rare", CHAN_AUTO);
	}

	protected void PlayVeryRareSound(Actor victim) const
	{
		victim.A_StartSound("bio/loot/veryrare", CHAN_AUTO);
	}
}

// Loot core subsystem. Includes the loot value buffer and multiplier,
// list of monsters which give 0 value, and monster/loot spawner key-value pairs.
extend class BIO_Global
{
	const LOOT_VALUE_THRESHOLD = 1500;

	// Collection of monster types which don't contribute to the loot value buffer.
	// Ensures there's no incentive to farm Pain Elementals or The Hungry, etc.
	// It's context-sensitive; monsters only get added if the mod which
	// defines them has been loaded.
	// (Currently unused! Never gets written to or read from. May be used later.)
	private Array<class<Actor> > ZeroValueMonsters;
	private float LootValueMultiplier; // Applied after all other factors.
	uint LootValueBuffer;

	Array<BIO_MonsterLootPair> MonsterLoot;

	bool DrainLootValueBuffer()
	{
		if (LootValueBuffer >= LOOT_VALUE_THRESHOLD)
		{
			LootValueBuffer -= LOOT_VALUE_THRESHOLD;
			return true;
		}

		return false;
	}

	clearscope uint GetMonsterValue(Actor mons) const
	{
		let ret = uint(Max(mons.Default.Health, mons.GetMaxHealth(true)));

		if (mons.bAlwaysFast)
			ret *= 1.2;

		if (mons.bJumpDown)
			ret *= 1.2;

		if (mons.bMissileMore)
			ret *= 1.2;

		if (mons.bMissileEvenMore)
			ret *= 1.2;

		if (mons.bNoInfighting)
			ret *= 1.2;

		if (mons.bNoTarget)
			ret *= 1.2;

		if (mons.bQuickToRetaliate)
			ret *= 1.2;

		// TODO: Refine further
		return ret * LootValueMultiplier;
	}

	clearscope float GetLootValueMultiplier() const { return LootValueMultiplier; }

	void ModifyLootValueMultiplier(float change)
	{
		LootValueMultiplier = Max(0.0, LootValueMultiplier + change);		
	}

	private void SetupLootCore()
	{
		LootValueMultiplier = 1.0;

		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			let loot_t = (class<BIO_LootSpawner>)(AllClasses[i]);

			if (loot_t == null || loot_t.IsAbstract())
				continue;

			let spawner = BIO_LootSpawner(new(loot_t));

			if (!spawner.CanSpawn())
				continue;

			Array<class<Actor> > monstypes;
			Array<bool> exact;

			spawner.AssociatedMonsters(monstypes, exact);

			if (monstypes.Size() < 1)
			{
				Console.Printf(
					Biomorph.LOGPFX_WARN ..
					"Loot spawner type `%s` has no associated monsters, and will "
					"not be registered.", loot_t.GetClassName()
				);
				continue;
			}

			if (monstypes.Size() < exact.Size())
			{
				Console.Printf(
					Biomorph.LOGPFX_WARN ..
					"Loot spawner type `%s` does not provide %d subclass-check "
					"specifications, and will not be registered.",
					loot_t.GetClassName(), monstypes.Size()
				);
				continue;
			}

			for (uint j = 0; j < monstypes.Size(); j++)
			{
				if (monstypes[j] == null)
				{
					Console.Printf(
						Biomorph.LOGPFX_WARN ..
						"Loot spawner type `%s` tried to register an association "
						"with a null actor type (index %d).",
						loot_t.GetClassName(), j
					);
					continue;
				}

				let pair = new('BIO_MonsterLootPair');
				pair.MonsterType = monstypes[j];
				pair.Spawner = spawner;
				pair.Exact = exact[j];
				MonsterLoot.Push(pair);
			}
		}
	}

	private void PushZeroValueMonster(name typename)
	{
		let type = (class<Actor>)(typename);

		if (type == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_WARN ..
				"Tried to push null type `%s` onto zero value monster array.",
				typename
			);
			return;
		}

		ZeroValueMonsters.Push(type);
	}

	private void PopulateZeroValueMonsterCache()
	{
		// Acknowledge the possibility of mix-n-match involvement here

		PushZeroValueMonster('LostSoul');

		if (BIO_Utils.DoomRLMonsterPack())
		{
			PushZeroValueMonster('RLArmageddonLostSoul'); // a.k.a. unlimited teeth works
			PushZeroValueMonster('RLCyberneticLostSoul'); // a.k.a. Hellmine
			PushZeroValueMonster('RLLostSoul');
			PushZeroValueMonster('RLNightmareLostSoulNPE');
		}

		if (BIO_Utils.IronSnail())
		{
			PushZeroValueMonster('BigEye');
		}

		if (BIO_Utils.PandemoniaMonsterPack())
		{
			PushZeroValueMonster('ChaosUmbra');
			PushZeroValueMonster('NewLostSoul');
			PushZeroValueMonster('Phantasm');
		}

		if (BIO_Utils.Rampancy())
		{
			PushZeroValueMonster('Robot_GunTurret');
			PushZeroValueMonster('Robot_ScoutDrone');
		}

		// TODO: More support for more monster packs
	}
}
