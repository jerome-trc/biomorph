class BIO_WeightedRandomTableEntry
{
	Class<Actor> Type;
	BIO_WeightedRandomTable Subtable;
	uint Weight;
}

// Simple running-sum weighted random Actor class picker with nesting support.
class BIO_WeightedRandomTable
{
	string Label;
	private Array<BIO_WeightedRandomTableEntry> Entries;
	private uint WeightSum;

	void Push(Class<Actor> type, uint weight)
	{
		if (type == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to push `null` onto WeightedRandomTable `%s`.",
				Label.Length() > 0 ? Label : String.Format("%p", self));
			return;
		}

		if (weight <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to push a weight of 0 onto WeightedRandomTable `%s` (%s).",
				Label.Length() > 0 ? Label : String.Format("%p", self),
				type.GetClassName());
			return;
		}

		uint end = Entries.Push(new('BIO_WeightedRandomTableEntry'));
		Entries[end].Type = type;
		Entries[end].Weight = weight;
		WeightSum += weight;
	}

	BIO_WeightedRandomTable EmplaceLayer(uint weight)
	{
		if (weight <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to add a layer with a weight of 0 onto WeightedRandomTable `%s`.",
				Label.Length() > 0 ? Label : String.Format("%p", self));
			return null;
		}
		
		uint end = Entries.Push(new('BIO_WeightedRandomTableEntry'));
		Entries[end].SubTable = new('BIO_WeightedRandomTable');
		Entries[end].Weight = weight;
		WeightSum += weight;
		return Entries[end].SubTable;
	}

	void PushLayer(BIO_WeightedRandomTable wrt, uint weight)
	{
		if (wrt == self)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to nest WeightedRandomTable `%s` within itself.",
				Label.Length() > 0 ? Label : String.Format("%p", self));
			return;
		}

		if (weight <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to push a layer with a weight of 0 onto WeightedRandomTable `%s`.",
				Label.Length() > 0 ? Label : String.Format("%p", self));
			return;
		}

		uint end  = Entries.Push(new('BIO_WeightedRandomTableEntry'));
		Entries[end].SubTable = wrt;
		Entries[end].Weight = weight;
		WeightSUm += weight;
	}

	Class<Actor> Result() const
	{
		if (Entries.Size() < 1)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to get a result from an empty WeightedRandomTable (`%s`).",
				Label.Length() > 0 ? Label : String.Format("%p", self));
			return null;
		}

		Class<Actor> ret = null;
		uint iters = 0;

		while (ret == null && iters < 10000)
		{
			readOnly<uint> chance = Random[BIO_WRT](1, WeightSum);
			uint runningSum = 0, choice = 0;

			for (uint i = 0; i < Entries.Size(); i++)
			{
				runningSum += Entries[i].Weight;
				if (chance <= runningSum) 
				{
					if (Entries[i].SubTable != null)
						return Entries[i].SubTable.Result();
					else
						return Entries[i].Type;
				}
				choice++;
			}

			iters++;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Failed to make a weighted random choice after 10000 tries (`%s`).",
			Label.Length() > 0 ? Label : String.Format("%p", self));
		return null;
	}

	void RemoveByType(Class<Actor> type)
	{
		for (uint i = Entries.Size() - 1; i >= 0; i--)
		{
			if (Entries[i].SubTable != null)
				Entries[i].SubTable.RemoveByType(type);
			
			if (Entries[i].Type == type)
				Entries.Delete(i);
		}
	}

	void Clear()
	{
		Entries.Clear();
		WeightSum = 0;
	}

	uint Size() const
	{
		uint ret = 0;

		for (uint i = 0; i < Entries.Size(); i++)
		{
			if (Entries[i].SubTable != null)
				ret += Entries[i].SubTable.Size();
			else
				ret++;
		}

		return ret;
	}

	void Print() const { PrintImpl(); }

	private void PrintImpl(uint depth = 0)
	{
		string lbl = Label.Length() > 0 ? Label : String.Format("%p", self);

		if (Entries.Size() < 1)
		{
			Console.Printf(Biomorph.LOGPFX_INFO ..
				"WeightedRandomTable `%s` is empty.", lbl);
			return;
		}
			
		Console.Printf(Biomorph.LOGPFX_INFO .. String.Format(
			"Contents of WeightedRandomTable `%s`:", lbl));

		string prefix = "\t";

		for (uint i = 0; i < depth; i++)
			prefix = prefix .. "\t";

		for (uint i = 0; i < Entries.Size(); i++)
		{
			if (Entries[i].SubTable != null)
				Entries[i].SubTable.PrintImpl(depth + 1);
			else
				Console.Printf(prefix .. "%s: %d",
					Entries[i].Type.GetClassName(), Entries[i].Weight);
		}
	}
}
