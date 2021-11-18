class BIO_RecoilThinker : Thinker abstract
{
	protected BIO_Weapon Weapon;
	protected int Lifetime, TimeToLive;
	protected float Scale;

	private virtual void Init() {}
	abstract float GetPitch(int lifeTic) const;

	static BIO_RecoilThinker Create(
		Class<BIO_RecoilThinker> type, BIO_Weapon weap,
		float scale = 1.0, bool invert = false)
	{
		let ret = BIO_RecoilThinker(new(type));
		ret.Weapon = weap;
		ret.Scale = scale;
		if (invert) ret.Scale = -ret.Scale;
		ret.Init();
		return ret;
	}

	override void Tick()
	{
		super.Tick();

		if (Lifetime >= TimeToLive)
		{
			if (!bDestroyed) Destroy();
			return;
		}

		Weapon.Owner.Pitch += (GetPitch(Lifetime++) * Scale);
	}
}

// =============================================================================
// Assume all values henceforth have been stolen from Yholl's DRLA
// (much like half of this mod conceptually)

class BIO_HandgunRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.8, -0.1, 0.15, 0.3, 0.35, 0.07, 0.02, 0.01
	};

	override void Init() { TimeToLive = 8; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_HandCannonRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-1.3, -0.1, 0.15, 0.3, 0.65, 0.27, 0.02, 0.01
	};

	override void Init() { TimeToLive = 8; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_ShotgunRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-1.4, -0.1, 0.15, 0.65, 0.5, 0.17, 0.02, 0.01
	};

	override void Init() { TimeToLive = 8; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_SuperShotgunRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-2.3, -0.1, 0.05, 1.25, 0.7, 0.37, 0.03
	};

	override void Init() { TimeToLive = 7; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_AutogunRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.45, 0.05, 0.35
	};

	override void Init() { TimeToLive = 3; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_RapidFireRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.2, 0.2
	};

	override void Init() { TimeToLive = 2; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_RocketLauncherRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-2.55, -0.45, 0.05, 1.04, 0.7, 0.39, 0.31, 0.25, 0.2, 0.07, 0.01
	};

	override void Init() { TimeToLive = 11; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_BFGRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-2.75, -0.5, 0.05, 1.25, 0.7, 0.43, 0.3, 0.29, 0.18, 0.05
	};

	override void Init() { TimeToLive = 10; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_VolleyGunRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-4.6, -0.2, 0.1, 2.5, 1.4, 0.74, 0.06
	};

	override void Init() { TimeToLive = 7; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_ShotgunPumpRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		0.05, 0.23, 0.08, -0.06, -0.28, -0.02
	};

	override void Init() { TimeToLive = 6; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

class BIO_HeavyReloadRecoil : BIO_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.85, -0.1, -0.05, 0.3, 0.25, 0.15, 0.1, 0.05, 0.02, 0.01
	};

	override void Init() { TimeToLive = 10; }
	override float GetPitch(int lifeTic) const { return PITCH_VALUES[lifeTic]; }
}

/*
First try at a purely-procedural implementation, kept as an artifact.

class BIO_RecoilThinker : Thinker
{
	private BIO_Weapon Weapon;
	private int Lifetime, TimeToLive;
	private float Scale;

	static BIO_RecoilThinker Create(BIO_Weapon weap, float scale, int timeToLive = 8)
	{
		let ret = new('BIO_RecoilThinker');
		ret.Weapon = weap;
		ret.Scale = scale;
		ret.TimeToLive = timeToLive;
		return ret;
	}

	override void Tick()
	{
		super.Tick();

		if (Lifetime++ >= TimeToLive)
		{
			if (!bDestroyed) Destroy();
			return;
		}

		Weapon.Owner.Pitch -= Sin(float(Lifetime * 64)) * Scale;
	}
}
*/