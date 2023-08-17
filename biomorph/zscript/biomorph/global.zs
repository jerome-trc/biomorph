// Note to reader: classes may be defined using `extend` blocks for code folding.

class biom_Global : Thinker
{
	const LOOT_VALUE_THRESHOLD = 2500;

	/// One per active player.
	private array<biom_PlayerData> playerData;
	/// How close are the players to getting their next loot drop?
	/// Whenever an enemy dies, this is increased based on approximately how
	/// "valuable" that monster was, and then this gets drained for as many times
	/// as it exceeds a threshold. For that many times, a loot item drops.
	private uint lootValueBuf;
	/// Applied after all other factors. This gets computed whenever a level is
	/// loaded, and is used to scale down monster value as the total amount
	/// of enemy health in a level grows.
	private float lootValueMulti;

	biom_PlayerData GetPlayerData(uint player) const
	{
		return self.playerData[player];
	}

	biom_PlayerData FindPlayerData(PlayerInfo pInfo) const
	{
		// Happens if a single player dies and loads their last saved game.
		if (self.playerData.Size() == 0)
			return null;

		for (uint i = 0; i < MAXPLAYERS; ++i)
			if (players[i] == pInfo)
				return self.playerData[i];

		Biomorph.Unreachable("failed to find a player datum.");
		return null;
	}

	clearscope uint CalcMonsterValue(Actor monster) const
	{
		let ret = float(Max(monster.default.health, monster.GetMaxHealth(true)));

		if (monster.bMissileMore)
			ret *= 1.2;

		if (monster.bMissileEvenMore)
			ret *= 1.2;

		return uint(ret * self.lootValueMulti);
	}

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

