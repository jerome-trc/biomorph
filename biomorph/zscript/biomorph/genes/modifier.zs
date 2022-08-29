class BIO_MGene_BerserkDamage : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_BERSERKDAMAGE_TAG";
		Inventory.Icon 'GENDB0';
		Inventory.PickupMessage "$BIO_MGENE_BERSERKDAMAGE_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ModifierGene.ModType 'BIO_WMod_BerserkDamage';
	}

	States
	{
	Spawn:
		GEND B 6;
		#### # 6 Bright Light("BIO_MutaGene_Red");
		Loop;
	}
}

class BIO_MGene_CanisterShot : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_CANISTERSHOT_TAG";
		Inventory.Icon 'GENNC0';
		Inventory.PickupMessage "$BIO_MGENE_CANISTERSHOT_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_CanisterShot';
	}

	States
	{
	Spawn:
		GENN C 6;
		#### # 6 Bright Light("BIO_MutaGene_Cyan");
		Loop;
	}
}

class BIO_MGene_DamageAdd : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_DAMAGEADD_TAG";
		Inventory.Icon '';
		Inventory.PickupMessage "$BIO_MGENE_DAMAGEADD_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYRARE;
		BIO_ModifierGene.ModType 'BIO_WMod_DamageAdd';
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

class BIO_MGene_FireTime : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_FIRETIME_TAG";
		Inventory.Icon 'GENTA0';
		Inventory.PickupMessage "$BIO_MGENE_FIRETIME_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON + LOOTWEIGHT_MIN;
		BIO_ModifierGene.ModType 'BIO_WMod_FireTime';
	}

	States
	{
	Spawn:
		GENT A 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
		Loop;
	}
}

class BIO_MGene_ForcePain : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_FORCEPAIN_TAG";
		Inventory.Icon 'GENPA0';
		Inventory.PickupMessage "$BIO_MGENE_FORCEPAIN_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ModifierGene.ModType 'BIO_WMod_ForcePain';
	}

	States
	{
	Spawn:
		GENP A 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_ForceRadiusDmg : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_FORCERADIUSDMG_TAG";
		Inventory.Icon 'GENPB0';
		Inventory.PickupMessage "$BIO_MGENE_FORCERADIUSDMG_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_ForceRadiusDmg';
	}

	States
	{
	Spawn:
		GENP B 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_Kickback : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_KICKBACK_TAG";
		Inventory.Icon 'GENMC0';
		Inventory.PickupMessage "$BIO_MGENE_KICKBACK_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_Kickback';
	}

	States
	{
	Spawn:
		GENM C 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_Lifesteal : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_LIFESTEAL_TAG";
		Inventory.Icon 'GENEA0';
		Inventory.PickupMessage "$BIO_MGENE_LIFESTEAL_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_Lifesteal';
	}

	States
	{
	Spawn:
		GENE A 6;
		#### # 6 Bright Light("BIO_MutaGene_Red");
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

class BIO_MGene_MagSizeToDamage : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_MAGSIZETODAMAGE_TAG";
		Inventory.Icon 'GENDE0';
		Inventory.PickupMessage "$BIO_MGENE_MAGSIZETODAMAGE_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_MagSizeToDamage';
	}

	States
	{
	Spawn:
		GEND E 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_NthRoundCost : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_NTHROUNDCOST_TAG";
		Inventory.Icon 'GENAE0';
		Inventory.PickupMessage "$BIO_MGENE_NTHROUNDCOST_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_NthRoundCost';
	}

	States
	{
	Spawn:
		GENA E 6;
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
		BIO_Gene.LootWeight LOOTWEIGHT_MIN;
		BIO_ModifierGene.ModType 'BIO_WMod_InfiniteAmmo';
	}

	States
	{
	Spawn:
		GENA D 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_ProjGravity : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_PROJGRAVITY_TAG";
		Inventory.Icon 'GENPC0';
		Inventory.PickupMessage "$BIO_MGENE_PROJGRAVITY_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_ProjGravity';
	}

	States
	{
	Spawn:
		GENP C 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_ProxMine : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_PROXMINE_TAG";
		Inventory.Icon 'GENNB0';
		Inventory.PickupMessage "$BIO_MGENE_PROXMINE_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_ProxMine';
	}

	States
	{
	Spawn:
		GENN B 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_RechamberUp : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_RECHAMBERUP_TAG";
		Inventory.Icon 'GENDD0';
		Inventory.PickupMessage "$BIO_MGENE_RECHAMBERUP_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_RechamberUp';
	}

	States
	{
	Spawn:
		GEND D 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
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
		BIO_Gene.LootWeight LOOTWEIGHT_VERYRARE;
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

class BIO_MGene_ReloadTime : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_RELOADTIME_TAG";
		Inventory.Icon 'GENTB0';
		Inventory.PickupMessage "$BIO_MGENE_RELOADTIME_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_ReloadTime';
	}

	States
	{
	Spawn:
		GENT B 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
		Loop;
	}
}

class BIO_MGene_ShellToSlug : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SHELLTOSLUG_TAG";
		Inventory.Icon 'GENNA0';
		Inventory.PickupMessage "$BIO_MGENE_SHELLTOSLUG_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_ShellToSlug';
	}

	States
	{
	Spawn:
		GENN A 6;
		#### # 6 Bright Light("BIO_MutaGene_Cyan");
		Loop;
	}
}

class BIO_MGene_SmartAim : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SMARTAIM_TAG";
		Inventory.Icon 'GENMF0';
		Inventory.PickupMessage "$BIO_MGENE_SMARTAIM_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ModifierGene.ModType 'BIO_WMod_SmartAim';
	}

	States
	{
	Spawn:
		GENM F 6;
		#### # 6 Bright Light("BIO_MutaGene_Purple");
		Loop;
	}
}

class BIO_MGene_SplashToHit : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SPLASHTOHIT_TAG";
		Inventory.Icon 'GENDC0';
		Inventory.PickupMessage "$BIO_MGENE_SPLASHTOHIT_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_SplashToHit';
	}

	States
	{
	Spawn:
		GEND C 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_Spooling : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SPOOLING_TAG";
		Inventory.Icon 'GENTC0';
		Inventory.PickupMessage "$BIO_MGENE_SPOOLING_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_Spooling';
	}

	States
	{
	Spawn:
		GENT C 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
		Loop;
	}
}

class BIO_MGene_Spread : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SPREAD_TAG";
		Inventory.Icon 'GENMA0';
		Inventory.PickupMessage "$BIO_MGENE_SPREAD_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_Spread';
	}

	States
	{
	Spawn:
		GENM A 6;
		#### # 6 Bright Light("BIO_MutaGene_LightBlue");
		Loop;
	}
}

class BIO_MGene_SpreadNarrow : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SPREADNARROW_TAG";
		Inventory.Icon 'GENMD0';
		Inventory.PickupMessage "$BIO_MGENE_SPREADNARROW_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_SpreadNarrow';
	}

	States
	{
	Spawn:
		GENM D 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_SpreadWiden : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SPREADWIDEN_TAG";
		Inventory.Icon 'GENME0';
		Inventory.PickupMessage "$BIO_MGENE_SPREADWIDEN_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_SpreadWiden';
	}

	States
	{
	Spawn:
		GENM E 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_SwitchSpeed : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_SWITCHSPEED_TAG";
		Inventory.Icon 'GENMB0';
		Inventory.PickupMessage "$BIO_MGENE_SWITCHSPEED_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ModifierGene.ModType 'BIO_WMod_SwitchSpeed';
	}

	States
	{
	Spawn:
		GENM B 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}
