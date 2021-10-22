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

		Globals = BIO_GlobalData.Get();
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
	}

	override void PlayerEntered(PlayerEvent event)
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Handling PlayerEntered (player %d)...", event.PlayerNumber);

		super.PlayerEntered(event);
	}

	override void PlayerSpawned(PlayerEvent event)
	{
		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Handling PlayerSpawned (player %d)...", event.PlayerNumber);

		super.PlayerSpawned(event);
	}

	override void WorldThingSpawned(WorldEvent event)
	{
		if (event.Thing == null || event.Thing.bIsMonster || event.Thing.bMissile)
			return;

		if (ReplaceSmallAmmo(event) || ReplaceBigAmmo(event))
			return;
	}

	private void FinalizeSpawn(Class<Actor> toSpawn, Actor eventThing) const
	{
		if (toSpawn == null)
		{
			Actor.Spawn("Unknown", eventThing.Pos, NO_REPLACE);
			// For diagnostic purposes, don't destroy the original thing
		}
		else
		{
			Actor.Spawn(toSpawn, eventThing.Pos);
			eventThing.Destroy();
		}
	}

	private bool ReplaceSmallAmmo(WorldEvent event)
	{
		if (event.Thing.GetClass() == "Clip")
			FinalizeSpawn("BIO_Clip", event.Thing);
		else if (event.Thing.GetClass() == "Shell")
			FinalizeSpawn("BIO_Shell", event.Thing);
		else if (event.Thing.GetClass() == "RocketAmmo")
			FinalizeSpawn("BIO_RocketAmmo", event.Thing);
		else if (event.Thing.GetClass() == "Cell")
			FinalizeSpawn("BIO_Cell", event.Thing);
		else
			return false;

		return true;
	}

	private bool ReplaceBigAmmo(WorldEvent event)
	{
		if (event.Thing.GetClass() == "ClipBox")
			FinalizeSpawn("BIO_ClipBox", event.Thing);
		else if (event.Thing.GetClass() == "ShellBox")
			FinalizeSpawn("BIO_ShellBox", event.Thing);
		else if (event.Thing.GetClass() == "RocketBox")
			FinalizeSpawn("BIO_RocketBox", event.Thing);
		else if (event.Thing.GetClass() == "CellPack")
			FinalizeSpawn("BIO_CellPack", event.Thing);
		else
			return false;

		return true;
	}
}
