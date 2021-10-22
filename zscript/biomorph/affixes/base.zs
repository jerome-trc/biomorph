class BIO_Affix play abstract
{
	const CRESC_POSITIVE = "\cd"; // Green
	const CRESC_NEGATIVE = "\cg"; // Red
	const CRESC_NEUTRAL = "\cc"; // Grey
	const CRESC_MIXED = "\cf"; // Gold
}

class BIO_WeaponAffix : BIO_Affix abstract
{
	abstract void Init(BIO_Weapon weap);
	abstract bool Compatible(BIO_Weapon weap) const;

	virtual void Apply(BIO_Weapon weap) const {}
	virtual void OnBulletFired(BIO_Weapon weap) const {}
	virtual void OnProjectileFired(BIO_Weapon weap, Actor proj) const {}

	// Output should be fully localized.
	abstract string ToString(BIO_Weapon weap) const;
}

class BIO_EquipmentAffix : BIO_Affix abstract
{
	abstract void Init(BIO_Equipment equip);
	abstract bool Compatible(BIO_Equipment equip) const;

	virtual void OnEquip(BIO_Equipment equip) const {}
	virtual void OnUnequip(BIO_Equipment equip, bool broken) const {}
	virtual void PreArmorApply(BIO_Armor armor, BIO_ArmorStats stats) const {}

	virtual void OnDamageTaken(BIO_Equipment equip, Actor inflictor,
		Actor source, in out int damage, name dmgType) const {}

	// Output should be fully localized.
	abstract string ToString() const;
}
