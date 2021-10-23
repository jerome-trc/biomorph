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

		if (ReplaceArmor(event))
			return;
	}

	override void ConsoleProcess(ConsoleEvent event)
	{
		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null) return;

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);

		if (event.Name ~== "bio_weapdiag" && weap != null)
		{
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
		}
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

	private bool ReplaceArmor(WorldEvent event)
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
}
