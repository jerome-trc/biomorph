/*	KeksDose / MemeDose (kd):

	This helps saying some stuff about actor relations, like their position
	in fov or something.
*/

struct BIOM_Pos play {
	private vector3						view_pos;
	private vector3						forw, right, down;
	private vector3						diff;

	void OrientForPlayer (PlayerInfo player) {
		let mo = player.mo;

		view_pos = mo.vec3offset(0, 0, player.viewheight);
		[forw, right, down] =
			BIOM_Vec.RolledViewOnb(mo.angle, -mo.pitch, -mo.roll);
	}

	void FromActor (Actor mo, double height_f = 0.5) {
		diff = levellocals.vec3diff(
			view_pos, mo.vec3offset(0, 0, height_f * mo.height));
	}

	// kd: Cuz why not.
	bool IsOutsideRectFov (double fov_hor, double fov_ver) {
		double depth = diff dot forw;

		if(	fov_hor < abs(VectorAngle(depth, diff dot right)) ||
			fov_ver < abs(VectorAngle(depth, diff dot down)) ) {
			return true;
		}

		return false;
	}

	bool IsInsideRectFov (double fov_hor, double fov_ver) {
		double depth = diff dot forw;
		return	abs(VectorAngle(depth, diff dot right)) < fov_hor &&
				abs(VectorAngle(depth, diff dot down))  < fov_ver;
	}

	double Distance2 () const {
		return diff dot diff;
	}
}
