class BIO_Affix play abstract
{
	virtual void ApplyToWeapon(BIO_Weapon weap) const {}
	virtual void OnBulletFired(BIO_Weapon weap) const {}
	virtual void OnProjectileFired(BIO_Weapon weap, Actor proj) const {}
}
