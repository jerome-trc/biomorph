// Inventory bar items for modifying the affixes on gear (primarily weapons).

// TODO: Pickup and on-use sounds for all of these

class BIO_Mutagen : Inventory abstract
{
	const DROPWT_RESET = 64;
	const DROPWT_ADD = 12;
	const DROPWT_RANDOM = 72;
	const DROPWT_REROLL = 10;
	const DROPWT_REMOVE = 24;
	const DROPWT_CORR = 1;

	meta uint DropWeight; property DropWeight: DropWeight;

	Default
    {
		-COUNTITEM
		+DONTGIB
		+INVENTORY.INVBAR

		Height 16;
        Radius 20;

		Inventory.InterHubAmount 9999;
        Inventory.MaxAmount 9999;

		BIO_Mutagen.DropWeight 0;
    }

	// Also prints failure messaging.
	protected bool CanUse(bool worksOnUniques = false) const
	{
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);
		if (weap == null)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NULLWEAP", 4.0);
			return false;
		}

		if (weap.BIOFlags & BIO_WF_CORRUPTED)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_CORRUPTED");
			return false;
		}

		if (!worksOnUniques && weap.Rarity == BIO_RARITY_UNIQUE)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_UNIQUE", 4.0);
			return false;
		}

		return true;
	}

	protected void RLMDangerLevel(uint danger) const
	{
		// If the DoomRL Arsenal Monster Pack is loaded, use
		// of certain mutagens increase its danger level
		name mpt_tn = 'RLMonsterpackThingo';
		Class<Actor> mpt_t = mpt_tn;

		if (mpt_t != null)
		{
			if (BIO_CVar.Debug() && danger > 0)
				Console.Printf(Biomorph.LOGPFX_DEBUG ..
					"Increasing DRLA danger level by %d.", danger);

			name rldl_tn = 'RLDangerLevel';
			A_GiveInventory(rldl_tn, danger, AAPTR_PLAYER1);
		}
	}
}

class BIO_MutagenReset : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_RESET_TAG";
		Inventory.Icon 'MUREA0';
		Inventory.PickupMessage "$BIO_MUTA_RESET_PICKUP";

		BIO_Mutagen.DropWeight DROPWT_RESET;
	}

	States
	{
	Spawn:
		MURE A 6;
		---- A 6 Bright;
		Loop;
	}

	override bool Use(bool pickup)
	{
		if (!CanUse()) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.Affixes.Size() < 1)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOAFFIXES", 4.0);
			return false;
		}

		weap.ResetStats();
		weap.ClearAffixes();
		weap.ApplyImplicitAffixes();
		Owner.A_Print("$BIO_MUTA_RESET_USE");
		return true;
	}
}

class BIO_MutagenAdd : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_ADD_TAG";
		Inventory.Icon 'MUADA0';
		Inventory.PickupMessage "$BIO_MUTA_ADD_PICKUP";
		BIO_Mutagen.DropWeight DROPWT_ADD;
	}

	States
	{
	Spawn:
		MUAD A 6;
		---- A 6 Bright;
		Loop;
	}

	override bool Use(bool pickup)
	{
		if (!CanUse()) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.Affixes.Size() > BIO_Weapon.MAX_AFFIXES)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_MAXAFFIXES", 4.0);
			return false;
		}

		if (!weap.AddRandomAffix())
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOCOMPATIBLEAFFIXES", 4.0);
			return false;
		}

		weap.ResetStats();
		weap.ApplyAllAffixes();
		Owner.A_Print("$BIO_MUTA_ADD_USE");
		RLMDangerLevel(5);
		return true;
	}
}

class BIO_MutagenRandom : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_RANDOM_TAG";
		Inventory.Icon 'MURAA0';
		Inventory.PickupMessage "$BIO_MUTA_RANDOM_PICKUP";
		BIO_Mutagen.DropWeight DROPWT_RANDOM;
	}

	States
	{
	Spawn:
		MURA A 6;
		---- A 6 Bright;
		Loop;
	}

	override bool Use(bool pickup)
	{
		if (!CanUse()) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);
		weap.RandomizeAffixes();
		Owner.A_Print("$BIO_MUTA_RANDOM_USE");
		RLMDangerLevel(5);
		return true;
	}
}

// For affixes which are initialized with random values, recompute these values.
class BIO_MutagenReroll : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_REROLL_TAG";
		Inventory.Icon 'MURRA0';
		Inventory.PickupMessage "$BIO_MUTA_REROLL_PICKUP";
		BIO_Mutagen.DropWeight DROPWT_REROLL;
	}

	States
	{
	Spawn:
		MURR A 6;
		---- A 6 Bright;
		Loop;
	}

	override bool Use(bool pickup)
	{
		if (!CanUse(true)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.NoAffixes())
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOAFFIXES", 4.0);
			return false;
		}

		// TODO: If no affixes have randomizable values, forbid usage

		weap.ResetStats();
		
		for (uint i = 0; i < weap.Affixes.Size(); i++)
			weap.Affixes[i].Init(weap);

		weap.ApplyAllAffixes();

		Owner.A_Print("$BIO_MUTA_REROLL_USE");
		RLMDangerLevel(1);
		return true;
	}
}

// Remove one affix at random from a weapon.
class BIO_MutagenRemove : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_REMOVE_TAG";
		Inventory.Icon 'MURMA0';
		Inventory.PickupMessage "$BIO_MUTA_REMOVE_PICKUP";
		BIO_Mutagen.DropWeight DROPWT_REMOVE;
	}

	States
	{
	Spawn:
		MURM A 6;
		---- A 6 Bright;
		Loop;
	}

	override bool Use(bool pickup)
	{
		if (!CanUse()) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.Affixes.Size() < 1)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOAFFIXES", 4.0);
			return false;
		}

		weap.ResetStats();
		weap.Affixes.Delete(Random(0, weap.Affixes.Size() - 1));
		weap.ApplyAllAffixes();

		Owner.A_Print("$BIO_MUTA_REROLL_USE");
		return true;
	}
}

class BIO_MutagenCorrupting : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_CORRUPT_TAG";
		Inventory.Icon 'MUCOA0';
		Inventory.PickupMessage "$BIO_MUTA_CORRUPT_PICKUP";
		BIO_Mutagen.DropWeight DROPWT_CORR;
	}

	States
	{
	Spawn:
		MUCO A 6;
		---- A 6 Bright;
		Loop;
	}

	override bool Use(bool pickup)
	{
		if (!CanUse(true)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		weap.ResetStats();
		weap.BIOFlags |= BIO_WF_CORRUPTED;

		switch (Random(0, 0))
		{
		default:
			// Randomize affixes and then hide them
			weap.RandomizeAffixes();
			weap.BIOFlags |= BIO_WF_AFFIXESHIDDEN;
			Owner.A_Print("$BIO_MUTA_CORRUPT_HIDDENRAND");
			break;
		}

		RLMDangerLevel(25);
		return true;
	}
}
