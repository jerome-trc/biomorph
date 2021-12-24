extend class BIO_Utils
{
	static BIO_JsonBool TryGetJsonBool(BIO_JSonElement elem, bool errMsg = true)
	{
		if (elem == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected bool, got null.");
			return null;
		}

		let ret = BIO_JsonBool(elem);
		if (ret == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Expected bool, got %s.", elem.GetClassName());
			return null;
		}

		return ret;
	}

	static BIO_JsonObject TryGetJsonObject(BIO_JsonElement elem, bool errMsg = true)
	{
		if (elem == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected object, got null.");
			return null;
		}

		let ret = BIO_JsonObject(elem);
		if (ret == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected object, got %s.",
					elem.GetClassName());
			return null;
		}

		return ret;
	}

	static BIO_JsonArray TryGetJsonArray(BIO_JsonElement elem, bool errMsg = true)
	{
		if (elem == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected array, got null.");
			return null;
		}

		let ret = BIO_JsonArray(elem);
		if (ret == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. 
					"Expected array, got %s.", elem.GetClassName());
			return null;
		}

		if (ret.Size() < 1)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Array is empty.");
			return null;
		}

		return ret;
	}

	static string StringFromJson(BIO_JsonElement elem, bool errMsg = true)
	{
		if (elem == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected string, got null.");
			return "";
		}

		let str = BIO_JsonString(elem);
		if (str == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Expected string, got %s.", elem.GetClassName());
			return "";
		}

		return str.s;
	}

	static BIO_JsonInt TryGetJsonInt(BIO_JsonElement elem, bool errMsg = true)
	{
		if (elem == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected int, got null.");
			return null;
		}

		let ret = BIO_JsonInt(elem);
		if (ret == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Expected int, got %s.", elem.GetClassName());
			return null;
		}

		return ret;
	}

	static Class<Object> TryGetJsonClassName(BIO_JsonElement elem, bool errMsg = true)
	{
		if (elem == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR .. "Expected string, got null.");
			return null;
		}

		let str = BIO_JsonString(elem);
		if (str == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Expected string, got %s", elem.GetClassName());
			return null;
		}

		Class<Object> ret = str.s;
		if (ret == null)
		{
			if (errMsg)
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Illegal class identifier: %s", str.s);
			return null;
		}

		return ret;
	}
}
