class BIO_Perk play abstract
{
	virtual void Apply(BIO_Player bioPlayer) const {}

	// Higher return value = higher priority = nearer to array front.
	virtual int OrderPriority() const { return 0; }
}

// Functor callers never consider `Count`. The callbacks have the
// responsibility to read and use it, or ignore it as they see fit.

class BIO_PlayerFunctor play abstract { uint Count; }

class BIO_DamageTakenFunctor : BIO_PlayerFunctor abstract
{
	virtual void OnDamageTaken(BIO_Player bioPlayer, Actor inflictor,
		Actor source, in out int damage, name dmgType) const {}
}

class BIO_EquipmentFunctor : BIO_PlayerFunctor abstract
{
	// Before any pointers get set, and before the equipment's
	// version of this callback gets invoked.
	virtual void OnEquip(BIO_Player player, BIO_Equipment equip) const {}

	// Before any pointers get unset, and before the equipment's
	// version of this callback gets invoked.
	virtual void OnUnequip(BIO_Player player, BIO_Equipment equip, bool broken) const {}

	// For modifying armor stats (e.g. SaveAmount and SavePercent).
	virtual void PreArmorApply(BIO_Player player, BIO_Armor armor,
		BIO_ArmorStats stats) const {}
}

class BIO_ItemPickupFunctor : BIO_PlayerFunctor abstract
{
	virtual void OnHealthPickup(
		BIO_Player bioPlayer, Inventory item) const {}
	virtual void OnAmmoPickup(
		BIO_Player bioPlayer, Inventory item) const {}
	virtual void OnArmorBonusPickup(
		BIO_Player bioPlayer, BIO_ArmorBonus bonus) const {}
	virtual void OnFirstBackpackPickup(
		BIO_Player bioPlayer, BIO_Backpack bkpk) const {}
	virtual void OnSubsequentBackpackPickup(
		BIO_Player bioPlayer, BIO_Backpack bkpk) const {}
	virtual void OnPowerupPickup(
		BIO_Player bioPlayer, Inventory item) const {}
	virtual void OnMapPickup(
		BIO_Player bioPlayer, Allmap map) const {}
}

class BIO_KillFunctor : BIO_PlayerFunctor abstract
{
	virtual void OnKill(BIO_Player bioPlayer, Actor inflictor, Actor killed) const {}
}

class BIO_PowerupFunctor : BIO_PlayerFunctor abstract
{
	virtual void OnPowerupAttach(BIO_Player bioPlayer, Powerup power) const {}
	virtual void OnPowerupDetach(BIO_Player bioPlayer, Powerup power) const {}
}

class BIO_TransitionFunctor : BIO_PlayerFunctor abstract
{
	virtual void WorldLoaded(BIO_Player bioPlayer, bool saveGame, bool reopen) const {}
	virtual void EnteredGame(BIO_Player bioPlayer, int playerNumber) const {}
}

class BIO_WeaponFunctor : BIO_PlayerFunctor abstract
{
	virtual void BeforeEachFire(BIO_Player bioPlayer, in out BIO_FireData fireData) const {}
}
