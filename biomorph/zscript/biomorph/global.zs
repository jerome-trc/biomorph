// Note to reader: classes may be defined using `extend` blocks for code folding.

class biom_Global : Thinker
{
	const LOOT_VALUE_THRESHOLD = 3000;

	/// The monster value threshold between loot drops is divided by this.
	private uint playerCount;
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

	readonly<biom_PlayerData> GetPlayerData(uint player) const
	{
		return self.playerData[player].AsConst();
	}

	readonly<biom_PlayerData> FindPlayerData(PlayerInfo pInfo) const
	{
		for (uint i = 0; i < MAXPLAYERS; ++i)
			if (players[i] == pInfo)
				return self.playerData[i].AsConst();

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
		if (self.lootValueBuf >= LOOT_VALUE_THRESHOLD)
		{
			self.lootValueBuf -= LOOT_VALUE_THRESHOLD;
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

			let pdat = biom_PlayerData.Create(ssgExists);
			pdat.balanceMod = balMod;
			ret.playerData.Push(pdat);
			ret.playerCount++;
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

	void OnWorldLoaded()
	{
		self.lootValueMulti = 1.0;

		let iter = ThinkerIterator.Create('Actor');
		uint hp = 0;

		while (true)
		{
			let mons = Actor(iter.Next());

			if (mons == null)
				break;

			if (!mons.bIsMonster)
				continue;

			hp += Max(mons.default.health, mons.GetMaxHealth(true));
		}

		self.lootValueMulti = 0.5 / Log10(float(hp));
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

	/// Determines how much the mutation system should favor or disfavor the
	/// players at the start of a new playthrough based on how much more difficult
	/// or easy their experience is likely to be. As an example, the balance
	/// is increased (i.e. make the players somewhat more powerful) if they are
	/// playing with LegenDoom Lite or Colourful Hell, to offset that added challenge.
	private static int NewGameBalanceModifier()
	{
		let ret = 0;

		if (biom_Utils.ColourfulHell())
		{
			if (biom_Utils.ColourfulHellRainbow())
				ret += BIOM_BALMOD_INC_L;
			else
				ret += BIOM_BALMOD_INC_M;
		}

		if (biom_Utils.DoomRLMonsterPack())
		{
			switch (skill)
			{
			case 3: // `hard`, a.k.a. "Standard".
			{
				ret += BIOM_BALMOD_INC_XS;
				break;
			}
			case 4: // `nightmare`
			case 5: // `technophobia`
			{
				ret += BIOM_BALMOD_INC_S;
				break;
			}
			case 6: // `armageddon`
			{
				ret += BIOM_BALMOD_INC_M;
				break;
			}
			// `adaptive` needs special handling.
			default:
				break;
			}
		}

		if (biom_Utils.LegenDoom())
			ret += BIOM_BALMOD_INC_S;

		if (biom_Utils.PandemoniaMonsters())
			ret += BIOM_BALMOD_INC_S;

		return ret;
	}
}

/// One exists per active player.
class biom_PlayerData
{
	/// When calculating the total balance of this player's mutation stack, this
	/// is the starting value. Given a vanilla configuration, this is always zero;
	/// it is affected by, for instance, using LegenDoom Lite or the progression
	/// of Corruption Cards.
	int balanceMod;
	/// What weapons will this player currently receive if they collect a weapon
	/// pickup? No element will ever be `null`.
	array<class <biom_Weapon> > weapons;
	/// Each subclass of `biom_WeaponData` appears in this array exactly once.
	array<biom_WeaponData> weaponData;

	static biom_PlayerData Create(bool withSuperShotgun)
	{
		let ret = new('biom_PlayerData');

		ret.weapons.Push((class<biom_Weapon>)('biom_Unarmed'));
		// TODO: What should the starting Chainsaw replacement be?
		ret.weapons.Push((class<biom_Weapon>)('biom_ServicePistol'));
		ret.weapons.Push((class<biom_Weapon>)('biom_PumpShotgun'));

		if (withSuperShotgun)
			ret.weapons.Push((class<biom_Weapon>)('biom_CombatStormgun'));

		ret.weapons.Push((class<biom_Weapon>)('biom_GPMG'));
		ret.weapons.Push((class<biom_Weapon>)('biom_MANPAT'));
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

	readonly<biom_WeaponData> GetWeaponData(class<biom_WeaponData> t) const
	{
		for (int i = 0; i < self.weaponData.Size(); ++i)
			if (weaponData[i].GetClass() == t)
				return weaponData[i].AsConst();

		return null;
	}

	readonly<biom_PlayerData> AsConst() const
	{
		return self;
	}
}

const BIOM_BALMOD_INC_XS = 1;
const BIOM_BALMOD_INC_S = 5;
const BIOM_BALMOD_INC_M = 10;
const BIOM_BALMOD_INC_L = 20;
const BIOM_BALMOD_INC_XL = 40;
const BIOM_BALMOD_DEC_XS = -BIOM_BALMOD_INC_XS;
const BIOM_BALMOD_DEC_S = -BIOM_BALMOD_INC_S;
const BIOM_BALMOD_DEC_M = -BIOM_BALMOD_INC_M;
const BIOM_BALMOD_DEC_L = -BIOM_BALMOD_INC_L;
const BIOM_BALMOD_DEC_XL = -BIOM_BALMOD_INC_XL;
