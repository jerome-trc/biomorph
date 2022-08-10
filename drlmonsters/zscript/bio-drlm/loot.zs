class BIORLM_Loot_EliteCaptainTristarBlaster : BIO_LootSpawner
{
	final override void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const
	{
		types.Push(BIO_Utils.TypeFromName('RLEliteCaptainTristarBlaster'));
		exact.Push(true);
	}

	final override void SpawnLoot() const
	{
		Actor.Spawn('BIORLM_MGene_Tristar', Pos);
	}
}

class BIORLM_Loot_SpiderOvermind : BIO_LootSpawner
{
	final override void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const
	{
		types.Push(BIO_Utils.TypeFromName('RLCyberneticSpiderMastermind'));
		exact.Push(true);
	}

	final override void SpawnLoot() const
	{
		if (BIO_Utils.IsLegendary(Target) || Random[BIO_Loot](1, 4) == 4)
		{
			Actor.Spawn('BIORLM_MGene_Overmind', Pos);
			PlayRareSound();
		}
	}
}

class BIORLM_Loot_SSG : BIO_LootSpawner
{
	final override void AssociatedMonsters(
		in out Array<class<Actor> > types,
		in out Array<bool> exact
	) const
	{
		types.Push(BIO_Utils.TypeFromName('RLEliteSergeantDoubleShotgun'));
		exact.Push(true);

		types.Push(BIO_Utils.TypeFromName('RLFormerOverwatch'));
		exact.Push(true);
	}

	final override void SpawnLoot() const
	{
		Actor.Spawn(BIO_Global.Get().LootWeaponType(BIO_WSCAT_SSG), Pos);
	}
}
