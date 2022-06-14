class BIO_WeaponModifier play abstract
{
	// If returning `false`, also return a string (can be un-localized)
	// explaining to the user why this modifier is incompatible.
	abstract bool, string Compatible(readOnly<BIO_Weapon> weap) const;

	// Effects have to be deterministic.
	abstract void Apply(BIO_Weapon weap) const;
	
	// If returning `false`, only one gene with this
	// modifier may be slotted into a graph.
	abstract bool AllowMultiple() const;

	// This modifier will never procedurally generate onto a graph
	// if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	// Flavourful name for this modifier.
	abstract string GetTag() const;

	// Explains in short-form and without context what the modifier does.
	abstract void Summary(in out Array<string> strings) const;

	// Explains what this modifier is doing to the weapon at the moment.
	abstract void Description(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const;

	readOnly<BIO_WeaponModifier> AsConst() const { return self; }
}
