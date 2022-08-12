version "3.7"

class BIOCC_EventHandler : EventHandler
{
	private transient CVar Enabled, LootValueMulti, ChaosMulti, MasterMulti;

	private uint InitialDeckSize;

	final override void OnRegister()
	{
		SetOrder(1);
		Enabled = CVar.GetCVar("BIOCC_enabled");
		LootValueMulti = CVar.GetCVar("BIOCC_lvalmulti");
		ChaosMulti = CVar.GetCVar("BIOCC_chaosmulti");
		MasterMulti = CVar.GetCVar("BIOCC_mastermulti");
	}

	final override void WorldTick()
	{
		// Card selection menu gets opened on `Level.Time 3` as of v3.8
		if (bDestroyed || Level.Time < 4)
			return;

		if (!Enabled.GetBool())
		{
			Destroy();
			return;
		}

		let ccgame = CCards_Functions.GetGame();

		if (Level.Time == 4)
			InitialDeckSize = ccgame.Deck.Size();

		// Wait until card selection is done
		if (ccgame.Deck.Size() <= InitialDeckSize)
			return;

		let globals = BIO_Global.Get();
		let lvm = LootValueMulti.GetFloat();
		let total = 0.0;

		if (ccgame.Global.Rules.CVarName ~== "ccards_chaosbest")
			lvm *= ChaosMulti.GetFloat();
		else if (ccgame.Global.Rules.CVarName ~== "ccards_masterbest")
			lvm *= MasterMulti.GetFloat();

		for (uint i = 0; i < ccgame.Deck.Size(); i++)
			total += float(ccgame.Deck[i].Tier) * lvm;

		if (BIO_debug)
		{
			Console.Printf(
				Biomorph.LOGPFX_DEBUG ..
				"(CCARDS) Adding %.2f to loot value multiplier.",
				total
			);
		}

		globals.ModifyLootValueMultiplier(total);
		Destroy();
	}
}
