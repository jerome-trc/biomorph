class BIO_WeaponAffix play abstract
{
	virtual void OnPickup(BIO_Weapon weap) const {}
	virtual void OnTick(BIO_Weapon weap) {}
	virtual void OnDrop(BIO_Weapon weap, BIO_Player dropper) const {}

	// Only gets called if enough ammo is present.
	virtual void BeforeDeplete(BIO_Weapon weap,
		in out int ammoUse, bool altFire) const {}

	virtual void OnMagLoad(BIO_Weapon weap, bool secondary, in out int diff) const {}

	// Modify only the shot count or the critical flag here;
	// everything else gets overwritten afterwards.
	virtual void BeforeAllFire(BIO_Weapon weap, in out BIO_ShotData shotData) const {}

	// Modifying `ShotCount` here does nothing, since it is overwritten afterwards.
	virtual void BeforeEachFire(BIO_Weapon weap, in out BIO_ShotData shotData) const {}

	virtual void OnSlowProjectileFired(BIO_Weapon weap,
		BIO_Projectile proj) const {}	
	virtual void OnFastProjectileFired(BIO_Weapon weap,
		BIO_FastProjectile proj) const {}
	virtual void OnPuffFired(BIO_Weapon weap,
		BIO_Puff puff) const {}

	// Be aware that this is called on the readied weapon, which may not be the
	// weapon which was actually used to cause the kill. Plan accordingly.
	virtual void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const {}

	abstract void Summary(in out Array<string> strings) const;
}
