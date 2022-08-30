class BIO_CVar abstract
{
	static int AutoReloadPre(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_autoreload_pre", pInfo).GetInt();
	}

	static int AutoReloadPost(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_autoreload_post", pInfo).GetInt();
	}

	static int BerserkSwitch(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_berserkswitch", pInfo).GetInt();
	}

	static bool MultiBarrelPrimary(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_multibarrelfire", pInfo)
			.GetInt() == BIO_CV_MBF_PRIM;
	}

	static bool MultiReloadAuto(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_multireload", pInfo)
			.GetInt() == BIO_CV_MRM_AUTORELOAD;
	}

	static bool InvClear_Always(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_invclear", pInfo).GetInt() == BIO_CV_INVCLEAR_PERMIT;
	}

	static bool InvClear_IfScheduled(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_invclear", pInfo).GetInt() != BIO_CV_INVCLEAR_RESTRICT;
	}

	static bool InvClear_Never(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_invclear", pInfo).GetInt() == BIO_CV_INVCLEAR_RESTRICT;
	}

	static int ResetInterval_Ammo(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_reset_ammo", pInfo).GetInt();
	}

	static int ResetInterval_Armor(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_reset_armor", pInfo).GetInt();
	}

	static int ResetInterval_Health(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_reset_health", pInfo).GetInt();
	}

	static int ResetInterval_Weapons(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_reset_weaps", pInfo).GetInt();
	}

	static bool StayZoomedAfterReload(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_postreloadzoom", pInfo).GetBool();
	}
}

enum BIO_CVar_AutoReload : int
{
	BIO_CV_AUTOREL_ALWAYS = 0,
	BIO_CV_AUTOREL_SINGLE = 1,
	BIO_CV_AUTOREL_NEVER = 2
}

enum BIO_CVar_BerserkSwitch : int
{
	BIO_CV_BSKS_NO = 0,
	BIO_CV_BSKS_MELEE = 1,
	BIO_CV_BSKS_ONLYFIRST = 2
}

enum BIO_CVar_InvClear : int
{
	BIO_CV_INVCLEAR_PERMIT = 0,
	BIO_CV_INVCLEAR_SCHEDULED = 1,
	BIO_CV_INVCLEAR_RESTRICT = 2,
}

enum BIO_CVar_LegenDoomLite : int
{
	BIO_CV_LDL_NONE = 0,
	BIO_CV_LDL_GENE = 1,
	BIO_CV_LDL_WEAP = 2
}

// For double-/quad-barreled shotguns and similar, does primary fire multiple
// barrels while secondary fires one, or vice versa? Default is 0, the former.
enum BIO_CVar_MultiBarrelFire : int
{
	BIO_CV_MBF_PRIM = 0,
	BIO_CV_MBF_SEC = 1
}

enum BIO_CVar_MultiReload : int
{
	BIO_CV_MRM_AUTORELOAD = 0,
	BIO_CV_MRM_HOLD = 1
}
