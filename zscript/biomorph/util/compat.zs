extend class BIO_Utils
{
	// Returns true if Zhs2's Intelligent Supplies has been loaded.
	static bool IntelligentSupplies()
	{
		name zhs2IS_name = 'Zhs2_IS_BaseItem';
		Class<Actor> zhs2IS = zhs2IS_name;
		return zhs2IS != null;
	}

	// Also checks for `ThriftyStimpack`.
	static bool IsStimpack(Class<Inventory> inv)
	{
		name thriftyStimName = 'ThriftyStimpack';
		Class<Inventory> thriftyStim = thriftyStimName;
		return inv is 'Stimpack' || inv is thriftyStim;
	}

	// Also checks for `ThriftyMedikit`.
	static bool IsMedikit(Class<Inventory> inv)
	{
		name thriftyMediName = 'ThriftyMedikit';
		Class<Inventory> thriftyMedi = thriftyMediName;
		return inv is 'Medikit' || inv is thriftyMedi;
	}

	static Class<Inventory> ExtInv(string tName)
	{
		Class<Inventory> ret = tName;
		return ret;
	}

	static Inventory TryFindInv(Actor a, string tName)
	{
		Class<Inventory> t = tName;
		if (t == null) return null;
		return a.FindInventory(t);
	}

	static play void TryGiveInv(Actor a, string tName, int amt, bool giveCheat = false)
	{
		Class<Inventory> t = tName;
		if (t == null) return;
		a.GiveInventory(t, 1, giveCheat);
	}

	static play bool TryA_GiveInv(Actor a, string tName, int amount = 0,
		int giveTo = AAPTR_DEFAULT)
	{
		Class<Inventory> t = tName;
		if (t == null) return false;
		return Actor.DoGiveInventory(a, false, t, amount, giveTo);
	}

	static play bool, Actor TrySpawnEx(Actor source, string typeName,
		double xofs = 0.0, double yofs = 0.0, double zofs = 0.0,
		double xvel = 0.0, double yvel = 0.0, double zvel = 0.0,
		double angle = 0.0, int flags = 0, int failchance = 0, int tid = 0)
	{
		Class<Actor> t = typeName;
		if (t == null) return false, null;

		bool ret0 = false;
		Actor ret1 = null;

		[ret0, ret1] = source.A_SpawnItemEx(
			t, xofs, yofs, zofs, xvel, yvel, zvel, angle, flags, failchance, tid);

		return ret0, ret1;
	}

	static play bool TryCheckInv(Actor a, string typeName, int amt,
		statelabel label, int owner = AAPTR_DEFAULT)
	{
		Class<Inventory> t = typeName;
		if (t == null) return null;
		return a.CheckInventory(t, amt, owner);
	}
}
