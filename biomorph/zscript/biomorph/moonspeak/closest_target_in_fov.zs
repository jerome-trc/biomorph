/*	KeksDose / MemeDose (kd):
	
	Here's a surprisingly aggressive struct. You've been warned. It finds the
	closest target in your fov and properly regards view tilting and rolling.	
*/

struct BIO_TargetInfo {
	Actor							mo;
	double							dist;
	
	void Copy (BIO_TargetInfo source) {
		mo		= source.mo;
		dist	= source.dist;
	}
	
	void Reset () {
		mo		= NULL;
		dist	= 0;
	}
	
	void FromLineTrace (FLineTraceData data) {
		if(data.hitactor) {
			mo			= data.hitactor;
			dist		= data.distance;
		}
	}
}

struct BIO_ClosestMonsterTracer play {
	
	private vector3						forw, right, down;
	private PlayerInfo					player_info;
	private Actor						player_mo;
	
	private vector3						top_left,	bottom_left;
	private vector3						top_right,	bottom_right;
	private transient FLineTraceData	trace_data;
	
	// Current target info:
	private BIO_TargetInfo					target, new_target;
	
	void Reset () {
		target.Reset();
		new_target.Reset();
	}
	
	void Copy (BIO_ClosestMonsterTracer source) {
		forw			= source.forw;
		right			= source.right;
		down			= source.down;
		player_info		= source.player_info;
		player_mo		= source.player_mo;
		top_left		= source.top_left;
		top_right		= source.top_right;
		bottom_left		= source.bottom_left;
		bottom_right	= source.bottom_right;
		// trace_data		= source.trace_data; // lol
		target.		Copy(source.target);
		new_target.	Copy(source.new_target);
	}
	
	private void OrientForPlayer (PlayerInfo player) {
		[forw, right, down] = BIO_Vec.RolledViewOnb(
			player.mo.angle,
		-	player.mo.pitch,
		-	player.mo.roll);
		
		player_info	= player;
		player_mo	= player.mo;
	}
	
	void Reorient (PlayerInfo player, double hor_fov = 30, double ver_fov = 20) {
		OrientForPlayer(player);
		
		top_right		= LocalToWorldDirection( hor_fov, -ver_fov);
		top_left		= LocalToWorldDirection(-hor_fov, -ver_fov);
		bottom_right	= LocalToWorldDirection( hor_fov,  ver_fov);
		bottom_left		= LocalToWorldDirection(-hor_fov,  ver_fov);
	}
	
	vector3 LocalToWorldDirection (double ang = 0, double vang = 0) const {
		double cosvang = cos(vang);
		
		// kd: If this seems familiar to you, I'll say you have keen eyes.
		return
			cosvang * (cos(ang) * forw + sin(ang) * right) +
			sin(vang) * down;
	}
	
	// kd: The fovs you passed span a view rectangle that is the same regardless
	// of your screen size.
	
	// (-1, -1) will aim to your top left, (1, 1) to your bottom right in view.
	// This is basically improved BFG-spread that works no matter how far
	// you tilt your head.
	bool FindActorLocally (vector2 normal = (0, 0), double dist = 2000) const {
		if(player_mo) {
			normal = 0.5 * ((1, 1) + normal);
			
			// kd: Linearly interpolate the location. I dunno if this is
			// actually faster than just doing the above with interpolated
			// angles, but yea.
			vector3 row_left	= top_left  + normal.y * (bottom_left  - top_left);
			vector3 row_right	= top_right + normal.y * (bottom_right - top_right);
			vector3 trace_dir 	= row_left  + normal.x * (row_right    - row_left);
			
			player_mo.LineTrace(
				BIO_Vec.Angle3(trace_dir),
				dist,
			-	BIO_Vec.Pitch(trace_dir),
				flags: TRF_THRUBLOCK,
				offsetz: player_info.viewheight,
				data: trace_data);
			
			// Actor hu = Actor.Spawn("Blood", player_mo.vec3offset(0, 0, player_mo.player.viewheight) + 100 * trace_dir);
			
			if(trace_data.hitactor) {
				new_target.FromLineTrace(trace_data);
				return true;
			}
			
			else {
				new_target.Reset();
			}
		}
		
		return false;
	}
	
	// kd: This is what you'd override if this were a class. I didn't make it a
	// class because there's no reason to yet.
	
	void SaveSpottedIfCloserThreat () {
		if(new_target.mo && player_mo) {
			if(	target.mo == NULL || (
				ActorEx.IsKillableLiveThing(new_target.mo, player_mo) &&
				(new_target.dist < target.dist || target.mo.health < 1) ) ) {
				target.Copy(new_target);
			}
		}
	}
	
