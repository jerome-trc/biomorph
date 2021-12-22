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
	meta bool WorksOnUniques; property WorksOnUniques: WorksOnUniques;

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
		BIO_Mutagen.WorksOnUniques false;
    }

	// Provides preliminary checks, and prints failure messaging.
	override bool Use(bool pickup)
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

		if (!WorksOnUniques && weap.Rarity == BIO_RARITY_UNIQUE)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_UNIQUE", 4.0);
			return false;
		}

		return true;
	}

	protected void RLMDangerLevel(uint danger) const
	{
		// If the DoomRL Arsenal Monster Pack is loaded, use
		// of certain mutagens increases its danger level
		name mpt_tn = 'RLMonsterpackThingo';
		Class<Actor> mpt_t = mpt_tn;

		if (mpt_t != null)
		{
			if (BIO_debug && danger > 0)
				Console.Printf(Biomorph.LOGPFX_DEBUG ..
					"Increasing DRLA danger level by %d.", danger);

			name rldl_tn = 'RLDangerLevel';
			A_GiveInventory(rldl_tn, danger, AAPTR_PLAYER1);
		}
	}
}

class BIO_Muta_Reset : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_RESET_TAG";
		Inventory.Icon 'MUREA0';
		Inventory.PickupMessage "$BIO_MUTA_RESET_PKUP";
		BIO_Mutagen.DropWeight DROPWT_RESET;
	}

	States
	{
	Spawn:
		MURE A 6;
		---- A 6 Bright;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.Affixes.Size() < 1)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOAFFIXES", 4.0);
			return false;
		}

		weap.ResetStats();
		weap.ClearAffixes();
		weap.ApplyImplicitAffixes();
		weap.OnWeaponChange();
		Owner.A_Print("$BIO_MUTA_RESET_USE");
		return true;
	}
}

class BIO_Muta_Add : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_ADD_TAG";
		Inventory.Icon 'MUADA0';
		Inventory.PickupMessage "$BIO_MUTA_ADD_PKUP";
		BIO_Mutagen.DropWeight DROPWT_ADD;
	}

	States
	{
	Spawn:
		MUAD A 6;
		---- A 6 Bright;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.FullOnAffixes())
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
		weap.OnWeaponChange();
		Owner.A_Print("$BIO_MUTA_ADD_USE");
		RLMDangerLevel(5);
		return true;
	}
}

class BIO_Muta_Random : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_RANDOM_TAG";
		Inventory.Icon 'MURAA0';
		Inventory.PickupMessage "$BIO_MUTA_RANDOM_PKUP";
		BIO_Mutagen.DropWeight DROPWT_RANDOM;
	}

	States
	{
	Spawn:
		MURA A 6;
		---- A 6 Bright;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);
		weap.RandomizeAffixes();
		weap.OnWeaponChange();
		Owner.A_Print("$BIO_MUTA_RANDOM_USE");
		RLMDangerLevel(5);
		return true;
	}
}

// For affixes which are initialized with random values, recompute these values.
class BIO_Muta_Reroll : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_REROLL_TAG";
		Inventory.Icon 'MURRA0';
		Inventory.PickupMessage "$BIO_MUTA_REROLL_PKUP";
		BIO_Mutagen.DropWeight DROPWT_REROLL;
		BIO_Mutagen.WorksOnUniques true;
	}

	States
	{
	Spawn:
		MURR A 6;
		---- A 6 Bright;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.NoAffixes())
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOAFFIXES", 4.0);
			return false;
		}

		// TODO: If no affixes have randomizable values, forbid usage

		weap.ResetStats();
		
		for (uint i = 0; i < weap.Affixes.Size(); i++)
			weap.Affixes[i].Init(weap.AsConst());

		weap.ApplyAllAffixes();
		weap.OnWeaponChange();

		Owner.A_Print("$BIO_MUTA_REROLL_USE");
		RLMDangerLevel(1);
		return true;
	}
}

