class biom_Mutator abstract
{
	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Tag() const;
	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Summary() const;
	/// Output can be null.
	abstract textureID Icon() const;
}
