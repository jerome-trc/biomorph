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
	protected int Minimum, Maximum;

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

	BIO_DmgFunc_Default CustomSet(int minDmg, int maxDmg)
	{
		Minimum = minDmg;
		Maximum = maxDmg;
		return self;
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
			StringTable.Localize("$BIO_DMGFUNC_DEFAULT"),
			crEsc_min, Minimum, crEsc_max, Maximum);
	}
}

// For imitating the vanilla behaviour of multiplying puff  
// damage by 1D3, or of multiplying projectile damage by 1D8.
class BIO_DmgFunc_1DX : BIO_DamageFunctor
{
	protected int Baseline, MaxFactor;

	override int Invoke() const
	{
		return Baseline * Random(1, MaxFactor);
	}

	BIO_DmgFunc_1DX CustomSet(int base, int maxFac)
	{
		Baseline = base;
		MaxFactor = maxFac;
		return self;
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
		let myDefs = BIO_DmgFunc_1DX(def);
		string crEsc = "";
		
		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);
		else
			crEsc = CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_DMGFUNC_1DX"),
			crEsc, Baseline, MaxFactor);
	}
}

class BIO_DmgFunc_Single : BIO_DamageFunctor
{
	protected int Value;

	override int Invoke() const { return Value; }

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Value);
	}

	override void SetValues(in out Array<int> vals)
	{
		Value = vals[0];
	}

	BIO_DmgFunc_Single CustomSet(int val) { Value = val; return self; }

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_Single(def);
		string crEsc = "";

		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Value, myDefs.Value);
		else
			crEsc = CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_DMGFUNC_SINGLE"),
			crEsc, Value);
	}
}
