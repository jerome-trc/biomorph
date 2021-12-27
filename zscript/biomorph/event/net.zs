extend class BIO_EventHandler
{
	final override void NetworkProcess(ConsoleEvent event)
	{
		// Normal gameplay events

		if (NetEvent_WUpOverlay(event) || NetEvent_WeaponUpgrade(event))
			return;

		// Debugging events

		if (NetEvent_AddPassive(event) || NetEvent_RemovePassive(event))
			return;

		if (NetEvent_AddWeapAffix(event) || NetEvent_RemoveWeapAffix(event))
			return;
	}

	const EVENT_WUPOVERLAY = "bio_wupoverlay";
	const EVENT_WEAPUPGRADE = "bio_weapupgrade";

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
		bioPlayer.GiveInventory(outputChoice, 1);
		bioPlayer.A_SelectWeapon(outputChoice);
		bioPlayer.TakeInventory(bioPlayer.Player.ReadyWeapon.GetClass(), 1);
		bioPlayer.A_StartSound("bio/item/weapupgrade/use", CHAN_ITEM);
		bioPlayer.TakeInventory('BIO_Muta_Upgrade', event.Args[0]);
		WeaponUpgradeOverlay.Destroy();
		return true;
	}

	private bool NetEvent_AddPassive(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return false;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_addpasv"))
			return false;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return true;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on Biomorph-class players.");
			return true;
		}

		if (nameParts.Size() < 2 || !nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide the class name of a player passive to add.");
			return true;
		}

		Class<BIO_Passive> pasv_t = nameParts[1];
		if (pasv_t == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a legal passive class name.", nameParts[1]);
			return true;
		}

		uint count = event.Args[0] != 0 ? Max(event.Args[0], 0) : 1;
		bioPlayer.PushPassive(pasv_t, count);
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Added passive effect %s x%d.", pasv_t.GetClassName(), count);
		return true;
	}

	private bool NetEvent_RemovePassive(ConsoleEvent event) const
	{
		if (event.Player != ConsolePlayer) return false;

		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_rmpasv"))
			return false;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return true;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on Biomorph-class players.");
			return true;
		}

		if (nameParts.Size() < 2 || !nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide the class name of a player passive to remove.");
			return true;
		}

		Class<BIO_Passive> pasv_t = nameParts[1];
		if (pasv_t == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a legal passive class name.", nameParts[1]);
			return true;
		}

		uint count = event.Args[0] != 0 ? Max(event.Args[0], 0) : 1;
		bioPlayer.PopPassive(pasv_t, count);
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Removed passive effect %s x%d.", pasv_t.GetClassName(), count);
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
}
