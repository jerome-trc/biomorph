extend class BIO_EventHandler
{
	final override void NetworkProcess(ConsoleEvent event)
	{
		// Normal gameplay events

		if (NetEvent_WUpOverlay(event) || NetEvent_WeaponUpgrade(event))
			return;

		// Debugging events

		if (NetEvent_AddWeapAffix(event) || NetEvent_RemoveWeapAffix(event))
			return;

		if (NetEvent_RecalcWeap(event))
			return;
	}

	const EVENT_WUPOVERLAY = "bio_wupoverlay";
	const EVENT_WEAPUPGRADE = "bio_weapupgrade";
	const EVENT_COMMITPERK = "bio_commitperk";

	private transient BIO_WeaponUpgradeOverlay WeaponUpgradeOverlay;

	private bool NetEvent_WUpOverlay(ConsoleEvent event) const
	{
		if (!(event.Name ~== EVENT_WUPOVERLAY)) return false;
		if (event.Player != ConsolePlayer) return true;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return true;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WUPOVERLAY ..
				" was illegally invoked by a non-Biomorph PlayerPawn.");
			return true;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WUPOVERLAY ..
				" was illegally invoked for a non-Biomorph weapon.");
			return true;
		}

		Array<BIO_WeaponUpgrade> options;
		Globals.PossibleWeaponUpgrades(options, weap.GetClass());

		if (options.Size() < 1)
		{
			bioPlayer.A_Print("$BIO_WUP_FAIL_NOOPTIONS");
			return true;
		}

		WeaponUpgradeOverlay = BIO_WeaponUpgradeOverlay.Create(options);
		return true;
	}

	private bool NetEvent_WeaponUpgrade(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return false;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== EVENT_WEAPUPGRADE))
			return false;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return true;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WEAPUPGRADE ..
				" was illegally invoked by a non-Biomorph PlayerPawn.");
			return true;
		}

		if (nameParts.Size() < 2)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				EVENT_WEAPUPGRADE .. " received no second part.");
			return true;
		}

		if (nameParts[1] == "_")
		{
			// The user cancelled this weapon upgrade operation
			WeaponUpgradeOverlay.Destroy();
			// TODO: Feedback sound
			return true;
		}

		Class<BIO_Weapon> outputChoice = nameParts[1];

		if (outputChoice == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Invalid weapon upgrade choice submitted: %s", nameParts[1]);
			return true;
		}

		if (bioPlayer.FindInventory(outputChoice))
		{
			bioPlayer.A_Print("$BIO_WUP_FAIL_ALREADYHELD", 4.0);
			return true;
		}

		if (event.Args[0] > bioPlayer.CountInv('BIO_Muta_Upgrade'))
		{
			bioPlayer.A_Print("$BIO_WUP_FAIL_INSUFFICIENT", 4.0);
			return true;
		}
		
		Globals.OnWeaponAcquired(GetDefaultByType(outputChoice).Grade);
		bioPlayer.A_SelectWeapon('BIO_Fist');
		bioPlayer.TakeInventory(bioPlayer.Player.ReadyWeapon.GetClass(), 1);
		bioPlayer.GiveInventory(outputChoice, 1);
		bioPlayer.A_SelectWeapon(outputChoice);
		bioPlayer.A_StartSound("bio/item/weapupgrade/use", CHAN_ITEM);
		bioPlayer.A_StartSound("bio/muta/use/general", CHAN_7);
		bioPlayer.TakeInventory('BIO_Muta_Upgrade', event.Args[0]);
		WeaponUpgradeOverlay.Destroy();
		return true;
	}

	private bool NetEvent_CommitPerk(ConsoleEvent event) const
	{
		if (!(event.Name ~== EVENT_COMMITPERK)) return false;
		if (event.Player != ConsolePlayer) return true;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return true;
		}

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return true;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_COMMITPERK ..
				" was illegally invoked by a non-Biomorph PlayerPawn.");
			return true;
		}

		let pGraph = Globals.GetPerkGraph(Players[ConsolePlayer]);
		let bGraph = Globals.GetBasePerkGraph();
		Class<BIO_Passive> pasv_t = null;

		if (event.Args[0] >= bGraph.Nodes.Size() ||
			event.Args[0] <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to commit perk under invalid UUID: %d", event.Args[0]);
			return true;
		}

		if (bGraph.Nodes[event.Args[0]].PerkClass == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to commit invalid perk class, UUID: %d", event.Args[0]);
			return true;
		}

		let pasv = BIO_Passive(new(bGraph.Nodes[event.Args[0]].PerkClass));
		pasv.Apply(bioPlayer);
		pGraph.Points--;
		return true;
	}

	private bool NetEvent_AddWeapAffix(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return false;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_addwafx"))
			return false;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return true;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return true;
		}

		if (nameParts.Size() < 2 || !nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide the class name of a weapon affix to add.");
			return true;
		}

		Class<BIO_WeaponAffix> wafx_t = nameParts[1];
		if (wafx_t == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a legal weapon affix class name.",
				nameParts[1]);
			return true;
		}

		uint e = weap.Affixes.Push(BIO_WeaponAffix(new(wafx_t)));
		weap.Affixes[e].Init(weap.AsConst());
		weap.Affixes[e].Apply(weap);
		weap.OnWeaponChange();
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Applied %s to your current weapon.", wafx_t.GetClassName());
		return true;
	}

	private bool NetEvent_RemoveWeapAffix(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return false;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_rmwafx"))
			return false;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return true;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return true;
		}

		if (nameParts.Size() < 2 || !nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide the class name of a weapon affix to remove.");
			return true;
		}

		Class<BIO_WeaponAffix> wafx_t = nameParts[1];
		if (wafx_t == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a legal weapon affix class name.",
				nameParts[1]);
			return true;
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
			return true;
		}

		weap.ResetStats();
		weap.ApplyAllAffixes();
		weap.OnWeaponChange();

		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Removed %s from your current weapon.", wafx_t.GetClassName());
		return true;
	}

	private bool NetEvent_RecalcWeap(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_recalcweap"))
			return false;
		
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"`bio_recalcweap`");
			return true;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return true;
		}

		weap.ResetStats();
		weap.ApplyAllAffixes();
		weap.OnWeaponChange();
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Reset stats and re-applied affixes of your readied weapon.");
		return true;
	}

	// =========================================================================

	static clearscope void CommitPerk(uint uuid)
	{
		EventHandler.SendNetworkEvent(EVENT_COMMITPERK, uuid);
	}
}
