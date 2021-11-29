class BIO_DamageFunctor play abstract
{
	abstract int Invoke() const;

	virtual void GetValues(in out Array<int> vals) const {}
	virtual void SetValues(in out Array<int> vals) {}

	uint ValueCount() const
	{
		Array<int> vals;
		GetValues(vals);
		return vals.Size();
	}

	// Output should be full localized.
	abstract string ToString(BIO_DamageFunctor def) const;

	readOnly<BIO_DamageFunctor> AsConst() const { return self; }
}

// Emits a random number between a minimum and a maximum.
class BIO_DmgFunc_Default : BIO_DamageFunctor
{
	private int Minimum, Maximum;

	override int Invoke() const { return Random(Minimum, Maximum); }

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
		string crEsc_min = "", crEsc_max = "";

		if (myDefs != null)
		{
			crEsc_min = BIO_Utils.StatFontColor(Minimum, myDefs.Minimum);
			crEsc_max = BIO_Utils.StatFontColor(Maximum, myDefs.Maximum);
		}
		else
		{
			crEsc_min = crEsc_max = CRESC_STATMODIFIED;
		}

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_DEFAULT"),
			crEsc_min, Minimum, crEsc_max, Maximum);
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
		string crEsc = "";
		
		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);
		else
			crEsc = CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			crEsc, Baseline);
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
		string crEsc = "";
		
		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);
		else
			crEsc = CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D8"),
			crEsc, Baseline);
	}
}

class BIO_DmgFunc_Single : BIO_DamageFunctor
{
	private int Value;

	override int Invoke() const { return Value; }

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Value);
	}

	override void SetValues(in out Array<int> vals)
	{
		Value = vals[0];
	}

	void CustomSet(int val) { Value = val; }

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_Single(def);
		string crEsc = "";

		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Value, myDefs.Value);
		else
			crEsc = CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_SINGLE"),
			crEsc, Value);
	}
}
