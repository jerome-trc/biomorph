enum BIO_Grade : uint8
{
	BIO_GRADE_NONE,
	BIO_GRADE_STANDARD,
	BIO_GRADE_SPECIALTY,
	BIO_GRADE_EXPERIMENTAL,
	BIO_GRADE_CLASSIFIED
}

mixin class BIO_Gear
{
	const CRESC_STATUNMODIFIED = "\cj"; // White
	const CRESC_STATMODIFIED = "\cn"; // Light blue

	meta BIO_Grade Grade; property Grade: Grade;

	// GetTag() only comes with color escape codes after BeginPlay(); use this
	// when derefencing defaults. Always comes with a '\c-' at the end.
	string GetColoredTag() const
	{
		return String.Format("%s%s\c-",
			BIO_Utils.FontColorToEscapeCode(BIO_Utils.GradeFontColor(Grade)),
			GetTag());
	}
}
