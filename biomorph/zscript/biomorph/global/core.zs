class BIO_Global : Thinker
{
	static BIO_Global Create()
	{
		let iter = ThinkerIterator.Create('BIO_Global', STAT_STATIC);

		if (iter.Next(true) != null)
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data.");
			return null;
		}

		uint ms = MsTime();
		let ret = new('BIO_Global');
		ret.ChangeStatNum(STAT_STATIC);

		ret.DetectContext();
		ret.PopulateWeaponLootTables();
		ret.PopulateWeaponMorphCache();
		ret.PopulateWeaponModifierCache();
		ret.PopulateMutagenLootTable();
		ret.PopulateGeneLootTable();
		ret.PopulatePerkLootTable();
		ret.SetupLootCore();

		for (uint i = 0; i < __BIO_WSCAT_COUNT__; i++)
		{
			if (ret.WeaponLoot[i].Size() < 1)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Failed to populate weapon loot array: %s",
					ret.WeaponLoot[i].Label);
			}
		}

		if (BIO_debug)
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);
		}

		return ret;
	}

	static clearscope BIO_Global Get()
	{
		let iter = ThinkerIterator.Create('BIO_Global', STAT_STATIC);
		return BIO_Global(iter.Next(true));
	}

	readOnly<BIO_Global> AsConst() const { return self; }

	final override void OnDestroy()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");
		
		super.OnDestroy();
	}
}

// Global context information.

enum BIO_GlobalContext : uint8
{
	BIO_GCTX_NONE = 0,
	BIO_GCTX_VALIANT = 1 << 0
}

extend class BIO_Global
{
	private BIO_GlobalContext ContextFlags;

	private void DetectContext()
	{
		if (BIO_Utils.Valiant())
		{
			ContextFlags |= BIO_GCTX_VALIANT;
		}
	}

	bool InValiant() const
	{
		return ContextFlags & BIO_GCTX_VALIANT;
	}
}
