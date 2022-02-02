enum BIO_EventHandlerContextFlags : uint8
{
	BIO_EHCF_NONE = 0,
	BIO_EHCF_VALIANT = 1 << 0,
	BIO_EHCF_NOSUPPLYBOXES = 1 << 1
}

// Events exclusive to StaticEventHandler may be found here,
// in case it ever gets changed as such.
class BIO_EventHandler : EventHandler
{
	private BIO_GlobalData Globals;
	private BIO_EventHandlerContextFlags ContextFlags;

	final override void OnRegister()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Registering event handler...");

		super.OnRegister();

		if (Globals == null)
			Globals = BIO_GlobalData.Get();

		name ldtoken_tn = 'LDLegendaryMonsterToken';
		LDToken = ldtoken_tn;
	}

	final override void OnUnregister()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Unregistering event handler...");

		super.OnUnregister();
	}

	final override void NewGame()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling NewGame event...");

		super.NewGame();
		Globals = BIO_GlobalData.Create();
	}

	final override void WorldLoaded(WorldEvent event)
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling WorldLoaded event...");

		super.WorldLoaded(event);

		if (BIO_Utils.Valiant())
			ContextFlags |= BIO_EHCF_VALIANT;

		// Prevent RAMP's hub from spawning a supply box
		if (Level.GetChecksum() ~== "8e1d1b012a817bb8828d7096dd1ecc28")
			ContextFlags |= BIO_EHCF_NOSUPPLYBOXES;

		for (uint i = 0; i < MAXPLAYERS; i++)
		{
			if (!PlayerInGame[i]) continue;
			let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
			
			if (bioPlayer == null) continue;
			bioPlayer.WorldLoaded(event.IsSaveGame, event.IsReopen);
			bioPlayer.SetMapSensitiveDefaults(ContextFlags);
		}
	}

	final override void PlayerEntered(PlayerEvent event)
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Handling PlayerEntered for %s...",
				Players[event.PlayerNumber].GetUserName());

		// Discarding retrieval to ensure this player's perk graph gets created
		Globals.GetPerkGraph(Players[event.PlayerNumber]);
	}

	final override void PlayerSpawned(PlayerEvent event)
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Handling PlayerSpawned for %s...",
				Players[event.PlayerNumber].GetUserName());

		super.PlayerSpawned(event);
	}

	final override bool InputProcess(InputEvent event)
	{
		if (WeaponUpgradeOverlay != null && WeaponUpgradeOverlay.Input(event))
			return true;
		
		return false; // Don't absorb this input
	}

	final override void RenderOverlay(RenderEvent event)
	{
		if (WeaponUpgradeOverlay != null) WeaponUpgradeOverlay.Draw(event);
	}

	final override void CheckReplacement(ReplaceEvent event)
	{
		if (ContextFlags & BIO_EHCF_VALIANT)
		{
			if (event.Replacee == 'Chaingun' || event.Replacee == 'BIO_Chaingun')
				event.Replacement = 'BIO_ValiantChaingun';
			else if (event.Replacee == 'Pistol' || event.Replacee == 'BIO_Pistol')
				event.Replacement = 'BIO_ValiantPistol';
		}
	}

	BIO_EventHandlerContextFlags GetContextFlags() const
	{
		return ContextFlags;
	}
}
