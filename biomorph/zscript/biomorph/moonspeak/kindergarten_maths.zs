// kd: Boring stuff to learn in preschool.

class BIO_PulseFunc {

	// kd: This pulse reaches its peak slightly to the left. f and the value
	// returned are in the 0 to 1 range.
    static double la_pulsef (double f) {
        double t = 1.0 - sqrt(f);
        return t * t * f * 16;
    }
	
	// This one has a right-aligned peak.
    static double ra_pulsef (double f) {
        double f2 = f * f;
               f2 = f2 * (f2 - 1.0);
        return f2 * f2 * 16;
    }
	
	// kd: This one goes slightly past 1, then back to 1. This is cool for
	// animations that kinda "snap in". f in 0 to 1, ends up at 1, but will
	// obviously go past 1.
	
	const sin100	= 0.98480775301;
	const sin110	= 0.93969262078;
	const sin120	= 0.86602540378;
	
	static double over_pulsef (double f) {
		return sin(100 * f) / sin100;
	}
	
	// kd: This one reaches a bit farther.
	static double over_pulse2f (double f) {
		return sin(110 * f) / sin110;
	}
	
	// kd: Yet farther.
	static double over_pulse3f (double f) {
		return sin(120 * f) / sin120;
	}
	
	// kd:
	// This allows us to make a rainbow colour cycle. I did it by overlaying
	// four offset trapezoid pulses.
	const trapezoid_width_2		= 0x180;	// 384 or 1.5 * 256, half the width
	const color_r_origin		= 0x080;
	const color_r_2nd_origin	= 0x380;
	const color_g_origin		= 0x180;
	const color_b_origin		= 0x280;
	const color_cycle_len		= 0x400;
	
	static int trap_b (int x) {
		return clamp(trapezoid_width_2 - abs(x), 0, 0xff);
	}
	
	static int ModIntoColorCycle (int x) {
		return x % color_cycle_len;
	}
	
	// Assumes you modded step with ModIntoColorCycle. (If you know you're never
	// going backwards, just use ModIntoColorCycle(x + cycle_speed)).
	static int CycleThroughColors (int x, int step) {
		x += step;
		
		if(0 < x) {
			return x + color_cycle_len;
		}
		
		return x % color_cycle_len;
	}
	
	// kd: These are colour locations for the below stuff.
	const color_red				= 0x000;
	const color_orange			= 0x090;
	const color_yellow			= 0x100;
	const color_turquoise		= 0x130;
	const color_green			= 0x180;
	const color_cyan			= 0x230;
	const color_blue			= 0x280;
	const color_magenta			= 0x300;
	
	static int, int, int Rgb255Cycle (int x) {
		return	trap_b(x - color_r_origin) +
				trap_b(x - color_r_2nd_origin),
				trap_b(x - color_g_origin),
				trap_b(x - color_b_origin);
	}
	
	static double, double, double RgbFloatCycle (int x) {
		return(	trap_b(x - color_r_origin) +
				trap_b(x - color_r_2nd_origin) ) / 255.0,
				trap_b(x - color_g_origin) / 255.0,
				trap_b(x - color_b_origin) / 255.0;
	}
	
	static Color RgbCycle (int x) {
		return Color(
			255,	// Alpha
			trap_b(x - color_r_origin) + trap_b(x - color_r_2nd_origin),
			trap_b(x - color_g_origin),
			trap_b(x - color_b_origin) );
	}
	
	// Alignable unit triangle pulse.
	static double tpulse_unit (double t, double mid) {
		if(t < mid) {
			return t / mid;
		}
		
		return (1.0 - t) / (1.0 - mid);
	}
}

/*	KeksDose / MemeDose (kd):
	Some interpolation functions. */

class BIO_Interpol {
	// Smooth curve connecting (0, 0) to (1, 1).
	static double trerp_unit (double t) {
		// return sin(-90.0f + 2 * t * 90.0f);
		return 0.5f * (1.0f + sin(90.0f * (2 * clamp(t, 0, 1) - 1)) );
	}
	
