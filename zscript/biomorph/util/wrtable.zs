class WeightedRandomTableEntry
{
	Class<Actor> Type;
	WeightedRandomTable Subtable;
	uint Weight;
}

// Simple running-sum weighted random Actor class picker with nesting support.
class WeightedRandomTable
{
	private Array<WeightedRandomTableEntry> Entries;
	private uint WeightSum;

	void Push(Class<Actor> type, uint weight)
	{
		if (type == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to push `null` onto a WeightedRandomTable.");
			return;
		}

		if (weight <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to push a weight of 0 onto a WeightedRandomTable (%s).",
				type.GetClassName());
			return;
		}

		uint end = Entries.Push(new('WeightedRandomTableEntry'));
		Entries[end].Type = type;
		Entries[end].Weight = weight;
		WeightSum += weight;
	}

	WeightedRandomTable AddLayer(uint weight)
	{
		if (weight <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to add a layer with a weight of 0 onto a WeightedRandomTable.");
			return null;
		}
		
		uint end = Entries.Push(new('WeightedRandomTableEntry'));
		Entries[end].SubTable = new('WeightedRandomTable');
		Entries[end].Weight = weight;
		WeightSum += weight;
		return Entries[end].SubTable;
	}

	void PushLayer(WeightedRandomTable wrt, uint weight)
	{
		if (wrt == self)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Attempted to nest a WeightedRandomTable within itself.");
			return;
		}

		if (weight <= 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to push a layer with a weight of 0 onto a WeightedRandomTable.");
			return;
		}

		uint end  = Entries.Push(new('WeightedRandomTableEntry'));
		Entries[end].SubTable = wrt;
		Entries[end].Weight = weight;
		WeightSUm += weight;
	}

	Class<Actor> Result() const
	{
		if (Entries.Size() < 1)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to get a result from an empty WeightedRandomTable.");
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
			"Failed to make a weighted random choice after 10000 tries.");
		return null;
	}		

	void Clear()
	{
		Entries.Clear();
		WeightSum = 0;
	}

	void Print(uint depth = 0) const
	{
		if (Entries.Size() < 1)
		{
			Console.Printf(Biomorph.LOGPFX_INFO .. "WeightedRandomTable is empty.");
			return;
		}

		string prefix = "";

		for (uint i = 0; i < depth; i++)
			prefix = prefix .. "\t";

		for (uint i = 0; i < Entries.Size(); i++)
		{
			if (Entries[i].SubTable != null)
				Entries[i].SubTable.Print(depth + 1);
			else
				Console.Printf(Biomorph.LOGPFX_INFO .. prefix .. "%s: %d",
					Entries[i].Type.GetClassName(), Entries[i].Weight);
		}
	}
}
