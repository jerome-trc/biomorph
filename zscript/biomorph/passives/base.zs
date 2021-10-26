class BIO_Passive abstract
{
	uint Count;

	// Invokers of these callbacks never consider `Count`. The callback has the
	// responsibility to read it and use or discard as appropriate.

	virtual void Apply(BIO_Player bioPlayer) const {}
	virtual void Remove(BIO_Player bioPlayer) const {}

	virtual void OnDamageTaken(BIO_Player bioPlayer, Actor inflictor,
		Actor source, in out int damage, name dmgType) const {}
	virtual void OnHealthPickup(BIO_Player bioPlayer, Inventory item) const {}
	virtual void OnAmmoPickup(BIO_Player bioPlayer, Inventory item) const {}
	virtual void OnBackpackPickup(BIO_Player bioPlayer, BIO_Backpack bkpk) const {}
	virtual void OnPowerupPickup(BIO_Player bioPlayer, Inventory item) const {}
	virtual void OnPowerupAttach(BIO_Player bioPlayer, Powerup power) const {}
	virtual void OnBerserk(BIO_Player bioPlayer, BIO_PowerStrength power) const {}

	// Before any pointers get set, and before the equipment's
	// version of this callback gets invoked.
	virtual void OnEquip(BIO_Player player, BIO_Equipment equip) const {}

	// Before any pointers get unset, and before the equipment's
	// version of this callback gets invoked.
	virtual void OnUnequip(BIO_Player player, BIO_Equipment equip, bool broken) const {}

	// Allow for modifying armor stats (e.g. SaveAmount and SavePercent).
	virtual void PreArmorApply(BIO_Player player, BIO_Armor armor, BIO_ArmorStats stats) const {}
}