	// Same, but starts halfway through, so it only slows down.
	static double trerpfast_unit (double t) {
		return sin(90 * t);
	}
	
	// This ignores alpha.
	static Color ColorLerpRgb (double t, Color x1, Color x2) {
		return Color(
			x2.a,
			int(x1.r + t * (x2.r - x1.r)),
			int(x1.g + t * (x2.g - x1.g)),
			int(x1.b + t * (x2.b - x1.b)) );
	}
	
	// This doesn't.
	static Color ColorLerpArgb (double t, Color x1, Color x2) {
		return Color(
			int(x1.a + t * (x2.a - x1.a)),
			int(x1.r + t * (x2.r - x1.r)),
			int(x1.g + t * (x2.g - x1.g)),
			int(x1.b + t * (x2.b - x1.b)) );
	}
	
	// Draw a line from (x1, y1) to (x2, y2)
	static double Line (double x, double x1, double y1, double x2, double y2) {
		return y1 + (x - x1) / (x2 - x1) * (y2 - y1);
	}
}

// kd: Might crop up sometimes:

class ActorEx play {
	
	// kd: This is like A_Explode, but through walls. 
	static void A_SuperExplode (
	Actor	user,
	int		damage,
	int		radius,
	String	damage_type		= "Normal",
	double	thrust_f		= 1,
	bool	can_damage_self	= true) {
		if(NULL == user || NULL == user.target || radius <= 0) {
			return;
		}
		
		let it = ThinkerIterator.Create("Actor");
		Actor mo;
		
		while(mo = Actor(it.Next())) if(
		mo.bshootable		&&
		0 < mo.health		&&
		(mo != user.target && !deathmatch)	&&
		mo.IsHostile(user.target)) {
            let diff = levellocals.vec3diff(
				user.pos,
				mo.vec3offset(0, 0, 0.5 * mo.height));
			
			if((
            mo is 'ExplosiveBarrel' ||
            (can_damage_self && mo == user.target)) &&
            !mo.CheckSight(user)) {
                continue;
            }
			
			let diff_len		= diff.length();
            let damage_dealt	= max(0, (1 - diff_len / radius) * damage);
			
            mo.DamageMobj(
                user,
				user.target,
                max(0, (1 - diff.length() / radius) * damage),
                damage_type);
            
			if(false == mo.bdontthrust) {
				if(diff_len < 10) {
					mo.vel.z += thrust_f * 100 / max(1, mo.mass) * damage_dealt;
				}

				else {
					mo.vel += thrust_f * 100 / max(1, mo.mass) * damage_dealt * diff / diff_len;
				}
			}
		}
	}

	static Actor UnderPlayerCrosshair (Actor user) {
		return user.AimTarget();
	}
	
	static bool IsKillableThreat (Actor who, Actor to_whom) {
		if(!who || !who.FindState("Death")) {
			return false;
		}
		
		return	who &&
				who.IsHostile(to_whom) &&
				0 < who.health &&
				!who.breflective &&
				!who.binvulnerable &&
				!who.bdormant &&
				who.bshootable;
	}
	
	static bool IsKillableMonster (Actor who, Actor to_whom) {
		return who.bismonster && IsKillableThreat(who, to_whom);
	}
	
	static bool IsKillableLiveThing (Actor who, Actor to_whom) {
		return (who.player || who.bismonster) && IsKillableThreat(who, to_whom);
	}
	
	static bool IsThreatInSight (Actor who, Actor to_whom) {
		return	IsKillableThreat(who, to_whom) &&
				who.CheckSight(to_whom);
	}
	
	static bool IsInPlayerFov (
	Actor		who,
	PlayerInfo	to_whom_player,
	double		hor_fov,
	double		ver_fov) {
		if(to_whom_player && to_whom_player.mo && who) {
			BIO_Pos pos;
			pos.OrientForPlayer(to_whom_player);
			pos.FromActor(who);
			return
				pos.IsInsideRectFov(hor_fov, ver_fov) &&
				who.CheckSight(to_whom_player.mo);
		}
		
		return false;
	}
	
