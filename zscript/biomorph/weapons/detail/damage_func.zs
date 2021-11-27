class BIO_DamageFunctor play abstract
{
	abstract int Invoke() const;
	abstract void Reset(readOnly<BIO_DamageFunctor> def);

	virtual void GetValues(in out Array<int> vals) const {}
	virtual void SetValues(in out Array<int> vals) {}

	// Output should be full localized.
	abstract string ToString(BIO_DamageFunctor def) const;

	readOnly<BIO_DamageFunctor> AsConst() const { return self; }
}

// Emits a random number between a minimum and a maximum.
class BIO_DmgFunc_Default : BIO_DamageFunctor
{
	private int Minimum, Maximum;

	override int Invoke() const { return Random(Minimum, Maximum); }

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDef = BIO_DmgFunc_Default(def);
		Minimum = myDef.Minimum;
		Maximum = myDef.Maximum;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Minimum, Maximum);
	}

	override void SetValues(in out Array<int> vals)
	{
		Minimum = vals[0];
		Maximum = vals[1];
	}

	void CustomSet(int minDmg, int maxDmg)
	{
		Minimum = minDmg;
		Maximum = maxDmg;
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_Default(def);

		string
			minClr = BIO_Utils.StatFontColor(Maximum, myDefs.Maximum),
			maxClr = BIO_Utils.StatFontColor(Minimum, myDefs.Minimum);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_DEFAULT"),
			minClr, Minimum, maxClr, Maximum);
	}
}

// Imitates the vanilla behaviour of multiplying bullet puff damage by 1D3.
class BIO_DmgFunc_1D3 : BIO_DamageFunctor
{
	private int Baseline;

	override int Invoke() const
	{
		return Baseline * Random(1, 3);
	}

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDefs = BIO_DmgFunc_1D3(def);
		Baseline = myDefs.Baseline;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_1D3(def);

		string fontColor = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			fontColor, Baseline);
	}
}

// Imitates the vanilla behaviour of multiplying projectile damage by 1D8.
class BIO_DmgFunc_1D8 : BIO_DamageFunctor
{
	private int Baseline;

	override int Invoke() const
	{
		return Baseline * Random(1, 8);
	}

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDefs = BIO_DmgFunc_1D8(def);
		Baseline = myDefs.Baseline;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_1D8(def);

		string fontColor = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			fontColor, Baseline);
	}
}
