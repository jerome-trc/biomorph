extend class BIO_Utils
{
	static string Capitalize(string input)
	{
		return input.Left(1).MakeUpper() .. input.Mid(1);
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

	// Output is fully localized.
	static string PayloadTag(class<Actor> payload, uint count)
	{
		if (payload is 'BIO_Projectile')
		{
			let defs = GetDefaultByType((class<BIO_Projectile>)(payload));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (payload is 'BIO_FastProjectile')
		{
			let defs = GetDefaultByType((class<BIO_FastProjectile>)(payload));
		
			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (payload is 'BIO_RailPuff')
		{
			let defs = GetDefaultByType((class<BIO_RailPuff>)(payload));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (payload is 'BIO_RailSpawn')
		{
			let defs = GetDefaultByType((class<BIO_RailSpawn>)(payload));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (payload is 'BIO_Puff')
		{
			let defs = GetDefaultByType((class<BIO_Puff>)(payload));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (payload is 'BIO_BFGExtra')
		{
			switch (count)
			{
			case -1:
			case 1: return StringTable.Localize("$BIO_PROJEXTRA_TAG_BFGRAY");
			default: return StringTable.Localize("$BIO_PROJEXTRA_TAG_BFGRAYS"); 
			}
		}
		else if (payload == null)
			return StringTable.Localize("$BIO_NOTHING");
		else
			return StringTable.Localize(GetDefaultByType(payload).GetTag());
	}
}
