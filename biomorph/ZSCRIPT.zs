version "3.7"

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
#include "zscript/biomorph/debug.zs"
#include "zscript/biomorph/event.zs"
#include "zscript/biomorph/gear.zs"
#include "zscript/biomorph/global.zs"
#include "zscript/biomorph/health.zs"
#include "zscript/biomorph/keybinds.zs"
#include "zscript/biomorph/mutagens.zs"
#include "zscript/biomorph/pickup.zs"
#include "zscript/biomorph/player.zs"
#include "zscript/biomorph/powerups.zs"
#include "zscript/biomorph/sbar.zs"
#include "zscript/biomorph/utils.zs"

#include "zscript/biomorph/genes/base.zs"
#include "zscript/biomorph/genes/active.zs"
#include "zscript/biomorph/genes/modifier.zs"
#include "zscript/biomorph/genes/support.zs"

#include "zscript/biomorph/menus/weapmod.zs"

#include "zscript/biomorph/payloads/base.zs"
#include "zscript/biomorph/payloads/projectiles.zs"
#include "zscript/biomorph/payloads/puffs.zs"

#include "zscript/biomorph/weapons/base.zs"
#include "zscript/biomorph/weapons/base_dual.zs"
#include "zscript/biomorph/weapons/detail.zs"
#include "zscript/biomorph/weapons/dmgfunc.zs"
#include "zscript/biomorph/weapons/firefunc.zs"
#include "zscript/biomorph/weapons/modgraph.zs"
#include "zscript/biomorph/weapons/morph.zs"
#include "zscript/biomorph/weapons/pipeline.zs"
#include "zscript/biomorph/weapons/recoil.zs"
#include "zscript/biomorph/weapons/simulator.zs"

#include "zscript/biomorph/weapons/modifiers/base.zs"
#include "zscript/biomorph/weapons/modifiers/ammo.zs"
#include "zscript/biomorph/weapons/modifiers/damage.zs"
#include "zscript/biomorph/weapons/modifiers/melee.zs"
#include "zscript/biomorph/weapons/modifiers/misc.zs"
#include "zscript/biomorph/weapons/modifiers/payload_alter.zs"
#include "zscript/biomorph/weapons/modifiers/payload_new.zs"
#include "zscript/biomorph/weapons/modifiers/timing.zs"

#include "zscript/biomorph/weapons/single/ralauncher.zs"
#include "zscript/biomorph/weapons/single/auto_shotgun.zs"
#include "zscript/biomorph/weapons/single/bfg.zs"
#include "zscript/biomorph/weapons/single/chainsaw.zs"
#include "zscript/biomorph/weapons/single/coachgun.zs"
#include "zscript/biomorph/weapons/single/machine_gun.zs"
#include "zscript/biomorph/weapons/single/microvulcan.zs"
#include "zscript/biomorph/weapons/single/plasma_rifle.zs"
#include "zscript/biomorph/weapons/single/pump_shotgun.zs"
#include "zscript/biomorph/weapons/single/service_pistol.zs"
#include "zscript/biomorph/weapons/single/volley_gun.zs"

#include "zscript/biomorph/weapons/dual/fists.zs"
#include "zscript/biomorph/weapons/dual/machine_gun.zs"
