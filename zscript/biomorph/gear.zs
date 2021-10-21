enum BIO_Grade : uint8
{
	BIO_GRADE_NONE,
	BIO_GRADE_STANDARD,
	BIO_GRADE_ADVANCED,
	BIO_GRADE_SPECIALTY,
	BIO_GRADE_EXPERIMENTAL,
	BIO_GRADE_CLASSIFIED
}

mixin class BIO_Gear
{
	const FONTCR_STATUNMODIFIED = "\cj"; // White
	const FONTCR_STATMODIFIED = "\cn"; // Light blue

	meta BIO_Grade Grade; property Grade: Grade;
	Array<BIO_Affix> Affixes;
}
