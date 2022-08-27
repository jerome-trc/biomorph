// Weapon loot tables.

extend class BIO_Global
{
	private BIO_LootTable WeaponLoot[__BIO_WSCAT_COUNT__];
	// Contains all tables in `WeaponLoot`.
	private BIO_LootTable WeaponLootMeta;

	private void PopulateWeaponLootTables()
	{
		for (uint i = 0; i < __BIO_WSCAT_COUNT__; i++)
		{
			WeaponLoot[i] = new('BIO_LootTable');

			switch (i)
			{
			case BIO_WSCAT_SHOTGUN:
				WeaponLoot[i].Label = "Weapon loot: Shotgun";
				break;
			case BIO_WSCAT_CHAINGUN:
				WeaponLoot[i].Label = "Weapon loot: Chaingun";
				break;
			case BIO_WSCAT_SSG:
				WeaponLoot[i].Label = "Weapon loot: Super Shotgun";
				break;
			case BIO_WSCAT_RLAUNCHER:
				WeaponLoot[i].Label = "Weapon loot: Rocket Launcher";
				break;
			case BIO_WSCAT_PLASRIFLE:
				WeaponLoot[i].Label = "Weapon loot: Plasma Rifle";
				break;
			case BIO_WSCAT_BFG9000:
				WeaponLoot[i].Label = "Weapon loot: BFG9000";
				break;
			case BIO_WSCAT_CHAINSAW:
				WeaponLoot[i].Label = "Weapon loot: Chainsaw";
				break;
			case BIO_WSCAT_PISTOL:
				WeaponLoot[i].Label = "Weapon loot: Pistol";
				break;
			default:
				Console.Printf(Biomorph.LOGPFX_ERR ..
					"Invalid weapon spawn category detected: %d", i);
				break;
			}
		}

		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let weap_t = (class<BIO_Weapon>)(AllActorClasses[i]);

			if (weap_t == null || weap_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(weap_t);

			if (defs.SpawnCategory == __BIO_WSCAT_COUNT__)
				continue;

			WeaponLoot[defs.SpawnCategory].Push(weap_t,
				defs.Unique ? 1 : 50				
			);
		}

		WeaponLootMeta = new('BIO_LootTable');
		WeaponLootMeta.Label = "Weapon loot: meta";

		for (uint i = 0; i < __BIO_WSCAT_COUNT__; i++)
		{
			uint weight = 0;

			switch (i)
			{
			default:
				Console.Printf(
					Biomorph.LOGPFX_ERR ..
					"Unhandled weapon spawn category: %d", i
				);
				break;
			case BIO_WSCAT_SHOTGUN:
			case BIO_WSCAT_CHAINGUN:
				weight = 18;
				break;
			case BIO_WSCAT_PISTOL:
			case BIO_WSCAT_SSG:
			case BIO_WSCAT_CHAINSAW:
				weight = 8;
				break;
			case BIO_WSCAT_RLAUNCHER:
				weight = 6;
				break;
			case BIO_WSCAT_PLASRIFLE:
				weight = 5;
				break;
			case BIO_WSCAT_BFG9000:
				weight = 1;
				break;
			}

			WeaponLootMeta.PushLayer(WeaponLoot[i], weight);
		}
	}

	class<BIO_Weapon> LootWeaponType(BIO_WeaponSpawnCategory category) const
	{
		return (class<BIO_Weapon>)(WeaponLoot[category].Result());
	}

	class<BIO_Weapon> AnyLootWeaponType() const
	{
		return (class<BIO_Weapon>)(WeaponLootMeta.Result());
	}
}
