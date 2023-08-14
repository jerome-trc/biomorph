/// A singleton of this type holds loot tables and alterant prototypes, since
/// these do not need to be written to save games but must always be present
/// (thus disallowing `transient`).
class biom_Static : StaticEventHandler
{
	/// Used by `biom_EventHandler::CheckReplacement`.
	private Dictionary replacements;
	/// Used by `biom_EventHandler::WorldThingDied`.
	private Dictionary legendaryLoot;
	private Array<biom_Alterant> alterants;

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

		for (int i = 0; i < allClasses.Size(); ++i)
		{
			let alter = (class<biom_Alterant>)(allClasses[i]);

			if (alter == null || alter.IsAbstract())
				continue;

			if (alter is 'biom_WeaponAlterant')
			{
				self.RegisterWeaponAlterant((class<biom_WeaponAlterant>)(alter));
				continue;
			}

			self.alterants.Push(biom_Alterant(new(alter)));
		}

		self.replacements = Dictionary.Create();

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

	readonly<biom_Alterant> GetAlterant(class<biom_Alterant> type) const
	{
		for (int i = 0; i < self.alterants.Size(); ++i)
			if (self.alterants[i].GetClass() == type)
				return self.alterants[i].AsConst();

		return null;
	}

	readonly<biom_WeaponAlterant> GetWeaponAlterant(
		class<biom_WeaponAlterant> type,
		class<biom_Weapon> weaponType
	) const
	{
		for (int i = 0; i < self.alterants.Size(); ++i)
		{
			let alter = biom_WeaponAlterant(self.alterants[i]);

			if (alter == null)
				continue;

			if (alter.GetClass() != type)
				continue;

			if (alter.weaponType != weaponType)
				continue;

			let b = alter.AsConst();
			return biom_WeaponAlterant(b);
		}

		return null;
	}

	void RegisterWeaponAlterant(class<biom_WeaponAlterant> alter)
	{
		for (int i = 0; i < allClasses.Size(); ++i)
		{
			let weap = (class<biom_Weapon>)(allClasses[i]);

			if (weap == null || weap.IsAbstract())
				continue;

			let proto = biom_WeaponAlterant(new(alter));
			proto.weaponType = weap;
			self.alterants.Push(proto);
		}
	}

	void GenerateAlterantBatch(
		in out biom_PendingAlterants pending,
		biom_Player pawn
	)
	{
		Array<biom_Alterant> upgrades, sidegrades, downgrades;

		for (int i = 0; i < self.alterants.Size(); ++i)
		{
			let alter = self.alterants[i];

			if (!alter.Compatible(pawn.AsConst()))
				continue;

			if (alter.IsSidegrade())
			{
				sidegrades.Push(alter);
			}
			else
			{
				let bal = alter.Balance();

				if (bal > 0)
					upgrades.Push(alter);
				else if (bal < 0)
					downgrades.Push(alter);
				else
					sidegrades.Push(alter);
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
