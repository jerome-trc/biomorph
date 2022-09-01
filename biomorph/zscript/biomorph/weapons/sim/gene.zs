// (Rat): My kingdom for some honest-to-god sum types

class BIO_WMS_Gene play abstract
{
	abstract BIO_GeneData Data() const;
	abstract BIO_GeneData Drain();

	class<BIO_Gene> ActorType() const { return Data().GetActorType(); }
	string Tag() const { return Data().GetTag(); }

	// Returns `true` if a modifier within pushes the host node
	// over that modifier's limit.
	bool IncrementModTypeCounts(
		in out Array<class<BIO_WeaponModifier> > modTypes,
		in out Array<uint> modCounts
	) const
	{
		return Data().IncrementModTypeCounts(modTypes, modCounts);
	}

	string GetSummaryTooltip() const
	{
		return String.Format(
			"\c[White]%s\n\n%s",
			StringTable.Localize(Data().GetTag()),
			StringTable.Localize(Data().Summary())
		);
	}
}

// When representing genes that can be moved around the simulated graph, this
// is used for genes which were in the player's inventory at simulation start.
class BIO_WMS_GeneReal : BIO_WMS_Gene
{
	BIO_Gene Gene;

	final override BIO_GeneData Data() const { return Gene.Inner(); }
	final override BIO_GeneData Drain() { return Gene.Drain(); }
}

// When representing genes that can be moved around the simulated graph, this
// is used for genes which were slotted into the tree at simulation start,
// since those genes have no associated items.
class BIO_WMS_GeneVirtual : BIO_WMS_Gene
{
	BIO_GeneData Gene;

	final override BIO_GeneData Data() const { return Gene; }

	final override BIO_GeneData Drain()
	{
		let ret = Gene;
		Gene = null;
		return ret;
	}
}
