class biom_RecoilThinker : Thinker abstract
{
	protected biom_Weapon weapon;
	protected int lifetime, timeToLive;
	protected float scale;

	abstract float GetPitch(int lifeTic) const;

	static biom_RecoilThinker Create(
		class<biom_RecoilThinker> type,
		biom_Weapon weap,
		float scale = 1.0,
		bool invert = false
	)
	{
		let ret = biom_RecoilThinker(new(type));
		ret.Weapon = weap;
		ret.Scale = scale;

		if (invert)
			ret.Scale = -ret.Scale;

		return ret;
	}

	override void Tick()
	{
		super.Tick();

		if (self.lifetime >= self.timeToLive ||
			self.weapon == null ||
			self.weapon.owner == null
		)
		{
			if (!self.bDestroyed)
				Destroy();

			return;
		}

		self.weapon.owner.pitch += (self.GetPitch(self.lifetime++) * self.scale);
	}
}

mixin class biom_RecoilImpl
{
	final override void PostBeginPlay()
	{
		super.PostBeginPlay();
		self.timeToLive = Self.PITCH_VALUES.Size();
	}

	final override float GetPitch(int lifeTic) const
	{
		return Self.PITCH_VALUES[lifeTic];
	}
}

class biom_recoil_Rake : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.05, -0.2, -0.4, 0.3, 0.15, 0.1, 0.07, 0.03
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_Handgun : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.8, -0.1, 0.15, 0.3, 0.35, 0.07, 0.02, 0.01
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_Shotgun : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-1.4, -0.1, 0.15, 0.65, 0.5, 0.17, 0.02, 0.01
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_DoubleShotgun : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-2.3, -0.1, 0.05, 1.25, 0.7, 0.37, 0.03
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_Autogun : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.45, 0.05, 0.35
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_RapidFire : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.2, 0.2
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_Heavy : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-2.55, -0.45, 0.05, 1.04, 0.7, 0.39, 0.31, 0.25, 0.2, 0.07, 0.01
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_BFG : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-2.75, -0.5, 0.05, 1.25, 0.7, 0.43, 0.3, 0.29, 0.18, 0.05
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_ShotgunPump : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		0.05, 0.23, 0.08, -0.06, -0.28, -0.02
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_HeavyReload : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.85, -0.1, -0.05, 0.3, 0.25, 0.15, 0.1, 0.05, 0.02, 0.01
	};

	mixin biom_RecoilImpl;
}

class biom_recoil_ChainsawIdle : biom_RecoilThinker
{
	static const float[] PITCH_VALUES = {
		-0.05, -0.2, -0.05, -0.02, 0.05, 0.2, 0.05, 0.02
	};

	mixin biom_RecoilImpl;
}
