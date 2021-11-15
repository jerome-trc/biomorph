// Events exclusive to StaticEventHandler may be found here,
// in case it ever gets changed as such.
class BIO_EventHandler : EventHandler
{
	private BIO_GlobalData Globals;

	override void OnRegister()
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Registering event handler...");

		super.OnRegister();

		Globals = BIO_GlobalData.Create();
		name ldtoken_tn = 'LDLegendaryMonsterToken';
		LDToken = ldtoken_tn;
	}

	override void OnUnregister()
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Unregistering event handler...");

		super.OnUnregister();
	}

	override void NewGame()
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling NewGame event...");

		super.NewGame();
	}

	override void WorldLoaded(WorldEvent event)
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling WorldLoaded event...");

		super.WorldLoaded(event);

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer != null)
		{
			bioPlayer.WorldLoaded(event.IsSaveGame, event.IsReopen);
		}
	}

	override void PlayerEntered(PlayerEvent event)
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Handling PlayerEntered (player %d)...", event.PlayerNumber);

		// Discarding retrieval to ensure this player's perk graph gets created
		Globals.GetPerkGraph(Players[event.PlayerNumber]);
	}

	override void PlayerSpawned(PlayerEvent event)
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Handling PlayerSpawned (player %d)...", event.PlayerNumber);

		super.PlayerSpawned(event);
	}

	override bool InputProcess(InputEvent event)
	{
		if (WeaponUpgradeOverlay != null && WeaponUpgradeOverlay.Input(event))
			return true;
		
		return false; // Don't absorb this input
	}

	override void RenderOverlay(RenderEvent event)
	{
		if (WeaponUpgradeOverlay != null) WeaponUpgradeOverlay.Draw(event);
	}
}
