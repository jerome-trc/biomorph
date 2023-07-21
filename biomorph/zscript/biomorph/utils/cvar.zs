class biom_CVar abstract
{
	static int AutoReloadPre(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIOM_autoreload_pre", pInfo).GetInt();
	}

	static int AutoReloadPost(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIOM_autoreload_post", pInfo).GetInt();
	}

	static int BerserkSwitch(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIOM_berserkswitch", pInfo).GetInt();
	}

	static bool MultiBarrelPrimary(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIOM_multibarrelfire", pInfo)
			.GetInt() == BIOM_CV_MBF_PRIM;
	}

	static bool MultiReloadAuto(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIOM_multireload", pInfo)
			.GetInt() == BIOM_CV_MRM_AUTORELOAD;
	}

	static bool StayZoomedAfterReload(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIOM_postreloadzoom", pInfo).GetBool();
	}
}

enum biom_cvar_AutoReload : int
{
	BIOM_CV_AUTOREL_ALWAYS = 0,
	BIOM_CV_AUTOREL_SINGLE = 1,
	BIOM_CV_AUTOREL_NEVER = 2
}

enum biom_cvar_BerserkSwitch : int
{
	BIOM_CV_BSKS_NO = 0,
	BIOM_CV_BSKS_MELEE = 1,
	BIOM_CV_BSKS_ONLYFIRST = 2
}

/// For double-/quad-barreled shotguns and similar, does primary fire multiple
/// barrels while secondary fires one, or vice versa? Default is 0, the former.
enum biom_cvar_MultiBarrelFire : int
{
	BIOM_CV_MBF_PRIM = 0,
	BIOM_CV_MBF_SEC = 1
}

enum biom_cvar_MultiReload : int
{
	BIOM_CV_MRM_AUTORELOAD = 0,
	BIOM_CV_MRM_HOLD = 1
}
