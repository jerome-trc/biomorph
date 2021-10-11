class BIO_GlobalData : Thinker
{
	private static BIO_GlobalData Create()
	{
		uint ms = MsTime();
		let ret = new("BIO_GlobalData");
		ret.ChangeStatNum(STAT_STATIC);

		if (BIO_CVar.Debug())
			Console.Printf(Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).", MsTime() - ms);

		return ret;
	}

	static BIO_GlobalData Get()
	{
		let iter = ThinkerIterator.Create("BIO_GlobalData", STAT_STATIC);
		let ret = BIO_GlobalData(iter.Next(true));
		if (ret == null) ret = BIO_GlobalData.Create();
		return ret;
	}
}
