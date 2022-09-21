class BIO_MGene_BerserkDamage : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENDB0';
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ProceduralGene.Modifier 'BIO_WMod_BerserkDamage';
	}

	States
	{
	Spawn:
		GEND B 6;
		#### # 6 Bright Light("BIO_MutaGene_Red");
		Loop;
	}
}

class BIO_MGene_CanisterShot : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENNC0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_CanisterShot';
	}

	States
	{
	Spawn:
		GENN C 6;
		#### # 6 Bright Light("BIO_MutaGene_Cyan");
		Loop;
	}
}

class BIO_MGene_DamageAdd : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon '';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYRARE;
		BIO_ProceduralGene.Modifier 'BIO_WMod_DamageAdd';
	}

	final override bool CanGenerate() const
	{
		// Lacks a sprite
		return false;
	}
}

// LegenDoom(Lite) exclusive. 400% damage to Legendary enemies.
class BIO_MGene_DemonSlayer : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENDA0';
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_DemonSlayer';
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

class BIO_MGene_ETMF : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENAC0';
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ETMF';
	}

	States
	{
	Spawn:
		GENA C 6;
		#### # 6 Bright Light("BIO_MutaGene_Blue");
		Loop;
	}
}

class BIO_MGene_FireTime : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENTA0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON + LOOTWEIGHT_MIN;
		BIO_ProceduralGene.Modifier 'BIO_WMod_FireTime';
	}

	States
	{
	Spawn:
		GENT A 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
		Loop;
	}
}

class BIO_MGene_ForcePain : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENPA0';
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ForcePain';
	}

	States
	{
	Spawn:
		GENP A 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_ForceRadiusDmg : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENPB0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ForceRadiusDmg';
	}

	States
	{
	Spawn:
		GENP B 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_Kickback : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENMC0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_Kickback';
	}

	States
	{
	Spawn:
		GENM C 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_Lifesteal : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENEA0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_Lifesteal';
	}

	States
	{
	Spawn:
		GENE A 6;
		#### # 6 Bright Light("BIO_MutaGene_Red");
		Loop;
	}
}

class BIO_MGene_MagSize : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENAA0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_MagSize';
	}

	States
	{
	Spawn:
		GENA A 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_MagSizeToDamage : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENDE0';
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_MagSizeToDamage';
	}

	States
	{
	Spawn:
		GEND E 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_NthRoundCost : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENAE0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_NthRoundCost';
	}

	States
	{
	Spawn:
		GENA E 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_InfiniteAmmo : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENAD0';
		BIO_Gene.LootWeight LOOTWEIGHT_MIN;
		BIO_ProceduralGene.Modifier 'BIO_WMod_InfiniteAmmo';
	}

	States
	{
	Spawn:
		GENA D 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_ProjGravity : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENPC0';
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ProjGravity';
	}

	States
	{
	Spawn:
		GENP C 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_ProxMine : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENNB0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ProxMine';
	}

	States
	{
	Spawn:
		GENN B 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_RechamberUp : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENDD0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_RechamberUp';
	}

	States
	{
	Spawn:
		GEND D 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_ReserveFeed : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENAB0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYRARE;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ReserveFeed';
	}

	States
	{
	Spawn:
		GENA B 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_ReloadTime : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENTB0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ReloadTime';
	}

	States
	{
	Spawn:
		GENT B 6;
		#### # 6 Bright Light("BIO_MutaGene_Orange");
		Loop;
	}
}

class BIO_MGene_ShellToSlug : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENNA0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ShellToSlug';
	}

	States
	{
	Spawn:
		GENN A 6;
		#### # 6 Bright Light("BIO_MutaGene_Cyan");
		Loop;
	}
}

class BIO_MGene_SmartAim : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENMF0';
		BIO_Gene.LootWeight LOOTWEIGHT_RARE;
		BIO_ProceduralGene.Modifier 'BIO_WMod_SmartAim';
	}

	States
	{
	Spawn:
		GENM F 6;
		#### # 6 Bright Light("BIO_MutaGene_Purple");
		Loop;
	}
}

class BIO_MGene_SplashToHit : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENDC0';
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_SplashToHit';
	}

	States
	{
	Spawn:
		GEND C 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}

class BIO_MGene_Spread : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENMA0';
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_Spread';
	}

	States
	{
	Spawn:
		GENM A 6;
		#### # 6 Bright Light("BIO_MutaGene_LightBlue");
		Loop;
	}
}

class BIO_MGene_SpreadNarrow : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENMD0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_SpreadNarrow';
	}

	States
	{
	Spawn:
		GENM D 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_SpreadWiden : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENME0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_SpreadWiden';
	}

	States
	{
	Spawn:
		GENM E 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_SwitchSpeed : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENMB0';
		BIO_Gene.LootWeight LOOTWEIGHT_VERYCOMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_SwitchSpeed';
	}

	States
	{
	Spawn:
		GENM B 6;
		#### # 6 Bright Light("BIO_MutaGene_White");
		Loop;
	}
}

class BIO_MGene_ToggleConnected : BIO_ProceduralGene
{
	Default
	{
		Inventory.Icon 'GENMG0';
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_ProceduralGene.Modifier 'BIO_WMod_ToggleConnected';
	}

	States
	{
	Spawn:
		GENM G 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}
}
