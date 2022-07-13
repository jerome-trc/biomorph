version "3.7"

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
