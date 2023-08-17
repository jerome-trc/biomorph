/// A singleton of this type holds loot tables and alterant prototypes, since
/// these do not need to be written to save games but must always be present
/// (thus disallowing `transient`).
class biom_Static : StaticEventHandler
{
	private array<biom_WeaponAlterant> weaponAlterants;
	private array<biom_PawnAlterant> pawnAlterants;

	/// Used by `biom_EventHandler::CheckReplacement`.
	private Dictionary replacements;
	/// Used by `biom_EventHandler::WorldThingDied`.
	private Dictionary legendaryLoot;

	static biom_Static Get()
	{
		return biom_Static(StaticEventHandler.Find('biom_Static'));
	}

	final override void OnRegister()
	{
		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Registering static event handler..."
			);
		}

		self.RegisterAlterantPrototypes();

		self.replacements = Dictionary.Create();
		self.legendaryLoot = Dictionary.Create();

		if (biom_Utils.LegenDoom())
		{
			if (developer >= 1)
			{
				Console.PrintF(
					Biomorph.LOGPFX_DEBUG ..
					"Populating LegenDoom Lite loot table..."
				);
			}

			self.PopulateLegenDoomLoot();
		}

		name valiantCG_tn = 'ValiantChaingun';

		if ((class<Weapon>)(valiantCG_tn) != null)
		{
			if (developer >= 1)
			{
				Console.PrintF(
					Biomorph.LOGPFX_DEBUG ..
					"Preparing Valiant replacement classes..."
				);
			}

			self.replacements.Insert("ValiantPistol", "biom_wpk_Slot2");
			self.replacements.Insert("ValiantShotgun", "biom_wpks_Shotgun");
			self.replacements.Insert("ValiantChaingun", "biom_wpks_Chaingun");
			self.replacements.Insert("ValiantSSG", "biom_wpks_SuperShotgun");
		}
	}

	// Alterants ///////////////////////////////////////////////////////////////

	biom_PawnAlterant GetPawnAlterant(class<biom_PawnAlterant> type) const
	{
		for (int i = 0; i < self.pawnAlterants.Size(); ++i)
			if (self.pawnAlterants[i].GetClass() == type)
				return self.pawnAlterants[i];

		return null;
	}

	biom_WeaponAlterant GetWeaponAlterant(class<biom_WeaponAlterant> type) const
	{
		for (int i = 0; i < self.weaponAlterants.Size(); ++i)
			if (self.weaponAlterants[i].GetClass() == type)
				return self.weaponAlterants[i];

		return null;
	}

	/// This is per kind (downgrade, sidegrade, upgrade), not in total.
	const ALTERANT_BATCH_SIZE = 5;

	/// `specific` is only for use with alterant items, so `null` is a valid argument.
	void GenerateAlterantBatch(
		in out biom_PendingAlterants pending,
		biom_Player pawn,
		biom_PendingAlterant specific
	)
	{
		let pdat = pawn.GetData();

		array<biom_PendingAlterant> upgrades, sidegrades, downgrades;

		let
			wrtUpgrades = new('biom_WeightedRandom'),
			wrtSidegrades = new('biom_WeightedRandom'),
			wrtDowngrades = new('biom_WeightedRandom');

		if (specific != null)
		{
			biom_Static.AddPendingAlterant(
				upgrades,
				sidegrades,
				downgrades,
				wrtUpgrades,
				wrtSidegrades,
				wrtDowngrades,
				specific,
				pawn.AsConst()
			);
		}

		for (int i = 0; i < self.pawnAlterants.Size(); ++i)
		{
			let alter = self.pawnAlterants[i];

			if (!alter.Natural() || !alter.Compatible(pawn.AsConst()))
				continue;

			let bal = alter.Balance(pawn.AsConst());

			let p = new('biom_PendingAlterant');
			p.inner = alter;

			biom_Static.AddPendingAlterant(
				upgrades,
				sidegrades,
				downgrades,
				wrtUpgrades,
				wrtSidegrades,
				wrtDowngrades,
				p,
				pawn.AsConst()
			);
		}

		for (int i = 0; i < self.weaponAlterants.Size(); ++i)
		{
			let alter = self.weaponAlterants[i];

			for (int ii = 0; ii < pdat.weapons.Size(); ++ii)
			{
				let wtdefs = GetDefaultByType(pdat.weapons[ii]);
				let wdat = pdat.GetWeaponData(wtdefs.DATA_CLASS);

				if (!alter.Natural() || !alter.Compatible(wdat))
					continue;

				let bal = alter.Balance(wdat);

				let p = new('biom_PendingAlterant');
				p.inner = alter;
				p.weaponData = wdat;

				biom_Static.AddPendingAlterant(
					upgrades,
					sidegrades,
					downgrades,
					wrtUpgrades,
					wrtSidegrades,
					wrtDowngrades,
					p,
					pawn.AsConst()
				);
			}
		}

		if (upgrades.Size() <= ALTERANT_BATCH_SIZE)
			pending.upgrades.Move(upgrades);
		else
			biom_Static.SelectRandomAlterants(pending.upgrades, upgrades, wrtUpgrades);

		if (sidegrades.Size() <= ALTERANT_BATCH_SIZE)
			pending.sidegrades.Move(sidegrades);
		else
			biom_Static.SelectRandomAlterants(pending.sidegrades, sidegrades, wrtSidegrades);

		if (downgrades.Size() <= ALTERANT_BATCH_SIZE)
			pending.downgrades.Move(downgrades);
		else
			biom_Static.SelectRandomAlterants(pending.downgrades, downgrades, wrtDowngrades);
	}

	private static void AddPendingAlterant(
		in out array<biom_PendingAlterant> upgrades,
		in out array<biom_PendingAlterant> sidegrades,
		in out array<biom_PendingAlterant> downgrades,
		biom_WeightedRandom wrtUpgrades,
		biom_WeightedRandom wrtSidegrades,
		biom_WeightedRandom wrtDowngrades,
		biom_PendingAlterant p,
		readonly<biom_Player> pawn
	)
	{
		int bal = 0;

		if (p.inner is 'biom_PawnAlterant')
		{
			bal = biom_PawnAlterant(p.inner).Balance(pawn);
		}
		else if (p.inner is 'biom_WeaponAlterant')
		{
			bal = biom_WeaponAlterant(p.inner).Balance(p.weaponData);
		}

		if (p.inner.IsSidegrade())
		{
			{
				sidegrades.Push(p);
				wrtSidegrades.Add(1);
			}
		}
		else
		{
			if (bal > 0)
			{
				upgrades.Push(p);
				wrtUpgrades.Add(1);
			}
			else if (bal < 0)
			{
				downgrades.Push(p);
				wrtDowngrades.Add(1);
			}
			else
			{
				sidegrades.Push(p);
				wrtSidegrades.Add(1);
			}
		}
	}

	private static void SelectRandomAlterants(
		in out array<biom_PendingAlterant> pending,
		in out array<biom_PendingAlterant> candidates,
		biom_WeightedRandom weights
	)
	{
		array<uint> selected;

		for (uint i = 0; i < ALTERANT_BATCH_SIZE; ++i)
		{
			uint r = uint.MAX;

			do
			{
				r = weights.Result();
			} while (selected.Find(r) != selected.Size());

			pending.Push(candidates[r]);
			selected.Push(r);
		}
	}

	private void RegisterAlterantPrototypes()
	{
		for (int i = 0; i < allClasses.Size(); ++i)
		{
			if (allClasses[i].IsAbstract())
				continue;

			if (allClasses[i] is 'biom_PawnAlterant')
			{
				let t = (class<biom_PawnAlterant>)(allClasses[i]);
				self.pawnAlterants.Push(biom_PawnAlterant(new(t)));
			}
			else if (allClasses[i] is 'biom_WeaponAlterant')
			{
				let t = (class<biom_WeaponAlterant>)(allClasses[i]);
				self.weaponAlterants.Push(biom_WeaponAlterant(new(t)));
			}
		}
	}

	// Loot ////////////////////////////////////////////////////////////////////

	class<Actor> GetReplacement(name type)
	{
		let tn = self.replacements.At(type);

		if (tn.Length() != 0)
			return (class<Actor>)(tn);

		return null;
	}

	class<Actor> GetLegendaryLoot(name type)
	{
		let tn = self.legendaryLoot.At(type);

		if (tn.Length() != 0)
			return (class<Actor>)(tn);

		return null;
	}

	private void PopulateLegenDoomLoot()
	{
		if (biom_Utils.DoomRLMonsterPack())
		{
			if (developer >= 1)
			{
				Console.PrintF(
					Biomorph.LOGPFX_DEBUG ..
					"Populating legendary loot table for the DoomRL Monster Pack..."
				);
			}

			name tn = 'BiomorphDoomRL';
			class t = tn;

			if (t != null)
			{
				self.legendaryLoot.Insert(
					"RLFormerSergeantCombatShotgun",
					"biomrl_alti_Plasmatic"
				);
			}
		}
	}
}
