class BIO_Affix play abstract {}

class BIO_WeaponAffix : BIO_Affix abstract
{
	virtual void ModifyDamage(in out int dmg) const {}
	virtual void ModifySpread(in out float hSpread, in out float vSpread) const {}
	virtual void ModifyBulletRange(in out int range) const {}
}
