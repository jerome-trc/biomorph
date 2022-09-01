class BIO_SGene_NodeMultiEast : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENXB0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_NodeMultiEast';
	}

	States
	{
	Spawn:
		GENX B 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}
}

class BIO_SGene_NodeMultiNorth : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENXA0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_NodeMultiNorth';
	}

	States
	{
	Spawn:
		GENX A 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}
}

class BIO_SGene_NodeMultiSouth : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENXC0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_NodeMultiSouth';
	}

	States
	{
	Spawn:
		GENX C 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}
}

class BIO_SGene_NodeMultiWest : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENXD0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_NodeMultiWest';
	}

	States
	{
	Spawn:
		GENX D 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}
}
