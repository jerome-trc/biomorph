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
	}

	// Actions /////////////////////////////////////////////////////////////////

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
}

/// An approximate measure of how "good" a weapon is on a 1-to-5 scale. Used by
/// mutators to determine whether they constitute upgrades, downgrades, or
/// sidegrades relative to what the player is currently using.
enum biom_WeaponGrade : uint8
{
	/// The default; should only ever appear in normal code because someone forgot
	/// to set it. Considered invalid by other code and is cause for exception.
	BIOM_WEAPGRADE_NONE,
	BIOM_WEAPGRADE_1,
	BIOM_WEAPGRADE_2,
	/// An "average" weapon. Vanilla weapons would have this grade, and
	/// therefore it's the grade for all the player's normal starting weapons.
	BIOM_WEAPGRADE_3,
	BIOM_WEAPGRADE_4,
	BIOM_WEAPGRADE_5,
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
