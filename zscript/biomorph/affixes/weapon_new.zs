class BIO_NewWeaponAffix : BIO_Affix abstract
{
	abstract bool Compatible(BIO_NewWeapon weap) const;
	virtual void Init(BIO_NewWeapon weap, Dictionary dict) {}
	virtual void Apply(BIO_NewWeapon weap) const {}

	virtual void ModifyDamage(BIO_NewWeapon weap, in out int damage) const {}

	virtual void OnTrueProjectileFired(BIO_NewWeapon weap,
		BIO_Projectile proj) const {}	
	virtual void OnFastProjectileFired(BIO_NewWeapon weap,
		BIO_FastProjectile proj) const {}
	virtual void OnKill(BIO_NewWeapon weap,
		Actor killed, Actor inflictor) const {}

	abstract void ToString(in out Array<string> strings, BIO_NewWeapon weap) const;
}

