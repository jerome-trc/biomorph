extend class BIO_EventHandler
{
	final override void NetworkProcess(ConsoleEvent event)
	{
		if (event.Name.Length() < 5 || !(event.Name.Left(4) ~== "bio_"))
			return;

		// Normal gameplay events

		NetEvent_WUpOverlay(event);
		NetEvent_WeaponUpgrade(event);
		NetEvent_PerkOp(event);

		// Debugging events

		NetEvent_AddWeapAffix(event);
		NetEvent_RemoveWeapAffix(event);
		NetEvent_RecalcWeap(event);
		NetEvent_LevelUp(event);
		NetEvent_XPReset(event);
		NetEvent_GlobalRegen(event);
	}

	const EVENT_WUPOVERLAY = "bio_wupoverlay";
	const EVENT_WEAPUPGRADE = "bio_weapupgrade";
	const EVENT_PERKOP = "bio_perkop";

	enum PerkOp : uint8
	{
		PERKOPARG_RESET,
		PERKOPARG_ADD,
		PERKOPARG_REFUND,
		PERKOPARG_COMMIT
	}

	enum GlobalRegen : uint8
	{
		GLOBALREGEN_UPGRADES = 0
	}

	private transient BIO_WeaponUpgradeOverlay WeaponUpgradeOverlay;

	private void NetEvent_WUpOverlay(ConsoleEvent event) const
	{
		if (!(event.Name ~== EVENT_WUPOVERLAY)) return;
		if (event.Player != ConsolePlayer) return;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WUPOVERLAY ..
				" was illegally invoked by a non-Biomorph PlayerPawn.");
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WUPOVERLAY ..
				" was illegally invoked for a non-Biomorph weapon.");
			return;
		}

		Array<BIO_WeaponUpgrade> options;
		Globals.PossibleWeaponUpgrades(options, weap.GetClass());

		if (options.Size() < 1)
		{
			bioPlayer.A_Print("$BIO_WUP_FAIL_NOOPTIONS");
			return;
		}

		WeaponUpgradeOverlay = BIO_WeaponUpgradeOverlay.Create(options);
	}

	private void NetEvent_WeaponUpgrade(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== EVENT_WEAPUPGRADE))
			return;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WEAPUPGRADE ..
				" was illegally invoked by a non-Biomorph PlayerPawn.");
			return;
		}

		if (nameParts.Size() < 2)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				EVENT_WEAPUPGRADE .. " received no second part.");
			return;
		}

		if (nameParts[1] == "_")
		{
			// The user cancelled this weapon upgrade operation
			WeaponUpgradeOverlay.Destroy();
			// TODO: Feedback sound
			return;
		}

		Class<BIO_Weapon> outputChoice = nameParts[1];

		if (outputChoice == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Invalid weapon upgrade choice submitted: %s", nameParts[1]);
			return;
		}

		if (bioPlayer.FindInventory(outputChoice))
		{
			bioPlayer.A_Print("$BIO_WUP_FAIL_ALREADYHELD", 4.0);
			return;
		}

		if (event.Args[0] > bioPlayer.CountInv('BIO_Muta_Upgrade'))
		{
			bioPlayer.A_Print("$BIO_WUP_FAIL_INSUFFICIENT", 4.0);
			return;
		}
		
		Globals.OnWeaponAcquired(GetDefaultByType(outputChoice).Grade);
		bioPlayer.A_SelectWeapon('BIO_Fist');
		let oldWeap = BIO_Weapon(bioPlayer.Player.ReadyWeapon);
		bool mut = oldWeap.Rarity == BIO_RARITY_MUTATED;
		bioPlayer.TakeInventory(oldWeap.GetClass(), 1);
		bioPlayer.GiveInventory(outputChoice, 1);

		if (mut)
		{
			let newWeap = BIO_Weapon(bioPlayer.FindInventory(outputChoice));
			newWeap.RandomizeAffixes();
			newWeap.OnChange();
		}

		bioPlayer.A_SelectWeapon(outputChoice);
		bioPlayer.A_StartSound("bio/item/weapupgrade/use", CHAN_AUTO);
		bioPlayer.A_StartSound("bio/muta/use/general", CHAN_7);
		bioPlayer.TakeInventory('BIO_Muta_Upgrade', event.Args[0]);
		WeaponUpgradeOverlay.Destroy();
	}

	private void NetEvent_PerkOp(ConsoleEvent event) const
	{
		if (!(event.Name ~== EVENT_PERKOP)) return;
		if (event.Player != ConsolePlayer) return;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_PERKOP ..
				" was illegally invoked by a non-Biomorph `PlayerPawn`.");
			return;
		}

		switch (event.Args[0])
		{
		case PERKOPARG_RESET:
			bioPlayer.Reset();
			return;
		case PERKOPARG_ADD:
			PerkOp_Add(bioPlayer, event.Args[1]);
			return;
		case PERKOPARG_REFUND:
			PerkOp_Refund(bioPlayer, event.Args[1]);
			return;
		case PERKOPARG_COMMIT:
			bioPlayer.ApplyPerks();
			return;
		default:
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Invalid perk operation requested: %d (player %s)",
				event.Args[0], Players[ConsolePlayer].GetUserName());
		}
	}

	private void PerkOp_Add(BIO_Player bioPlayer, uint uuid) const
	{
		let pGraph = Globals.GetPerkGraph(Players[ConsolePlayer]);
		let bGraph = Globals.GetBasePerkGraph();

		if (uuid >= bGraph.Nodes.Size())
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to add perk under invalid UUID %d to player %s",
				uuid, Players[ConsolePlayer].GetUserName());
			return;
		}

		if (bGraph.Nodes[uuid].Perk == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to add null perk (UUID %d) to player %s",
				uuid, Players[ConsolePlayer].GetUserName());
			return;
		}

		if (pGraph.PerkActive[uuid])
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to add already-active perk, UUID: %d", uuid);
			return;
		}

		pGraph.PerkActive[uuid] = true;
		pGraph.Points--;
	}

	private void PerkOp_Refund(BIO_Player bioPlayer, uint uuid) const
	{
		let pGraph = Globals.GetPerkGraph(Players[ConsolePlayer]);
		let bGraph = Globals.GetBasePerkGraph();

		if (uuid >= bGraph.Nodes.Size())
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to refund perk under invalid UUID %d for player %s",
				uuid, Players[ConsolePlayer].GetUserName());
			return;
		}

		if (!pGraph.PerkActive[uuid])
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to refund inactive perk (UUID %d) for player %s",
				uuid, Players[ConsolePlayer].GetUserName());
			return;
		}

		pGraph.PerkActive[uuid] = false;
		pGraph.Points++;
		pGraph.Refunds--;
	}

	// If first argument is non-zero, force adding the affix.
	// If second argument is non-zero, add the affix as implicit.
	private void NetEvent_AddWeapAffix(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_addwafx"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return;
		}

		if (nameParts.Size() < 2 || !nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide the class name of a weapon affix to add.");
			return;
		}

		Class<BIO_WeaponAffix> wafx_t = nameParts[1];
		if (wafx_t == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a legal weapon affix class name.",
				nameParts[1]);
			return;
		}

		bool force = event.Args[0] != 0;
		bool implicit = event.Args[1] != 0;

		if (weap.HasAffixOfType(wafx_t, implicit: implicit) && !force)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Weapon already has affix of type `%s` "
				"(give non-zero as second argument to force).",
				wafx_t.GetClassName());
			return;
		}

		if (weap.HasAffixOfType(wafx_t, implicit: implicit) && !force)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Weapon already has affix of type `%s` "
				"(give non-zero as second argument to force).",
				wafx_t.GetClassName());
			return;
		}

		if (!Globals.WeaponAffixCompatible(
			wafx_t, weap.AsConst(), implicit: implicit) && !force)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Weapon incompatible with affix of type `%s` "
				"(give non-zero as arg. 2 to force).",
				wafx_t.GetClassName());
			return;
		}

		if (!implicit)
		{
			uint e = weap.Affixes.Push(BIO_WeaponAffix(new(wafx_t)));
			weap.Affixes[e].Init(weap.AsConst());
		}
		else
		{
			uint e = weap.ImplicitAffixes.Push(BIO_WeaponAffix(new(wafx_t)));
			weap.ImplicitAffixes[e].Init(weap.AsConst());
		}

		weap.OnChange();
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Applied %s to your current weapon.", wafx_t.GetClassName());
	}

	private void NetEvent_RemoveWeapAffix(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_rmwafx"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return;
		}

		if (nameParts.Size() < 2 || !nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide the class name of a weapon affix to remove.");
			return;
		}

		Class<BIO_WeaponAffix> wafx_t = nameParts[1];
		if (wafx_t == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a legal weapon affix class name.",
				nameParts[1]);
			return;
		}

		if (weap.HasAffixOfType(wafx_t, false))
		{
			for (uint i = 0; i < weap.Affixes.Size(); i++)
			{
				if (weap.Affixes[i].GetClass() == wafx_t)
				{
					weap.Affixes.Delete(i);
					break;
				}
			}
		}
		else if (weap.HasAffixOfType(wafx_t, true))
		{
			for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
			{
				if (weap.ImplicitAffixes[i].GetClass() == wafx_t)
				{
					weap.ImplicitAffixes.Delete(i);
					break;
				}
			}
		}
		else
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Your current weapon has no affix of class %s.",
				wafx_t.GetClassName());
			return;
		}

		weap.OnChange();

		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Removed %s from your current weapon.", wafx_t.GetClassName());
	}

	// If the first argument is greater than 0, a
	// full affix re-initialisation is also performed.
	private void NetEvent_RecalcWeap(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_recalcweap"))
			return;
		
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Net event `bio_recalcweap` can only be manually invoked.");
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return;
		}

		if (event.Args[0] > 0)
		{
			for (uint i = 0; i < weap.Affixes.Size(); i++)
			{
				weap.Affixes[i] = BIO_WeaponAffix(new(weap.Affixes[i].GetClass()));
				weap.Affixes[i].Init(weap.AsConst());
			}
		}

		weap.OnChange();
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Reset stats and re-applied affixes of your readied weapon.");
	}

	private void NetEvent_LevelUp(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_levelup") && !(event.Name ~== "bio_lvlup"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Net event `bio_levelup` can only be manually invoked.");
			return;
		}

		for (uint i = 0; i < Max(event.Args[0], 1); i++)
			Globals.LevelUp();
	}

	private void NetEvent_XPReset(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_xpreset"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Net event `bio_xpreset` can only be manually invoked.");
			return;
		}

		if (!(Players[event.Player].MO is 'BIO_Player'))
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on Biomorph-class players.");
			return;
		}

		Globals.XPReset();
	}

	private void NetEvent_GlobalRegen(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_globalregen"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Net event `bio_globalregen` can only be manually invoked.");
			return;
		}

		switch (event.Args[0])
		{
		case GLOBALREGEN_UPGRADES:
			Globals.RegenUpgrades();
			return;
		default:
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Invalid global regen requested: %d", event.Args[0]);
		}
	}

	// =========================================================================

	static clearscope void ResetPlayer()
	{
		EventHandler.SendNetworkEvent(EVENT_PERKOP, PERKOPARG_RESET);
	}

	static clearscope void AddPerk(uint uuid)
	{
		EventHandler.SendNetworkEvent(EVENT_PERKOP, PERKOPARG_ADD, uuid);
	}

	static clearscope void RefundPerk(uint uuid)
	{
		EventHandler.SendNetworkEvent(EVENT_PERKOP, PERKOPARG_REFUND, uuid);
	}

	static clearscope void CommitPerks()
	{
		EventHandler.SendNetworkEvent(EVENT_PERKOP, PERKOPARG_COMMIT);
	}
}
