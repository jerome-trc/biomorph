/// Functions for easily dealing with actor types which may not exist.
extend class BIO_Utils
{
	static class<Inventory> ExtInv(name tName)
	{
		class<Inventory> ret = tName;
		return ret;
	}

	static Inventory TryFindInv(Actor a, name tName)
	{
		class<Inventory> t = tName;
		if (t == null) return null;
		return a.FindInventory(t);
	}

	static play void TryGiveInv(Actor a, name tName, int amt, bool giveCheat = false)
	{
		class<Inventory> t = tName;
		if (t == null) return;
		a.GiveInventory(t, 1, giveCheat);
	}

	static play bool TryA_GiveInv(Actor a, name tName, int amount = 0,
		int giveTo = AAPTR_DEFAULT)
	{
		class<Inventory> t = tName;
		if (t == null) return false;
		return Actor.DoGiveInventory(a, false, t, amount, giveTo);
	}

	static play bool, Actor TrySpawnEx(
		Actor source, name typeName,
		double xofs = 0.0, double yofs = 0.0, double zofs = 0.0,
		double xvel = 0.0, double yvel = 0.0, double zvel = 0.0,
		double angle = 0.0, int flags = 0, int failchance = 0, int tid = 0
	)
	{
		class<Actor> t = typeName;
		if (t == null) return false, null;

		bool ret0 = false;
		Actor ret1 = null;

		[ret0, ret1] = source.A_SpawnItemEx(
			t, xofs, yofs, zofs, xvel, yvel, zvel, angle, flags, failchance, tid
		);

		return ret0, ret1;
	}

	static play bool TryCheckInv(Actor a, name typeName, int amt,
		statelabel label, int owner = AAPTR_DEFAULT)
	{
		class<Inventory> t = typeName;
		if (t == null) return null;
		return a.CheckInventory(t, amt, owner);
	}

	static play int TryCountInv(Actor a, name typeName, int ptr_select = AAPTR_DEFAULT)
	{
		class<Inventory> t = typeName;
		if (t == null) return 0;
		return a.CountInv(t, ptr_select);
	}

	static play bool IsLegendary(Actor monster)
	{
		return BIO_Utils.TryFindInv(monster, 'LDLegendaryMonsterToken') != null;
	}
}

