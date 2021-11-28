enum BIO_WeaponAffixFlags : uint16
{
	BIO_WAF_NONE = 0,
	BIO_WAF_FIREFUNC = 1 << 0,
	BIO_WAF_FIRETYPE = 1 << 1,
	BIO_WAF_FIRECOUNT = 1 << 2,
	BIO_WAF_DAMAGE = 1 << 3,
	BIO_WAF_ACCURACY = 1 << 4,
	BIO_WAF_FIRETIME = 1 << 5,
	BIO_WAF_RELOADTIME = 1 << 6,
	BIO_WAF_MAGSIZE = 1 << 7,
	BIO_WAF_ALERT = 1 << 8,
	BIO_WAF_ALL = uint16.MAX
}

class BIO_NewWeaponAffix : BIO_Affix abstract
{
	abstract bool Compatible(BIO_NewWeapon weap) const;
	virtual void Init(BIO_NewWeapon weap) {}
	virtual void CustomInit(BIO_NewWeapon weap, Dictionary dict) {}
	virtual void Apply(BIO_NewWeapon weap) const {}

	virtual void ModifyDamage(BIO_NewWeapon weap, in out int damage) const {}

	virtual void OnTrueProjectileFired(BIO_NewWeapon weap,
		BIO_Projectile proj) const {}	
	virtual void OnFastProjectileFired(BIO_NewWeapon weap,
		BIO_FastProjectile proj) const {}
	virtual void OnKill(BIO_NewWeapon weap,
		Actor killed, Actor inflictor) const {}

	abstract void ToString(in out Array<string> strings, BIO_NewWeapon weap) const;
	abstract BIO_WeaponAffixFlags GetFlags() const;
}

