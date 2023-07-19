class BIOM_EventHandler : EventHandler
{
	/// Passed in the event's `args[0]`.
	enum UserEvent
	{
		/// Prints a list of all available debug event aliases.
		USREVENT_HELP,
		/// Opens the mutation menu.
		USREVENT_MUTMENU,
	}

	private BIOM_Global globals;

	final override void OnRegister()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Registering event handler...");

		if (self.globals == null)
			self.globals = BIOM_Global.Get();
	}

	final override void OnUnregister()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Unregistering event handler...");
	}

	final override void NewGame()
	{
		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Handling event: `NewGame`..."
			);
		}

		self.globals = BIOM_Global.Create();
	}

	final override void WorldLoaded(WorldEvent event)
	{
		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Handling event: `WorldLoaded`..."
			);
		}
	}

	final override void WorldUnloaded(WorldEvent event)
	{
		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Handling event: `WorldUnloaded`..."
			);
		}
	}

	final override void ConsoleProcess(ConsoleEvent event)
	{
		if (!(event.name ~== "biom_console"))
			return;

		switch (event.args[0])
		{
		case USREVENT_HELP:
			if (!event.isManual)
			{
				Console.PrintF(
					Biomorph.LOGPFX_ERR ..
					"Illegal attempt by a script to invoke the `biom_console` event. "
					"Argument 0: %d",
					event.args[0]
				);

				return;
			}

			Console.PrintF(
				Biomorph.LOGPFX_INFO .. "\n"
				"\c[Gold]Console events:\c-"
				"\n"
				"	biom_help"
				"\n\n"
				"		Prints a list of all available debug event aliases."
			);

			break;
		case USREVENT_MUTMENU:
			if (gameState != GS_LEVEL)
				break;

			if (players[consolePlayer].health <= 0)
				break;

			if (!(players[consolePlayer].mo is 'BIOM_Player'))
				break;

			if (Menu.GetCurrentMenu() is 'BIOM_MutationMenu')
				break;

			Menu.SetMenu('BIOM_MutationMenu');
			break;
		default:
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Illegal user console event argument: %d",
				event.args[0]
			);

			break;
		}
	}
}