// Remove one affix at random from a weapon.
class BIO_Muta_Remove : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_REMOVE_TAG";
		Inventory.Icon 'MURMA0';
		Inventory.PickupMessage "$BIO_MUTA_REMOVE_PKUP";
		BIO_Mutagen.DropWeight DROPWT_REMOVE;
	}

	States
	{
	Spawn:
		MURM A 6;
		---- A 6 Bright;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap.Affixes.Size() < 1)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NOAFFIXES", 4.0);
			return false;
		}

		weap.ResetStats();
		weap.Affixes.Delete(Random(0, weap.Affixes.Size() - 1));
		weap.ApplyAllAffixes();
		weap.OnWeaponChange();

		Owner.A_Print("$BIO_MUTA_REROLL_USE");
		return true;
	}
}

class BIO_Muta_Corrupting : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_CORRUPT_TAG";
		Inventory.Icon 'MUCOA0';
		Inventory.PickupMessage "$BIO_MUTA_CORRUPT_PKUP";
		BIO_Mutagen.DropWeight DROPWT_CORR;
		BIO_Mutagen.WorksOnUniques true;
	}

	States
	{
	Spawn:
		MUCO A 6;
		---- A 6 Bright;
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup)) return false;
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		bool proceed = true, consumed = true;
		[proceed, consumed] = weap.OnCorrupt();

		if (!proceed) return consumed;
		
		weap.ResetStats();
		Array<BIO_CorruptionFunctor> funcs;
		
		for (uint i = 0; i < AllClasses.Size(); i++)
		{
			let t = (Class<BIO_CorruptionFunctor>)(AllClasses[i]);
			if (t == null || t.IsAbstract()) continue;
			let func = BIO_CorruptionFunctor(new(t));
			if (!func.Compatible(weap.AsConst())) continue;
			funcs.Push(func);
		}

		weap.ApplyImplicitAffixes();
		funcs[Random(0, funcs.Size() - 1)].Invoke(weap);

		// Prune explicit affixes which are no longer compatible post-corruption
		for (uint i = weap.Affixes.Size() - 1; i >= 0; i--)
		{
			if (!weap.Affixes[i].Compatible(weap.AsConst()))
				weap.Affixes.Delete(i);
		}

		weap.ApplyExplicitAffixes();
		weap.BIOFlags |= BIO_WF_CORRUPTED;
		weap.OnWeaponChange();
		RLMDangerLevel(25);
		return true;
	}
}

class BIO_CorruptionFunctor play abstract
{
	abstract void Invoke(BIO_Weapon weap) const;
	abstract bool Compatible(readOnly<BIO_Weapon> weap) const;
}

// Randomize affixes and then obfuscates them from the player.
class BIO_CorrFunc_RandomizeHide : BIO_CorruptionFunctor
{
	final override void Invoke(BIO_Weapon weap) const
	{
		weap.ClearAffixes();

		uint c = Random(2, weap.MaxAffixes);

		for (uint i = 0; i < c; i++)
			weap.AddRandomAffix();
		
		weap.BIOFlags |= BIO_WF_AFFIXESHIDDEN;
		weap.Owner.A_Print("$BIO_MUTA_CORRUPT_HIDDENRAND");
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return true;
	}
}

// Add either one or two implicit affixes.
class BIO_CorrFunc_Implicit : BIO_CorruptionFunctor
{
	Array<BIO_WeaponAffix> Eligibles;

	final override void Invoke(BIO_Weapon weap) const
	{
		if (Eligibles.Size() == 1)
		{
			uint r = Random(0, Eligibles.Size() - 1);
			uint e = weap.ImplicitAffixes.Push(Eligibles[r]);
			weap.ImplicitAffixes[e].Init(weap.AsConst());
			weap.ImplicitAffixes[e].Apply(weap);
		}
		else
		{
			uint r = Random(0, Eligibles.Size() - 1);
			uint e = weap.ImplicitAffixes.Push(Eligibles[r]);
			weap.ImplicitAffixes[e].Init(weap.AsConst());
			weap.ImplicitAffixes[e].Apply(weap);

			Eligibles.Delete(r);

			r = Random(0, Eligibles.Size() - 1);
			e = weap.ImplicitAffixes.Push(Eligibles[r]);
			weap.ImplicitAffixes[e].Init(weap.AsConst());
			weap.ImplicitAffixes[e].Apply(weap);
		}
	}

	final override bool Compatible(readOnly<BIO_Weapon> weap) const
	{
		return BIO_GlobalData.Get().EligibleImplicitWeaponAffixes(Eligibles, weap);
	}
}