	static String BetterTag (Actor mo) {
		let player_mo = PlayerPawn(mo);
		
		if(player_mo && player_mo.player) {
			return player_mo.player.GetUserName();
		}
		
		return mo.GetTag();
	}
	
	// kd: AimTarget does undocumented and very zany garbage. Here's what
	// happens to the hp viewer if you use AimTarget:
	
	// 1. Looking straight up or down at an actor doesn't count.
	// 2. It actually casts 3 rays in like 8° from one another in front of you.
	// 3. IIRC it's used for gzd picking up autoaim targets.
	// 4. Limited to 1024 range (hardcoded).
	
	// So yea. don't use it, even if it's convenient. Use this here instead.
	static Actor BetterAimTarget (PlayerPawn mo) {
		FLineTraceData data;
		
		mo.LineTrace(
			mo.angle,
			25000.1337,
			mo.pitch,
			TRF_THRUBLOCK | TRF_THRUHITSCAN,
			offsetz: 0.5 * mo.height + mo.floorclip + mo.attackzoffset,
			data: data);
		
		return data.hitactor;
	}
	
	// kd: For things that aren't players.
	static Actor ActorAimTarget (Actor mo) {
		FLineTraceData data;
		
		mo.LineTrace(
			mo.angle,
			25000.1337,
			mo.pitch,
			TRF_THRUBLOCK | TRF_THRUHITSCAN,
			offsetz: 0.5 * mo.height + mo.floorclip,
			data: data);
		
		return data.hitactor;
	}
	
	// kd: This won't trace through one-sided walls. Sad!
	static Actor AimTargetNoWalls (PlayerPawn mo) {
		// console.printf("remember, no walls");
		
		BIO_NoWallsTracer tracer = new("BIO_NoWallsTracer");
		
		if(tracer == NULL) {
			return NULL;
		}
		
		let start_pos	= mo.vec3offset(
			0, 0, mo.height / 2 + mo.floorclip + mo.attackzoffset);
		let start_sec	= mo.cursector;
		let trace_dir	= BIO_Vec.Direction(mo.angle, -mo.pitch);
		let max_dist	= 25000.1337;
		let trace_flags	= TRACE_HITSKY;
		
		tracer.AttachTo(mo);
		tracer.Trace(start_pos, start_sec, trace_dir, max_dist, trace_flags);
		return tracer.Spotted();
	} 
	
	static void PrintValid (String msg, Actor mo) {
		console.printf("%s is %s.", msg, mo ? "valid" : "not valid");
	}
	
	// kd: I kinda expected MoltenArmor to have a field I can read here that
	// determines how much gets added. I expected wrong. If it ever changes,
	// here's a place where it could be centralised. Oh well.
	
	static clearscope int MoltenBonus () {
		return 10;
	}
}

class BIO_NoWallsTracer : LineTracer {
	protected Actor spotted_mo;
	protected Actor user;
	
	void AttachTo (Actor mo) {
		user = mo;
	}
	
	override EtraceStatus TraceCallback () {
		if(
		results.hittype == trace_hitactor &&
		results.hitactor) {
			if(results.hitactor == user) {
				return trace_continue;
			}
			
			spotted_mo = results.hitactor;
			return trace_stop;
		}
		
		else {
			return trace_skip;
		}
		
		return trace_continue;
	}
	
	Actor Spotted () const {
		return spotted_mo;
	}
}

// kd: Might also appear:

class CvarEx {
	// You can't use var as an identifier lol
	static bool BoolDef (Cvar c, bool def = false) {
		return c ? c.GetBool() : def;
	}
	
	static int IntDef (Cvar c, int def = 0) {
		return c ? c.GetInt() : def;
	}
	
