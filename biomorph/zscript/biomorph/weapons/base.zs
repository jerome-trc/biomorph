class biom_Weapon : DoomWeapon abstract
{
	// `SelectionOrder` is for when ammo runs out; lower number, higher priority.

	const SELORDER_PLASRIFLE = 100;
	const SELORDER_SSG = 400;
	const SELORDER_CHAINGUN = 700;
	const SELORDER_SHOTGUN = 1300;
	const SELORDER_PISTOL = 1900;
	const SELORDER_CHAINSAW = 2200;
	const SELORDER_RLAUNCHER = 2500;
	const SELORDER_BFG = 2800;
	const SELORDER_FIST = 3700;

	// `SlotPriority` is for manual selection; higher number, higher priority.

	const SLOTPRIO_MAX = 1.0;
	const SLOTPRIO_HIGH = 0.6;
	const SLOTPRIO_LOW = 0.3;
	const SLOTPRIO_MIN = 0.0;

	meta biom_WeaponFamily FAMILY;
	property Family: FAMILY;

	/// Should never be `null`.
	meta class<biom_WeaponData> DATA_CLASS;
	property DataClass: DATA_CLASS;

	private uint dynFlags;
	flagdef hitGround: dynFlags, 0;
	// The last 4 flags (28 to 31) are reserved for derived classes.

	protected readonly<biom_WeaponData> data;

	Default
	{
		-SPECIAL
		+DONTGIB
		+NOBLOCKMONST
		+THRUACTORS
		+INVENTORY.UNDROPPABLE
		+WEAPON.ALT_AMMO_OPTIONAL
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT

		Height 8;
		Radius 16;

		Inventory.PickupMessage "";
		Inventory.RestrictedTo 'biom_Player';

		Weapon.BobStyle 'InverseSmooth';
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobSpeed 2.0;

		biom_Weapon.Family BIOM_WEAPFAM_INVALID;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		stop;
	}

	// Overrides ///////////////////////////////////////////////////////////////

	override void AttachToOwner(Actor other)
	{
		super.AttachToOwner(other);

		let pawn = biom_Player(other);

		if (pawn == null)
			return;

		let pdat = pawn.GetOrInitData();

		// See `biom_Player::PostBeginPlay`.
		if (pdat == null)
			return;

		self.data = pdat.GetWeaponData(self.DATA_CLASS);
	}

	override void DetachFromOwner()
	{
		super.DetachFromOwner();
		self.data = null;
	}

	// Virtual/abstract methods ////////////////////////////////////////////////

	/// If you are overriding this, it should return `true`.
	virtual bool GetMagazine(in out biom_Magazine data, bool secondary = false) const
	{
		return false;
	}

	virtual void FillMagazine(uint amt) {}

	virtual ui void DrawToHUD(biom_StatusBar sbar) const {}

	// Actions /////////////////////////////////////////////////////////////////

	protected action state A_biom_CheckAmmo(
		bool secondary = false,
		int multi = 1,
		statelabel fallback = 'Ready.Main',
		statelabel reload = 'Reload',
		statelabel dryfire = 'Dryfire'
	)
	{
		if (invoker.EnoughAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
		{
			state dfs = ResolveState(dryfire);

			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}

		let cv = biom_CVar.AutoReloadPre(invoker.owner.player);

		if (cv == BIOM_CV_AUTOREL_ALWAYS)
		{
			return ResolveState(reload);
		}
		else
		{
			state dfs = ResolveState(dryfire);

			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}
	}

	/// Call on a `TNT1 A 0` state at the beginning of a `Reload` state sequence.
	protected action state A_biom_CheckReload(
		bool secondary = false,
		statelabel fallback = 'Ready.Main'
	)
	{
		if (invoker.CanReload(secondary))
			return state(null);
		else
			return ResolveState(fallback);
	}

	protected action void A_biom_Recoil(
		class<biom_RecoilThinker> recoil_t,
		float scale = 1.0,
		bool invert = false
	)
	{
		biom_RecoilThinker.Create(recoil_t, biom_Weapon(invoker), scale, invert);
	}

	protected action void A_biom_Reload(
		uint amt = 0,
		bool secondary = false
	)
	{
		biom_Magazine mag;

		if (!invoker.GetMagazine(mag, secondary))
			Biomorph.Unreachable("Tried to reload a magazine-less weapon.");

		if (mag.current >= mag.max)
			return;

		class<Ammo> reserve_t = !secondary ? invoker.ammoType1 : invoker.ammoType2;
		int reserve = invoker.owner.CountInv(reserve_t);
		int toLoad = -1, toDraw = -1;

		if (amt > 0)
		{
			toLoad = amt * mag.output;
		}
		else
		{
			toLoad = mag.max - mag.current;
			toLoad = int(Floor(float(toLoad) / float(mag.output)));
		}

		toDraw = Min(toLoad * mag.cost, reserve);
		toLoad = Min(toLoad, toDraw) * mag.output;
		invoker.owner.TakeInventory(reserve_t, toDraw);
		invoker.FillMagazine(toLoad);
	}

	/// Use to assert that state machine flow does not fall through unintentionally.
	protected action void A_Unreachable()
	{
		Biomorph.Unreachable("unexpected state flow fallthrough.");
	}

	// Ammo helpers ////////////////////////////////////////////////////////////

	bool CanReload(bool secondary = false) const
	{
		biom_Magazine m;

		if (!self.GetMagazine(m, secondary))
			return false;

		if (m.current >= m.max)
			return false;

		Ammo reserve = !secondary ? self.ammo1 : self.ammo2;

		if (reserve == null)
			return true; // e.g. sidearms.

		return reserve.amount >= m.cost;
	}

	bool CheckInfiniteAmmo() const
	{
		if (sv_infiniteammo)
			return true;

		return
			self.owner != null &&
			self.owner.FindInventory('PowerInfiniteAmmo', true) != null;
	}

	bool HasMagazine(bool secondary = false) const
	{
		biom_Magazine m;
		return self.GetMagazine(m, secondary);
	}

	/// i.e. to fire a round.
	bool EnoughAmmo(bool secondary = false, int multi = 1) const
	{
		if (self.CheckInfiniteAmmo())
			return true;

		biom_Magazine mag;
		bool hasMagazine = self.GetMagazine(mag, secondary);

		if (!secondary)
		{
			if (hasMagazine)
				return mag.current >= (self.ammoUse1 * multi);
			else if (self.ammo1 != null)
				return self.ammo1.amount >= (self.ammoUse1 * multi);
			else
				return true;
		}
		else
		{
			if (hasMagazine)
				return mag.current >= (self.ammoUse2 * multi);
			else if (self.ammo2 != null)
				return self.ammo2.amount >= (self.ammoUse2 * multi);
			else
				return true;
		}
	}
}

/// The source of truth for a weapon's stats and behavior.
/// - Every weapon subclasses this once.
/// - Every player has one per weapon.
class biom_WeaponData abstract
{
	/// For setting values to their defaults.
	abstract void Reset();

	readonly<biom_WeaponData> AsConst() const
	{
		return self;
	}
}

/// Corresponds loosely to the weapon's slot number but accounts for the
/// difference between shotgun counterparts and super shotgun counterparts,
/// both of which occupy slot number 3.
enum biom_WeaponFamily : uint8
{
	BIOM_WEAPFAM_INVALID = 0,
	BIOM_WEAPFAM_MELEE = 1 << 0,
	BIOM_WEAPFAM_SIDEARM = 1 << 1,
	BIOM_WEAPFAM_SHOTGUN = 1 << 2,
	BIOM_WEAPFAM_SUPERSHOTGUN = 1 << 3,
	BIOM_WEAPFAM_AUTOGUN = 1 << 4,
	BIOM_WEAPFAM_LAUNCHER = 1 << 5,
	BIOM_WEAPFAM_ENERGY = 1 << 6,
	BIOM_WEAPFAM_SUPER = 1 << 7,
	BIOM_WEAPFAM_ALL = uint8.MAX,
}

/// A helper structure allowing weapons to succinctly report the "interface"
/// of their magazine code.
struct biom_Magazine
{
	uint current, max, cost, output;
}
