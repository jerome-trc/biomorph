class BIO_WeaponOperatingMode play abstract
{
	Array<BIO_StateTimeGroup> FireTimeGroups;

	protected uint8 BurstCount;
	protected uint8 BurstClock1, BurstClock2;

	abstract class<BIO_Weapon> WeaponType() const;

	// For setting up reload time groups, and any internal fields.
	virtual void Init(readOnly<BIO_Weapon> weap) {}
	abstract statelabel FireState() const;

	// Called by `BIO_Weapon::LazyInit()` after
	// `SetDefaults()` and `IntrinsicModGraph()`.
	virtual void SideEffects(BIO_Weapon weap) const {}
	virtual statelabel PostFireState() const { return '_'; }

	virtual string Tag() const { return ""; }

	void SetBurstCount(uint burstCount)
	{
		self.BurstCount = Clamp(burstCount, 1, 5);
	}

	// Returns `true` if the current burst is finished.
	bool CheckBurst(bool secondary = false)
	{
		if (!secondary)
		{
			if (++BurstClock1 >= BurstCount)
			{
				BurstClock1 = 0;
				return true;
			}

			return false;
		}
		else
		{
			if (++BurstClock2 >= BurstCount)
			{
				BurstClock2 = 0;
				return true;
			}

			return false;
		}
	}

	// Functions only implemented by certain sub-classes of operating mode,
	// provided universally for brevity on the caller's side.

	// Returns `true` if the current burst is finished.
	virtual bool CheckInterlude(bool secondary = false) { return false; }
	virtual void ResetInterlude(bool secondary = false) {}

	virtual void NextSpoolStage(bool secondary = false) { }
	virtual uint GetSpoolStage(bool secondary = false) { return uint.MAX; }

	static BIO_WeaponOperatingMode Create(
		class<BIO_WeaponOperatingMode> t,
		BIO_Weapon weap
	)
	{
		let ret = BIO_WeaponOperatingMode(new(t));
		ret.BurstCount = 1;
		ret.Init(weap.AsConst());
		return ret;
	}
}

mixin class BIO_OpMode_Assertions_HybridBurst
{
	final override bool CheckInterlude(bool secondary)
	{
		ThrowAbortException(
			Biomorph.LOGPFX_ERR ..
			"`BIO_WeaponOperatingMode::CheckInterlude()` was called "
			"on a class instance not derived from `BIO_OpMode_HybridBurst`."
		);

		return false;
	}

	final override void ResetInterlude(bool secondary)
	{
		ThrowAbortException(
			Biomorph.LOGPFX_ERR ..
			"`BIO_WeaponOperatingMode::ResetInterlude()` was called "
			"on a class instance not derived from `BIO_OpMode_HybridBurst`."
		);
	}
}

mixin class BIO_OpMode_Assertions_StagedSpool
{
	final override void NextSpoolStage(bool secondary)
	{
		ThrowAbortException(
			Biomorph.LOGPFX_ERR ..
			"`BIO_WeaponOperatingMode::NextSpoolStage()` was called "
			"on a class instance not derived from `BIO_OpMode_StagedSpool`."
		);
	}

	final override uint GetSpoolStage(bool secondary)
	{
		ThrowAbortException(
			Biomorph.LOGPFX_ERR ..
			"`BIO_WeaponOperatingMode::GetSpoolStage()` was called "
			"on a class instance not derived from `BIO_OpMode_StagedSpool`."
		);

		return uint.MAX;
	}
}

// Fully-automatic. Simple and common.
class BIO_OpMode_Rapid : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_HybridBurst;
	mixin BIO_OpMode_Assertions_StagedSpool;
}

// Start with a 2/3/4/5-round burst. Afterwards, switch to a
// slower full-auto mode. Inspired by Final Doomer's Burst Needler.
class BIO_OpMode_HybridBurst : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_StagedSpool;

	private uint8 InterludeClock1, InterludeClock2;

	final override bool CheckInterlude(bool secondary)
	{
		if (!secondary)
			return ++InterludeClock1 >= 6;
		else
			return ++InterludeClock2 >= 6;
	}

	final override void ResetInterlude(bool secondary)
	{
		if (!secondary)
			InterludeClock1 = 0;
		else
			InterludeClock2 = 0;
	}
}

// Only a few rounds between reloads, but those reloads are extremely fast.
class BIO_OpMode_SmallMag : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_HybridBurst;
	mixin BIO_OpMode_Assertions_StagedSpool;
}

// Hold fire input to starting spooling; weapon waits until full spool
// to begin firing, with no complexity beyond this.
class BIO_OpMode_BinarySpool : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_HybridBurst;
	mixin BIO_OpMode_Assertions_StagedSpool;
}

// Hold fire input to start spooling. Firing can start at any of multiple stage
// of winding, with different rates of fire/special effects per stage.
class BIO_OpMode_StagedSpool : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_HybridBurst;
	
	private uint8 CurStage1, CurStage2;

	final override void NextSpoolStage(bool secondary)
	{
		if (!secondary)
			CurStage1++;
		else
			CurStage2++;
	}

	final override uint GetSpoolStage(bool secondary)
	{
		return !secondary ? CurStage1 : CurStage2;
	}
}

// Hold fire input to start charging, and release to fire one round.
// Purely a downside for non-melee weapon; compensate with other benefits.
class BIO_OpMode_HoldRelease : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_HybridBurst;
	mixin BIO_OpMode_Assertions_StagedSpool;
}

// Like hold-release, but ammunition leaves magazine/reserve and enters a buffer.
// The longer the user holds the fire input, the more rounds come out upon release.
class BIO_OpMode_Buffered : BIO_WeaponOperatingMode abstract
{
	mixin BIO_OpMode_Assertions_HybridBurst;
	mixin BIO_OpMode_Assertions_StagedSpool;
}
