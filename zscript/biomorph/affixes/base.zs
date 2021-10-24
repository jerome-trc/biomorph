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

	virtual void ModifySplash(BIO_Weapon weap, in out int dmg, in out int radius) const {}

	virtual void OnTrueProjectileFired(BIO_Weapon weap, BIO_Projectile proj) const {}	
	virtual void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) const {}

	virtual void ModifyLifesteal(BIO_Weapon weap, in out float lifeSteal) const {}

	virtual void PreAlertMonsters(BIO_Weapon weap,
		in out double maxDist, in out int flags) const {}

	// Output should be fully localized.
	abstract void ToString(in out Array<string> strings, BIO_Weapon weap) const;
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
	abstract void ToString(in out Array<string> strings, BIO_Equipment equip) const;
}
