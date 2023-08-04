version "3.7"

class biom_CCardsEventHandler : EventHandler
{
	private uint initialDeckSize;

	final override void OnRegister()
	{
		self.SetOrder(1);
	}

	final override void WorldTick()
	{
		// Card selection menu gets opened on `Level.time 3` as of v5.0.
		if (self.bDestroyed || level.time < 4)
			return;

		let ccgame = CCards_Functions.GetGame();

		if (level.time == 4)
			self.initialDeckSize = ccgame.deck.Size();

		// Wait until card selection is done.
		if (ccgame.deck.Size() <= self.initialDeckSize)
			return;

		let globals = biom_Global.Get();
		let bal = ccgame.deck[ccgame.deck.Size() - 1].tier;
		globals.ModifyBalance(bal);

		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"(CCARDS) Added %d to all players' balance modifier.",
				bal
			);
		}

		self.Destroy();
	}
}
