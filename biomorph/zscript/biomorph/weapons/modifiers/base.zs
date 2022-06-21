enum BIO_WeapModRepeatRules : uint8
{
	// This weapon modifier can not or should not be repeated.
	BIO_WMODREPEATRULES_NONE,
	// This weapon modifier will be repeated by calling `Apply()` multiple times.
	BIO_WMODREPEATRULES_EXTERNAL,
	// `Apply()` will only get called once and handle `Count` on its own.
	BIO_WMODREPEATRULES_INTERNAL
}

// Currently only so that weapon upgrade recipes can check how many of a graph's
// modifiers affect one particular facet of the weapon.
enum BIO_WeaponModFlags : uint
{
	BIO_WMODF_NONE = 0,
	BIO_WMODF_AMMOTYPE = 1 << 0,
	BIO_WMODF_MAGTYPE = 1 << 1,
	BIO_WMODF_MAGSIZE = 1 << 2,
	BIO_WMODF_FIRETIME = 1 << 3,
	BIO_WMODF_RELOADTIME = 1 << 4,
	BIO_WMODF_PAYLOAD = 1 << 5,
	BIO_WMODF_SHOTCOUNT = 1 << 6,
	BIO_WMODF_DAMAGE = 1 << 7,
	BIO_WMODF_SPREAD = 1 << 8
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

	readOnly<BIO_WeaponModifier> AsConst() const { return self; }
}
