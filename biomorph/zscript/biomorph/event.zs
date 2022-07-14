// Note to reader: classes are defined using `extend` blocks for code folding.

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
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling NewGame event...");

		Globals = BIO_Global.Create();
	}

	final override void WorldLoaded(WorldEvent event)
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Handling WorldLoaded event...");

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

	const EVENT_FIRSTPKUP = "bio_firstpkup";

	static clearscope void BroadcastFirstPickup(name typeName)
	{
		EventHandler.SendNetworkEvent(EVENT_FIRSTPKUP .. ":" .. typeName);
	}
}

// Network event handling.
extend class BIO_EventHandler
{
	enum GlobalRegen
	{
		GLOBALREGEN_LOOTCORE,
		GLOBALREGEN_WEAPLOOT,
		GLOBALREGEN_MUTALOOT,
		GLOBALREGEN_GENELOOT,
		GLOBALREGEN_MORPH
	}

	enum WeapModOp
	{
		WEAPMODOP_START,
		WEAPMODOP_INSERT,
		WEAPMODOP_NODEMOVE,
		WEAPMODOP_INVMOVE,
		WEAPMODOP_EXTRACT,
		WEAPMODOP_SWAPNODEANDSLOT,
		WEAPMODOP_SIMULATE,
		WEAPMODOP_COMMIT,
		WEAPMODOP_REVERT,
		WEAPMODOP_MORPH,
		WEAPMODOP_STOP
	}

	const EVENT_WEAPMOD = "bio_wmod";

	final override void NetworkProcess(ConsoleEvent event)
	{
		// Normal gameplay events

		NetEvent_WeapMod(event);

		// Debugging events

		NetEvent_GlobalDataRegen(event);
	}

	private static void NetEvent_WeapMod(ConsoleEvent event)
	{
		if (!(event.Name ~== EVENT_WEAPMOD))
			return;

		if (event.Player != ConsolePlayer)
			return;

		if (event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event cannot be invoked manually.");
			return;
		}

		let pawn = BIO_Player(Players[ConsolePlayer].MO);

		if (pawn == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR .. EVENT_WEAPMOD ..
				" was illegally invoked by a non-Biomorph player pawn."
			);
			return;
		}

		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);

		if (weap == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR .. EVENT_WEAPMOD ..
				" was illegally invoked for a non-Biomorph weapon."
			);
			return;
		}

		switch (event.Args[0])
		{
		case WEAPMODOP_START:
			BIO_WeaponModSimulator.Create(weap);
			break;
		case WEAPMODOP_INSERT:
			BIO_WeaponModSimulator.Get(weap).InsertGene(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_NODEMOVE:
			BIO_WeaponModSimulator.Get(weap).NodeMove(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_INVMOVE:
			BIO_WeaponModSimulator.Get(weap).InventoryMove(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_SWAPNODEANDSLOT:
			BIO_WeaponModSimulator.Get(weap).SwapNodeAndSlot(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_EXTRACT:
			BIO_WeaponModSimulator.Get(weap).ExtractGene(
				uint(event.Args[1]), uint(event.Args[2])
			);
			break;
		case WEAPMODOP_SIMULATE:
			BIO_WeaponModSimulator.Get(weap).Simulate();
			break;
		case WEAPMODOP_COMMIT:
			WeapMod_Commit(pawn, event.Args[1]);
			break;
		case WEAPMODOP_REVERT:
			BIO_WeaponModSimulator.Get(weap).Revert();
			break;
		case WEAPMODOP_MORPH:
			WeapMod_Morph(pawn, uint(event.Args[1]));
			break;
		case WEAPMODOP_STOP:
			BIO_WeaponModSimulator.Get(weap).Destroy();
			break;
		default:
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal weapon mod. operation requested: %d",
				event.Args[0]
			);
			break;
		}
	}

	private static void WeapMod_Commit(BIO_Player pawn, int geneTID)
	{
		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);
		let sim = BIO_WeaponModSimulator.Get(weap);
		let cost = sim.CommitCost();

		if (pawn.CountInv('BIO_Muta_General') < cost)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Player %s has insufficient mutagen to commit modifications.",
				pawn.Player.GetUserName()
			);
			return;
		}

		Array<class<BIO_Gene> > toGive;
		Array<Inventory> toDestroy;

		for (uint i = 0; i < sim.Genes.Size(); i++)
		{
			if (sim.Genes[i] == null)
				continue;

			toGive.Push(sim.Genes[i].GetType());
		}

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
		{
			if (i is 'BIO_Gene')
				toDestroy.Push(i);
		}

		sim.Commit();

		for (uint i = 0; i < toDestroy.Size(); i++)	
		{
			toDestroy[i].Amount = 0;
			toDestroy[i].DepleteOrDestroy();
		}

		for (uint i = 0; i < toGive.Size(); i++)
			pawn.GiveInventory(toGive[i], 1);

		sim.PostCommit();
		pawn.TakeInventory('BIO_Muta_General', cost);
		pawn.A_StartSound("bio/mutation/general");
	}

	private static void WeapMod_Morph(BIO_Player pawn, uint node)
	{
		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);
		let sim = BIO_WeaponModSimulator.Get(weap);
		let cost = sim.MorphCost(node);

		if (pawn.CountInv('BIO_Muta_General') < cost)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Player %s has insufficient mutagen to morph weapon %s.",
				pawn.Player.GetUserName(), weap.GetClassName()
			);
			return;
		}

		let morph = sim.Nodes[node].MorphRecipe;
		Array<class<BIO_Gene> > toGive;
		Array<Inventory> toDestroy;

		for (uint i = 0; i < sim.Genes.Size(); i++)
		{
			if (sim.Genes[i] == null)
				continue;

			toGive.Push(sim.Genes[i].GetType());
		}

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
		{
			if (i is 'BIO_Gene')
				toDestroy.Push(i);
		}

		for (uint i = 0; i < toDestroy.Size(); i++)	
		{
			toDestroy[i].Amount = 0;
			toDestroy[i].DepleteOrDestroy();
		}

		for (uint i = 0; i < toGive.Size(); i++)
			pawn.GiveInventory(toGive[i], 1);

		uint qual = weap.InheritedGraphQuality() + morph.QualityAdded();

		weap.Amount = 0;
		weap.DepleteOrDestroy();

		pawn.GiveInventory(morph.Output(), 1);
		let output = BIO_Weapon(pawn.FindInventory(morph.Output()));
		output.Mutate();
		output.ModGraph.TryGenerateNodes(qual);

		pawn.TakeInventory('BIO_Muta_General', cost);
		pawn.A_StartSound("bio/mutation/general");
		pawn.A_SelectWeapon(morph.Output());

		BIO_Utils.DRLMDangerLevel(1);
	}

	private void NetEvent_GlobalDataRegen(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_globalregen"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Net event `bio_globalregen` can only be manually invoked."
			);
			return;
		}

		if (event.Player != Net_Arbitrator)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Net event `bio_globalregen` "
				"can only be invoked by the network arbitrator."
			);
			return;
		}

		switch (event.Args[0])
		{
		case GLOBALREGEN_LOOTCORE:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating loot core subsystem..."
			);
			Globals.RegenLootCore();
			return;
		case GLOBALREGEN_WEAPLOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating weapon loot tables..."
			);
			Globals.RegenWeaponLoot();
			return;
		case GLOBALREGEN_MUTALOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating mutagen loot table..."
			);
			Globals.RegenMutagenLoot();
			return;
		case GLOBALREGEN_GENELOOT:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating gene loot table..."
			);
			Globals.RegenGeneLoot();
			return;
		case GLOBALREGEN_MORPH:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Regenerating weapon morph recipe cache..."
			);
			Globals.RegenWeaponMorphCache();
			return;
		default:
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Invalid global regen requested: %d", event.Args[0]
			);
		}
	}
}

