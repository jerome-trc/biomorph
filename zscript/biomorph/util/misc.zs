class BIO_Utils abstract
{
	enum TranslucencyStyle : int
	{
		TRANSLUCENCY_NORMAL = 0,
		TRANSLUCENCY_ADDITIVE = 1,
		TRANSLUCENCY_FUZZ = 2
	}

	static play void GivePowerup(Actor target, Class<Powerup> type, int tics)
	{
		let giver = BIO_PowerupGiver(Actor.Spawn('BIO_PowerupGiver', target.Pos));
	
		if (giver == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Failed to grant powerup %s to %s.",
				target.GetClassName(), type.GetClassName());
			return;
		}

		giver.PowerupType = type;
		giver.EffectTics = tics;
		giver.AttachToOwner(target);
		giver.Use(false);
		target.TakeInventory('BIO_PowerupGiver', 1);
	}

	// Only effective on single words.
	static string Capitalize(string input)
	{
		return input.Left(1).MakeUpper() .. input.Mid(1);
	}

	// The first return value is the actual maximum.
	// The second is the first element in the array to be the maximum.
	static int, uint IntArrayMax(Array<int> arr)
	{
		uint idx = arr.Size(), max = int.MIN;
		
		for (uint i = 0; i < arr.Size(); i++)
		{
			if (arr[i] > max)
			{
				idx = i;
				max = arr[i];
			}
		}

		return max, idx;
	}

	// The first return value is the actual minimum.
	// The second is the first element in the array to be the minimum.
	static int, uint IntArrayMin(Array<int> arr)
	{
		uint idx = arr.Size(), min = int.MAX;

		for (uint i = 0; i < arr.Size(); i++)
		{
			if (arr[i] < min)
			{
				idx = i;
				min = arr[i];
			}
		}

		return min, idx;
	}

	static int IntArraySum(Array<int> arr)
	{
		int ret = 0;

		for (uint i = 0; i < arr.Size(); i++)
			ret += arr[i];

		return ret;
	}

	static string GradeToString(BIO_Grade grade)
	{
		switch (grade)
		{
		case BIO_GRADE_SURPLUS:
			return StringTable.Localize("$BIO_GRADE_SURPLUS");
		case BIO_GRADE_STANDARD:
			return StringTable.Localize("$BIO_GRADE_STANDARD");
		case BIO_GRADE_SPECIALTY:
			return StringTable.Localize("$BIO_GRADE_SPECIALTY");
		case BIO_GRADE_CLASSIFIED:
			return StringTable.Localize("$BIO_GRADE_CLASSIFIED");
		case BIO_GRADE_NONE:
		default:
			return StringTable.Localize("$BIO_NONE");
		}
	}

	static string PickupVerb(BIO_Grade grade)
	{
		switch (grade)
		{
		default:
			return StringTable.Localize("$BIO_PKUP_STANDARD");
		case BIO_GRADE_SPECIALTY:
			return StringTable.Localize("$BIO_PKUP_SPECIALTY");
		case BIO_GRADE_CLASSIFIED:
			return StringTable.Localize("$BIO_PKUP_CLASSIFIED");
		}
	}

	static string RarityToString(BIO_Rarity rarity)
	{
		switch (rarity)
		{
		case BIO_RARITY_COMMON:
			return StringTable.Localize("$BIO_RARITY_COMMON");
		case BIO_RARITY_MUTATED:
			return StringTable.Localize("$BIO_RARITY_MUTATED");
		case BIO_RARITY_UNIQUE:
			return StringTable.Localize("$BIO_RARITY_UNIQUE");
		case BIO_RARITY_NONE:
		default:
			return StringTable.Localize("$BIO_NONE");
		}
	}

	static string PrimaryKeyName(int key1, int key2 = 0)
	{
		string str = Bindings.NameKeys(key1, key2);
		Array<string> arr;
		str.Split(arr, ", ");

		if (arr.Size() < 1)
			return "";
		else
			return arr[0];
	}

	static string, string KeyNames(int key1, int key2)
	{
		string str = Bindings.NameKeys(key1, key2);
		Array<string> arr;
		str.Split(arr, ", ");

		if (arr.Size() == 0)
			return "", "";
		else if (arr.Size() == 1)
			return arr[0], "";
		else
			return arr[0], arr[1];
	}

	static double SquaredDistance(Vector2 a, Vector2 b)
	{
		return ((a.X - b.X) ** 2) + ((a.Y - b.Y) ** 2); 
	}
}

class BIO_PermanentInventory : Inventory abstract
{
	Default
	{
		Inventory.Icon 'TNT1A0';
		Inventory.InterHubAmount 1;
		Inventory.MaxAmount 1;
		Inventory.PickupMessage
			"If you're seeing this message, things might break.";

		-COUNTITEM
		+INVENTORY.KEEPDEPLETED
		+INVENTORY.PERSISTENTPOWER
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Loop;
	}
}

class BIO_FakePuff : BIO_Puff
{
	Default
	{
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOTIMEFREEZE
		+NOTONAUTOMAP
		
		Height 6.0;
		Radius 6.0;
	}

    States
    {
    Spawn:
	    TNT1 AA 1;
        Stop;
    }
}

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

// Symbolic constants which pretend to be a part of certain gzdoom.pk3 enums
// (zscript/constants.zs), for better clarity what arguments really mean. 

const BFGF_NONE = 0; // EBFGSprayFlags
const CPF_NONE = 0; // ECustomPunchFlags
const FBF_NONE = 0; // EFireBulletsFlags
const LAF_NONE = 0; // ELineAttackFlags
const RGF_NONE = 0; // ERailFlags
const TRF_NONE = 0; // ELineTraceFlags
const XF_NONE = 0; // EExplodeFlags
