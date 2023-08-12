version "3.7"

/// Mod meta-class. If your mod ever needs to check if Biomorph is loaded,
/// you can always rely on this class to exist.
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

	static void Unreachable(string msg = "")
	{
		if (msg.Length() > 0)
		{
			ThrowAbortException(
				Biomorph.LOGPFX_ERR ..
				"Hit unreachable code: %s",
				msg
			);
		}
		else
		{
			ThrowAbortException(
				Biomorph.LOGPFX_ERR ..
				"Hit unreachable code."
			);
		}
	}

	static void Assert(bool cond, string msg = "")
	{
		if (!cond)
		{
			if (msg.Length() > 0)
				ThrowAbortException(Biomorph.LOGPFX_ERR .. msg);
			else
				ThrowAbortException(Biomorph.LOGPFX_ERR .. "An assertion failed.");
		}
	}
}

// Third-party dependencies ////////////////////////////////////////////////////

#include "zscript/libeye/ZSCRIPT.zs"
#include "zscript/libtooltipmenu/ZSCRIPT.zs"
#include "zscript/moonspeak/ZSCRIPT.zs"

// General /////////////////////////////////////////////////////////////////////

#include "zscript/biomorph/ammo.zs"
#include "zscript/biomorph/armor.zs"
#include "zscript/biomorph/debug.zs"
#include "zscript/biomorph/event.zs"
#include "zscript/biomorph/global.zs"
#include "zscript/biomorph/health.zs"
#include "zscript/biomorph/mutagen.zs"
#include "zscript/biomorph/pickup.zs"
#include "zscript/biomorph/player.zs"
#include "zscript/biomorph/powerups.zs"
#include "zscript/biomorph/projectiles.zs"
#include "zscript/biomorph/puffs.zs"
#include "zscript/biomorph/recoil.zs"
#include "zscript/biomorph/sbar.zs"
#include "zscript/biomorph/static.zs"

#include "zscript/biomorph/alter/base.zs"

#include "zscript/biomorph/menus/player.zs"

#include "zscript/biomorph/utils/misc.zs"
#include "zscript/biomorph/utils/actor.zs"
#include "zscript/biomorph/utils/array.zs"
#include "zscript/biomorph/utils/color.zs"
#include "zscript/biomorph/utils/compat.zs"
#include "zscript/biomorph/utils/constants.zs"
#include "zscript/biomorph/utils/cvar.zs"
#include "zscript/biomorph/utils/random.zs"

// Weapons /////////////////////////////////////////////////////////////////////

#include "zscript/biomorph/weapons/base.zs"
#include "zscript/biomorph/weapons/pickup.zs"

#include "zscript/biomorph/weapons/bite-rifle.zs"
#include "zscript/biomorph/weapons/caster-cannon.zs"
#include "zscript/biomorph/weapons/dpsg.zs"
#include "zscript/biomorph/weapons/gpmg.zs"
#include "zscript/biomorph/weapons/multi-gl.zs"
#include "zscript/biomorph/weapons/pump-shotgun.zs"
#include "zscript/biomorph/weapons/service-pistol.zs"
#include "zscript/biomorph/weapons/tactical-shotgun.zs"
#include "zscript/biomorph/weapons/unarmed.zs"
