version "3.7"

class BIOCC_EventHandler : EventHandler
{
	private transient CVar Enabled, LootValueMulti;

	private uint InitialDeckSize;

	final override void OnRegister()
	{
		SetOrder(1);
		Enabled = CVar.GetCVar("BIOCC_enabled");
		LootValueMulti = CVar.GetCVar("BIOCC_lvalmulti");
	}

	final override void WorldTick()
	{
		// Card selection menu gets opened on `Level.Time 3` as of v3.5a
		if (bDestroyed || Level.Time < 4)
			return;

		if (!Enabled.GetBool())
		{
			Destroy();
			return;
		}

		let ccgame = CCards_Game(EventHandler.Find('CCards_Game'));

		if (Level.Time == 4)
			InitialDeckSize = ccgame.Deck.Size();

		// Wait until card selection is done
		if (ccgame.Deck.Size() <= InitialDeckSize)
			return;

		let globals = BIO_Global.Get();
		let lvm = float(LootValueMulti.GetInt()) * 0.01;

		for (uint i = 0; i < ccgame.Deck.Size(); i++)
		{
			globals.ModifyLootValueMultiplier(
				float(ccgame.Deck[i].Tier) * lvm
			);
		}

		Destroy();
	}
}
