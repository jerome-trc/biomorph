class BIO_Affix play abstract
{
	abstract string ToString() const;
	abstract int GetFontColour() const;
}

class BIO_WeaponAffix : BIO_Affix abstract
{
	virtual void ApplyToWeapon(BIO_Weapon weap) const {}
	virtual void OnBulletFired(BIO_Weapon weap) const {}
	virtual void OnProjectileFired(BIO_Weapon weap, Actor proj) const {}
}

class BIO_EquipmentAffix : BIO_Affix abstract
{

}