// Console event handling.
extend class BIO_EventHandler
{
	final override void ConsoleProcess(ConsoleEvent event)
	{
		if (event.Name.Length() < 5 || !(event.Name.Left(4) ~== "bio_"))
			return;

		// Normal gameplay events

		ConEvent_WeapModMenu(event);

		// Debugging events

		ConEvent_Help(event);
		ConEvent_WeapDiag(event);
		ConEvent_LootDiag(event);
		ConEvent_MonsVal(event);
		ConEvent_LootSim(event);
		ConEvent_WeapSerialize(event);
	}

	private static ui void ConEvent_Help(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_help"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_help`."
			);
			return;
		}

		Console.Printf(
			Biomorph.LOGPFX_INFO .. "\n"
			"\c[Gold]Console events:\c-\n"
			"\tbio_help_\n"
			"\tbio_lootdiag_\n"
			"\tbio_weapdiag_\n"
			"\tbio_monsval_\n"
			"\tbio_lootsim_\n"
			"\tbio_weapserialize_\n"
			"\c[Gold]Network events:\c-\n"
			"\tbio_weaplootregen_\n"
			"\tbio_mutalootregen_\n"
			"\tbio_genelootregen_\n"
			"\tbio_morphregen_"
		);
	}

	private ui void ConEvent_LootDiag(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_lootdiag"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_lootdiag`."
			);
			return;
		}

		Globals.PrintLootDiag();
	}

	private static ui void ConEvent_WeapDiag(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_weapdiag"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_weapdiag`."
			);
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);

		if (weap == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon."
			);
			return;
		}

		string output = String.Format(
			"%sWeapon diagnostics for: %s\n",
			Biomorph.LOGPFX_INFO, weap.GetTag()
		);

		output.AppendFormat("\c[Yellow]Class:\c- `%s`\n", weap.GetClassName());

		output.AppendFormat(
			"\c[Yellow]Switch speeds\c-: %d lower, %d raise\n",
			weap.LowerSpeed, weap.RaiseSpeed
		);

		// Pipelines

		output = output .. "\n";

		if (weap.Pipelines.Size() > 0)
			output.AppendFormat("\c[Yellow]Pipelines\c-:\n");

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];

			if (ppl.Tag.Length() > 0)
				output.AppendFormat("\t-> \c[Green]Pipeline: %s\c-\n", ppl.Tag);
			else
				output.AppendFormat("\t-> \c[Green]Pipeline: %d\c-\n", i);

			output.AppendFormat(
				"\t\tUses secondary ammo: %s\n",
				ppl.SecondaryAmmo ? "yes" : "no"
			);
			output.AppendFormat(
				"\t\tFiring functor: %s\n",
				ppl.FireFunctor.GetClassName()
			);
			output.AppendFormat(
				"\t\tPayload: %s\n",
				ppl.Payload.GetClassName()
			);
			output.AppendFormat(
				"\t\tDamage functor: %s\n",
				ppl.Damage.GetClassName()
			);
		}

		// Timings

		output = output .. "\n";

		if (weap.FireTimeGroups.Size() > 0)
			output.AppendFormat("\c[Yellow]Fire time groups:\c-\n");

		for (uint i = 0; i < weap.FireTimeGroups.Size(); i++)
		{
			let ftg = weap.FireTimeGroups[i];
			string tag = ftg.Tag.Length() > 0 ? ftg.Tag : "num. " .. i;
			output.AppendFormat("\t-> \c[Green]Group %s\c-\n", tag);

			for (uint j = 0; j < ftg.Times.Size(); j++)
				output.AppendFormat("\t\t%d, min. %d\n", ftg.Times[j], ftg.Minimums[j]);
		}

		if (weap.ReloadTimeGroups.Size() > 0)
			output.AppendFormat("\c[Yellow]Reload time groups:\c-\n");

		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
		{
			let rtg = weap.ReloadTimeGroups[i];
			string tag = rtg.Tag.Length() > 0 ? rtg.Tag : "num. " .. i;
			output.AppendFormat("\t-> \c[Green]Group %s\c-\n", tag);

			for (uint j = 0; j < rtg.Times.Size(); j++)
				output.AppendFormat("\t\t%d, min. %d\n", rtg.Times[j], rtg.Minimums[j]);
		}

		Console.Printf(output);
	}

	private static ui void ConEvent_WeapModMenu(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_weapmodmenu"))
			return;

		if (GameState != GS_LEVEL)
			return;

		if (Players[ConsolePlayer].Health <= 0)
			return;

		if (!(Players[ConsolePlayer].MO is 'BIO_Player'))
			return;

		if (Menu.GetCurrentMenu() is 'BIO_WeaponModMenu')
			return;

		if (!(Players[ConsolePlayer].ReadyWeapon is 'BIO_Weapon'))
			return;

		Menu.SetMenu('BIO_WeaponModMenu');
	}

	private ui void ConEvent_MonsVal(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_monsval"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_monsval`."
			);
			return;
		}

		let val = MapTotalMonsterValue();
		let loot = val / BIO_Global.LOOT_VALUE_THRESHOLD;

		Console.Printf(
			Biomorph.LOGPFX_INFO .. "\n"
			"\tTotal monster value in this level: %d\n"
			"\tLoot value multiplier: %.2f\n"
			"\tNumber of times loot value threshold was crossed: %d",
			val, Globals.GetLootValueMultiplier(), loot
		);
	}

	private ui void ConEvent_LootSim(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_lootsim"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_lootsim`."
			);
			return;
		}

		string output = Biomorph.LOGPFX_INFO .. "running loot simulation...\n";

		Array<class<BIO_Mutagen> > mTypes;
		Array<class<BIO_Gene> > gTypes;
		Array<uint> mCounters, gCounters;

		let val = MapTotalMonsterValue();
		let loot = val / BIO_Global.LOOT_VALUE_THRESHOLD;

		for (uint i = 0; i < loot; i++)
		{
			if (Random[BIO_Loot](1, GENE_CHANCE_DENOM) == 1)
			{
				let gene_t = Globals.RandomGeneType();
				let idx = gTypes.Find(gene_t);

				if (idx == gTypes.Size())
				{
					idx = gTypes.Push(gene_t);
					gCounters.Push(1);
				}
				else
				{
					gCounters[idx]++;
				}
			}
			else
			{
				let muta_t = Globals.RandomMutagenType();
				let idx = mTypes.Find(muta_t);

				if (idx == mTypes.Size())
				{
					idx = mTypes.Push(muta_t);
					mCounters.Push(1);
				}
				else
				{
					mCounters[idx]++;
				}
			}
		}

		output = output .. "\c[Yellow]Mutagen loot results:\c-\n";

		for (uint i = 0; i < mTypes.Size(); i++)
		{
			let defs = GetDefaultByType(mTypes[i]);

			output.AppendFormat(
				"\t%s (wt. \c[Green]%d\c-): %d\n",
				mTypes[i].GetClassName(), defs.LootWeight, mCounters[i]
			);
		}

		output = output .. "\c[Yellow]Gene loot results:\c-\n";

		for (uint i = 0; i < gTypes.Size(); i++)
		{
			let defs = GetDefaultByType(gTypes[i]);

			output.AppendFormat(
				"\t%s (wt. \c[Green]%d\c-): %d\n",
				gTypes[i].GetClassName(), defs.LootWeight, gCounters[i]
			);
		}

		output.DeleteLastCharacter();
		Console.Printf(output);
	}

	private static ui void ConEvent_WeapSerialize(ConsoleEvent event)
	{
		if (!(event.Name ~== "bio_weapserialize"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_weapserialize`."
			);
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);

		if (weap == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon."
			);
			return;
		}

		Console.Printf(weap.Serialize().ToString());
	}
}

// Death handling.
extend class BIO_EventHandler
{
	const GENE_CHANCE_DENOM = 10;

	// Assigned in `OnRegister()`
	// (will be null if LegenDoom or its Lite version isn't loaded).
	private class<Inventory> LDToken;

	clearscope uint MapTotalMonsterValue() const
	{
		let iter = ThinkerIterator.Create('Actor');
		uint ret = 0;

		while (true)
		{
			let mons = Actor(iter.Next());

			if (mons == null)
				break;

			if (!mons.bIsMonster)
				continue;

			ret += Globals.GetMonsterValue(mons);
		}

		return ret;
	}

	final override void WorldThingDied(WorldEvent event)
	{
		if (event.Thing == null || !event.Thing.bIsMonster)
			return;

		let pawn = BIO_Player(event.Thing.Target);

		if (pawn != null)
			pawn.OnKill(event.Thing, event.Inflictor);

		if (event.Thing.FindInventory(LDToken))
		{
			switch (BIO_ldl)
			{
			case BIO_CV_LDL_WEAP:
				SpawnLegendaryLootWeapon(event.Thing);
				break;
			case BIO_CV_LDL_GENE:
				SpawnLootGene(event.Thing);

				if (event.Thing.bBoss)
					SpawnLootGene(event.Thing);
				break;
			default:
				break;
			}
		}

		for (uint i = 0; i < Globals.MonsterLoot.Size(); i++)
		{
			if (Globals.MonsterLoot[i].Exact)
			{
				if (event.Thing.GetClass() != Globals.MonsterLoot[i].MonsterType)
					continue;
			}
			else
			{
				if (!(event.Thing is Globals.MonsterLoot[i].MonsterType))
					continue;
			}

			bool success = false;
			Actor spawned = null;

			let spawner_t = Globals.MonsterLoot[i].SpawnerType;

			[success, spawned] = event.Thing.A_SpawnItemEx(
				spawner_t,
				0.0, 0.0, 32.0,
				FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
				FRandom(0.0, 360.0)
			);

			if (success && spawned != null)
			{
				BIO_LootSpawner(spawned).Target = event.Thing;
			}
			else
			{
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"Failed to create loot spawner of type `%s` "
					"upon death of monster of type `%s`.",
					spawner_t.GetClassName(), event.Thing.GetClassName()
				);
			}
		}

		Globals.LootValueBuffer += Globals.GetMonsterValue(event.Thing);

		while (Globals.DrainLootValueBuffer())
		{
			if (Random[BIO_Loot](1, GENE_CHANCE_DENOM) == 1)
			{
				SpawnLootGene(event.Thing);
			}
			else
			{
				let muta_t = Globals.RandomMutagenType();
				BIO_Mutagen.PlayRaritySound(GetDefaultByType(muta_t).LootWeight);

				event.Thing.A_SpawnItemEx(
					muta_t,
					0.0, 0.0, 32.0,
					FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
					FRandom(0.0, 360.0)
				);
			}
		}
	}

	private void SpawnLootGene(Actor mons)
	{
		let gene_t = Globals.RandomGeneType();
		BIO_Gene.PlayRaritySound(GetDefaultByType(gene_t).LootWeight);

		mons.A_SpawnItemEx(
			gene_t,
			0.0, 0.0, 32.0,
			FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
			FRandom(0.0, 360.0)
		);
	}

	private void SpawnLegendaryLootWeapon(Actor mons)
	{
		bool success = false;
		Actor spawned = null;

		[success, spawned] = mons.A_SpawnItemEx(
			Globals.AnyLootWeaponType(),
			0.0, 0.0, 32.0,
			FRandom(1.0, 6.0), 0.0, FRandom(1.0, 6.0),
			FRandom(0.0, 360.0)
		);

		if (!success || spawned == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Failed to spawn a weapon loot drop from a dead Legendary."
			);
			return;
		}

		let weap = BIO_Weapon(spawned);

		uint gcf = 1, gcc = 1;

		if (mons.bBoss)
			gcf++;

		if (BIO_Utils.DoomRLMonsterPack())
			gcc++;

		weap.SpecialLootMutate(
			extraNodes: mons.bBoss ? 1 : 0,
			geneCount: uint(Random[BIO_Loot](gcf, gcc)),
			noDuplicateGenes: true,
			raritySound: true
		);
	}
}

// Spawn event handler.
extend class BIO_EventHandler
{
	final override void WorldThingSpawned(WorldEvent event)
	{
		if (event.Thing is 'Inventory')
		{
			{
				let item = Inventory(event.Thing);

				if (item.Owner != null || item.Master != null)
					return;
			}

			OnAmmoSpawn(event);
		}
		else if (event.Thing is 'BIO_WeaponReplacer')
		{
			OnWeaponSpawn(event);
		}
	}

	private static void FinalizeSpawn(class<Actor> toSpawn, Actor eventThing)
	{
		if (toSpawn == null)
		{
			Actor.Spawn('Unknown', eventThing.Pos, NO_REPLACE);
			// For diagnostic purposes, don't destroy the original thing
		}
		else
		{
			Actor.Spawn(toSpawn, eventThing.Pos);
			eventThing.Destroy();
		}
	}

	private void OnWeaponSpawn(WorldEvent event) const
	{
		let replacer = BIO_WeaponReplacer(event.Thing);

		if (replacer == null)
			return;

		class<BIO_Weapon> lwt = Globals.LootWeaponType(replacer.SpawnCategory);

		if (GetDefaultByType(lwt).Unique)
			S_StartSound("bio/loot/unique", CHAN_AUTO);

		FinalizeSpawn(lwt, event.Thing);
	}

	private bool OnAmmoSpawn(WorldEvent event) const
	{
		if (event.Thing.GetClass() == 'Clip')
		{
			if (Random[BIO_Loot](1, 50) == 1)
			{
				Actor.Spawn(
					Globals.LootWeaponType(BIO_WSCAT_PISTOL),
					event.Thing.Pos
				);
			}

			FinalizeSpawn('BIO_Clip', event.Thing);
		}
		else if (event.Thing.GetClass() == 'Shell')
			FinalizeSpawn('BIO_Shell', event.Thing);
		else if (event.Thing.GetClass() == 'RocketAmmo')
			FinalizeSpawn('BIO_RocketAmmo', event.Thing);
		else if (event.Thing.GetClass() == 'Cell')
			FinalizeSpawn('BIO_Cell', event.Thing);
		else if (event.Thing.GetClass() == 'ClipBox')
			FinalizeSpawn('BIO_ClipBox', event.Thing);
		else if (event.Thing.GetClass() == 'ShellBox')
			FinalizeSpawn('BIO_ShellBox', event.Thing);
		else if (event.Thing.GetClass() == 'RocketBox')
			FinalizeSpawn('BIO_RocketBox', event.Thing);
		else if (event.Thing.GetClass() == 'CellPack')
			FinalizeSpawn('BIO_CellPack', event.Thing);
		else
			return false;

		return true;
	}
}

// Static helpers for sending network events.
extend class BIO_EventHandler
{
	static clearscope void WeapModSim_Start()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_START
		);
	}

	static clearscope void WeapModSim_InsertGeneFromInventory(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_INSERT,
			node, slot
		);
	}

	static clearscope void WeapModSim_MoveGeneBetweenNodes(
		uint fromNode, uint toNode)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_NODEMOVE,
			fromNode, toNode
		);
	}

	static clearscope void WeapModSim_MoveGeneBetweenInventorySlots(
		uint fromSlot, uint toSlot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_INVMOVE,
			fromSlot, toSlot
		);
	}

	static clearscope void WeapModSim_SwapNodeAndSlot(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_SWAPNODEANDSLOT,
			node, slot
		);
	}

	static clearscope void WeapModSim_ExtractGeneFromNode(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_EXTRACT,
			node, slot
		);
	}

	static clearscope void WeapModSim_Run()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_SIMULATE	
		);
	}

	static clearscope void WeapModSim_Commit()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_COMMIT
		);
	}

	static clearscope void WeapModSim_Revert()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_REVERT
		);
	}

	static clearscope void WeapModSim_Morph(uint node)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_MORPH,
			node
		);
	}

	static clearscope void WeapModSim_Stop()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_STOP
		);
	}
}

struct BIO_RenderContext
{
	RenderEvent Event;
	BIOLE_ProjScreen Projector;
	BIOLE_Viewport Viewport;
}

// Overlay rendering and related members.
extend class BIO_EventHandler
{
	private transient CVar RenderMode;
	private BIOLE_ProjScreen ScreenProjector;

	private void RenderPrepare()
	{
		RenderMode = CVar.GetCVar("vid_rendermode", Players[ConsolePlayer]);

		switch (RenderMode.GetInt())
		{
		default:
			ScreenProjector = new('BIOLE_GLScreen');
			break;
		case 0:
		case 1:
			ScreenProjector = new('BIOLE_SWScreen');
			break;
		}
	}

	final override void RenderOverlay(RenderEvent event)
	{
		ScreenProjector.CacheResolution();
		ScreenProjector.CacheFOV(Players[ConsolePlayer].FOV);
		ScreenProjector.OrientForRenderOverlay(event);
		ScreenProjector.BeginProjection();

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);

		if (weap == null)
			return;

		BIO_RenderContext context;
		context.Event = event;
		context.Projector = ScreenProjector;
		context.Viewport.FromHUD();
		weap.RenderOverlay(context);
	}
}
