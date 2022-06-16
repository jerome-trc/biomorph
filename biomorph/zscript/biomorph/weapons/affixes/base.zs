// Affixes are how modifiers apply behaviours to weapons rather than stat changes.
class BIO_WeaponAffix play abstract
{
	// Called by `DoPickupSpecial()`.
	virtual void OnPickup(BIO_Weapon weap) {}
	virtual void OnTick(BIO_Weapon weap) {}

	// Called by the `BIO_Weapon` functions of the same name.
	virtual void OnSelect(BIO_Weapon weap) {}
	virtual void OnDeselect(BIO_Weapon weap) {}

	// Called before magazine pointers are invalidated.
	virtual void OnDrop(BIO_Weapon weap, BIO_Player dropper) {}

	// Only gets called if enough ammo is present.
	virtual void BeforeAmmoDeplete(BIO_Weapon weap,
		in out int ammoUse, bool altFire) {}

	// Called by `A_BIO_LoadMag()`, right after all calculations are finished,
	// and directly before taking player reserves and increasing magazine amount.
	virtual void OnMagLoad(BIO_Weapon weap, bool secondary,
		in out int toDraw, in out int toLoad) {}

	// Modify only the shot count or the critical flag here;
	// everything else gets overwritten afterwards.
	virtual void BeforeAllFire(BIO_Weapon weap, in out BIO_ShotData shotData) {}

	// Modifying `ShotCount` here does nothing, since it is overwritten afterwards.
	virtual void BeforeEachFire(BIO_Weapon weap, in out BIO_ShotData shotData) {}

	virtual void OnSlowProjectileFired(BIO_Weapon weap, BIO_Projectile proj) {}	
	virtual void OnFastProjectileFired(BIO_Weapon weap, BIO_FastProjectile proj) {}
	virtual void OnPuffFired(BIO_Weapon weap, BIO_Puff puff) {}

	// Be aware that this is called on the readied weapon, which may not be the
	// weapon which was actually used to cause the kill. Plan accordingly.
	virtual void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) {}

	abstract void Summary(in out Array<string> strings) const;
}
