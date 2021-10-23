// In case a class needs to interact with a type which may or not be loaded.
mixin class BIO_ExternalTypeFunctions
{
	Inventory FindInv_Ext(string typeName)
	{
		Class<Inventory> t = typeName;
		if (t == null) return null;
		return self.FindInventory(t);
	}

	void GiveInv_Ext(string typeName, int amt, bool giveCheat = false)
	{
		Class<Inventory> t = typeName;
		if (t == null) return;
		self.GiveInventory(t, 1);
	}

	action void A_GiveInv_Ext(
		string typeName, int amt = 0, EPointerFlags giveTo = AAPTR_DEFAULT)
	{
		Class<Inventory> t = typeName;
		if (t == null) return;
		A_GiveInventory(t, amt, giveTo);
	}

	action bool, Actor A_SpawnEx_Ext(string typeName,
		double xofs = 0.0, double yofs = 0.0, double zofs = 0.0,
		double xvel = 0.0, double yvel = 0.0, double zvel = 0.0,
		double angle = 0.0, int flags = 0, int failchance = 0, int tid = 0)
	{
		Class<Actor> t = typeName;
		if (t == null) return false, null;

		bool ret0 = false;
		Actor ret1 = null;

		[ret0, ret1] = A_SpawnItemEx(
			t, xofs, yofs, zofs, xvel, yvel, zvel, angle, flags, failchance, tid);
		return ret0, ret1;
	}

	action state A_JumpIfInventory_Ext(string typeName, int amt,
		statelabel label,int owner = AAPTR_DEFAULT)
	{
		Class<Inventory> t = typeName;
		if (t == null) return null;
		return CheckInventory(t, amt, owner) ? ResolveState(label) : null;
	}
}

class BIO_Utils abstract
{
	enum TranslucencyStyle : int
	{
		TRANSLUCENCY_NORMAL = 0,
		TRANSLUCENCY_ADDITIVE = 1,
		TRANSLUCENCY_FUZZ = 2
	}

	// The first return value is the first element in the array to be the max.
	// The second is the actual max.
	static uint, int IntArrayMax(Array<int> arr)
	{
		uint idx = arr.Size(), max = -2147483647;
		for (uint i = 0; i < arr.Size(); i++)
		{
			if (arr[i] > max)
			{
				idx = i;
				max = arr[i];
			}
		}
		return idx, max;
	}

	// The first return value is the first element in the array to be the min.
	// The second is the actual min.
	static uint, int IntArrayMin(Array<int> arr)
	{
		uint idx = arr.Size(), min = 2147483647;
		for (uint i = 0; i < arr.Size(); i++)
		{
			if (arr[i] < min)
			{
				idx = i;
				min = arr[i];
			}
		}
		return idx, min;
	}

	static string GradeToString(BIO_Grade grade)
	{
		switch (grade)
		{
		case BIO_GRADE_STANDARD:
			return StringTable.Localize("$BIO_GRADE_STANDARD");
		case BIO_GRADE_SPECIALTY:
			return StringTable.Localize("$BIO_GRADE_SPECIALTY");
		case BIO_GRADE_EXPERIMENTAL:
			return StringTable.Localize("$BIO_GRADE_EXPERIMENTAL");
		case BIO_GRADE_CLASSIFIED:
			return StringTable.Localize("$BIO_GRADE_CLASSIFIED");
		case BIO_GRADE_NONE:
		default:
			return StringTable.Localize("$BIO_NONE");
		}
	}

	static int GradeFontColor(BIO_Grade grade)
	{
		switch (grade)
		{
		default:
		case BIO_GRADE_NONE:
		case BIO_GRADE_STANDARD: return Font.CR_WHITE;
		case BIO_GRADE_SPECIALTY: return Font.CR_GREEN;
		case BIO_GRADE_EXPERIMENTAL: return Font.CR_CYAN;
		case BIO_GRADE_CLASSIFIED: return Font.CR_ORANGE;
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

	// Returns true if Zhs2's Intelligent Supplies has been loaded.
	static bool IntelligentSupplies()
	{
		string zhs2IS_name = "Zhs2_IS_BaseItem";
		Class<Actor> zhs2IS = zhs2IS_name;
		return zhs2IS != null;
	}

	// Also checks for ThriftyStimpack.
	static bool IsStimpack(Class<Inventory> inv)
	{
		string thriftyStimName = "ThriftyStimpack";
		Class<Inventory> thriftyStim = thriftyStimName;
		return inv is "Stimpack" || inv is thriftyStim;
	}

	// Also checks for ThriftyMedikit.
	static bool IsMedikit(Class<Inventory> inv)
	{
		string thriftyMediName = "ThriftyMedikit";
		Class<Inventory> thriftyMedi = thriftyMediName;
		return inv is "Medikit" || inv is thriftyMedi;
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

	static play void TouchlessGive(Actor holder, Class<Inventory> type, int amt = 1)
	{
		let existing = holder.FindInventory(type);
		
		if (existing != null)
		{
			existing.Amount += amt;
			return;
		}

		let newItem = Inventory(Actor.Spawn(type));
		newItem.Amount = amt;
		newItem.AttachToOwner(holder);
	}
}
