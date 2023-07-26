// Note to reader: classes may be defined using `extend` blocks for code folding.

class biom_Global : Thinker
{
	/// The monster value threshold between mutagen drops is divided by this.
	private uint playerCount;
	/// One per active player.
	private array<biom_PlayerData> playerData;

	readonly<biom_PlayerData> GetPlayerData(uint player) const
	{
		return self.playerData[player].AsConst();
	}

	readonly<biom_PlayerData> FindPlayerData(PlayerInfo pInfo) const
	{
		for (uint i = 0; i < MAXPLAYERS; ++i)
			if (players[i] == pInfo)
				return self.playerData[i].AsConst();

		Biomorph.Unreachable();
		return null;
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

		for (uint i = 0; i < MAXPLAYERS; ++i)
		{
			if (!playerInGame[i])
				continue;

			ret.playerData.Push(biom_PlayerData.Create());
			ret.playerCount++;
		}

		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).",
				MsTime() - ms
			);
		}

		return ret;
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
}

/// One exists per active player.
class biom_PlayerData
{
	/// What weapons will this player currently receive if they collect a weapon
	/// pickup? No element will ever be `null`.
	array<class <biom_Weapon> > weapons;
	/// Each subclass of `biom_WeaponData` appears in this array exactly once.
	array<biom_WeaponData> weaponData;

	static biom_PlayerData Create()
	{
		let ret = new('biom_PlayerData');

		ret.weapons.Push((class<biom_Weapon>)('biom_Unarmed'));
		// TODO: What should the starting Chainsaw replacement be?
		ret.weapons.Push((class<biom_Weapon>)('biom_ServicePistol'));
		ret.weapons.Push((class<biom_Weapon>)('biom_PumpShotgun'));
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

	readonly<biom_PlayerData> AsConst() const
	{
		return self;
	}
}