	static double FloatDef (Cvar c, double def = 0) {
		return c ? c.GetFloat() : def;
	}
	
	static String StringDef (Cvar c, String def = "") {
		return c ? c.GetString() : def;
	}
	
	static bool GetBoolDef (
	String var_name, PlayerInfo player, bool def = false) {
		Cvar c = Cvar.GetCvar(var_name, player);
		return c ? c.GetBool() : def;
	}
	
	static int GetIntDef (
	String var_name, PlayerInfo player, int def = 0) {
		Cvar c = Cvar.GetCvar(var_name, player);
		return c ? c.GetInt() : def;
	}
	
	static double GetFloatDef (
	String var_name, PlayerInfo player, double def = 0) {
		Cvar c = Cvar.GetCvar(var_name, player);
		return c ? c.GetFloat() : def;
	}
	
	static String GetStringDef (
	String var_name, PlayerInfo player, String def = "") {
		Cvar c = Cvar.GetCvar(var_name, player);
		return c ? c.GetString() : def;
	}
	
	static bool UserBoolDef (
	String var_name, bool def = false) {
		Cvar c = Cvar.FindCvar(var_name);
		return c ? c.GetBool() : def;
	}
	
	static int UserIntDef (
	String var_name, int def = 0) {
		Cvar c = Cvar.FindCvar(var_name);
		return c ? c.GetInt() : def;
	}
	
	static double UserFloatDef (
	String var_name, double def = 0) {
		Cvar c = Cvar.FindCvar(var_name);
		return c ? c.GetFloat() : def;
	}
	
	static String UserStringDef (
	String var_name, String def = "") {
		Cvar c = Cvar.FindCvar(var_name);
		return c ? c.GetString() : def;
	}
	
	static bool IsUser (int player) {
		return player == consoleplayer;
	}
	
	static void SetUserInt (String var_name, int val) {
		let c = Cvar.FindCvar(var_name);
		c.SetInt(val);
	}
	
	static void SetUserFloat (String var_name, double val) {
		let c = Cvar.FindCvar(var_name);
		c.SetFloat(val);
	}
	
	static void SetUserString (String var_name, String val) {
		let c = Cvar.FindCvar(var_name);
		c.SetString(val);
	}
}

class MiscOps {
	
	// kd: We decide to pretend 0 has 0 sign, since usually, we'll use this
	// for stuff like movements. (See the Tick struct for a good example, in
	// particular, RenderStandardDelta.)
	static int IntSign (int x) {
		return x == 0 ? 0 : x < 0 ? -1 : 1;
	}
	
	static int ClosestMultiple (int val, int mul) {
		return (val / mul) * mul;
	}
}

// kd: zs string is nonsense sometimes

class GCString {
	static String Replace (String s, String to_replace, String with) {
		s.Replace(to_replace, with);
		return s;
	}
	
	static bool IsEmpty (String s) {
		return s.Length() < 1;
	}
}

// kd: Might as well drop this here cuz I lost my sense of organisation long
// ago in a galaxy right here actually.

class BIO_Sprite {
	static TextureId Empty () {
		return TexMan.CheckForTexture("tnt1a0", TexMan.type_any);
	}
	
	static TextureId Load (String name) {
		return TexMan.CheckForTexture(name, TexMan.type_any);
	}
}

// kd: For weapon stuff that gzd seems to have internally but is tangled up in
// such a mess that sane people have to reverse engineer it.

class BIO_WeaponHelp {

	// kd: Returns true if it's a gnu that makes sense to select in order to
	// pew pew demons ded (has ammo or doesn't need it).
	static bool IsSensible (PlayerPawn user, Weapon weap) {
		if(!weap || !user) {
			return false;
		}
		
		// let def_weap	= GetDefaultByType(weap);
		let def_weap	= weap;
		let ammo_type1	= def_weap.ammotype1;
		let ammo_type2	= def_weap.ammotype2;
		
		if(ammo_type1) {
			let inv = user.FindInventory(ammo_type1);
			
			// We'll just assume that having ammo is good enough.
			if(inv && (0 < inv.amount || inv.maxamount <= 0)) {
				return true;
			}
			
			else if(ammo_type2) {
				inv = user.FindInventory(ammo_type2);
				
				if(inv && (0 < inv.amount || inv.maxamount <= 0)) {
					return false;
				}
			}
			
			return false;
		}
		
		return true;
	}
}

