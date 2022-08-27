// Player inventory reset scheduling.

class BIO_PlayerResetTracker
{
	PlayerInfo Player;
	uint Ammo, Health, Armor, Weapons;
}

extend class BIO_Global
{
	private Array<BIO_PlayerResetTracker> PlayerResetTrackers;

	// Also performs lazy initialization.
	private BIO_PlayerResetTracker GetPlayerResetTracker(PlayerInfo pInfo) const
	{
		for (uint i = 0; i < PlayerResetTrackers.Size(); i++)
			if (PlayerResetTrackers[i].Player == pInfo)
				return PlayerResetTrackers[i];
		
		let ret = new('BIO_PlayerResetTracker');
		ret.Player = pInfo;
		PlayerResetTrackers.Push(ret);
		return ret;
	}

	bool ResetPlayerAmmo(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Ammo(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Ammo == interval)
		{
			tracker.Ammo = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerArmor(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Armor(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Armor == interval)
		{
			tracker.Armor = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerHealth(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Health(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Health == interval)
		{
			tracker.Health = 0;
			return true;
		}

		return false;
	}

	bool ResetPlayerWeapons(PlayerInfo pInfo)
	{
		let interval = BIO_CVar.ResetInterval_Weapons(pInfo);

		if (interval <= 0)
			return false;

		let tracker = GetPlayerResetTracker(pInfo);

		if (++tracker.Weapons == interval)
		{
			tracker.Weapons = 0;
			return true;
		}

		return false;
	}
}
