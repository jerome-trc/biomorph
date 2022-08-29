version "3.7"

// Prolific symbols, and a good way to check if this mod is loaded.
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
}

#include "zscript/biomorph/ammo.zs"
#include "zscript/biomorph/armor.zs"
#include "zscript/biomorph/debug.zs"
#include "zscript/biomorph/health.zs"
#include "zscript/biomorph/keybinds.zs"
#include "zscript/biomorph/mutagens.zs"
#include "zscript/biomorph/perk.zs"
#include "zscript/biomorph/pickup.zs"
#include "zscript/biomorph/player.zs"
#include "zscript/biomorph/powerups.zs"
#include "zscript/biomorph/sbar.zs"
#include "zscript/biomorph/supply_box.zs"

#include "zscript/biomorph/event/core.zs"
#include "zscript/biomorph/event/console.zs"
#include "zscript/biomorph/event/death.zs"
#include "zscript/biomorph/event/net.zs"
#include "zscript/biomorph/event/render.zs"
#include "zscript/biomorph/event/spawn.zs"
#include "zscript/biomorph/event/static.zs"

#include "zscript/biomorph/genes/base.zs"
#include "zscript/biomorph/genes/active.zs"
#include "zscript/biomorph/genes/modifier.zs"
#include "zscript/biomorph/genes/support.zs"

#include "zscript/biomorph/global/core.zs"
#include "zscript/biomorph/global/console.zs"
#include "zscript/biomorph/global/genes.zs"
#include "zscript/biomorph/global/inv_reset.zs"
#include "zscript/biomorph/global/loot.zs"
#include "zscript/biomorph/global/morph.zs"
#include "zscript/biomorph/global/mutagens.zs"
#include "zscript/biomorph/global/opmodes.zs"
#include "zscript/biomorph/global/perks.zs"
#include "zscript/biomorph/global/weapons.zs"

#include "zscript/biomorph/menus/tooltipoptions.zs"
#include "zscript/biomorph/menus/weapmod.zs"

#include "zscript/biomorph/payloads/base.zs"
#include "zscript/biomorph/payloads/functors.zs"
#include "zscript/biomorph/payloads/projectiles.zs"
#include "zscript/biomorph/payloads/puffs.zs"

#include "zscript/biomorph/utils/misc.zs"
#include "zscript/biomorph/utils/actors.zs"
#include "zscript/biomorph/utils/array.zs"
#include "zscript/biomorph/utils/color.zs"
#include "zscript/biomorph/utils/compat.zs"
#include "zscript/biomorph/utils/constants.zs"
#include "zscript/biomorph/utils/cvar.zs"
#include "zscript/biomorph/utils/keyboard.zs"
#include "zscript/biomorph/utils/random.zs"
#include "zscript/biomorph/utils/string.zs"

#include "zscript/biomorph/weapons/detail.zs"
#include "zscript/biomorph/weapons/damage_base.zs"
#include "zscript/biomorph/weapons/damage_effect.zs"
#include "zscript/biomorph/weapons/firefunc.zs"
#include "zscript/biomorph/weapons/magazine.zs"
#include "zscript/biomorph/weapons/modgraph.zs"
#include "zscript/biomorph/weapons/opmode.zs"
#include "zscript/biomorph/weapons/pipeline.zs"
#include "zscript/biomorph/weapons/pipeline_builder.zs"
#include "zscript/biomorph/weapons/recoil.zs"
#include "zscript/biomorph/weapons/replacers.zs"
#include "zscript/biomorph/weapons/time.zs"

#include "zscript/biomorph/weapons/base/core.zs"
#include "zscript/biomorph/weapons/base/actions.zs"
#include "zscript/biomorph/weapons/base/attacks.zs"
#include "zscript/biomorph/weapons/base/dual.zs"
#include "zscript/biomorph/weapons/base/helper.zs"
#include "zscript/biomorph/weapons/base/ops.zs"
#include "zscript/biomorph/weapons/base/override.zs"

#include "zscript/biomorph/weapons/modifiers/base.zs"
#include "zscript/biomorph/weapons/modifiers/ammo.zs"
#include "zscript/biomorph/weapons/modifiers/damage.zs"
#include "zscript/biomorph/weapons/modifiers/melee.zs"
#include "zscript/biomorph/weapons/modifiers/misc.zs"
#include "zscript/biomorph/weapons/modifiers/payload_alter.zs"
#include "zscript/biomorph/weapons/modifiers/payload_new.zs"
#include "zscript/biomorph/weapons/modifiers/timing.zs"

#include "zscript/biomorph/weapons/morph/base.zs"
#include "zscript/biomorph/weapons/morph/downgrade.zs"
#include "zscript/biomorph/weapons/morph/upgrade.zs"

#include "zscript/biomorph/weapons/sim/core.zs"
#include "zscript/biomorph/weapons/sim/access_ex.zs"
#include "zscript/biomorph/weapons/sim/access.zs"
#include "zscript/biomorph/weapons/sim/gene.zs"
#include "zscript/biomorph/weapons/sim/helpers.zs"
#include "zscript/biomorph/weapons/sim/menu.zs"
#include "zscript/biomorph/weapons/sim/node.zs"
#include "zscript/biomorph/weapons/sim/ops_crit.zs"
#include "zscript/biomorph/weapons/sim/ops_inter.zs"
#include "zscript/biomorph/weapons/sim/snapshot.zs"

#include "zscript/biomorph/weapons/single/arc_caster.zs"
#include "zscript/biomorph/weapons/single/auto_shotgun.zs"
#include "zscript/biomorph/weapons/single/bfg.zs"
#include "zscript/biomorph/weapons/single/breaching_axe.zs"
#include "zscript/biomorph/weapons/single/chainsaw.zs"
#include "zscript/biomorph/weapons/single/coachgun.zs"
#include "zscript/biomorph/weapons/single/gamma_projector.zs"
#include "zscript/biomorph/weapons/single/machine_gun.zs"
#include "zscript/biomorph/weapons/single/microvulcan.zs"
#include "zscript/biomorph/weapons/single/minivulcan.zs"
#include "zscript/biomorph/weapons/single/plasma_rifle.zs"
#include "zscript/biomorph/weapons/single/pump_shotgun.zs"
#include "zscript/biomorph/weapons/single/ralauncher.zs"
#include "zscript/biomorph/weapons/single/service_pistol.zs"
#include "zscript/biomorph/weapons/single/turbovulcan.zs"
#include "zscript/biomorph/weapons/single/unarmed.zs"
#include "zscript/biomorph/weapons/single/volley_gun.zs"

#include "zscript/biomorph/weapons/dual/machine_gun.zs"

// Third-party /////////////////////////////////////////////////////////////////

#include "zscript/biomorph/libeye/projector_gl.zs"
#include "zscript/biomorph/libeye/projector_planar.zs"
#include "zscript/biomorph/libeye/projector.zs"
#include "zscript/biomorph/libeye/viewport.zs"

#include "zscript/biomorph/moonspeak/closest_target_in_fov.zs"
#include "zscript/biomorph/moonspeak/kindergarten_maths.zs"
#include "zscript/biomorph/moonspeak/pos.zs"
#include "zscript/biomorph/moonspeak/smart_aim.zs"
#include "zscript/biomorph/moonspeak/timer.zs"
#include "zscript/biomorph/moonspeak/vector.zs"
