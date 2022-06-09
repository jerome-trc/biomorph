version "2.4"

// Mod meta-class. If your mod ever needs to check if Biomorph is loaded,
// you can always rely on this class to exist.
class Biomorph abstract
{
	const VERSION_MAJOR = 0;
	const VERSION_MINOR = 0;
	const VERSION_PATCH = 0;

	static string VersionString()
	{
		return VERSION_MAJOR .. "." .. VERSION_MINOR .. "." .. VERSION_PATCH;
	}

	const LOGPFX_INFO = "\c[Cyan]Biomorph: \c-";
	const LOGPFX_WARN = "\c[Cyan]Biomorph: \c[Yellow](WARNING)\c- ";
	const LOGPFX_ERR = "\c[Cyan]Biomorph: \c[Red](ERROR)\c- ";
	const LOGPFX_DEBUG = "\c[Cyan]Biomorph: \c[LightBlue](DEBUG)\c- ";
}

#include "zscript/biomorph/ammo.zs"
#include "zscript/biomorph/armor.zs"
#include "zscript/biomorph/event.zs"
#include "zscript/biomorph/global.zs"
#include "zscript/biomorph/health.zs"
#include "zscript/biomorph/pickup.zs"
#include "zscript/biomorph/player.zs"
#include "zscript/biomorph/powerups.zs"
#include "zscript/biomorph/utils.zs"
