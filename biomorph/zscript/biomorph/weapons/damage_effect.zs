class BIO_DamageEffect abstract
{
	bool HitOnly;

	abstract void Invoke(in out BIO_DamageOutput output) const;
	abstract BIO_DamageEffect Copy() const;
}

class BIO_DmgFx_Modify : BIO_DamageEffect
{
	int Modifier;

	final override void Invoke(in out BIO_DamageOutput output) const
	{
		output.Current += Modifier;
		output.Minimum += Modifier;
		output.Maximum += Modifier;
	}

	final override BIO_DamageEffect Copy() const
	{
		return BIO_DmgFx_Modify.Create(Modifier);
	}

	static BIO_DmgFx_Modify Create(int modifier, bool hitOnly = false)
	{
		let ret = new('BIO_DmgFx_Modify');
		ret.HitOnly = hitOnly;
		ret.Modifier = modifier;
		return ret;
	}
}

class BIO_DmgFx_Multi : BIO_DamageEffect
{
	float Multiplier;

	final override void Invoke(in out BIO_DamageOutput output) const
	{
		output.Current *= Multiplier;
		output.Minimum *= Multiplier;
		output.Maximum *= Multiplier;
	}

	final override BIO_DamageEffect Copy() const
	{
		return BIO_DmgFx_Multi.Create(Multiplier);
	}

	static BIO_DmgFx_Multi Create(float multiplier, bool hitOnly = false)
	{
		let ret = new('BIO_DmgFx_Multi');
		ret.HitOnly = hitOnly;
		ret.Multiplier = multiplier;
		return ret;
	}
}

class BIO_DmgFx_MaxOnly : BIO_DamageEffect
{
	final override void Invoke(in out BIO_DamageOutput output) const
	{
		output.Minimum = output.Current = output.Maximum;
	}

	final override BIO_DamageEffect Copy() const
	{
		return new('BIO_DmgFx_MaxOnly');
	}
}
