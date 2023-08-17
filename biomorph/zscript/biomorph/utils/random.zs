/// Simple running-sum weighted random table.
/// Returns an generic index to allow re-use with a collection of the user's choice.
class biom_WeightedRandom
{
	private array<uint> weights;
	private uint weightSum;

	/// Marked as `virtual` to allow using a specific RNG table.
	virtual protected uint RandomImpl() const
	{
		return Random(1, self.weightSum);
	}

	void Add(uint weight)
	{
		self.weights.Push(weight);
		self.weightSum += 1;
	}

	uint Result() const
	{
		uint attempts = 0;

		while (attempts < 100)
		{
			uint chance = self.RandomImpl();
			uint runningSum = 0, choice = 0;

			for (uint i = 0; i < self.weights.Size(); i++)
			{
				runningSum += self.weights[i];

				if (chance <= runningSum)
					return i;

				choice += 1;
			}

			attempts += 1;
		}

		Console.PrintF(
			Biomorph.LOGPFX_ERR ..
			"Failed to make a weighted random choice after 100 attempts."
		);

		return uint.MAX;
	}
}