// kd: And the rest is outdated.

// kd: Describes a unit circle on a plane that faces in the "forw" direction
// (by which I mean, forw and right make up the plane, so don't go in assuming
// Orient takes the normal).

struct BIO_TiltedRing {
	vector3 forw, right;
	
	void Orient (double ang, double vang) {
		let cosang   = cos(ang);
		let sinang   = sin(ang);
		let cosvang  = cos(vang);
		
		forw = (
			cosvang * cosang,
			cosvang * sinang,
			sin(vang) );
		right = ( sinang, -cosang, 0 );
	}
	
	vector3 Position (double ang, double radius = 1) {
		return radius * (cos(ang) * forw + sin(ang) * right);
	}
	
	vector3 EllipticPos (double ang, double forw_rad = 1, double right_rad = 1) {
		return forw_rad * cos(ang) * forw + right_rad * sin(ang) * right;
	}
	
	vector3 Tangent (double ang, double len = 1.0f) {
		return len * (-sin(ang) * forw + cos(ang) * right);
	}
	
	vector3 EllipticTan (double ang, double forw_len = 1, double right_len = 1) {
		return cos(ang) * right_len * right - sin(ang) * forw_len * forw;
	}
}

// kd: Same thing but I add another dimension so it's first grade, not
// preschool.

struct BIO_Sphere {
	vector3 forw, right, up;
	
	void Orient (double ang, double vang) {
		let cosang    = cos(ang);
		let sinang    = sin(ang);
		let cosvang   = cos(vang);
		let sinvang   = sin(vang);
		
		forw	= ( cosvang * cosang,  cosvang * sinang, sinvang);
		right	= (          -sinang,            cosang, 0);
		up		= (-sinvang * cosang, -sinvang * sinang, cosvang);
	}
	
	// kd: It makes sense to put this here since the three vectors are
	// around here (usually I'd just return them but I decided against that
	// this time, I forgot why).
	
	vector3, double, double PrismPosAnglePitch (
	double f_dist,
	double h_dist,
	double disc_rad,
	double sin_open_ang,
	double ang) const {
		vector3 diff	= cos(ang) * right + sin(ang) * up;
		vector3 pos		= f_dist * forw +     disc_rad * diff - h_dist * right;
		vector3	angles	=          forw + sin_open_ang * diff;
		
		return	pos,
				VectorAngle(angles.x, angles.y),
				VectorAngle(angles.xy.length(), angles.z);
	}
}

// kd: Some assorted stuff.

class BIO_MiscOps {
	// kd: Shortest linear modulo space movement from a to b. If you read this
	// and don't understand it, write it yourself and it'll make sense.
	
	// For example, the parameters (10, 350, 15, 360) would result in the
	// value 355, because if you imagined a and b as angles marked on a circle,
	// the shorter way to turn is the one over the 0° mark.
	static double linstep_mod (double a, double b, double step, double mod) {
		if(a < b) {
			return
				b - 0.5 * mod < a ?
					a + step < b ?
						a + step : b :
					b < a - step + mod ?
						a - step + mod : b;
		}
		
		return
			b + 0.5 * mod < a ?
				(a + step) % mod < b ?
					(a + step) % mod : b :
				b < a - step ?
					a - step : b;
	}
	
	// kd: I didn't find a pi constant in zs so...
	const pi    = 3.1415926;
	const pi2   = 6.2831853; // kd: 2 stands for * 2, _2 stands for / 2.
	const pi_2  = 1.5707963; // pi is useless anyway. (But still cool.)
	const full_ang_inv = 1.0 / 360.0;
	
