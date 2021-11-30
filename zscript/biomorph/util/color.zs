extend class BIO_Utils
{
	static string GradeColorEscapeCode(BIO_Grade grade)
	{
		switch (grade)
		{
		case BIO_GRADE_SURPLUS: return "\c[Surp]";
		case BIO_GRADE_SPECIALTY: return "\c[Spec]";
		case BIO_GRADE_CLASSIFIED: return "\c[Clsf]";
		default: return "\c[White]";
		}
	}

	static string RarityColorEscapeCode(BIO_Rarity rarity)
	{
		switch (rarity)
		{
		default:
		case BIO_RARITY_COMMON: return "\c[White]";
		case BIO_RARITY_MUTATED: return "\c[Cyan]";
		case BIO_RARITY_UNIQUE: return "\c[Orange]";
		}
	}

	static int RarityFontColor(BIO_Rarity rarity)
	{
		switch (rarity)
		{
		default:
		case BIO_GRADE_NONE:
		case BIO_RARITY_COMMON: return Font.CR_WHITE;
		case BIO_RARITY_MUTATED: return Font.CR_CYAN;
		case BIO_RARITY_UNIQUE: return Font.CR_ORANGE;
		}
	}

	static string FontColorToEscapeCode(int fontColor)
	{
		switch (fontColor)
		{
		default:
		case Font.CR_UNDEFINED:
		case Font.CR_UNTRANSLATED: return "";
		case Font.CR_BRICK: return "\ca";
		case Font.CR_TAN: return "\cb";
		case Font.CR_GRAY: return "\cc";
		case Font.CR_GREEN: return "\cd";
		case Font.CR_BROWN: return "\ce";
		case Font.CR_GOLD: return "\cf";
		case Font.CR_RED: return "\cg";
		case Font.CR_BLUE: return "\ch";
		case Font.CR_ORANGE: return "\ci";
		case Font.CR_WHITE: return "\cj";
		case Font.CR_YELLOW: return "\ck";
		case Font.CR_BLACK: return "\cm";
		case Font.CR_LIGHTBLUE: return "\cn";
		case Font.CR_CREAM: return "\co";
		case Font.CR_OLIVE: return "\cp";
		case Font.CR_DARKGREEN: return "\cq";
		case Font.CR_DARKRED: return "\cr";
		case Font.CR_DARKBROWN: return "\cs";
		case Font.CR_PURPLE: return "\ct";
		case Font.CR_DARKGRAY: return "\cu";
		case Font.CR_CYAN: return "\cv";
		case Font.CR_ICE: return "\cw";
		case Font.CR_FIRE: return "\cx";
		case Font.CR_SAPPHIRE: return "\cy";
		case Font.CR_TEAL: return "\cz";
		}
	}

	// `fallback` gets passed to `StringTable.Localize()`.
	static string RankString(uint rank, string fallback = "")
	{
		switch (rank)
		{
		case 0: return StringTable.Localize("$BIO_PRIMARY");
		case 1: return StringTable.Localize("$BIO_SECONDARY");
		case 2: return StringTable.Localize("$BIO_TERTIARY");
		case 3: return StringTable.Localize("$BIO_QUATERNARY");
		default:
			return String.Format("%s%d", StringTable.Localize(fallback), rank);
		}
	}

	// Return green if `stat1` is greater than `stat2`, red if it's less, and
	// white if they're equal. `invert` reverses the check.
	static string StatFontColor(int stat1, int stat2, bool invert = false)
	{
		if (!invert)
		{
			if (stat1 > stat2)
				return CRESC_STATBETTER;
			else if (stat1 < stat2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (stat1 < stat2)
				return CRESC_STATBETTER;
			else if (stat1 > stat2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
	}

	static string StatFontColorF(float stat1, float stat2, bool invert = false)
	{
		if (!invert)
		{
			if (stat1 ~== stat2)
				return CRESC_STATDEFAULT;
			else if (stat1 > stat2)
				return CRESC_STATBETTER;
			else if (stat1 < stat2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
		else
		{
			if (stat1 ~== stat2)
				return CRESC_STATDEFAULT;
			else if (stat1 < stat2)
				return CRESC_STATBETTER;
			else if (stat1 > stat2)
				return CRESC_STATWORSE;
			else
				return CRESC_STATDEFAULT;
		}
	}
}
