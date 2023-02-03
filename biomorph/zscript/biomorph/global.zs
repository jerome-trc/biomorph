// Note to reader: classes are defined using `extend` blocks for code folding.

class BIOM_Global : Thinker
{
	static BIOM_Global Create()
	{
		let iter = ThinkerIterator.Create('BIOM_Global', STAT_STATIC);

		if (iter.Next(true) != null)
		{
			Console.Printf(Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data.");
			return null;
		}

		uint ms = MsTime();
		let ret = new('BIOM_Global');
		ret.ChangeStatNum(STAT_STATIC);

		if (BIOM_debug)
		{
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);
		}

		return ret;
	}

	static clearscope BIOM_Global Get()
	{
		let iter = ThinkerIterator.Create('BIOM_Global', STAT_STATIC);
		return BIOM_Global(iter.Next(true));
	}

	final override void OnDestroy()
	{
		if (BIOM_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");

		super.OnDestroy();
	}
}
