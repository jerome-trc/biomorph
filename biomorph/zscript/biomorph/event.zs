class biom_EventHandler : EventHandler
{
	/// Passed in the event's `args[0]`.
	enum UserEvent
	{
		/// Opens the player menu.
		USREVENT_PLAYERMENU,
		/// Prints a list of all available debug event aliases.
		USREVENT_HELP,
		USREVENT_LOOTSIM,
	}

	private biom_Global globals;
	private transient biom_Static staticData;

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

		self.globals.OnWorldLoaded();
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
		case USREVENT_PLAYERMENU:
			if (gameState != GS_LEVEL)
				break;

			if (players[consolePlayer].health <= 0)
				break;

			if (!(players[consolePlayer].mo is 'biom_Player'))
				break;

			// TODO: Player menu when ZForms gets updated.
			break;
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
				"\n\n"
				"	biom_lootsim"
				"\n\n"
				"		Reports how much monster value is in this map, \n"
				"and how many loot items would drop if all of them were killed."
			);

			break;
		case USREVENT_LOOTSIM:
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

			let output = Biomorph.LOGPFX_INFO .. "running loot simulation.\n";
			output.AppendFormat("	Current loot value multiplier: %.2f\n", self.globals.LootValueMultiplier());
			let total = self.globals.MapTotalMonsterValue();
			output.AppendFormat("	Total monster value in map: %d\n", total);
			let numDrops = total / biom_Global.LOOT_VALUE_THRESHOLD;
			output.AppendFormat("	Total loot drops: %d\n", numDrops);

			Console.PrintF(output);
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

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.thing == null || !event.thing.bIsMonster)
			return;

		self.globals.AddLootValue(self.globals.CalcMonsterValue(event.thing));
		let thresholdPassed = false;

		while (self.globals.DrainLootValueBuffer())
		{
			thresholdPassed = true;
		}

		if (thresholdPassed)
		{
			S_StartSound("biom/alter/levelup", CHAN_AUTO);
			Console.MidPrint('JenocideFontRed', "$BIOM_ALTERLEVEL", true);
		}
	}

	final override void CheckReplacement(ReplaceEvent event)
	{
		// `DestroyAllThinkers` with CCards can VM abort if not for this check.
		if (self.globals == null)
			return;

		let t = self.GetStaticData().GetReplacement(event.replacee.GetClassName());

		if (t != null)
			event.replacement = t;
	}

	biom_Static GetStaticData()
	{
		if (self.staticData != null)
			return self.staticData;

		let e = biom_Static(StaticEventHandler.Find('biom_Static'));
		self.staticData = e;
		return self.staticData;
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
