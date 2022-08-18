class BIO_DamageBaseFunctor abstract
{
	// Return, in order, the actual damage,
	// the minimum potential damage, and the maximum potential damage.
	abstract int, int, int Invoke() const;
	abstract string Description(BIO_DamageBaseFunctor def) const;
	abstract BIO_DamageBaseFunctor Copy() const;

	readOnly<BIO_DamageBaseFunctor> AsConst() const { return self; }
}

// Emits a random number between a minimum and a maximum.
class BIO_DmgBase_Range : BIO_DamageBaseFunctor
{
	int Minimum, Maximum;

	override int, int, int Invoke() const
	{
		return Random(Minimum, Maximum), Minimum, Maximum;
	}

	override string Description(BIO_DamageBaseFunctor def) const
	{
		let myDefs = BIO_DmgBase_Range(def);
		string crEsc_min = "", crEsc_max = "";

		if (myDefs != null)
		{
			crEsc_min = BIO_Utils.StatFontColor(Minimum, myDefs.Minimum);
			crEsc_max = BIO_Utils.StatFontColor(Maximum, myDefs.Maximum);
		}
		else
		{
			crEsc_min = crEsc_max = Biomorph.CRESC_STATMODIFIED;
		}

		return String.Format(
			StringTable.Localize("$BIO_DMGBASE_RANGE"),
			crEsc_min, Minimum, 
			crEsc_max, Maximum
		);
	}

	override BIO_DamageBaseFunctor Copy() const
	{
		let ret = new('BIO_DmgBase_Range');
		ret.Minimum = Minimum;
		ret.Maximum = Maximum;
		return ret;
	}
}

class BIO_DmgBase_XTimesRand : BIO_DamageBaseFunctor
{
	int Multiplier, MinRandom, MaxRandom;

	override int, int, int Invoke() const
	{
		return
			Multiplier * Random(MinRandom, MaxRandom),
			Multiplier * MinRandom,
			Multiplier * MaxRandom;
	}

	override string Description(BIO_DamageBaseFunctor def) const
	{
		let myDefs = BIO_DmgBase_XTimesRand(def);
		string crEsc_multi = "", crEsc_min = "", crEsc_max = "";

		if (myDefs != null)
		{
			crEsc_multi = BIO_Utils.StatFontColor(Multiplier, myDefs.Multiplier);
			crEsc_min = BIO_Utils.StatFontColor(MinRandom, myDefs.MinRandom);
			crEsc_max = BIO_Utils.StatFontColor(MaxRandom, myDefs.MaxRandom);
		}
		else
		{
			crEsc_multi = crEsc_min = crEsc_max = Biomorph.CRESC_STATMODIFIED;
		}

		return String.Format(
			StringTable.Localize("$BIO_DMGBASE_XTIMESRAND"),
			crEsc_multi, Multiplier,
			crEsc_min, MinRandom,
			crEsc_max, MaxRandom
		);
	}

	override BIO_DamageBaseFunctor Copy() const
	{
		let ret = new('BIO_DmgBase_XTimesRand');
		ret.Multiplier = Multiplier;
		ret.MinRandom = MinRandom;
		ret.MaxRandom = MaxRandom;
		return ret;
	}
}

class BIO_DmgBase_XPlusRand : BIO_DamageBaseFunctor
{
	int Baseline, MinRandom, MaxRandom;

	override int, int, int Invoke() const
	{
		return
			Baseline + Random(MinRandom, MaxRandom),
			Baseline + MinRandom,
			Baseline + MaxRandom;
	}

	override string Description(BIO_DamageBaseFunctor def) const
	{
		let myDefs = BIO_DmgBase_XPlusRand(def);
		string creEsc_base = "", crEsc_min = "", crEsc_max = "";

		if (myDefs != null)
		{
			creEsc_base = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);
			crEsc_min = BIO_Utils.StatFontColor(MinRandom, myDefs.MinRandom);
			crEsc_max = BIO_Utils.StatFontColor(MaxRandom, myDefs.MaxRandom);
		}
		else
		{
			creEsc_base = crEsc_min = crEsc_max = Biomorph.CRESC_STATMODIFIED;
		}

		return String.Format(
			StringTable.Localize("$BIO_DMGBASE_XPLUSRAND"),
			creEsc_base, Baseline,
			crEsc_min, MinRandom,
			crEsc_max, MaxRandom
		);
	}

	override BIO_DamageBaseFunctor Copy() const
	{
		let ret = new('BIO_DmgBase_XPlusRand');
		ret.Baseline = Baseline;
		return ret;
	}
}

class BIO_DmgBase_RandomPick : BIO_DamageBaseFunctor
{
	Array<int> Values;

	override int, int, int Invoke() const
	{
		return
			Values[Random(0, Values.Size() - 1)],
			BIO_Utils.IntArrayMin(Values),
			BIO_Utils.IntArrayMax(Values);
	}

	override string Description(BIO_DamageBaseFunctor def) const
	{
		let myDefs = BIO_DmgBase_RandomPick(def);
		string crEsc = "";

		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(
				BIO_Utils.IntArrayAverage(Values),
				BIO_Utils.IntArrayAverage(myDefs.Values)
			);
		else
			crEsc = Biomorph.CRESC_STATMODIFIED;

		string ret = StringTable.Localize("$BIO_DMGBASE_RANDOMPICK") .. crEsc;

		for (uint i = 0; i < Values.Size() - 1; i++)
		{
			ret.AppendFormat("%d, ", Values[i]);
		}

		if (Values.Size() > 1)
			ret.AppendFormat("\c[MidGrey]%s %s",
				StringTable.Localize("$BIO_OR"), crEsc
			);

		ret.AppendFormat("%d\c[MidGrey])", Values[Values.Size() - 1]);
		return ret;
	}

	override BIO_DamageBaseFunctor Copy() const
	{
		let ret = new('BIO_DmgBase_RandomPick');
		ret.Values.Copy(Values);
		return ret;
	}
}

class BIO_DmgBase_Single : BIO_DamageBaseFunctor
{
	int Value;

	override int, int, int Invoke() const
	{
		return Value, Value, Value;
	}

	override string Description(BIO_DamageBaseFunctor def) const
	{
		let myDefs = BIO_DmgBase_Single(def);
		string crEsc = "";

		if (myDefs != null)
			crEsc = BIO_Utils.StatFontColor(Value, myDefs.Value);
		else
			crEsc = Biomorph.CRESC_STATMODIFIED;

		return String.Format(
			StringTable.Localize("$BIO_DMGBASE_SINGLE"),
			crEsc, Value
		);
	}

	override BIO_DamageBaseFunctor Copy() const
	{
		let ret = new('BIO_DmgBase_Single');
		ret.Value = Value;
		return ret;
	}
}

class BIO_DmgBase_Noop : BIO_DamageBaseFunctor
{
	override int, int, int Invoke() const
	{
		return 0, 0, 0;
	}

	override string Description(BIO_DamageBaseFunctor _) const
	{
		return "$BIO_DMGBASE_NOOP";
	}

	override BIO_DamageBaseFunctor Copy() const
	{
		return new('BIO_DmgBase_Noop');
	}
}
