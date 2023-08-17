class biom_palt_MaxHealth : biom_PawnAlterant
{
	final override void Apply(biom_Player pawn) const
	{
		if (pawn.maxHealth == 0)
			pawn.maxHealth = 105;
		else
			pawn.maxHealth += 5;
	}

	final override bool, string Compatible(readonly<biom_Player> _) const
	{
		return true;
	}

	final override int Balance(readonly<biom_Player> _) const
	{
		return BIOM_BALMOD_DEC_XS * 2;
	}

	final override bool Natural() const
	{
		return true;
	}

	final override string Tag() const
	{
		return "$BIOM_ALTER_MAXHEALTH_TAG";
	}

	final override string Summary() const
	{
		return "$BIOM_ALTER_MAXHEALTH_SUMMARY";
	}
}
