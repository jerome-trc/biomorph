class biom_Alterant abstract
{
	abstract void Apply(biom_Player pawn) const;
	/// If returning `false`, also return a string (localization not necessary)
	/// explaining to the user why this alterant is incompatible.
	abstract bool, string Compatible(readonly<biom_Player> pawn) const;
	/// Positive return values means this alterant makes the player stronger;
	/// negative return values means this alterant makes the player weaker.
	abstract int Balance() const;
	/// If returning `false`, whether this alterant is an upgrade or downgrade
	/// is determined by the return value of `Balance`. If that returns 0,
	/// this alterant is considered a sidegrade regardless of the return value
	/// of this function.
	abstract bool IsSidegrade() const;

	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Tag() const;
	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Summary() const;
	/// Output can be null.
	abstract textureID Icon() const;
}

/// Whereas one prototype instance for each direct subtype of `biom_Alterant` is
/// stored, the set of prototype instances kept for each subtype of this class is
/// the Cartesian product of all subtypes of this class and all subtypes of
/// `biom_Weapon`.
///
/// This is primarily for use in alterants which unregister a weapon from the player's
/// arsenal (specifically the one of `biom_WeaponAlterant::weaponType`) to replace
/// it with a new one.
class biom_WeaponAlterant : biom_Alterant abstract
{
	class<biom_Weapon> weaponType;
}

const BIOM_BALMOD_INC_XS = 1;
const BIOM_BALMOD_INC_S = 5;
const BIOM_BALMOD_INC_M = 10;
const BIOM_BALMOD_INC_L = 20;
const BIOM_BALMOD_INC_XL = 40;
const BIOM_BALMOD_DEC_XS = -BIOM_BALMOD_INC_XS;
const BIOM_BALMOD_DEC_S = -BIOM_BALMOD_INC_S;
const BIOM_BALMOD_DEC_M = -BIOM_BALMOD_INC_M;
const BIOM_BALMOD_DEC_L = -BIOM_BALMOD_INC_L;
const BIOM_BALMOD_DEC_XL = -BIOM_BALMOD_INC_XL;
