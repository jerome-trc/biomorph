// kd: Might crop up sometimes:

class BIO_ActorEx play {
	
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

class BIO_MiscOps {
	
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

// kd: Some assorted stuff.

extend class BIO_MiscOps {
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
