// Events exclusive to StaticEventHandler may be found here,
// in case it ever gets changed as such.
class BIO_EventHandler : EventHandler
{
	private BIO_GlobalData Globals;

	private bool InValiant;

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
		InValiant = BIO_Utils.Valiant();

		for (uint i = 0; i < MAXPLAYERS; i++)
		{
			if (!PlayerInGame[i]) continue;
			let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
			
			if (bioPlayer == null) continue;
			bioPlayer.WorldLoaded(event.IsSaveGame, event.IsReopen);
			
			if (!InValiant) continue;
			let clipItem = Ammo(bioPlayer.FindInventory('Clip'));
			
			if (clipItem.MaxAmount < 300)
				clipItem.MaxAmount = 300;

			if (clipItem.BackpackMaxAmount < (clipItem.MaxAmount * 2))
				clipItem.BackpackMaxAmount = clipItem.MaxAmount * 2;
		
			let pistol = bioPlayer.FindInventory('BIO_Pistol');
			if (pistol != null)
			{
				bioPlayer.A_SelectWeapon('BIO_Fist');
				bioPlayer.TakeInventory('BIO_Pistol', 1);
				bioPlayer.GiveInventory('BIO_ValiantPistol', 1);
				bioPlayer.A_SelectWeapon('BIO_ValiantPistol');
			}
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
		if (InValiant)
		{
			if (event.Replacee == 'Chaingun' || event.Replacee == 'BIO_Chaingun')
				event.Replacement = 'BIO_ValiantChaingun';
			else if (event.Replacee == 'Pistol' || event.Replacee == 'BIO_Pistol')
				event.Replacement = 'BIO_ValiantPistol';
		}
	}
}