			ret += self.CalcMonsterValue(mons);
		}

		return ret;
	}

	void AddLootValue(uint val)
	{
		self.lootValueBuf += val;
	}

	bool DrainLootValueBuffer()
	{
		if (self.lootValueBuf >= biom_Global.LOOT_VALUE_THRESHOLD)
		{
			self.lootValueBuf -= biom_Global.LOOT_VALUE_THRESHOLD;
			return true;
		}

		return false;
	}

	float LootValueMultiplier() const
	{
		return self.lootValueMulti;
	}

	/// Affects every player.
	void ModifyBalance(int bal)
	{
		for (int i = 0; i < self.playerData.Size(); ++i)
			self.playerData[i].balanceMod += bal;
	}

	void NextAlteration()
	{
		for (int i = 0; i < self.playerData.Size(); ++i)
			self.playerData[i].NextAlteration(null);
	}

	static biom_Global Create()
	{
		let iter = ThinkerIterator.Create('biom_Global', STAT_STATIC);

		if (iter.Next(true) != null)
		{
			Console.PrintF(
				Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data."
			);

			return null;
		}

		uint ms = MSTime();
		let ret = new('biom_Global');
		ret.ChangeStatNum(STAT_STATIC);
		let ssgExists = biom_Utils.SuperShotgunExists();
		let balMod = biom_Global.NewGameBalanceModifier();

		for (uint i = 0; i < MAXPLAYERS; ++i)
		{
			if (!playerInGame[i])
				continue;

			let pdat = biom_PlayerData.Create(players[i], ssgExists);
			pdat.balanceMod = balMod;
			ret.playerData.Push(pdat);
		}

		if (developer >= 1)
		{
			Console.Printf(
				Biomorph.LOGPFX_DEBUG ..
				"Starting balance modifier: %d",
				balMod
			);

			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).",
				MsTime() - ms
			);
		}

		return ret;
	}

	/// Can not be called by `EventHandler::OnWorldLoaded`, since not all monsters
	/// may have finished their replacement process yet.
	void CalculateLootValueMultiplier()
	{
		self.LootValueMultiplierFormulaV1();
	}

	private void LootValueMultiplierFormulaV1()
	{
		self.lootValueMulti = 1.0;

		let iter = ThinkerIterator.Create('Actor');
		uint hp = 0;

		while (true)
		{
			let monster = Actor(iter.Next());

			if (monster == null)
				break;

			if (!monster.bIsMonster)
				continue;

			hp += Max(monster.default.health, monster.GetMaxHealth(true));
		}

		self.lootValueMulti = 0.5 / Log10(float(hp));
	}

	private void LootValueMultiplierFormulaV2()
	{
		let lvm = 1.0;

		let iter = ThinkerIterator.Create('Actor');

		while (true)
		{
			let monster = Actor(iter.Next());

			if (monster == null)
				break;

			if (!monster.bIsMonster)
				continue;

			let h = Max(monster.default.health, monster.GetMaxHealth(true));
			let hf = Log10(float(h)) * 0.00275;
			lvm -= hf;
		}

		self.lootValueMulti = Max(lvm, 0.01);
	}

	static clearscope biom_Global Get()
	{
		let iter = ThinkerIterator.Create('biom_Global', STAT_STATIC);
		return biom_Global(iter.Next(true));
	}

	final override void OnDestroy()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");

		super.OnDestroy();
	}

	/// Determines how much the alteration system should favor or disfavor the
	/// players at the start of a new playthrough based on how much more difficult
	/// or easy their experience is likely to be. As an example, the balance
	/// is increased (i.e. make the players somewhat more powerful) if they are
	/// playing with LegenDoom Lite or Colourful Hell, to offset that added challenge.
	private static int NewGameBalanceModifier()
	{
		let ret = 0;
		array<string> reports;

		if (biom_Utils.ColourfulHell())
		{
			let bm = 0;

			if (biom_Utils.ColourfulHellRainbow())
				bm = BIOM_BALMOD_INC_L;
			else if (biom_Utils.ColourfulHellAdaptive())
			{} // Needs special handling.
			else
				bm = BIOM_BALMOD_INC_M;

			reports.Push(
				String.Format(
					StringTable.Localize("$BIOM_BALMODREPORT"),
					"Colourful Hell",
					bm
				)
			);
		}

		if (biom_Utils.CyberaugmentedMonsters())
		{
			ret += BIOM_BALMOD_INC_S;

			reports.Push(
				String.Format(
					StringTable.Localize("$BIOM_BALMODREPORT"),
					"Cyberaugmented Monsters",
					BIOM_BALMOD_INC_S
				)
			);
		}

		if (biom_Utils.DoomRLMonsterPack())
		{
			let bm = 0;

			switch (skill)
			{
			case 3: // `hard`, a.k.a. "Standard".
			{
				bm = BIOM_BALMOD_INC_S;
				break;
			}
			case 4: // `nightmare`
			case 5: // `technophobia`
			{
				bm = BIOM_BALMOD_INC_M;
				break;
			}
			case 6: // `armageddon`
			{
				bm = BIOM_BALMOD_INC_L;
				break;
			}
			// `adaptive` needs special handling.
			default:
				break;
			}

			ret += bm;

			reports.Push(
				String.Format(
					StringTable.Localize("$BIOM_BALMODREPORT"),
					"DoomRL Monsters",
					bm
				)
			);
		}

		if (biom_Utils.LegenDoom())
		{
			let bm = 0;

			if (CVar.GetCVar("LD_diemode").GetBool())
			{
				bm = BIOM_BALMOD_INC_XL * 2;
			}
			else
			{
				let cvChance = CVar.GetCVar("LD_legendarychance").GetInt();
				bm = BIOM_BALMOD_INC_M + (BIOM_BALMOD_INC_S * cvChance);
			}

			ret += bm;

			reports.Push(
				String.Format(
					StringTable.Localize("$BIOM_BALMODREPORT"),
					"LegenDoom Lite",
					bm
				)
			);
		}

		if (biom_Utils.PandemoniaMonsters())
		{
			ret += BIOM_BALMOD_INC_S;

			reports.Push(
				String.Format(
					StringTable.Localize("$BIOM_BALMODREPORT"),
					"Pandemonia Monsters",
					BIOM_BALMOD_INC_S
				)
			);
		}

		let reporter = biom_BalanceModifierReporter.Create();
		reporter.reports.Move(reports);
		return ret;
	}
}

/// One exists per active player.
class biom_PlayerData
{
	PlayerInfo pInfo;
	/// When calculating the total balance of this player's alteration stack, this
	/// is the starting value. Given a vanilla configuration, this is always zero;
	/// it is affected by, for instance, using LegenDoom Lite or the progression
	/// of Corruption Cards.
	int balanceMod;
	/// What weapons will this player currently receive if they collect a weapon
	/// pickup? No element will ever be `null`.
	array<class <biom_Weapon> > weapons;
	/// Each subclass of `biom_WeaponData` appears in this array exactly once.
	array<biom_WeaponData> weaponData;
	biom_PendingAlterants pendingAlterants;
	/// It is impossible to buffer multiple batches of alterants, since a player's
	/// choice in one batch affects eligibility in future batches. As such, this
	/// is how many batches of alterants are waiting to be offered once the player's
	/// choice for the current batch has been made.
	uint pendingAlterations;

