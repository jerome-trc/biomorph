version "2.4"

// Mod meta-class. If your mod ever needs to check if Biomorph is loaded,
// you can always rely on this class to exist.
class Biomorph abstract
{
	const VERS_STR = "0.0.1";

	const LOGPFX_INFO = "\cfBiomorph: \c-";
	const LOGPFX_WARN = "\cfBiomorph: \ck(WARNING)\c- "; // Yellow
	const LOGPFX_ERR = "\cfBiomorph: \cg(ERROR)\c- "; // Red
	const LOGPFX_DEBUG = "\cfBiomorph: \cn(DEBUG)\c- "; // Light blue
}

const CRESC_STATDEFAULT = "\c[White]";
const CRESC_STATMODIFIED = "\c[Cyan]";
const CRESC_STATBETTER = "\c[Green]";
const CRESC_STATWORSE = "\c[Red]";

#include "zscript/bio_zjson/Include.zs"

#include "zscript/biomorph/ammo.zs"
#include "zscript/biomorph/cvars.zs"
#include "zscript/biomorph/debug.zs"
#include "zscript/biomorph/gear.zs"
#include "zscript/biomorph/global.zs"
#include "zscript/biomorph/health.zs"
#include "zscript/biomorph/keybinds.zs"
#include "zscript/biomorph/mutagens.zs"
#include "zscript/biomorph/player.zs"
#include "zscript/biomorph/powerups.zs"
#include "zscript/biomorph/sbar.zs"

#include "zscript/biomorph/util/misc.zs"
#include "zscript/biomorph/util/color.zs"
#include "zscript/biomorph/util/compat.zs"
#include "zscript/biomorph/util/json.zs"
#include "zscript/biomorph/util/texture.zs"
#include "zscript/biomorph/util/wrtable.zs"

#include "zscript/biomorph/affixes/base.zs"
#include "zscript/biomorph/affixes/armor.zs"
#include "zscript/biomorph/affixes/weapon.zs"
// #include "zscript/biomorph/affixes/weapon_old.zs"

#include "zscript/biomorph/equip/base.zs"
#include "zscript/biomorph/equip/armor.zs"

#include "zscript/biomorph/event/core.zs"
#include "zscript/biomorph/event/console.zs"
#include "zscript/biomorph/event/death.zs"
#include "zscript/biomorph/event/net.zs"
#include "zscript/biomorph/event/spawn.zs"

#include "zscript/biomorph/firetypes/detail.zs"
#include "zscript/biomorph/firetypes/projectiles.zs"
#include "zscript/biomorph/firetypes/puffs.zs"

#include "zscript/biomorph/menus/perk.zs"

#include "zscript/biomorph/overlays/modal_base.zs"
#include "zscript/biomorph/overlays/weapon_upgrade.zs"

#include "zscript/biomorph/passives/base.zs"
#include "zscript/biomorph/passives/perks.zs"

#include "zscript/biomorph/weapons/fist.zs"
#include "zscript/biomorph/weapons/upgrade_kit.zs"

#include "zscript/biomorph/weapons/detail/base_dw.zs"
#include "zscript/biomorph/weapons/detail/base.zs"
#include "zscript/biomorph/weapons/detail/builder.zs"
#include "zscript/biomorph/weapons/detail/constants.zs"
#include "zscript/biomorph/weapons/detail/damage_func.zs"
#include "zscript/biomorph/weapons/detail/fire_func.zs"
#include "zscript/biomorph/weapons/detail/pipeline.zs"
#include "zscript/biomorph/weapons/detail/recoil.zs"

#include "zscript/biomorph/weapons/standard/bfg9000.zs"
#include "zscript/biomorph/weapons/standard/chaingun.zs"
#include "zscript/biomorph/weapons/standard/chainsaw.zs"
#include "zscript/biomorph/weapons/standard/pistol.zs"
#include "zscript/biomorph/weapons/standard/plasma_rifle.zs"
#include "zscript/biomorph/weapons/standard/rocket_launcher.zs"
#include "zscript/biomorph/weapons/standard/shotgun.zs"
#include "zscript/biomorph/weapons/standard/super_shotgun.zs"

#include "zscript/biomorph/weapons/specialty/assault_handgun.zs"
#include "zscript/biomorph/weapons/specialty/auto_shotgun.zs"
#include "zscript/biomorph/weapons/specialty/nailgun.zs"
#include "zscript/biomorph/weapons/specialty/plasma_cannon.zs"
#include "zscript/biomorph/weapons/specialty/precision_rifle.zs"

#include "zscript/biomorph/weapons/classified/autocannon.zs"
#include "zscript/biomorph/weapons/classified/hand_cannon.zs"
#include "zscript/biomorph/weapons/classified/heavy_battle_rifle.zs"
#include "zscript/biomorph/weapons/classified/incursion_shotgun.zs"
#include "zscript/biomorph/weapons/classified/barrage_launcher.zs"

#include "zscript/biomorph/weapons/unique/megaton.zs"
