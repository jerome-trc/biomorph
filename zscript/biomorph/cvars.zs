// Helper functions for getting and setting Biomorph's user CVars.
class BIO_CVar abstract
{
	static int AutoReloadPre(PlayerInfo pInfo)
	{
		return CVar.GetCVar('BIO_autoreload_pre', pInfo).GetInt();
	}

	static int AutoReloadPost(PlayerInfo pInfo)
	{
		return CVar.GetCVar('BIO_autoreload_post', pInfo).GetInt();
	}

	static int BerserkSwitch(PlayerInfo pInfo)
	{
		return CVar.GetCVar('BIO_berserkswitch', pInfo).GetInt();
	}

	static bool MultiBarrelPrimary(PlayerInfo pInfo)
	{
		return CVar.GetCVar('BIO_multibarrelfire', pInfo)
			.GetInt() == BIO_CV_MBF_PRIM;
	}

	static bool MultiReloadAuto(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_multireload", pInfo)
			.GetInt() == BIO_CV_MRM_AUTORELOAD;
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

// For the Super Shotgun and similar weapons, does primary fire multiple barrels
// while secondary fires one, or vice versa? Default is 0, the former.
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