	static biom_PlayerData Create(PlayerInfo pInfo, bool withSuperShotgun)
	{
		let ret = new('biom_PlayerData');
		ret.pInfo = pInfo;

		ret.weapons.Push((class<biom_Weapon>)('biom_Unarmed'));
		// TODO: What should the starting Chainsaw replacement be?
		ret.weapons.Push((class<biom_Weapon>)('biom_ElecPunch'));
		ret.weapons.Push((class<biom_Weapon>)('biom_ServicePistol'));
		ret.weapons.Push((class<biom_Weapon>)('biom_PumpShotgun'));

		if (withSuperShotgun)
			ret.weapons.Push((class<biom_Weapon>)('biom_DoublePumpShotgun'));

		ret.weapons.Push((class<biom_Weapon>)('biom_GPMG'));
		ret.weapons.Push((class<biom_Weapon>)('biom_MultiGL'));
		ret.weapons.Push((class<biom_Weapon>)('biom_BiteRifle'));
		ret.weapons.Push((class<biom_Weapon>)('biom_CasterCannon'));

		for (uint i = 0; i < allClasses.Size(); ++i)
		{
			let wdat = (class<biom_WeaponData>)(allClasses[i]);

			if (wdat == null || wdat.IsAbstract())
				continue;

			let e = ret.weaponData.Push(biom_WeaponData(new(wdat)));
			ret.weaponData[e].Reset();
		}

		return ret;
	}

	/// `specific` is only for use with alterant items, so `null` is a valid argument.
	play void NextAlteration(biom_PendingAlterant specific)
	{
		if (self.pendingAlterants.IsEmpty())
		{
			let sdat = biom_Static.Get();

			sdat.GenerateAlterantBatch(
				self.pendingAlterants,
				self.GetPawn(),
				specific
			);
		}
		else
		{
			self.pendingAlterations += 1;
		}
	}

	readonly<biom_WeaponData> GetWeaponData(class<biom_WeaponData> t) const
	{
		for (int i = 0; i < self.weaponData.Size(); ++i)
			if (weaponData[i].GetClass() == t)
				return weaponData[i].AsConst();

		return null;
	}

	biom_WeaponData GetWeaponDataMut(class<biom_WeaponData> t) const
	{
		for (int i = 0; i < self.weaponData.Size(); ++i)
			if (weaponData[i].GetClass() == t)
				return weaponData[i];

		return null;
	}

	readonly<biom_PlayerData> AsConst() const
	{
		return self;
	}

	biom_Player GetPawn() const
	{
		for (uint i = 0; i < MAXPLAYERS; ++i)
		{
			if (players[i] != self.pInfo)
				continue;

			let ret = biom_Player(players[i].mo);
			Biomorph.Assert(ret != null);
			return ret;
		}

		return null;
	}
}

/// A compositional aid for `biom_PlayerData`.
struct biom_PendingAlterants
{
	array<biom_PendingAlterant> upgrades, sidegrades, downgrades;

	void Clear()
	{
		self.upgrades.Clear();
		self.sidegrades.Clear();
		self.downgrades.Clear();
	}

	/// i.e. is there currently an open batch of alterants on offer?
	bool IsEmpty() const
	{
		return
			self.upgrades.Size() <= 0 &&
			self.sidegrades.Size() <= 0 &&
			self.downgrades.Size() <= 0;
	}
}

/// Gradually prints messages to all users' HUDs to tell them what factors are
/// affecting the baseline balance at the start of a new game.
class biom_BalanceModifierReporter : Thinker
{
	array<string> reports;
	uint ticsUntilNext;

	static biom_BalanceModifierReporter Create()
	{
		let ret = new('biom_BalanceModifierReporter');
		ret.ticsUntilNext = TICRATE * 2;
		return ret;
	}

	final override void Tick()
	{
		super.Tick();

		if (self.bDestroyed)
			return;

		if (self.reports.Size() <= 0)
			self.Destroy();

		self.ticsUntilNext -= 1;

		if (ticsUntilNext == 0)
		{
			ticsUntilNext = TICRATE * 2;

			Console.MidPrint(
				'JenocideFontRed',
				self.reports[self.reports.Size() - 1],
				true
			);

			S_StartSound("biom/alter/levelup", CHAN_AUTO);

			self.reports.Pop();
		}
	}
}
