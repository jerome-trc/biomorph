// Start every level with berserk (but non-melee weapons take 300% capacity) ===

class BIO_Perk_StartingBerserk : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer)
	{
		bioPlayer.PushFunctor('BIO_TransFunc_StartingBerserk');

		if (BIO_GlobalData.Get().GetPartyLevel() <= 1)
		{
			bioPlayer.GiveInventory('BIO_PowerStrength', 1);
		}
	}
}

class BIO_TransFunc_StartingBerserk : BIO_TransitionFunctor
{
	final override void WorldLoaded(BIO_Player bioPlayer, bool savegame, bool reopen) const
	{
		if (savegame || reopen) return;
		bioPlayer.GiveInventory('BIO_PowerStrength', 1);
	}
}
