// Symbols common to weapons and equippables like armour.

// Used as a measure of the quality of the gear item at a baseline.
enum BIO_Grade : uint8
{
	BIO_GRADE_NONE,
	BIO_GRADE_SURPLUS, // Unused placeholder
	BIO_GRADE_STANDARD,
	BIO_GRADE_SPECIALTY,
	BIO_GRADE_EXPERIMENTAL,
	BIO_GRADE_CLASSIFIED // Unused placeholder
}

// Used to differentiate between a gear item with no affixes, a gear item
// with randomly-generated affixes, and a gear item with unique affixes.
enum BIO_Rarity : uint8
{
	BIO_RARITY_NONE,
	BIO_RARITY_COMMON,
	BIO_RARITY_MUTATED,
	BIO_RARITY_UNIQUE
}

mixin class BIO_Gear
{
	const CRESC_STATUNMODIFIED = "\cj"; // White
	const CRESC_STATMODIFIED = "\cn"; // Light blue

	meta BIO_Grade Grade; property Grade: Grade;
	BIO_Rarity Rarity; property Rarity: Rarity;

	// GetTag() only comes with color escape codes after BeginPlay(); use this
	// when derefencing defaults. Always comes with a '\c-' at the end.
	string GetColoredTag() const
	{
		return String.Format("%s%s\c-",
			BIO_Utils.FontColorToEscapeCode(
				BIO_Utils.RarityFontColor(Rarity)),
			GetTag());
	}
}
