// Events exclusive to StaticEventHandler may be found here,
// in case it ever gets changed as such.
class BIO_EventHandler : EventHandler
{
	const LOOT_RNG_THRESHOLD = 200;

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

	override void ConsoleProcess(ConsoleEvent event)
	{
		if (ConEvent_WeapDiag(event)) return;
		if (ConEvent_XPInfo(event)) return;
		if (ConEvent_WeapAfxCompat(event)) return;
	}

	private ui bool ConEvent_WeapDiag(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_weapdiag")) return false;
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked manually.");
			return true;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null) return true;

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return true;
		}

		string output = Biomorph.LOGPFX_INFO;
		output.AppendFormat("%s\n%s\n", weap.GetClassName(), weap.GetTag());

		string ft1, ft2;

		if (weap.FireType1 != null)
			ft1 = weap.FireType1.GetClassName();
		else
			ft1 = "null";

		if (weap.FireType2 != null)
			ft2 = weap.FireType2.GetClassName();
		else
			ft2 = "null";

		output = output .. "Primary stats:\n";
		output.AppendFormat("Fire data: %d x %s\n", weap.FireCount1, ft1);
		output.AppendFormat("Damage: [%d, %d]\n", weap.MinDamage1, weap.MaxDamage1);

		output = output .. "Secondary stats:\n";
		output.AppendFormat("Fire data: %d x %s\n", weap.FireCount2, ft2);
		output.AppendFormat("Damage: [%d, %d]\n", weap.MinDamage2, weap.MaxDamage2);

		Array<int> fireTimes;
		weap.GetFireTimes(fireTimes);
		if (fireTimes.Size() > 0)
		{
			output = output .. "Fire times:\n";
			for (uint i = 0; i < fireTimes.Size(); i++)
				output = output .. "\t" .. fireTimes[i] .. "\n";
		}

		Array<int> reloadTimes;
		weap.GetReloadTimes(reloadTimes);
		if (reloadTimes.Size() > 0)
		{
			output = output .. "Reload times:\n";
			for (uint i = 0; i < reloadTimes.Size(); i++)
				output = output .. "\t" .. reloadTimes[i] .. "\n";
		}

		output.AppendFormat("Switch speeds: %d lower, %d raise\n",
			weap.LowerSpeed, weap.RaiseSpeed);

		output.AppendFormat("Kickback: %d", weap.Kickback);

		if (weap.ImplicitAffixes.Size() > 0)
		{
			output = output .. "Implicit affixes:\n";
			for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
				output.AppendFormat("\t%s\n", weap.ImplicitAffixes[i].GetClassName());
		}

		if (weap.Affixes.Size() > 0)
		{
			output = output .. "Affixes:\n";
			for (uint i = 0; i < weap.Affixes.Size(); i++)
				output.AppendFormat("\t%s\n", weap.Affixes[i].GetClassName());
		}

		Console.Printf(output);
		return true;
	}

	private ui bool ConEvent_WeapAfxCompat(ConsoleEvent event) const
	{
		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_weapafxcompat"))
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

		if (!nameParts[1])
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Please provide a weapon affix class name.");
			return true;
		}
	
		Class<BIO_WeaponAffix> afx_t = nameParts[1];
		if (!afx_t)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a valid weapon affix class name.", nameParts[1]);
			return true;
		}

		bool compat = BIO_WeaponAffix(new(afx_t)).Compatible(weap);
		string output;
		
		if (compat)
			output.AppendFormat("\ck%s\c- is \cdcompatible\c- with this weapon.",
				afx_t.GetClassName());
		else
			output.AppendFormat("\ck%s\c- is \cgincompatible\c- with this weapon.",
				afx_t.GetClassName());
		
		Console.Printf(Biomorph.LOGPFX_INFO .. output);
		return true;
	}

	private ui bool ConEvent_XPInfo(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_xp")) return false;
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"This event can only be invoked manually.");
			return true;
		}

		Console.Printf(Biomorph.LOGPFX_INFO .. "Party XP and levelling info:\n");
		Console.Printf("Party level: %d", Globals.GetPartyLevel());
		Console.Printf("Current party XP: %d", Globals.GetPartyXP());
		Console.Printf("XP to next level: %d", Globals.XPToNextLevel());
		return true;
	}

	override void WorldThingSpawned(WorldEvent event)
	{
		if (event.Thing == null || event.Thing.bMissile || event.Thing.bIsMonster)
			return;

		if (event.Thing is "Inventory")
		{
			let item = Inventory(event.Thing);
			if (item.Owner != null || item.Master != null)
			{
				super.WorldThingSpawned(event);
				return;
			}
		}

		if (ReplaceSmallAmmo(event) || ReplaceBigAmmo(event))
			return;

		if (ReplaceShotgun(event) || ReplaceChaingun(event))
			return;

		if (ReplaceArmor(event))
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

	private bool ReplaceSmallAmmo(WorldEvent event) const
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

	private bool ReplaceBigAmmo(WorldEvent event) const
	{
		Class<Actor> choice = null;

		if (event.Thing.GetClass() == "ClipBox")
			choice = "BIO_ClipBox";
		else if (event.Thing.GetClass() == "ShellBox")
			choice = "BIO_ShellBox";
		else if (event.Thing.GetClass() == "RocketBox")
			choice = "BIO_RocketBox";
		else if (event.Thing.GetClass() == "CellPack")
			choice = "BIO_CellPack";
		else
			return false;

		if (Random(0, 8) == 0)
			Actor.Spawn("BIO_WeaponUpgradeKitSpawner", event.Thing.Pos);

		FinalizeSpawn(choice, event.Thing);
		return true;
	}

	private bool ReplaceArmor(WorldEvent event) const
	{
		if (event.Thing.GetClass() == "GreenArmor")
			FinalizeSpawn("BIO_StandardArmor", event.Thing);
		else if (event.Thing.GetClass() == "BlueArmor")
		{
			if (Random(1, 6))
				FinalizeSpawn("BIO_ExperimentalArmor", event.Thing);
			else
				FinalizeSpawn("BIO_SpecialtyArmor", event.Thing);
		}
		else
			return false;

		return true;
	}

	private bool ReplaceShotgun(WorldEvent event) const
	{
		if (event.Thing.GetClass() != "BIO_Shotgun") return false;

		// If a Shotgun has been dropped (as opposed to hand-placed on the map),
		// almost always replace it with an ammo pickup
		if (Level.MapTime > 0 && Random(0, 15) != 0)
			FinalizeSpawn("BIO_Shell", event.Thing);

		return true;
	}

	private bool ReplaceChaingun(WorldEvent event) const
	{
		if (event.Thing.GetClass() != "BIO_Chaingun") return false;

		// If a Chaingun has been dropped (as opposed to hand-placed on the map),
		// almost always replace it with an ammo pickup
		if (Level.MapTime > 0 && Random(0, 15) != 0)
			FinalizeSpawn("BIO_Clip", event.Thing);

		return true;
	}

	override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster) return;

		// There's no way to know if a Lost Soul was a Pain Elemental spawn,
		// so just forbid Lost Souls from giving anything to prevent farming
		if (event.Thing is "LostSoul") return;

		/*	Every monster has a "value" that determines the XP it gives the party,
			and the chance that it drops a mutagen. This value is derived from its
			relative strength (health, certain properties, flags, etc.).

			This value turns into the chance that the monster drops a mutagen;
			this chance can overflow such that a monster drops multiple
		*/

		// Killing a Baron guarantees one mutagen
		int val = LOOT_RNG_THRESHOLD * (float(event.Thing.Default.Health) / 1000.0);

		// More pain resistance means more value
		val += ((256 - event.Thing.Default.PainChance) / 4);

		// How much faster is it than a ZombieMan?
		val += (Max(event.Thing.Default.Speed - 8, 0) * 3);

		if (event.Thing.bBoss) val *= 2;

		if (event.Thing.bNoRadiusDmg) val *= 1.1;
		if (event.Thing.bNoPain) val *= 1.1;
		if (event.Thing.bAlwaysFast) val *= 1.1;
		if (event.Thing.bMissileMore) val *= 1.1;
		if (event.Thing.bMissileEvenMore) val *= 1.1;
		if (event.Thing.bQuickToRetaliate) val *= 1.1;
		if (event.Thing.bNoFear) val *= 1.02;
		if (event.Thing.bSeeInvisible) val *= 1.02;

		// Refusing to infight and being unable to draw infighting aggro
		// are small difficulty increases
		if (event.Thing.bNoTarget) val *= 1.05;
		if (event.Thing.bNoInfighting) val *= 1.05;

		// JUMPDOWN increases monster aggression and agility
		if (event.Thing.bJumpDown) val *= 1.01;

		// Slightly better value if the monster was gibbed
		if (event.Thing.Health < event.Thing.GibHealth) val += 15;

		Globals.AddPartyXP(val);

		// If not even at threshold, maybe push it over
		if (val < LOOT_RNG_THRESHOLD)
			val += Random(0, LOOT_RNG_THRESHOLD - val) + 5;

		for (int i = 0; i < (val / LOOT_RNG_THRESHOLD); i++)
		{
			event.Thing.A_SpawnItemEx(BIO_GlobalData.Get().RandomMutagenType(),
				0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0));
		}
	}

	override void NetworkProcess(ConsoleEvent event)
	{
		if (NetEvent_WUKOverlay(event) || NetEvent_WeaponUpgrade(event))
			return;

		if (NetEvent_AddWeapAffix(event) || NetEvent_RemoveWeapAffix(event))
			return;
	}

	const EVENT_WUKOVERLAY = "bio_wukoverlay";
	const EVENT_WEAPUPGRADE = "bio_weapupgrade";

	private transient BIO_WeaponUpgradeOverlay WeaponUpgradeOverlay;

	private bool NetEvent_WUKOverlay(ConsoleEvent event)
	{
		if (!(event.Name ~== EVENT_WUKOVERLAY)) return false;
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
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WUKOVERLAY ..
				" was illegally invoked by a non-Biomorph PlayerPawn.");
			return true;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR .. EVENT_WUKOVERLAY ..
				" was illegally invoked for a non-Biomorph weapon.");
			return true;
		}

		Array<BIO_WeaponUpgrade> options;
		Globals.PossibleWeaponUpgrades(options, weap.GetClass());

		if (options.Size() < 1)
		{
			bioPlayer.A_Print("$BIO_WUK_FAIL_NOOPTIONS");
			return true;
		}

		WeaponUpgradeOverlay = BIO_WeaponUpgradeOverlay.Create(options);
		return true;
	}

	private bool NetEvent_WeaponUpgrade(ConsoleEvent event)
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

		if (event.Args[0] > bioPlayer.CountInv("BIO_WeaponUpgradeKit"))
		{
			bioPlayer.A_Print("$BIO_WUK_FAIL_INSUFFICIENT", 4.0);
			return true;
		}
		
		Globals.OnWeaponAcquired(GetDefaultByType(outputChoice).Grade);
		bioPlayer.GiveInventory(outputChoice, 1);
		bioPlayer.A_SelectWeapon(outputChoice);
		bioPlayer.TakeInventory(bioPlayer.Player.ReadyWeapon.GetClass(), 1);
		bioPlayer.A_StartSound("misc/weapupgrade", CHAN_ITEM);
		bioPlayer.TakeInventory("BIO_WeaponUpgradeKit", event.Args[0]);
		WeaponUpgradeOverlay.Destroy();
		return true;
	}

	private bool NetEvent_AddWeapAffix(ConsoleEvent event)
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

		if (!nameParts[1])
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
		weap.Affixes[e].Init(weap);
		weap.Affixes[e].Apply(weap);
		weap.RewriteAffixReadout();
		weap.RewriteStatReadout();
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Applied %s to your current weapon.", wafx_t.GetClassName());
		return true;
	}

	private bool NetEvent_RemoveWeapAffix(ConsoleEvent event)
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

		if (!nameParts[1])
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

		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Removed %s from your current weapon.", wafx_t.GetClassName());
		return true;
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
