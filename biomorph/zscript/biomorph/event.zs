class biom_EventHandler : EventHandler
{
	/// Passed in the event's `args[0]`.
	enum UserEvent
	{
		/// Prints a list of all available debug event aliases.
		USREVENT_HELP,
		/// Opens the mutation menu.
		USREVENT_MUTMENU,
	}

	private biom_Global globals;

	final override void OnRegister()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Registering event handler...");

		if (self.globals == null)
			self.globals = biom_Global.Get();
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

		Self.IncompatibilityAssertions();
		self.globals = biom_Global.Create();
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

			if (!(players[consolePlayer].mo is 'biom_Player'))
				break;

			// TODO: `biom_MutationMenu` when ZForms gets updated.
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

	private static void IncompatibilityAssertions()
	{
		{
			name htn = 'ThriftyHealth';
			class<Health> ht = htn;

			name atn = 'ThriftyAmmo';
			class<Ammo> at = atn;

			if (ht != null || at != null)
			{
				ThrowAbortException(
					"\n---\n"
					"Thrifty Health or Thrifty Ammo detected.\n"
					"Biomorph already has waste-proof pickups "
					"and is incompatible with these mods.\n"
					"Disable them to continue.\n"
					"---"
				);
			}
		}

		{
			name tn = 'Zhs2_IS_BaseItem';
			class<Inventory> t = tn;

			if (t != null)
			{
				ThrowAbortException(
					"\n---\n"
					"Intelligent Supplies detected.\n"
					"Biomorph already has waste-proof pickups "
					"and is incompatible with this mod.\n"
					"Disable it to continue.\n"
					"---"
				);
			}
		}
	}
}
