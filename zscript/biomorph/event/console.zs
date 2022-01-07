extend class BIO_EventHandler
{
	final override void ConsoleProcess(ConsoleEvent event)
	{
		if (event.Name.Length() < 5 || !(event.Name.Left(4) ~== "bio_"))
			return;

		// Normal gameplay events
		
		ConEvent_PerkMenu(event);

		// Debugging events
		
		ConEvent_Help(event);
		ConEvent_PlayerDiag(event);
		ConEvent_WeapDiag(event);
		ConEvent_EquipDiag(event);
		ConEvent_XPInfo(event);
		ConEvent_LootDiag(event);
		ConEvent_WeapAfxCompat(event);
	}

	private ui void ConEvent_PerkMenu(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_perkmenu")) return;

		if (GameState != GS_LEVEL) return;
		if (Players[ConsolePlayer].Health <= 0) return;
		if (!(Players[ConsolePlayer].MO is 'BIO_Player')) return;
		if (Menu.GetCurrentMenu() is 'BIO_PerkMenu') return;

		Menu.SetMenu('BIO_PerkMenu');
	}

	private ui void ConEvent_Help(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_help"))
			return;
		
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_help`.");
			return;
		}

		Console.Printf(
			"\c[Gold]Console events:\c-\n"
			"bio_help_\n" ..
			"bio_playerdiag_\n" ..
			"bio_weapdiag_\n" ..
			"bio_equipdiag_\n" ..
			"bio_xpinfo_\n" ..
			"event bio_wafxcompat:Classname\n" ..
			"\c[Gold]Network events:\c-\n" ..
			"netevent bio_addwafx:Classname\n" ..
			"netevent bio_rmwafx:Classname\n" ..
			"bio_recalcweap_ (alias: bio_weaprecalc_)" ..
			"bio_lvlup_ (also: bio_lvlup_5 and bio_lvlup_10)");
	}

	private ui void ConEvent_PlayerDiag(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_playerdiag")) return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_playerdiag`.");
			return;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on Biomorph-class players.");
			return;
		}

		Console.Printf(Biomorph.LOGPFX_INFO .. "Mutable stats:\n"
			"\tFriction: %.2f\n"
			"\tGravity: %.2f\n"
			"\tHeight: %.2f\n"
			"\tMass: %.2f\n"
			"\tMax step height: %.2f\n"
			"\tMax slope steepness: %.2f\n"
			"\tMaximum health: %d\n"
			"\tBonus health: %d\n"
			"\tStamina: %d\n"
			"\tForward move: %.2f/%.2f\n"
			"\tSideways move: %.2f/%.2f\n"
			"\tJump Z: %.2f\n"
			"\tUse range: %.2f\n"
			"\tRadius damage factor: %.2f\n"
			"\tSelf-damage factor: %.2f\n"
			"\tAir capacity: %.2f\n",
			bioPlayer.Friction, bioPlayer.Gravity, bioPlayer.Height, bioPlayer.Mass,
			bioPlayer.MaxStepHeight, bioPlayer.MaxSlopeSteepness, bioPlayer.MaxHealth,
			bioPlayer.BonusHealth, bioPlayer.Stamina, bioPlayer.ForwardMove1,
			bioPlayer.ForwardMove2, bioPlayer.SideMove1, bioPlayer.SideMove2,
			bioPlayer.JumpZ, bioPlayer.UseRange, bioPlayer.RadiusDamageFactor,
			bioPlayer.SelfDamageFactor, bioPlayer.AirCapacity);

		Console.Printf(Biomorph.LOGPFX_INFO .. "All functors:");

		for (uint i = 0; i < bioPlayer.Functors.Size(); i++)
		{
			for (uint j = 0; j < bioPlayer.Functors[i].Size(); j++)
				Console.Printf("\t%s x %d",
					bioPlayer.Functors[i][j].GetClassName(),
					bioPlayer.Functors[i][j].Count);
		}
	}

	private ui void ConEvent_WeapDiag(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_weapdiag")) return;
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_weapdiag`.");
			return;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on Biomorph-class players.");
			return;
		}

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);
		if (weap == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on a Biomorph weapon.");
			return;
		}

		string output = Biomorph.LOGPFX_INFO;
		output.AppendFormat("%s (%s)\n", weap.GetClassName(), weap.GetTag());
		output.AppendFormat("\c[Yellow]Grade\c-: %s\n\c-", BIO_Utils.GradeToString(weap.Grade));
		output.AppendFormat("\c[Yellow]Rarity\c-: %s\n\c-", BIO_Utils.RarityToString(weap.Rarity));
		output.AppendFormat("\c[Yellow]Pipelines\c-:\n");

		string ammo1_tn = "null", ammo2_tn = "null";

		if (weap.AmmoType1 != null)
			ammo1_tn = weap.AmmoType1.GetClassName();
		if (weap.AmmoType2 != null)
			ammo2_tn = weap.AmmoType2.GetClassName();

		output.AppendFormat("\c[Yellow]Ammo 1\c-: %s (give %d, use %d)\n",
			ammo1_tn, weap.AmmoGive1, weap.AmmoUse1);
		output.AppendFormat("\c[Yellow]Ammo 2\c-: %s (give %d, use %d)\n",
			ammo2_tn, weap.AmmoGive2, weap.AmmoUse2);

		output.AppendFormat("\c[Yellow]Switch speeds\c-: %d lower, %d raise\n",
			weap.LowerSpeed, weap.RaiseSpeed);

		output.AppendFormat("\c[Yellow]Kickback\c-: %d\n", weap.Kickback);

		if (weap.Userdata != null)
		{
			output.AppendFormat("\c[Yellow]Userdata contents\c-:\n");

			let iter = DictionaryIterator.Create(weap.Userdata);
			while (iter.Next())
			{
				output.AppendFormat("{ \"%s\": \"%s\" }\n",
					iter.Key(), iter.Value());
			}
		}

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			let ppl = weap.Pipelines[i];
			output.AppendFormat("\tRestriction mask: %d\n", ppl.GetRestrictions());
			output.AppendFormat("\tUses secondary ammo: %s\n",
				ppl.UsesSecondaryAmmo() ? "yes" : "no");
			output.AppendFormat("\tFiring functor: %s\n",
				ppl.GetFireFunctorConst().GetClassName());
			output.AppendFormat("\tFired type: %s\n",
				ppl.GetFireType().GetClassName());
			output.AppendFormat("\tDamage functor: %s\n",
				ppl.GetDamageFunctorConst().GetClassName());

			output = output .. "\n";
		}

		for (uint i = 0; i < weap.FireTimeGroups.Size(); i++)
		{
			let ftg = weap.FireTimeGroups[i];
			string tag = ftg.Tag.Length() > 0 ? ftg.Tag : "num. " .. i;
			output.AppendFormat("Fire time group: %s\n", tag);

			for (uint j = 0; j < ftg.Times.Size(); j++)
				output.AppendFormat("\t%d, min. %d\n", ftg.Times[j], ftg.Minimums[j]);
		}

		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
		{
			let rtg = weap.ReloadTimeGroups[i];
			string tag = rtg.Tag.Length() > 0 ? rtg.Tag : "num. " .. i;
			output.AppendFormat("Reload time group: %s\n", tag);

			for (uint j = 0; j < rtg.Times.Size(); j++)
				output.AppendFormat("\t%d, min. %d\n", rtg.Times[j], rtg.Minimums[j]);
		}

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

	private ui void ConEvent_EquipDiag(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_equipdiag")) return;
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_equipdiag`.");
			return;
		}

		let bioPlayer = BIO_Player(Players[ConsolePlayer].MO);
		if (bioPlayer == null)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"This event can only be invoked on Biomorph-class players.");
			return;
		}

		string armorStr;

		if (bioPlayer.EquippedArmor != null)
			armorStr = String.Format("%s, %d remaining",
				bioPlayer.EquippedArmor.GetClassName(),
				bioPlayer.EquippedArmor.ArmorData.SaveAmount);
		else
			armorStr = "null";


		Console.Printf("Equipped armor: %s", armorStr);
	}

	private ui void ConEvent_WeapAfxCompat(ConsoleEvent event) const
	{
		Array<string> nameParts;
		event.Name.Split(nameParts, ":");

		if (!nameParts[0] || !(nameParts[0] ~== "bio_wafxcompat"))
			return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"Illegal attempt by a script to invoke `bio_wafxcompat`.");
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
				"Please provide a weapon affix class name.");
			return;
		}
	
		Class<BIO_WeaponAffix> afx_t = nameParts[1];
		if (!afx_t)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"%s is not a valid weapon affix class name.", nameParts[1]);
			return;
		}

		bool compat = BIO_WeaponAffix(new(afx_t)).Compatible(weap.AsConst());
		string output;
		
		if (compat)
			output.AppendFormat("\ck%s\c- is \cdcompatible\c- with this weapon.",
				afx_t.GetClassName());
		else
			output.AppendFormat("\ck%s\c- is \cgincompatible\c- with this weapon.",
				afx_t.GetClassName());
		
		Console.Printf(Biomorph.LOGPFX_INFO .. output);
	}

	private ui void ConEvent_XPInfo(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_xp")) return;
		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_xp`.");
			return;
		}

		Console.Printf(Biomorph.LOGPFX_INFO .. "Party XP and levelling info:\n");
		Console.Printf("Party level: %d", Globals.GetPartyLevel());
		Console.Printf("Current party XP: %d", Globals.GetPartyXP());
		Console.Printf("XP to next level: %d", Globals.XPToNextLevel());
	}

	private ui void ConEvent_LootDiag(ConsoleEvent event) const
	{
		if (!(event.Name ~== "bio_lootdiag")) return;

		if (!event.IsManual)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegal attempt by a script to invoke `bio_lootdiag`.");
			return;
		}

		Console.Printf(Biomorph.LOGPFX_INFO .. "All loot tables:");
		Globals.PrintLootDiag();
	}
}
