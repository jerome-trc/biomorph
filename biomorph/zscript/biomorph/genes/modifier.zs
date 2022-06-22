class BIO_MGene_DamageAdd : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_DAMAGEADD_TAG";
		Inventory.Icon '';
		Inventory.PickupMessage "$BIO_MGENE_DAMAGEADD_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYRARE;
		BIO_Gene.Summary "$BIO_WMOD_DAMAGEADD_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_DamageAdd';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_INTERNAL;
	}

	final override bool CanGenerate() const
	{
		// Lacks a sprite
		return false;
	}
}

// LegenDoom(Lite) exclusive. 400% damage to Legendary enemies.
class BIO_MGene_DemonSlayer : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_DEMONSLAYER_TAG";
		Inventory.Icon 'GENDA0';
		Inventory.PickupMessage "$BIO_MGENE_DEMONSLAYER_PKUP";
		BIO_Gene.Summary "$BIO_WMOD_DEMONSLAYER_SUMM";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_DemonSlayer';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_EXTERNAL;
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
		BIO_Gene.Limit 1;
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_Gene.Summary "$BIO_WMOD_ETMF_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_ETMF';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_INTERNAL;
	}

	States
	{
	Spawn:
		GENA C 6;
		#### # 6 Bright Light("BIO_MutaGene_Blue");
		Loop;
	}
}

class BIO_MGene_FireTime : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_FIRETIME_TAG";
		Inventory.Icon 'GENTA0';
		Inventory.PickupMessage "$BIO_MGENE_FIRETIME_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Summary "$BIO_WMOD_FIRETIME_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_FireTime';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_INTERNAL;
	}

	States
	{
	Spawn:
		GENT A 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
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
		BIO_Gene.Summary "$BIO_WMOD_MAGSIZE_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_MagSize';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_EXTERNAL;
	}

	States
	{
	Spawn:
		GENA A 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_InfiniteAmmo : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_INFINITEAMMO_TAG";
		Inventory.Icon 'GENAD0';
		Inventory.PickupMessage "$BIO_MGENE_MAGSIZE_PKUP";
		BIO_Gene.Limit 1;
		BIO_Gene.LootWeight LOOTWEIGHT_VERYRARE;
		BIO_Gene.Summary "$BIO_WMOD_INFINITEAMMO_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_InfiniteAmmo';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_NONE;
	}

	States
	{
	Spawn:
		GENA D 6;
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
		BIO_Gene.Limit 1;
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_Gene.Summary "$BIO_WMOD_RESERVEFEED_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_ReserveFeed';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_NONE;
	}

	States
	{
	Spawn:
		GENA B 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_ReloadTime : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_RELOADTIME_TAG";
		Inventory.Icon 'GENTB0';
		Inventory.PickupMessage "$BIO_MGENE_RELOADTIME_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Summary "$BIO_WMOD_RELOADTIME_SUMM";
		BIO_ModifierGene.ModType 'BIO_WMod_ReloadTime';
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_INTERNAL;
	}

	States
	{
	Spawn:
		GENT B 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
		Loop;
	}
}
