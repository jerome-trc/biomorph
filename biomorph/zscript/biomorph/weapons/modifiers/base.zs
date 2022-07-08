enum BIO_WeapModRepeatRules : uint8
{
	// This weapon modifier can not or should not be repeated.
	BIO_WMODREPEATRULES_NONE,
	// This weapon modifier will be repeated by calling `Apply()` multiple times.
	BIO_WMODREPEATRULES_EXTERNAL,
	// `Apply()` will only get called once and handle `Count` on its own.
	BIO_WMODREPEATRULES_INTERNAL
}

// Flags exist so that modifiers can inspect if, for instance, a weapon has already
// had gravity or bounce applied to it, and so weapon morph recipes can check 
// how many of a graph's modifiers affect one particular facet of the weapon.

// Anything inherited from `Weapon` (e.g. ammo type) or part of `BIO_Weapon`.
enum BIO_WeaponCoreModFlags : uint
{
	BIO_WCMF_NONE = 0,
	// Miscellaneous
	BIO_WCMF_KICKBACK_INC = 1 << 0,
	BIO_WCMF_KICKBACK_DEC = 1 << 1,
	BIO_WCMF_SWITCHSPEED_INC = 1 << 2,
	BIO_WCMF_SWITCHSPEED_DEC = 1 << 3,
	// Ammo- and magazine-related
	BIO_WCMF_AMMOTYPE = 1 << 4,
	BIO_WCMF_AMMOUSE_INC = 1 << 5,
	BIO_WCMF_AMMOUSE_DEC = 1 << 6,
	BIO_WCMF_RELOADCOST_INC = 1 << 7,
	BIO_WCMF_RELOADCOST_DEC = 1 << 8,
	BIO_WCMF_RELOADOUTPUT_INC = 1 << 9,
	BIO_WCMF_RELOADOUTPUT_DEC = 1 << 10,
	BIO_WCMF_MAGTYPE = 1 << 11,
	BIO_WCMF_MAGSIZE_INC = 1 << 12,
	BIO_WCMF_MAGSIZE_DEC = 1 << 13,
	// Timing
	BIO_WCMF_FIRETIME_INC = 1 << 14,
	BIO_WCMF_FIRETIME_DEC = 1 << 15,
	BIO_WCMF_RELOADTIME_INC = 1 << 16,
	BIO_WCMF_RELOADTIME_DEC = 1 << 17
}

enum BIO_WeaponPipelineModFlags : uint
{
	BIO_WPMF_NONE = 0,
	BIO_WPMF_PAYLOAD_NEW = 1 << 0,
	BIO_WPMF_PAYLOAD_ALTER = 1 << 1,
	BIO_WPMF_SHOTCOUNT_INC = 1 << 2,
	BIO_WPMF_SHOTCOUNT_DEC = 1 << 3,
	BIO_WPMF_DAMAGE_INC = 1 << 4,
	BIO_WPMF_DAMAGE_DEC = 1 << 5,
	BIO_WPMF_SPREAD_INC = 1 << 6,
	BIO_WPMF_SPREAD_DEC = 1 << 7,
	BIO_WPMF_SPLASHDAMAGE_INC = 1 << 8,
	BIO_WPMF_SPLASHDAMAGE_DEC = 1 << 9,
	BIO_WPMF_SPLASHRADIUS_INC = 1 << 10,
	BIO_WPMF_SPLASHRADIUS_DEC = 1 << 11,
	BIO_WPMF_SPLASHREMOVE = BIO_WPMF_SPLASHDAMAGE_DEC | BIO_WPMF_SPLASHRADIUS_DEC,
	BIO_WPMF_PROJSPEED_INC = 1 << 12,
	BIO_WPMF_PROJSPEED_DEC = 1 << 13,
	BIO_WPMF_GRAVITY_ADD = 1 << 14,
	BIO_WPMF_GRAVITY_REMOVE = 1 << 15,
	BIO_WPMF_BOUNCE_ADD = 1 << 16,
	BIO_WPMF_BOUNCE_REMOVE = 1 << 17,
	BIO_WPMF_SEEKING_ADD = 1 << 18,
	BIO_WPMF_SEEKING_REMOVE = 1 << 19,
	// Melee-exclusive
	BIO_WPMF_LIFESTEAL_INC = 1 << 28,
	BIO_WPMF_LIFESTEAL_DEC = 1 << 29,
	BIO_WPMF_MELEERANGE_INC = 1 << 30,
	BIO_WPMF_MELEERANGE_DEC = 1 << 31
}

struct BIO_GeneContext
{
	readOnly<BIO_WeaponModSimulator> Sim;
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

	abstract BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags Flags() const;

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
