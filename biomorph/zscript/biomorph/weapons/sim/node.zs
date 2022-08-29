class BIO_WMS_Node play
{
	// This is a reflection of the real state of the weapon's mod graph.
	// Only gets altered when the simulation gets committed, so it and the graph
	// are always in perfect sync.
	BIO_WMGNode Basis;

	uint Multiplier;

	// Null if no gene is being simulated in this node.
	// Acts as a representative for what will end up in `Basis.GeneType`.
	BIO_WMS_Gene Gene;
	bool Valid;
	string Message;

	BIO_WeaponMorphRecipe MorphRecipe;

	// Accessors ///////////////////////////////////////////////////////////////

	bool IsOccupied() const { return Gene != null; }
	bool IsActive() const { return IsOccupied() || Basis.UUID == 0; }
	bool IsMorph() const { return MorphRecipe != null; }

	BIO_WeaponModifier GetModifier() const
	{
		return Gene == null ? null : Gene.Modifier;
	}

	bool HasModifier() const
	{
		if (Gene == null)
			return false;

		return Gene.GetType() is 'BIO_ModifierGene';
	}

	class<BIO_Gene> GetGeneType() const
	{
		return Gene == null ? null : Gene.GetType();
	}

	textureID GetIcon() const
	{
		textureID ret;
		ret.SetNull();

		if (Gene != null)
			ret = GetDefaultByType(Gene.GetType()).Icon;
		else if (MorphRecipe != null)
			ret = GetDefaultByType(MorphRecipe.Output()).Icon;

		return ret;
	}

	bool Repeatable() const
	{
		let mod = GetModifier();

		if (mod == null)
			return false;

		return mod.Limit() > 1;
	}

	bool Repeating() const
	{
		return Repeatable() && Multiplier > 1;
	}

	string GetTag() const
	{
		let gene_t = Gene.GetType();
		let defs = GetDefaultByType(gene_t);
		return defs.GetTag();
	}

	bool HasTooltip() const { return IsOccupied() || IsMorph(); }

	bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		BIO_GeneContext context
	) const
	{
		if (Gene == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Attempted to check compatibility of node %d, which lacks a gene.",
				Basis.UUID
			);
			return false, "";
		}

		let gene_t = Gene.GetType();
		bool ret1 = false;
		string ret2 = "";

		if (gene_t is 'BIO_ModifierGene')
		{
			[ret1, ret2] = Gene.Modifier.Compatible(context);
		}
		else if (gene_t is 'BIO_SupportGene')
		{
			let sgene_t = (class<BIO_SupportGene>)(gene_t);
			let defs = GetDefaultByType(sgene_t);
			[ret1, ret2] = defs.Compatible(context);
		}
		else if (gene_t is 'BIO_ActiveGene')
		{
			let agene_t = (class<BIO_ActiveGene>)(gene_t);
			let defs = GetDefaultByType(agene_t);
			[ret1, ret2] = defs.Compatible(context);
		}
		else
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Attempted to check compatibility of node %d, with illegal gene type %s.",
				Basis.UUID, gene_t.GetClassName()
			);
			return false, "";
		}

		return ret1, ret2;
	}

	// Mutators ////////////////////////////////////////////////////////////////

	void Update()
	{
		if (Gene != null)
			Gene.UpdateModifier();
	}

	string Apply(
		BIO_Weapon weap, BIO_WeaponModSimulator sim,
		in out BIO_GeneContext context
	) const
	{
		if (Gene == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Attempted to apply node %d, which lacks a gene.",
				Basis.UUID
			);
			return "";
		}

		string ret = "";
		let gene_t = Gene.GetType();

		if (gene_t is 'BIO_ModifierGene')
		{
			let mod = Gene.Modifier;
			ret = mod.Apply(weap, context);
		}
		else if (gene_t is 'BIO_SupportGene')
		{
			let sgene_t = (class<BIO_SupportGene>)(gene_t);
			let defs = GetDefaultByType(sgene_t);
			ret = defs.Apply(context);
		}
		else if (gene_t is 'BIO_ActiveGene')
		{
			let agene_t = (class<BIO_ActiveGene>)(gene_t);
			let defs = GetDefaultByType(agene_t);
			ret = defs.Apply(weap, sim, context);
		}

		return ret;
	}
}
