class biom_WeightedRandomTableEntry
{
	class<Object> type;
	/// May be null.
	biom_WeightedRandomTable subtable;
	uint weight;
}

/// Simple running-sum weighted random class picker with nesting support.
class biom_WeightedRandomTable
{
	string label;
	protected array<biom_WeightedRandomTableEntry> entries;
	protected uint weightSum;

	virtual protected uint RandomImpl() const
	{
		return Random(1, self.weightSum);
	}

	void Push(class<Object> type, uint weight)
	{
		if (type == null)
		{
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Tried to push `null` onto WeightedRandomTable `%s`.",
				self.label.Length() > 0 ? self.label : String.Format("%p", self)
			);

			return;
		}

		if (weight <= 0)
		{
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Tried to push a weight of 0 onto WeightedRandomTable `%s` (%s).",
				self.label.Length() > 0 ? self.label : String.Format("%p", self),
				type.GetClassName()
			);

			return;
		}

		uint end = self.entries.Push(new('biom_WeightedRandomTableEntry'));
		self.entries[end].type = type;
		self.entries[end].weight = weight;
		self.weightSum += weight;
	}

	biom_WeightedRandomTable EmplaceLayer(uint weight)
	{
		if (weight <= 0)
		{
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Tried to add a layer with a weight of 0 onto WeightedRandomTable `%s`.",
				self.label.Length() > 0 ? self.label : String.Format("%p", self)
			);

			return null;
		}

		uint end = self.entries.Push(new('biom_WeightedRandomTableEntry'));
		self.entries[end].subTable = biom_WeightedRandomTable(new(GetClass()));
		self.entries[end].weight = weight;
		self.weightSum += weight;
		return self.entries[end].subTable;
	}

	void PushLayer(biom_WeightedRandomTable wrt, uint weight)
	{
		if (wrt == self)
		{
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Attempted to nest WeightedRandomTable `%s` within itself.",
				self.label.Length() > 0 ? self.label : String.Format("%p", self)
			);

			return;
		}

		if (weight <= 0)
		{
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Tried to push a layer with a weight of 0 onto WeightedRandomTable `%s`.",
				self.label.Length() > 0 ? self.label : String.Format("%p", self)
			);

			return;
		}

		uint end  = self.entries.Push(new('biom_WeightedRandomTableEntry'));
		self.entries[end].subTable = wrt;
		self.entries[end].weight = weight;
		self.weightSum += weight;
	}

	class<Object> Result() const
	{
		if (self.entries.Size() < 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_ERR ..
				"Tried to get a result from an empty WeightedRandomTable (`%s`).",
				self.label.Length() > 0 ? self.label : String.Format("%p", self)
			);

			return null;
		}

		uint iters = 0;

		while (iters < 10000)
		{
			uint chance = RandomImpl();
			uint runningSum = 0, choice = 0;

			for (uint i = 0; i < self.entries.Size(); i++)
			{
				runningSum += self.entries[i].weight;

				if (chance <= runningSum)
				{
					if (self.entries[i].subTable != null)
						return self.entries[i].subTable.Result();
					else
						return self.entries[i].type;
				}

				choice++;
			}

			iters++;
		}

		Console.PrintF(
			Biomorph.LOGPFX_ERR ..
			"Failed to make a weighted random choice after 10000 tries (`%s`).",
			self.label.Length() > 0 ? self.label : String.Format("%p", self)
		);

		return null;
	}

	void FromArray(
		in out array<class<Object> > arr, in out array<uint> weights
	)
	{
		if (arr.Size() != weights.Size())
		{
			Console.PrintF(Biomorph.LOGPFX_ERR ..
				"WeightedRandomTable::FromArray() received unequal-sized "
				"parallel arrays.");
			return;
		}

		for (uint i = 0; i < arr.Size(); i++)
			Push(arr[i], weights[i]);
	}

	void RemoveByType(class<Object> type)
	{
		for (uint i = self.entries.Size() - 1; i >= 0; i--)
		{
			if (self.entries[i].subTable != null)
				self.entries[i].subTable.RemoveByType(type);

			if (self.entries[i].type == type)
			{
				self.weightSum -= self.entries[i].weight;
				self.entries.Delete(i);
			}
		}
	}

	void Clear()
	{
		self.entries.Clear();
		self.weightSum = 0;
	}

	uint Size() const
	{
		uint ret = 0;

		for (uint i = 0; i < self.entries.Size(); i++)
		{
			if (self.entries[i].subTable != null)
				ret += self.entries[i].subTable.Size();
			else
				ret++;
		}

		return ret;
	}

	string ToString() const { return ToStringImpl(0); }

	private string ToStringImpl(uint depth) const
	{
		string ret = String.Format(
			"Contents of WeightedRandomTable `%s`:\n",
			self.label.Length() > 0 ? self.label : String.Format("%p", self)
		);

		string prefix = "\t";

		for (uint i = 0; i < depth; i++)
			prefix = prefix .. "\t";

		for (uint i = 0; i < self.entries.Size(); i++)
		{
			if (self.entries[i].subTable != null)
			{
				ret.AppendFormat(self.entries[i].subTable.ToStringImpl(depth + 1));
			}
			else
			{
				ret.AppendFormat(
					prefix .. "\t%s: %d\n",
					self.entries[i].type.GetClassName(), self.entries[i].weight
				);
			}
		}

		ret.DeleteLastCharacter();
		return ret;
	}
}
