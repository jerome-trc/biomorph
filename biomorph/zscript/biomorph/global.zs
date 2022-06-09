// Note to reader: classes are defined using `extend` blocks for code folding.

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

	final override void OnDestroy()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");
		
		super.OnDestroy();
	}
}
