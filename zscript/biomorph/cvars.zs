// Helper functions for getting and setting Biomorph's CVars.
class BIO_CVar abstract
{
	static bool Debug() { return CVar.GetCVar("BIO_debug").GetBool(); }

	static bool MultiBarrelPrimary(PlayerInfo pInfo)
	{
		return CVar.GetCVar("BIO_multibarrelfire", pInfo)
			.GetInt() == BIO_CV_MBF_PRIM;
	}
}

// For the Super Shotgun and similar weapons, does primary fire multiple barrels
// while secondary fires one, or vice versa? Default is 0, the former.
enum BIO_CVar_MultiBarrelFire : int
{
	BIO_CV_MBF_PRIM = 0,
	BIO_CV_MBF_SEC = 1
}
