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

	meta biom_WeaponGrade grade;
	property Grade: grade;

	meta biom_WeaponFamily FAMILY;
	property Family: FAMILY;

	/// Should never be `null`.
	meta class<biom_WeaponData> dataClass;
	property DataClass: dataClass;

	private uint dynFlags;
	flagdef hitGround: dynFlags, 0;
	// The last 4 flags (28 to 31) are reserved for derived classes.

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

		biom_Weapon.Grade BIOM_WEAPGRADE_NONE;
		biom_Weapon.Family __BIOM_WEAPFAM_COUNT__;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		stop;
	}

	// Virtual/abstract methods ////////////////////////////////////////////////

	/// Should return:
	/// 1. Whether the weapon has a magazine.
	/// 2. The magazine's current quantity.
	/// 3. The magazine's capacity.
	virtual bool, int, int GetMagazine(bool secondary = false) const
	{
		return false, -1, -1;
	}

	virtual ui void DrawToHUD(biom_StatusBar sbar) const {}

	// Actions /////////////////////////////////////////////////////////////////

	protected action state A_biom_CheckAmmo(
		bool secondary = false,
		statelabel fallback = 'Ready.Main',
		statelabel reload = 'Reload',
		statelabel dryfire = 'Dryfire'
	)
	{
		if (invoker.SufficientAmmo(secondary))
			return state(null);

		let cv = biom_CVar.AutoReloadPre(invoker.owner.player);

		if (!invoker.HasMagazine())
		{
			state dfs = ResolveState(dryfire);

			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}

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

	protected action void A_biom_Recoil(
		class<biom_RecoilThinker> recoil_t,
		float scale = 1.0,
		bool invert = false
	)
	{
		biom_RecoilThinker.Create(recoil_t, biom_Weapon(invoker), scale, invert);
	}

	/// Use to assert that state machine flow does not fall through unintentionally.
	protected action void A_Unreachable()
	{
		Biomorph.Unreachable("unexpected state flow fallthrough.");
	}

	// Ammo helpers ////////////////////////////////////////////////////////////

	bool SufficientAmmo(bool secondary = false) const
	{
		if (self.CheckInfiniteAmmo())
			return true;

		int magazine = -1, capacity = -1;
		bool hasMagazine = false;
		[hasMagazine, magazine, capacity] = self.GetMagazine(secondary);

		if (!secondary)
		{
			if (hasMagazine)
				return magazine >= self.ammoUse1;
			else if (self.ammo1 != null)
				return self.ammo1.amount >= self.ammoUse1;
			else
				return true;
		}
		else
		{
			if (hasMagazine)
				return magazine >= self.ammoUse2;
			else if (self.ammo2 != null)
				return self.ammo2.amount >= self.ammoUse2;
			else
				return true;
		}
	}

	bool CheckInfiniteAmmo() const
	{
		if (sv_infiniteammo)
			return true;

		return self.owner != null && self.owner.FindInventory('PowerInfiniteAmmo', true) != null;
	}

	bool HasMagazine(bool secondary = false) const
	{
		int magazine = -1, capacity = -1;
		bool hasMagazine = false;
		[hasMagazine, magazine, capacity] = self.GetMagazine(secondary);
		return hasMagazine;
	}
}

/// An approximate measure of how "good" a weapon is on a 1-to-3 scale.
/// Affects only the number of mutation slots the weapon gets; better weapons
/// have less room for modification, such that the difference between low- and
/// high-grade weapons can be equalized by such modification.
enum biom_WeaponGrade : uint8
{
	/// The default; should only ever appear in normal code because someone forgot
	/// to set it. Considered invalid by other code and is cause for exception.
	BIOM_WEAPGRADE_NONE,
	/// This weapon gets 4 mutation slots.
	BIOM_WEAPGRADE_1,
	/// This weapon gets 2 mutation slots.
	BIOM_WEAPGRADE_2,
	/// This weapon gets 1 mutation slot.
	BIOM_WEAPGRADE_3,
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
	BIOM_WEAPFAM_MELEE = 0,
	BIOM_WEAPFAM_SIDEARM = 1,
	BIOM_WEAPFAM_SHOTGUN = 2,
	BIOM_WEAPFAM_SUPERSHOTGUN = 3,
	BIOM_WEAPFAM_AUTOGUN = 4,
	BIOM_WEAPFAM_LAUNCHER = 5,
	BIOM_WEAPFAM_ENERGY = 6,
	BIOM_WEAPFAM_SUPER = 7,
	__BIOM_WEAPFAM_COUNT__,
}
