class BIO_MGene_DemonSlayer : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_DEMONSLAYER_TAG";
		Inventory.Icon 'GENDA0';
		Inventory.PickupMessage "$BIO_MGENE_DEMONSLAYER_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_DemonSlayer';
	}

	States
	{
	Spawn:
		GEND A 6;
		#### # 6 Bright Light("BIO_MutaGene_Red");
		Loop;
	}

	final override bool CanGenerate() const
	{
		return BIO_Utils.LegenDoom();
	}
}

class BIO_MGene_ETMF : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_ETMF_TAG";
		Inventory.Icon 'GENAC0';
		Inventory.PickupMessage "$BIO_MGENE_ETMF_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ModifierGene.ModType 'BIO_WMod_ETMF';
	}

	States
	{
	Spawn:
		GENA C 6;
		#### # 6 Bright Light("BIO_MutaGene_Blue");
		Loop;
	}
}

class BIO_MGene_MagSize : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_MAGSIZE_TAG";
		Inventory.Icon 'GENAA0';
		Inventory.PickupMessage "$BIO_MGENE_MAGSIZE_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_MagSize';
	}

	States
	{
	Spawn:
		GENA A 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_ReserveFeed : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_RESERVEFEED_TAG";
		Inventory.Icon 'GENAB0';
		Inventory.PickupMessage "$BIO_MGENE_RESERVEFEED_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ModifierGene.ModType 'BIO_WMod_ReserveFeed';
	}

	States
	{
	Spawn:
		GENA B 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}
