enum BIO_WeapModRepeatRules : uint8
{
	// This weapon modifier can not or should not be repeated.
	BIO_WMODREPEATRULES_NONE,
	// This weapon modifier will be repeated by calling `Apply()` multiple times.
	BIO_WMODREPEATRULES_EXTERNAL,
	// `Apply()` will only get called once and handle `Count` on its own.
	BIO_WMODREPEATRULES_INTERNAL
}

class BIO_WeaponModifier play abstract
{
	// If returning `false`, also return a string (can be un-localized)
	// explaining to the user why this modifier is incompatible.
	abstract bool, string Compatible(readOnly<BIO_Weapon> weap, uint count) const;

	// Effects have to be deterministic.
	abstract void Apply(BIO_Weapon weap, uint count) const;

	// If returning `false`, only one gene with this
	// modifier may be slotted into a graph.
	abstract bool AllowMultiple() const;

	abstract BIO_WeapModRepeatRules RepeatRules() const;

	// This modifier will never procedurally generate onto a graph
	// if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	// Flavourful name for this modifier.
	abstract string GetTag() const;

	// Explains in short-form and without context what the modifier does.
	abstract void Summary(in out Array<string> strings) const;

	// Explains what this modifier is doing to the weapon at the moment.
	abstract void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap, uint count) const;

	readOnly<BIO_WeaponModifier> AsConst() const { return self; }
}
