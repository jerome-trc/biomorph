class BIO_WMS_Node play
{
	// This is a reflection of the real state of the weapon's mod graph.
	// Only gets altered when the simulation gets committed,
	// so it and the real graph are always in perfect sync.
	BIO_WMGNode Basis;

	uint Multiplier;

	// Null if no gene is being simulated in this node.
	// Acts as a wrapper, representing what will end up in `Basis.Gene`.
	BIO_WMS_Gene Gene;
	bool Valid;
	string Message;

	BIO_WeaponMorphRecipe MorphRecipe;

	bool IsOccupied() const { return Gene != null; }
	bool IsActive() const { return IsOccupied() || Basis.UUID == 0; }
	bool IsMorph() const { return MorphRecipe != null; }

	textureID GetIcon() const
	{
		textureID ret;
		ret.SetNull();

		if (Gene != null)
			ret = GetDefaultByType(Gene.Data().GetActorType()).Icon;
		else if (MorphRecipe != null)
			ret = GetDefaultByType(MorphRecipe.Output()).Icon;

		return ret;
	}

	bool Repeatable() const
	{
		if (Gene == null)
			return false;

		return Gene.Data().Limit() > 1;
	}

	bool Repeating() const
	{
		return Repeatable() && Multiplier > 1;
	}

	BIO_GeneData GetGeneData() const
	{
		if (Gene == null)
			return null;
		else
			return Gene.Data();
	}

	class<BIO_Gene> GetGeneActorType() const
	{
		if (Gene == null)
			return null;
		else
			return Gene.Data().GetActorType();
	}

	string GetTag() const
	{
		return Gene.Data().GetTag();
	}

	BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags CombinedModifierFlags() const
	{
		if (Gene == null)
			return BIO_WCMF_NONE, BIO_WPMF_NONE;

		return Gene.Data().CombinedModifierFlags();
	}

	uint CountCoreModFlags(
		BIO_WeaponCoreModFlags flags,
		bool ignoreMultiplier = false
	) const
	{
		if (Gene == null)
			return 0;

		let ret = Gene.Data().CountCoreModFlags(flags);

		if (!ignoreMultiplier)
			ret *= Multiplier;

		return ret;
	}

	uint CountPipelineModFlags(
		BIO_WeaponPipelineModFlags flags,
		bool ignoreMultiplier = false
	) const
	{
		if (Gene == null)
			return 0;

		let ret = Gene.Data().CountPipelineModFlags(flags);

		if (!ignoreMultiplier)
			ret *= Multiplier;

		return ret;
	}

	uint CountModifierFlags(
		BIO_WeaponCoreModFlags coreFlags,
		BIO_WeaponPipelineModFlags pipelineFlags,
		bool ignoreMultiplier = true
	) const
	{
		if (Gene == null)
			return 0;

		let ret = Gene.Data().CountModifierFlags(coreFlags, pipelineFlags);

		if (!ignoreMultiplier)
			ret *= Multiplier;

		return ret;
	}

	bool ContainsModifierOfType(class<BIO_WeaponModifier> type) const
	{
		if (Gene == null)
			return false;

		return Gene.Data().ContainsModifierOfType(type);
	}

	bool HasTooltip() const { return IsOccupied() || IsMorph(); }

	void Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		in out BIO_GeneContext context,
		BIO_WeaponModSimPass simPass
	)
	{
		[Valid, Message] = Gene.Data().Apply(weap, sim, context, simPass);
	}

	void Reset()
	{
		Multiplier = 1;
		Valid = true;
		Message = "";
	}
}