	void SaveSpotted () {
		target.Copy(new_target);
	}
	
	Actor Get () const {
		return target.mo;
	}
}

struct BIO_FovClosestMonster play {
	private PlayerInfo					player_info;
	private BIO_ClosestMonsterTracer		tracer;
	private	double						current_hor;
	private	double						current_ver;
	private double						hor_step;
	private	double						ver_step;
	private double						columns_per_step;
	private double						columns_scanned_f;
	private double						horizontal_fov;
	private double						vertical_fov;
	private int							columns_scanned;
	private int							hor_rays;
	private int							ver_rays;
	private int							tics;
	private bool						is_active;
	private int							scan_count;
	
	const auto_offsets		= 10;
	const auto_offsets_2	= auto_offsets / 2;
	
	void AttachTo (PlayerInfo player) {
		player_info	= player;
	}
	
	void Begin (
	double		hor_fov		= 12,
	double		ver_fov		= 28,
	int			ray_cols	= 10,	// kd: This setup casts 20 rays per tic,
	int			ray_rows	= 7,	// scanning from left to right in 2 columns
	int			scan_time	= 10) {	// of 10 rays each.
		
		horizontal_fov	= max(0.001, hor_fov);
		vertical_fov	= max(0.001, ver_fov);
		
		hor_rays	= max(1, ray_cols);
		ver_rays	= max(1, ray_rows);
		hor_step	= 2.0 / hor_rays;
		ver_step	= 2.0 / ver_rays;
		tics		= max(1, scan_time);
		
		columns_per_step	= 1.0 * hor_rays / tics;
		columns_scanned_f	= 0;
		columns_scanned		= 0;
		
		// Search starts top left.
		
		double scan_f	= 2.0 * scan_count / auto_offsets;
		current_hor		= -1 - scan_f * hor_step + hor_step;
		current_ver		= -1 + 0.5 * ver_step;
		
		// kd: The scan counter will cause the scanner to shift slightly,
		// so at the end of the day, if you scan over and over, more area is
		// covered.
		scan_count++;
		
		if(auto_offsets <= scan_count) {
			scan_count = 0;
		}
	}
	
	// kd: If you ever wanna search right to left instead of left to right...
	void Reverse () {
		current_hor	= current_hor * (-1);
		hor_step	= hor_step * (-1);
	}
	
	void Reset () {
		scan_count	= 0;
		current_hor	= -1;
		current_ver	= -1;
		tics		= 0;
		hor_rays	= 0;
		hor_step	= 0;
		ver_rays	= 0;
		ver_step	= 0;
		columns_per_step	= 0;
		columns_scanned_f	= 0;
		columns_scanned		= 0;
		tracer.Reset();
	}
	
	private int						it_columns;
	
	private double					it_current_ver;
	private double					it_current_hor;
	
	void StartStep () {
		tracer.Reorient(
			player_info,
			hor_fov: horizontal_fov,
			ver_fov: vertical_fov);
		
		// kd: Initialises the step.
		columns_scanned_f += columns_per_step;
		it_columns = floor(columns_scanned_f) - columns_scanned;
		
		// kd: This already prepares for next step.
		it_current_ver	= 0;
		it_current_hor	= 0;
		columns_scanned	= floor(columns_scanned_f);
		tics--;
	}
	
	bool IsIterating () {
		return it_current_hor < it_columns;
	}
	
	Actor Trace () {
		tracer.FindActorLocally((current_hor, current_ver));
		tracer.SaveSpotted();
		return tracer.Get();
	}
	
	void Iterate () {
		it_current_ver++;
		current_ver += ver_step;
		
		if(ver_rays <= it_current_ver) {
			current_hor += hor_step;
			current_ver = -1 + 0.5 * ver_step;
			it_current_hor++;
			it_current_ver = 0;
		}
	}
	
	// kd: Weird name, eh? But it was here first before I went full
	// FCS (Flat Code Society) on it. This'll let the Sandman work as before.
	void NextStep () {
		StartStep();
		
		while(IsIterating()) {
			tracer.FindActorLocally((current_hor, current_ver));
			tracer.SaveSpottedIfCloserThreat();
			Iterate();
		}
	}
	
	bool IsDone () const {
		return tics <= 0;
	}
	
	Actor Get () const {
		return tracer.Get();
	}
	
	int CurrentTics () const {
		return tics;
	}
}
