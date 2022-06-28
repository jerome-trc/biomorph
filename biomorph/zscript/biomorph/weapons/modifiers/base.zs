enum BIO_WeapModRepeatRules : uint8
{
	// This weapon modifier can not or should not be repeated.
	BIO_WMODREPEATRULES_NONE,
	// This weapon modifier will be repeated by calling `Apply()` multiple times.
	BIO_WMODREPEATRULES_EXTERNAL,
	// `Apply()` will only get called once and handle `Count` on its own.
	BIO_WMODREPEATRULES_INTERNAL
}

// Flags curently only really exist so that weapon morph recipes can check how
// many of a graph's modifiers affect one particular facet of the weapon.

enum BIO_WeaponModFlags : uint
{
	BIO_WMODF_NONE = 0,
	// Core stats; inherited from `Weapon` e.g. ammo-type or part of `BIO_Weapon`
	BIO_WMODF_KICKBACK_INC = 1 << 0,
	BIO_WMODF_KICKBACK_DEC = 1 << 1,
	BIO_WMODF_SWITCHSPEED_INC = 1 << 2,
	BIO_WMODF_SWITCHSPEED_DEC = 1 << 3,
	BIO_WMODF_AMMOTYPE = 1 << 4,
	BIO_WMODF_AMMOUSE_INC = 1 << 5,
	BIO_WMODF_AMMOUSE_DEC = 1 << 6,
	BIO_WMODF_MAGTYPE = 1 << 7,
	BIO_WMODF_MAGSIZE_INC = 1 << 8,
	BIO_WMODF_MAGSIZE_DEC = 1 << 9,
	// Timing
	BIO_WMODF_FIRETIME_INC = 1 << 10,
	BIO_WMODF_FIRETIME_DEC = 1 << 11,
	BIO_WMODF_RELOADTIME_INC = 1 << 12,
	BIO_WMODF_RELOADTIME_DEC = 1 << 13,
	// Pipeline, general
	BIO_WMODF_PAYLOAD_NEW = 1 << 14,
	BIO_WMODF_PAYLOAD_ALTER = 1 << 15,
	BIO_WMODF_SHOTCOUNT_INC = 1 << 16,
	BIO_WMODF_SHOTCOUNT_DEC = 1 << 17,
	BIO_WMODF_DAMAGE_INC = 1 << 18,
	BIO_WMODF_DAMAGE_DEC = 1 << 19,
	BIO_WMODF_SPREAD_INC = 1 << 20,
	BIO_WMODF_SPREAD_DEC = 1 << 21,
	BIO_WMODF_SPLASHDAMAGE_INC = 1 << 22,
	BIO_WMODF_SPLASHDAMAGE_DEC = 1 << 23,
	BIO_WMODF_SPLASHRADIUS_INC = 1 << 24,
	BIO_WMODF_SPLASHRADIUS_DEC = 1 << 25,
	BIO_WMODF_PROJSPEED_INC = 1 << 26,
	BIO_WMODF_PROJSPEED_DEC = 1 << 27,
	// Pipeline, melee-exclusive
	BIO_WMODF_LIFESTEAL_INC = 1 << 28,
	BIO_WMODF_LIFESTEAL_DEC = 1 << 29,
	BIO_WMODF_MELEERANGE_INC = 1 << 30,
	BIO_WMODF_MELEERANGE_DEC = 1 << 31
}

struct BIO_GeneContext
{
	readOnly<BIO_Weapon> Weap;
	
	// Loaded with `BIO_WeaponModSimNode::Multiplier`.
	uint NodeCount;
	// Total number of times this gene type is present on the graph,
	// including the gene receiving the argument.
	uint TotalCount;
	// If true, this is the first time this gene has been hit
	// during a compatibility check or application.
	bool First;
}

class BIO_WeaponModifier play abstract
{
	// If returning `false`, also return a string (localization not necessary)
	// explaining to the user why this modifier is incompatible.
	abstract bool, string Compatible(BIO_GeneContext context) const;

	// Effects have to be deterministic.
	// Optionally return a message to attach to the node.
	abstract string Apply(BIO_Weapon weap, BIO_GeneContext context) const;

	// Explains what this modifier is doing to the weapon at the moment.
	abstract string Description(BIO_GeneContext context) const;

	abstract BIO_WeaponModFlags Flags() const;

	abstract class<BIO_ModifierGene> GeneType() const;

	// If your modifier keeps data to facilitate writing its description,
	// make sure this transfers a copy of that data.
	virtual BIO_WeaponModifier Copy() const
	{
		return BIO_WeaponModifier(new(GetClass()));
	}

	readOnly<BIO_WeaponModifier> AsConst() const { return self; }

	// Helpers /////////////////////////////////////////////////////////////////

	string Summary() const
	{
		return GetDefaultByType(GeneType()).Summary;
	}
}
