enum BIO_StateTimeGroupFlags : uint8
{
	BIO_STGF_NONE = 0,
	// If set, this STG isn't shown to the user anywhere.
	BIO_STGF_HIDDEN = 1 << 0,
	// Changes how a fire-time group is presented to the user
	// ("attack time" rather than "fire time").
	BIO_STGF_MELEE = 1 << 1,
	// This state time group isn't involved in the core action itself.
	// e.g., a fire time group is for spool up/down but not the actual fire cycle,
	// or a reload time group is for recharging instead of actual reloading.
	BIO_STGF_AUXILIARY = 1 << 1,
}

class BIO_StateTimeGroup
{
	BIO_StateTimeGroupFlags Flags;
	string Tag;
	Array<uint8> Times, Minimums;

	uint TotalTime() const
	{
		uint ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Times[i];

		return ret;
	}

	// Used for checking if fire/reload time modifications are possible,
	// and the allowances on any reductions made. Returns a positive number.
	uint PossibleReduction() const
	{
		uint ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Max(Times[i] - Minimums[i], 0);

		return ret;
	}

	uint MinTotalTime() const
	{
		uint ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Minimums[i];

		return ret;
	}

	bool IsHidden() const { return Flags & BIO_STGF_HIDDEN; }
	bool IsAuxiliary() const { return Flags & BIO_STGF_AUXILIARY; }

	void Modify(int modifier)
	{
		if (modifier == 0)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal time modifier of 0 given to state time group %s.",
				Tag
			);
			return;
		}

		let pr = PossibleReduction();
		uint e = Abs(modifier);

		for (uint i = 0; i < e; i++)
		{
			if (pr <= 0)
				break;

			uint idx = 0, minOrMax = 0;

			if (modifier > 0)
			{
				[minOrMax, idx] = BIO_Utils.Uint8ArrayMin(Times);
				pr++;
			}
			else
			{
				[minOrMax, idx] = BIO_Utils.Uint8ArrayMax(Times);
				pr--;
			}

			Times[idx] = modifier > 0 ? Times[idx] + 1 : Times[idx] - 1;
		}
	}

	void SetTotalTime(uint newTotal)
	{
		Modify(-(int(TotalTime()) - int(newTotal)));
	}

	void SetToMinTotalTime()
	{
		for (uint i = 0; i < Times.Size(); i++)
			Times[i] = Minimums[i];
	}

	private void Populate(state base)
	{
		Array<state> done;

		for (state s = base; s.InStateSequence(base); s = s.NextState)
		{
			if (done.Find(s) != done.Size())
				return; // Infinite loop protection

			if (s.Tics == 0)
				continue; // `TNT1 A 0` and the like

			done.Push(s);
			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set  
			// to 0, effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			// States marked `Slow` are kept immutable
			else if (s.bSlow)
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	private void RangePopulate(state from, state to)
	{
		for (state s = from; s.InStateSequence(from); s = s.NextState)
		{
			if (s.DistanceTo(to) <= 0)
				return;

			if (s.Tics == 0)
				continue; // `TNT1 A 0` and the like

			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set  
			// to 0, effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			// States marked `Slow` are kept immutable
			else if (s.bSlow)
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	string GetTagAsQualifier(string parenthClr = "\c[White]") const
	{
		if (Tag.Length() < 1)
			return "";
		else
			return String.Format("%s(\c[Yellow]%s%s)",
				parenthClr, StringTable.Localize(Tag), parenthClr);
	}

	BIO_StateTimeGroup Copy() const
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Flags = Flags;
		ret.Tag = Tag;
		ret.Times.Copy(Times);
		ret.Minimums.Copy(Minimums);
		return ret;
	}

	// Add the tic times from all states in a contiguous sequence from `basis`
	// to this group. Beware that this will skip labels, and treats
	// `Goto MyState; MyState:` as contiguous.
	static BIO_StateTimeGroup FromState(
		state basis,
		string tag = "",
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Flags = flags;
		ret.Populate(basis);

		if (ret.Times.Size() < 1)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A state time group was populated with no states."
			);
		}

		return ret;
	}

	// Same as `FromState()`, but stops adding times upon arriving at `end`.
	static BIO_StateTimeGroup FromStateRange(
		state start,
		state end,
		string tag = "",
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Flags = flags;
		ret.RangePopulate(start, end);
		
		if (ret.Times.Size() < 1)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A state time group was populated with no states."
			);
		}
		
		return ret;
	}

	static BIO_StateTimeGroup FromStates(
		Array<state> stateptrs,
		string tag = "",
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Flags = flags;

		for (uint i = 0; i < stateptrs.Size(); i++)
			ret.Populate(stateptrs[i]);

		if (ret.Times.Size() < 1)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A state time group was populated with no states."
			);
		}

		return ret;
	}

	// Note that the return value will always have `BIO_STGF_AUXILIARY` set.
	static BIO_StateTimeGroup RechargeTime(
		uint tics,
		uint minimum = 1,
		string tag = "",
		BIO_StateTimeGroupFlags flags = BIO_STGF_NONE
	)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Flags = flags | BIO_STGF_AUXILIARY;
		ret.Times.Push(tics);
		ret.Minimums.Push(minimum);
		return ret;
	}
}
