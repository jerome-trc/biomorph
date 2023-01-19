// kd: This will scan and pick a target automatically in front of you, kinda like the BFG9000 does.
struct BIO_SmartAim play {
	void Begin (PlayerInfo player, double horizontal_fov = 38, double vertical_fov = 16) {
		hor_fov			= abs(horizontal_fov);
		ver_fov			= abs(vertical_fov);
		Reset();
		closest_target.AttachTo(player);
	}
	
	void Reset () {
		locked_mo		= NULL;
		old_locked_mo	= NULL;
		has_target		= false;
		had_target		= false;
		closest_target.Reset();
	}
	
	void Next (PlayerPawn owner_po) {
		// kd: Targets under your crosshair are preferred, even if you already
		// have a target.
		let considered_mo = BIO_ActorEx.BetterAimTarget(owner_po);
		
		// kd: We don't want to aim at stuff like statues or invulnerable
		// monsters.
		if(ShouldEject(owner_po, considered_mo)) {
			considered_mo = NULL;
		}
		
		// If your crosshair doesn't pick up anything, the Sandman will scan
		// the environment over a span of 3 tics.
		if(!locked_mo && !considered_mo) {
			bool just_lost_target = locked_mo && !old_locked_mo;
			
			if(just_lost_target || closest_target.IsDone()) {
				closest_target.Reset();
				closest_target.Begin(
					hor_fov,
					ver_fov,
					ray_cols: 30,
					ray_rows: 7,
					scan_time: 3);
			}
			
			closest_target.NextStep();
			considered_mo = closest_target.Get();
			
			if(ShouldEject(owner_po, considered_mo)) {
				considered_mo = NULL;
			}
		}
		
		// kd: Output.
		if(considered_mo) {
			old_locked_mo = locked_mo;
			locked_mo = considered_mo;
			is_ejecting = false;
			eject_t.Force(0);
		}
		
		had_target = has_target;
		has_target = locked_mo != NULL;
		
		// kd: Maybe start eject sequence. This allows you to keep the target
		// a little bit longer, so bars are less annoying (but you can do zany
		// stuff like blasting a guy who just teleported into a different
		// dimension... it's a Sandman feature now).
		
		// But don't do that if the target died.
		if(locked_mo && locked_mo.health < 1) {
			old_locked_mo = locked_mo;
			locked_mo = NULL;
		}
		
		else if(!is_ejecting && ShouldEject(owner_po, locked_mo)) {
			is_ejecting = true;
			eject_t.To(10, from: 0);
		}
		
		if(is_ejecting) {
			eject_t.Next();
			
			if(eject_t.IsDone()) {
				old_locked_mo = locked_mo;
				locked_mo = NULL;
				is_ejecting = false;
			}
		}
	}
	
	// kd: We don't like certain targets, so the Sandman shouldn't pick them
	// up at all. Like your friends or statues, it's nonsense.
	bool ShouldEject (Actor owner, Actor mo) const {
		if(mo == NULL) {
			return false;
		}
		
		if(
		!BIO_ActorEx.IsInPlayerFov(mo, owner.player, hor_fov, ver_fov) ||
		mo.health < 1 ||
		!mo.IsHostile(owner) ||
		mo.bdormant ||
		mo.binvulnerable) {
			return true;
		}
		
		return false;
	}
	
	bool JustGotTarget () const {
		return (locked_mo && has_target) && !(had_target && old_locked_mo);
	}
	
	bool JustLostTarget () const {
		return !(locked_mo && has_target) && (had_target && old_locked_mo);
	}
	
	bool SwitchedTarget () const {
		return has_target && had_target && locked_mo != old_locked_mo;
	}
	
	bool HasTarget () const {
		return has_target && locked_mo;
	}
	
	Actor Target () const {
		return locked_mo;
	}
	
	bool IsEjecting () const {
		return is_ejecting;
	}
	
	BIO_FovClosestMonster		closest_target;
	bool						is_ejecting;
	BIO_FadeTick					eject_t;
	
	// kd: Parameters
	double						hor_fov;
	double						ver_fov;
	
	// kd: Output
	bool						has_target;
	bool						had_target;
	Actor						locked_mo;
	Actor						old_locked_mo;
}