/// Functions for checking which level set is being played.
extend class BIO_Utils
{
	static bool Lexicon()
	{
		name lxvg_tn = 'Lexicon_VoteGun';
		class<Weapon> lxvg_t = lxvg_tn;
		return lxvg_t != null;
	}

	/// Checks if the player is in a level from Valiant, its Vaccinated Edition,
	/// or the Valiant levels bundled with the Sentinel's Lexicon.
	static bool Valiant()
	{
		static const string VALIANT_CHECKSUMS[] = {
			"ae1162f07cc8007433e391865ebfb6ee",
			"51e995f290c6de343ab6ac49aa8b6e07",
			"dce5a618c79720c17dbbd59cfd2aa714",
			"3b9ce476c10e1394b1d956a1c7d03a9f",
			"7f3ad07a459b184f2bc4d584664c8052",
			"3d3f0b43de546417ca3732df41c5df92",
			"5592e023c40b80062a87a8ff07e118f4",
			"64145988c49af65ae216c56352ff1d0a",
			"3dfadef6a080838a3733299f15212e07",
			"4e95ebed00dd83e4c677f8c80e334c0b",
			"9eabdc8fa72a816c9bd5a326f8d23f51",
			"55d50ac622a68fb1cc91dec17252b415",
			"dc76b23c73a66e4dec556c8dfcc01ffe",
			"fc393258b414fc26129d4b6fc7fbe539",
			"45927fb1b547c3494ae54ff7d9672f3b",
			"f400fc2ae45ee31a85386b5da9e7d37e",
			"650eb014337845ce831e7f95fbae992c",
			"73173e499231ec9b8ec14be080fa6854",
			"32f3e114d16490e920f9d049bbf04f9b",
			"de281679869aa0b49389f8dfc0e1ded2",
			"3067dd58e12c8a0db64eca709efbb6a1",
			"ff79364affc1c2163fa64b2b1cb21391",
			"4822c3907bc1f2839132b677274958e6",
			"8a08c436ebbbd9ed4bbe4d7e58fab42e",
			"3fbc4f5fa0589a19e37578ce77c7db31",
			"ea08f34fa394be693379b11fd0cc3b62",
			"b83fbaf88d08a71ecc4f7cf8fd29119a",
			"a0aa482fc7225d1c8b331e4b09e3f2d3",
			"2912919c8c12d0849b48352eb5c202a1",
			"a06f7e651c53025ceac91aff61b1695a",
			"7bdbf7185ec069f35b70b3a56be0b204",
			"2cd06346f8678637f82beaa8c749fb8f"
		};

		static const string VALVE_CHECKSUMS[] = {
			"ef1f9c78fd1018594aa2b4d079b5a891",
			"51e995f290c6de343ab6ac49aa8b6e07",
			"dce5a618c79720c17dbbd59cfd2aa714",
			"7bfdfb4c562c31e4143c5bd28bff253a",
			"68db0a695c5e0029df95ae9b17e6f408",
			"be86aff70163fe6064d0f61f5dfc1c7b",
			"fd332e22812a10fdcf438a2ae9847ae2",
			"33a53ac5cc75c4f26b652ccb33e18c1a",
			"4425441fc7c02d7d6edc7652bb7f031c",
			"13ce78b29f74465f4fd0bce91db6b259",
			"12de28bd6babe168b896890885fb280b",
			"8a08a36a6fb835dc100b8ef8cf874c7a",
			"c5a7fbc20e1affdef55761ffe3b3e7b6",
			"019553247ddc770cf44a1e4c41d1148e",
			"9cd1729f064107fe15a19da6970cd345",
			"cc8cf9498a05bbd3b51b58660efc311e",
			"8810c4683d12dbe04461d4de2427ee75",
			"e4eaa1c784272d128257dd42bf99107c",
			"4d3067326f1c0e96b93df2cf3b6f3b40",
			"7b2ed6ad4f7b0a0a8bf6773f566edb7d",
			"be87a2e974eea657c41dca16bab9ae22",
			"b5dd76bf9d4ccbb68d1b24f92d5cacfb",
			"3cb7a0a534826190587b301bec3a609b",
			"80f53a8c8e749e7ce815e4e2cc5b6743",
			"4ae0c6d4f91456e551831259657fbf10",
			"f7517cc809572e91f4685dc4ec4ccb67",
			"841178b954b1d0ed2a4fc1966b319744",
			"b8efefe6264c9d5e6ad900467502652a",
			"767e6f3157b5639110c6c662e0fcea6a",
			"4abb65f0f6898a59adf9e7ea1b8a2f55",
			"d41ad237c6ff17960879c57c4b617148",
			"de20cc70e92364af30c07e45ab36ae7e"
		};

		static const string LEXVAL_CHECKSUMS[] = {
			"f70a1d88ced4ccab042348c868172702",
			"4c5e7dda87e4a7640d4a7ad7b07ebd42",
			"46617669cf68efe89d3729a4dc8eb703",
			"71735bd35fab3302d4280d602bc66411",
			"c0ae8eee98e9e82d43fea81baac24228",
			"a49e632d67a1f79fde122a4d9aca15a3",
			"5f102bafcaf1a0e31a3917411a04cb40",
			"8a5498283c6693e7a18f52e0cbcb3b7a",
			"8609b07ce240c208618ba1216e974360",
			"f4db5acbfc3ac29fb9ba1457d1306899",
			"a05323a8ed3b1c28590f1847a1013c3b",
			"95dae32b8926c022f5b8b320d3817d57",
			"858df36062606e17bfa820f91f2c72f0",
			"2f9c9cbc7749a710337e58fb7f559d83",
			"dc8f9459c080c05b5d7970de5668c9a2",
			"47e2ede893a20f839da396374eb27319",
			"888797e8a6aa7f2ca7ff37679c41683b",
			"3b236e1d5c5c36aac8534dd0ada5f2e7",
			"e55e3f9a32cab7c7b59ba8bc9949f081",
			"326a8947748c19ed88a2a60c2177be2c",
			"1fe289f103b07ee7a48a2d92353f1f69",
			"afdbdc168aafc09e9386b6b1caa091bb",
			"2423330a5a9ea1fa605e77ea5fd38f86",
			"02e5e4af8794095de2263513afc1e36a",
			"883c1ea3d62c3044a5c2257279af1f3c",
			"981b32603ae78056e90cdf2bc727549c",
			"6f2706a473001b75632f6b473b9c2976",
			"c484c1204085295c8c424fba0150cea7",
			"cd21c202d11d2210e5551c54e051dcb2",
			"7701151e5fca01a3f7052d54fcba9379",
			"3bc61fa1f2278350634804749b276c2b",
			"c7f68b5da014f08df8635baaf3b922cc"
		};

		string checksum = Level.GetChecksum();

		for (uint i = 0; i < 32; i++)
		{
			if (checksum ~== VALIANT_CHECKSUMS[i] ||
				checksum ~== VALVE_CHECKSUMS[i] ||
				checksum ~== LEXVAL_CHECKSUMS[i])
				return true;
		}

		return false;
	}

	static bool Eviternity()
	{
		static const string EVITERNITY_CHECKSUMS[] = {
			"9831c412420f16fa0de000fd1dbfe901",
			"beecc27d3c8c07a83968a687a2dde6e5",
			"baee63d6a50b6aed95e854ad492209dd",
			"5797ac4531c129c5948130665e31542d",
			"33b8501b10ce5e2555c03725f765a914",
			"60d62607aff6dc8a05ea02e5615a8152",
			"f819e7885813a1383f12bb49644bb412",
			"8dd9f9f5d29d18d0d4b902a8c30dddd7",
			"142fd784ed7258f7485aace4fd2d6b2a",
			"9e83602d325677b8d7c3bc44bef9b03f",
			"565e9732fd5a8f232e8fd9042328ce6a",
			"449b980d0c12aa691eff320eafff228f",
			"2fb41f5372ce5516cca2f117af1d3391",
			"e02845a2b5a296a34910345df2729d74",
			"ca40e6ddab6b5c924cdc36b1f851421e",
			"9cee502cca6550a06dedd7881aa427d5",
			"f1e331e5f4f5783bef5e8ac2346b45e1",
			"63101445e0ccc310a06ecf47f585a20b",
			"4b213789c03829eca0138ffe103e5a19",
			"f34b3fd4d13ac763469a8e0d7379b9d0",
			"0dacfa8721965f394181be83bebe7951",
			"6b53e2052580cb5d9cba8f27b9552f66",
			"551c4fd48490c1f2a69b0bbfdfeb576e",
			"f0ee83a9cb1d1c708bfda339c40b79a8",
			"196bc735473c593f924a59b238574c35",
			"380e0b6fd8baec2125e145e5c0f40af9",
			"a9650e9b73e9f7589885ef7d440987ce",
			"ded749a5a2059dbfbf4e647937b4dc43",
			"9d4b3a1426486c5fe8ae5736366e098f",
			"5c5e5c08af3572f31cf27318679f2b4e",
			"39820d2fa2045a526dcdecdfd99126ef",
			"c1f312482636da54c2657bd2a2c3d59f"
		};

		string checksum = Level.GetChecksum();

		for (uint i = 0; i < 32; i++)
			if (checksum ~== EVITERNITY_CHECKSUMS[i])
				return true;

		return false;
	}
}
