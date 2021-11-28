class BIO_Affix play abstract
{
	const CRESC_POSITIVE = "\cd"; // Green
	const CRESC_NEGATIVE = "\cg"; // Red
	const CRESC_NEUTRAL = "\cc"; // Grey
	const CRESC_MIXED = "\cf"; // Gold

	// Output should be fully localized.
	abstract string GetTag() const;
}

class BIO_WeaponAffix : BIO_Affix abstract
{
	abstract bool Compatible(BIO_Weapon weap) const;
	virtual void Init(BIO_Weapon weap) {}
	virtual void CustomInit(BIO_Weapon weap, Dictionary dict)
	{
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"This weapon has no custom initialiser.");
	}
	virtual void Apply(BIO_Weapon weap) const {}

	virtual void ModifyDamage(BIO_Weapon weap, in out int damage) const {}

	virtual void OnTrueProjectileFired(BIO_Weapon weap,
		BIO_Projectile proj) const {}	
	virtual void OnFastProjectileFired(BIO_Weapon weap,
		BIO_FastProjectile proj) const {}
	virtual void OnKill(readOnly<BIO_Weapon> weap,
		Actor killed, Actor inflictor) const {}

	abstract void ToString(in out Array<string> strings, BIO_Weapon weap) const;
	abstract BIO_WeaponAffixFlags GetFlags() const;
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
