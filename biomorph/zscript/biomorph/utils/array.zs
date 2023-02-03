extend class BIOM_Utils
{
	static int IntArraySum(array<int> arr)
	{
		int ret = 0;

		for (uint i = 0; i < arr.Size(); i++)
			ret += arr[i];

		return ret;
	}

	static int IntArrayAverage(array<int> arr)
	{
		int ret = 0;

		for (uint i = 0; i < arr.Size(); i++)
			ret += arr[i];

		return ret / int(arr.Size());
	}

	// The first return value is the actual maximum.
	// The second is the first element in the array to be the maximum.
	static int, uint IntArrayMax(array<int> arr)
	{
		uint idx = arr.Size();
		int max = int.MIN;

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
	static int, uint IntArrayMin(array<int> arr)
	{
		uint idx = arr.Size();
		int min = int.MAX;

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

	// The first return value is the actual maximum.
	// The second is the first element in the array to be the maximum.
	static uint, uint UintArrayMax(array<uint> arr)
	{
		uint idx = arr.Size(), max = uint.MIN;

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
	static uint, uint UintArrayMin(array<uint> arr)
	{
		uint idx = arr.Size(), min = uint.MAX;

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

	// The first return value is the actual maximum.
	// The second is the first element in the array to be the maximum.
	static uint, uint Uint8ArrayMax(array<uint8> arr)
	{
		uint idx = arr.Size(), max = uint8.MIN;

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
	static uint, uint Uint8ArrayMin(array<uint8> arr)
	{
		uint idx = arr.Size(), min = uint8.MAX;

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
}
