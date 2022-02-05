class BIO_DamageFunctor play abstract
{
	abstract int Invoke() const;

	abstract int MinOutput() const;
	abstract int MaxOutput() const;

	virtual void GetValues(in out Array<int> vals) const {}
	virtual void SetValues(in out Array<int> vals) {}

	int AverageOutput(uint sampleSize = 500)
	{
		int total = 0;

		for (uint i = 0; i < sampleSize; i++)
			total += Invoke();

		return total / int(sampleSize);
	}

	uint ValueCount() const
	{
		Array<int> vals;
		GetValues(vals);
		return vals.Size();
	}

	// Output should be fully localized.
	abstract string ToString(BIO_DamageFunctor def) const;

	readOnly<BIO_DamageFunctor> AsConst() const { return self; }
}

// Emits a random number between a minimum and a maximum.
class BIO_DmgFunc_Rand : BIO_DamageFunctor
{
	protected int Minimum, Maximum;

	override int Invoke() const { return Random(Minimum, Maximum); }

	override int MinOutput() const { return Minimum; }
	override int MaxOutput() const { return Maximum; }

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Minimum, Maximum);
	}

	override void SetValues(in out Array<int> vals)
	{
		Minimum = vals[0];
		Maximum = vals[1];
	}

	BIO_DmgFunc_Rand CustomSet(int minDmg, int maxDmg)
	{
		Minimum = minDmg;
		Maximum = maxDmg;
		return self;
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_Rand(def);
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
			StringTable.Localize("$BIO_DMGFUNC_RAND"),
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

	override int MinOutput() const { return Baseline; }
	override int MaxOutput() const { return Baseline * MaxFactor; }

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

class BIO_DmgFunc_XTimesRand : BIO_DamageFunctor
{
	protected int Multiplier, MinRandom, MaxRandom;

	override int Invoke() const { return Multiplier * Random(MinRandom, MaxRandom); }

	override int MinOutput() const { return Multiplier * MinRandom; }
	override int MaxOutput() const { return Multiplier * MaxRandom; }

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(MinRandom, MaxRandom);
	}

	override void SetValues(in out Array<int> vals)
	{
		MinRandom = vals[0];
		MaxRandom = vals[1];
	}

	BIO_DmgFunc_XTimesRand CustomSet(int multi, int minRand, int maxRand)
	{
		Multiplier = multi;
		MinRandom = minRand;
		MaxRandom = maxRand;
		return self;
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_XTimesRand(def);
		string crEsc_multi = "", crEsc_min = "", crEsc_max = "";

		if (myDefs != null)
		{
			crEsc_multi = BIO_Utils.StatFontColor(Multiplier, myDefs.Multiplier);
			crEsc_min = BIO_Utils.StatFontColor(MinRandom, myDefs.MinRandom);
			crEsc_max = BIO_Utils.StatFontColor(MaxRandom, myDefs.MaxRandom);
		}
		else
		{
			crEsc_multi = crEsc_min = crEsc_max = CRESC_STATMODIFIED;
		}

		return String.Format(
			StringTable.Localize("$BIO_DMGFUNC_XTIMESRAND"),
			crEsc_multi, Multiplier, crEsc_min, MinRandom, crEsc_max, MaxRandom);
	}
}

class BIO_DmgFunc_XPlus1D3 : BIO_DamageFunctor
{
	protected int Baseline;

	override int Invoke() const { return Baseline + Random(1, 3); }

	override int MinOutput() const { return Baseline + 1; }
	override int MaxOutput() const { return Baseline + 3; }

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	BIO_DmgFunc_XPlus1D3 CustomSet(int val)
	{
		Baseline = val;
		return self;
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_XPlus1D3(def);
		string crEsc = "";

		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);
		else
			crEsc = CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_DMGFUNC_XPLUS1D3"),
			crEsc, Baseline);
	}
}

class BIO_DmgFunc_RandomPick : BIO_DamageFunctor
{
	Array<int> Values;

	override int Invoke() const { return Values[Random(0, Values.Size() - 1)]; }

	override int MinOutput() const { return BIO_Utils.IntArrayMin(Values); }
	override int MaxOutput() const { return BIO_Utils.IntArrayMax(Values); }

	BIO_DmgFunc_RandomPick Push(int val)
	{
		Values.Push(val);
		return self;
	}

	override void GetValues(in out Array<int> vals) const
	{
		for (uint i = 0; i < Values.Size(); i++)
			vals.Push(Values[i]);
	}

	override void SetValues(in out Array<int> vals)
	{
		uint s = Values.Size();
		Values.Clear();

		for (uint i = 0; i < s; i++)
			Values.Push(vals[i]);
	}

	int AverageValue() const
	{
		return BIO_Utils.IntArraySum(Values) / Values.Size();
	}

	override string ToString(BIO_DamageFunctor def) const
	{
		let myDefs = BIO_DmgFunc_RandomPick(def);
		string crEsc = "";

		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(AverageValue(), myDefs.AverageValue());
		else
			crEsc = CRESC_STATMODIFIED;

		string ret = StringTable.Localize("$BIO_DMGFUNC_RANDOMPICK") .. crEsc;

		for (uint i = 0; i < Values.Size() - 1; i++)
		{
			ret.AppendFormat("%d, ", Values[i]);
		}

		if (Values.Size() > 1)
			ret.AppendFormat("\c[MidGrey]%s %s",
				StringTable.Localize("$BIO_OR"), crEsc);
		
		ret.AppendFormat("%d\c[MidGrey])", Values[Values.Size() - 1]);
		return ret;
	}
}

class BIO_DmgFunc_Single : BIO_DamageFunctor
{
	protected int Value;

	override int Invoke() const { return Value; }

	override int MinOutput() const { return Value; }
	override int MaxOutput() const { return Value; }

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

class BIO_DmgFunc_Noop : BIO_DamageFunctor
{
	override int Invoke() const { return 0; }
	override int MinOutput() const { return 0; }
	override int MaxOutput() const { return 0; }
	
	override string ToString(BIO_DamageFunctor def) const
	{
		return StringTable.Localize("$BIO_DMGFUNC_NOOP");
	}
}
