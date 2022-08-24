class BIO_WeaponOperatingMode play abstract
{
	Array<BIO_WeaponPipeline> Pipelines;
	Array<BIO_StateTimeGroup> FireTimeGroups;

	protected uint8 BurstCount, BurstClock;

	abstract class<BIO_Weapon> WeaponType() const;

	// For setting up reload time groups, and any internal fields.
	virtual void Init(readOnly<BIO_Weapon> weap) {}
	// Called by `BIO_Weapon::LazyInit()` after
	// `SetDefaults()` and `IntrinsicModGraph()`.
	virtual void SideEffects(BIO_Weapon weap) const {}

	abstract statelabel EntryState() const;
	virtual statelabel ClosingState() const { return '_'; }

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

	virtual BIO_WeaponOperatingMode Copy() const
	{
		let ret = BIO_WeaponOperatingMode(new(GetClass()));
		ret.BurstCount = BurstCount;

		for (uint i = 0; i < Pipelines.Size(); i++)
			ret.Pipelines.Push(Pipelines[i].Copy());
		for (uint i = 0; i < FireTimeGroups.Size(); i++)
			ret.FireTimeGroups.Push(FireTimeGroups[i].Copy());

		return ret;
	}

	void SetBurstCount(uint burstCount)
	{
		self.BurstCount = Clamp(burstCount, 1, 5);
	}

	// Returns `true` if the current burst is finished.
	bool CheckBurst()
	{
		if (++BurstClock >= BurstCount)
		{
			BurstClock = 0;
			return true;
		}

		return false;
	}

	// Functions only implemented by certain sub-classes of operating mode,
	// provided universally for brevity on the caller's side.

	// Returns `true` if the current burst is finished.
	virtual bool CheckInterlude() { return false; }
	virtual void ResetInterlude() {}

	virtual void NextSpoolStage() { }
	virtual uint GetSpoolStage() const { return uint.MAX; }

	// Introspective helpers ///////////////////////////////////////////////////

	bool FireTimesReducible() const
	{
		// State sequences can't have all of their tic times reduced to 0.
		// Fire rate-affecting affixes must know in advance if
		// they can even have any effect, given this caveat.
		for (uint i = 0; i < FireTimeGroups.Size(); i++)
			if (FireTimeGroups[i].PossibleReduction() > 1)
				return true;

		return false;
	}

	bool FireTimesMutable() const
	{
		return FireTimeGroups.Size() > 0 && FireTimesReducible();
	}

	bool DealsAnyHitDamage() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DealsAnyHitDamage())
				return true;

		return false;
	}

	bool DealsAnySplashDamage() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DealsAnySplashDamage())
				return true;

		return false;
	}

	bool AnyPipelineFiresPayload(class<Actor> payload, bool subclass = false) const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
		{
			if (subclass)
			{
				if (Pipelines[i].Payload is payload)
					return true;
			}
			else
			{
				if (Pipelines[i].Payload == payload)
					return true;
			}
		}

		return false;
	}
}

mixin class BIO_OpMode_Assertions_HybridBurst
{
	final override bool CheckInterlude()
	{
		ThrowAbortException(
			Biomorph.LOGPFX_ERR ..
			"`BIO_WeaponOperatingMode::CheckInterlude()` was called "
			"on a class instance not derived from `BIO_OpMode_HybridBurst`."
		);

		return false;
	}

	final override void ResetInterlude()
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
	final override void NextSpoolStage()
	{
		ThrowAbortException(
			Biomorph.LOGPFX_ERR ..
			"`BIO_WeaponOperatingMode::NextSpoolStage()` was called "
			"on a class instance not derived from `BIO_OpMode_StagedSpool`."
		);
	}

	final override uint GetSpoolStage() const
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

	private uint8 InterludeClock;

	final override bool CheckInterlude()
	{
		return ++InterludeClock >= 6;
	}

	final override void ResetInterlude()
	{
		InterludeClock = 0;
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
	
	private uint8 CurStage;

	final override void NextSpoolStage()
	{
		CurStage++;
	}

	final override uint GetSpoolStage() const
	{
		return CurStage;
	}
}

// Hold fire input to start charging, and release to fire one round.
// Purely a downside for non-melee weapons; compensate with other benefits.
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