	// kd: Returns the velocity for an actor to complete a round in a circle
	// of a given radius in some given time.
	static double RevolutionSpeed (double radius, double seconds) {
		return pi2 * radius / (seconds * 35.0f);
	}
	
	// kd: Helps documentation a little.
	static double AngularSpeed (double seconds) {
		return 360.0f / (seconds * 35.0f);
	}
	
	// kd: Two floats close enough?
	static bool CloseEnough (double x, double y, double len = 0.0001337) {
		return abs(x - y) < len;
	}
}

// kd: This is a niche object. If you use this on an actor that has a position
// being set repeatedly (like the orbiters), then it will cause this actor to
// kind of glide from the initial position to whatever the final position is
// going to be at least continuously.

class BIO_Glider : Thinker {
	private Actor     mo;
	private vector3   init_pos;
	private vector3   old_pos;
	private double    f;
	private double     f_rate;
	
	static BIO_Glider Create (Actor who, vector3 start, double rate) {
		BIO_Glider g = new("BIO_Glider");
		
		if(g) {
			g.Init(who, start, rate);
		}
		
		return g;
	}
	
	private bool Init (Actor who, vector3 start, double rate) {
		if(who == NULL) {
			return false;
		}
		
		ChangeStatNum(STAT_SCRIPTS);
		mo        = who;
		init_pos  = start;
		f_rate    = clamp(rate, 0.0f, 1.0f);
		f         = 0;
		old_pos   = mo.pos;
		return true;
	}
	
	override void Tick () {
		if(mo == NULL) {
			Destroy();
			return;
		}
		
		vector3 pos    = mo.pos;
		vector3 offset = f * (pos - old_pos);
		
		mo.SetOrigin(old_pos, false);
		mo.SetOrigin(mo.Vec3Offset(offset.x, offset.y, offset.z), true);
		
		f += f_rate;
		
		if(1.0f <= f) {
			Destroy();
		}
		
		old_pos = mo.pos;
	}
}

// kd: YOU GUYS LIKE NO JUMPING NO CROUCHING???

class HahaSaidTheClown : Actor {
	override void PostBeginPlay () {
		let sector_count = level.sectors.size();
		
		let min_z = int.max;
		let max_z = int.min;
		
		for(let i = 0; i < sector_count; i++) {
			Sector sec = level.sectors [i];
			
			let floor_d = sec.floorplane.d;
			let ceiling_d = -sec.ceilingplane.d;
			
			if(floor_d < min_z) {
				min_z = floor_d;
			}
			
			if(max_z < ceiling_d) {
				max_z = ceiling_d;
			}
		}
		
		let temp = min_z;
		min_z = max_z;
		max_z = -temp;
		
		console.printf("min: %d, max: %d", min_z, max_z);
		
		let in_floor_z = min_z;
		let in_ceiling_z = max_z;
		
		let target_floor_z = min_z;
		let target_ceiling_z = max_z;
		
		let move_speed = 0.0001;
		for(let i = 0; i < sector_count; i++) {
			Sector sec = level.sectors [i];
			sec.lightlevel = 255;
			let floor_d = sec.floorplane.d;
			let ceiling_d = sec.ceilingplane.d;
			let floor_diff = floor_d - target_floor_z;
			let ceiling_diff = target_ceiling_z - ceiling_d;
			
			sec.MoveFloor(move_speed,	target_floor_z, 0, 0 < floor_diff ? -1 : 1, false);
			sec.MoveCeiling(move_speed, target_ceiling_z, 0, 0 < ceiling_diff ? -1 : 1, false);
		}
		
		let praise_sprite = TexMan.CheckForTexture("praise", TexMan.type_any);
		level.ChangeSky(praise_sprite, praise_sprite);
	}
}

class BetterSkyViewpoint : SkyViewpoint {
	override void Tick () {
		pitch = -30;
		roll += 1;
	}
}
