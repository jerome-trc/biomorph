extend class BIOM_Utils
{
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
}
