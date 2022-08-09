class BIO_NamedKey
{
	int ScanCode_0, ScanCode_1;
	string KeyName;

	static BIO_NamedKey Create(string cmd)
	{
		let ret = new('BIO_NamedKey');

		[ret.ScanCode_0, ret.ScanCode_1] = Bindings.GetKeysForCommand(cmd);
		
		Array<string> parts;
		ret.KeyName = Bindings.GetBinding(ret.ScanCode_0);
		Bindings.NameKeys(ret.ScanCode_0, ret.ScanCode_1).Split(parts, ", ");

		if (parts.Size() == 0)
			ret.KeyName = StringTable.Localize("$BIO_UNASSIGNED_KEY");
		else if (parts.Size() == 1)
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			ret.KeyName = "\cn" .. parts[0] .. "\c-";
		}
		else
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			parts[1].Replace("\cm", "");
			parts[1].Replace("\c-", "");
			ret.KeyName = String.Format("\cn%s\c-/\cn%s\c-", parts[0], parts[1]);
		}

		return ret;
	}

	void Recolor(string escCode)
	{
		Array<string> parts;
		KeyName = Bindings.GetBinding(ScanCode_0);
		Bindings.NameKeys(ScanCode_0, ScanCode_1).Split(parts, ", ");

		if (parts.Size() == 0)
			KeyName = StringTable.Localize("$BIO_UNASSIGNED_KEY");
		else if (parts.Size() == 1)
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			KeyName = escCode .. parts[0] .. "\c-";
		}
		else
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			parts[1].Replace("\cm", "");
			parts[1].Replace("\c-", "");
			KeyName = String.Format("%s%s\c-/\%s%s\c-",
				escCode, parts[0], escCode, parts[1]);
		}
	}
	
	bool Matches(int code) const { return code == ScanCode_0 || code == ScanCode_1; }
}
