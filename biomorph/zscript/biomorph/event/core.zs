// Class declaration, registration/unregistration, new-game.
class BIO_EventHandler : EventHandler
{
	private BIO_Global Globals;

	final override void OnRegister()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Registering event handler...");

		if (Globals == null)
			Globals = BIO_Global.Get();

		name ldtoken_tn = 'LDLegendaryMonsterToken';
		LDToken = ldtoken_tn;

		RenderPrepare();
	}

	final override void OnUnregister()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Unregistering event handler...");
	}

	final override void NewGame()
	{
		if (BIO_debug)
		{
			Console.Printf(
				Biomorph.LOGPFX_DEBUG ..
				"Handling event: `NewGame`..."
			);
		}

		Globals = BIO_Global.Create();
	}

	final override void WorldLoaded(WorldEvent event)
	{
		if (BIO_debug)
		{
			Console.Printf(
				Biomorph.LOGPFX_DEBUG ..
				"Handling event: `WorldLoaded`..."
			);
		}

		if (Level.Total_Secrets < 1)
			return;

		for (uint i = 0; i < Level.Sectors.Size(); i++)
		{
			if (!Level.Sectors[i].IsSecret())
				continue;
			
			if (Level.Sectors[i].ThingList == null)
			{
				SpawnSupplyBox(
					(Level.Sectors[i].CenterSpot, Level.Sectors[i].CenterFloor())
				);
			}
			else
			{
				Actor tgt = null;

				do
				{
					for (Actor a = Level.Sectors[i].ThingList; a != null; a = a.SNext)
					{
						if (Random[BIO_Loot](1, 3) == 1)
						{
							tgt = a;
							break;
						}
					}
				} while (tgt == null);

				SpawnSupplyBox(tgt.Pos);
			}
		}
	}

	private void SpawnSupplyBox(Vector3 position)
	{
		let spawner = Actor.Spawn('BIO_WanderingSpawner', position);

		if (spawner == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Failed to create supply box's wandering spawner at position: "
				"(%.2f, %.2f, %.2f)", position.X, position.Y, position.Z
			);
			return;
		}

		BIO_WanderingSpawner(spawner).Initialize('BIO_SupplyBox', 10);
	}

	final override void WorldUnloaded(WorldEvent event)
	{
		if (BIO_debug)
		{
			Console.Printf(
				Biomorph.LOGPFX_DEBUG ..
				"Handling event: `WorldUnloaded`..."
			);
		}		
	}
}
