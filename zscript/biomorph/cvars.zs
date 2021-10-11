// Helper functions for getting and setting Biomorph's CVars.
class BIO_CVar abstract
{
	static bool Debug() { return CVar.GetCVar("BIO_debug").GetBool(); }
}
