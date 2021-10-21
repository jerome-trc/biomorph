version "2.4"

// Mod meta-class. If your mod ever needs to check if Biomorph is loaded,
// you can always rely on this class to exist.
class Biomorph abstract
{
	const VERS_STR = "0.0.1";

	const LOGPFX_INFO = "\cfBIO:\c-";
	const LOGPFX_WARN = "\cfBIO: \ck(WARNING)\c- "; // Yellow
	const LOGPFX_ERR = "\cfBIO: \cg(ERROR)\c- "; // Red
	const LOGPFX_DEBUG = "\cfBIO: \cn(DEBUG)\c- "; // Light blue
}

#include "zscript/biomorph/cvars.zs"
#include "zscript/biomorph/events.zs"
#include "zscript/biomorph/gear.zs"
#include "zscript/biomorph/global.zs"
#include "zscript/biomorph/keybinds.zs"
#include "zscript/biomorph/player.zs"
#include "zscript/biomorph/projectiles.zs"
#include "zscript/biomorph/sbar.zs"
#include "zscript/biomorph/utils.zs"

#include "zscript/biomorph/affixes/base.zs"
#include "zscript/biomorph/affixes/armor.zs"

#include "zscript/biomorph/equip/base.zs"
#include "zscript/biomorph/equip/armor.zs"

#include "zscript/biomorph/weapons/base.zs"

#include "zscript/biomorph/weapons/fist.zs"
#include "zscript/biomorph/weapons/standard/pistol.zs"
#include "zscript/biomorph/weapons/standard/shotgun.zs"
