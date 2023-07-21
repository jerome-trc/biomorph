/*	KeksDose / MemeDose (kd):

	You can use this as a timer and as a fader for few animations.
*/

struct biom_FadeTick {
	private int					ticks;
	private int					start;
	private int					target;
	private int					tick_dir;
	private int					old_delta;

	void Copy (biom_FadeTick source) {
		ticks		= source.ticks;
		start		= source.start;
		target		= source.target;
		tick_dir	= source.tick_dir;
		old_delta	= source.old_delta;
	}

	void To (int count, int from = 0) {
		start = from;
		ticks = from;
		target = count;
		SetTickDir();
	}

	void ContinueTo (int count) {
		start = ticks;
		target = count;
		SetTickDir();
	}

	void Force (int count, int from = 0) {
		start = from;
		ticks = count;
		target = count;
		SetTickDir();
	}

	void ForceDone () {
		ticks = target;
	}

	void Next () {
		// ticks = clamp(ticks + tick_dir, start, target);
		old_delta = ticks;

		if(tick_dir < 0) {
			ticks = max(ticks - 1, target);
		}

		else {
			ticks = min(ticks + 1, target);
		}

		old_delta = old_delta - ticks;
	}

	void NextStep (int step) {
		old_delta = ticks;

		if(tick_dir < 0) {
			ticks = max(ticks - step, target);
		}

		else {
			ticks = min(ticks + step, target);
		}

		old_delta = old_delta - ticks;
	}

	void NextScaleStep (double f = 1) {
		old_delta = ticks;
		ticks = ticks + (target - ticks) * f;
		old_delta = ticks - old_delta;
	}

	int Now () const {
		return ticks;
	}

	int TargetTick () const {
		return target;
	}

	bool IsDone () const {
		return ticks == target;
	}

	bool IsCountdown () const {
		return tick_dir < 0;
	}

	bool IsCountup () const {
		return 0 < tick_dir;
	}

	// kd: This scales interval into the [0, 1] range, so if you decided to
	// tick from 50 to 100 and it's at 75, then this returns 0.5.
	/* double Normal () const {
		return (double)(ticks - start) / tick_delta;
	} */

	// This allows you to set the interval bounds and do the same as Normal.
	double RelNormal (int rel_start, int rel_target) const {
		return (double)(ticks - rel_start) / (rel_target - rel_start);
	}

	// Same as RelNormal, but you don't state the interval target, you instead
	// state "target - start".
	double RelNormalDelta (int rel_start, double rel_delta) const {
		return (ticks - rel_start) / rel_delta;
	}

	// This is a special case of Normal, where start is 0 (it's super common
	// for practically any animation).
	double StandardDelta (double delta) const {
		return ticks / delta;
	}

	// hu
	double Standard () const {
		return 1.0 * ticks / target;
	}

	// And this is StandardDelta, but you can pass in the RenderEvent fractic
	// field to get interpolated animation going without having to store the
	// old tick value.
	double RenderStandardDelta (double delta, double t) const {
		return
			ticks == target ?
				ticks / delta :
				(ticks + (1 - t) * old_delta) / delta;
	}

	// Same, but delta is the same as target, which is only really useful if
	// start was 0. So yea. But hey, it does come in handier than you think.
	double RenderStandardTarget (double t) const {
		return clamp((ticks + (1 - t) * old_delta) / max(start, target), 0, 1);
	}

	double RenderT (double t) const {
		return clamp((ticks + (1 - t) * old_delta) / target, 0, 1);
	}

	private void SetTickDir () {
		tick_dir = biom_MiscOps.IntSign(target - ticks);
	}
}

/*	KeksDose / MemeDose (kd):

	Same as the above, but can use floats.
*/

struct biom_FadeTickF {
	private double				ticks;
	private double				start;
	private double				target;
	private double				old_delta;
	private int					tick_dir;
	private int					tick_delta;
	private bool				is_done; // not so good...

	void Copy (biom_FadeTickF source) {
		ticks		= source.ticks;
		start		= source.start;
		target		= source.target;
		tick_dir	= source.tick_dir;
		old_delta	= source.old_delta;
		tick_delta	= source.tick_delta;
		is_done		= source.is_done;
	}

	void To (double count, double from = 0) {
		start = from;
		ticks = from;
		target = count;
		SetTickDir();
		is_done = false;
	}

	void ContinueTo (double count) {
		start = ticks;
		target = count;
		SetTickDir();
		is_done = false;
	}

	void Force (double count, double from = 0) {
		start = from;
		ticks = count;
		target = count;
		SetTickDir();
		is_done = false;
	}

	void ForceDone () {
		ticks = target;
		is_done = true;
	}

	void NextStep (double step) {
		old_delta = ticks;

		if(is_done) {
			return;
		}

		if(tick_dir < 0) {
			ticks = ticks - step;

			if(ticks < target) {
				ticks = target;
				is_done = true;
			}
		}

		else {
			ticks = ticks + step;

			if(target < ticks) {
				ticks = target;
				is_done = true;
			}
		}

		old_delta = ticks - old_delta;
	}

	int Now () const {
		return ticks;
	}

	bool IsDone () const {
		return is_done;
	}

	bool IsCountdown () const {
		return tick_dir < 0;
	}

	double RenderStandardDelta (double delta, double t = 1) const {
		return IsDone() ?
			ticks / delta :
			(ticks + (t - 1) * old_delta) / delta;
	}

	private void SetTickDir () {
		tick_dir = biom_MiscOps.IntSign(target - ticks);
	}
}
