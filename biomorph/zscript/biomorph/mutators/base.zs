/// Mutators can affect the player's own stats (e.g. powerup duration), what
/// weapons the player has in a given slot, or the weapons themselves.
class biom_Mutator abstract
{
	abstract bool Eligible(readonly<biom_Player> pawn) const;
	abstract biom_MutatorCategory Category(readonly<biom_Player> pawn) const;
	abstract void Apply(biom_Player pawn) const;

	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Tag() const;
	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Summary() const;
	/// Output can be null.
	abstract textureID Icon() const;
}

/// Are the effects of this mutator beneficial to the player,
/// slightly detrimental, or neither?
enum biom_MutatorCategory : uint8
{
	/// This mutator is (mildly) detrimental to the player or their arsenal,
	/// but committing to it biases future mutators towards being upgrades.
	BIOM_MUTCAT_DOWNGRADE,
	/// This mutator changes the player or their arsenal without significantly
	/// improving it or worsening it.
	BIOM_MUTCAT_SIDEGRADE,
	/// This mutator improves the player or their arsenal.
	BIOM_MUTCAT_UPGRADE,
}
