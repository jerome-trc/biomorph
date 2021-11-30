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
		uint idx = arr.Size(), max = int.MIN;
		
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
		uint idx = arr.Size(), min = int.MAX;

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

	static string RarityToString(BIO_Rarity rarity)
	{
		switch (rarity)
		{
		case BIO_RARITY_COMMON:
			return StringTable.Localize("$BIO_GRADE_SURPLUS");
		case BIO_RARITY_MUTATED:
			return StringTable.Localize("$BIO_GRADE_STANDARD");
		case BIO_RARITY_UNIQUE:
			return StringTable.Localize("$BIO_GRADE_SPECIALTY");
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
}