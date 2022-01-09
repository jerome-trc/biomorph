// Pistol damage gained as fire rate goes down =================================

class BIO_Perk_ScaledPistolDamage : BIO_Perk
{
	final override void Apply(BIO_Player bioPlayer)
	{
		bioPlayer.PushFunctor('BIO_WeapFunc_ScaledPistolDamage');
	}
}

class BIO_WeapFunc_ScaledPistolDamage : BIO_WeaponFunctor
{
	final override void BeforeEachFire(BIO_Player bioPlayer,
		in out BIO_FireData fireData) const
	{
		let weap = BIO_Weapon(bioPlayer.Player.ReadyWeapon);
		
		if (weap == null) return;
		if (!(weap.BIOFlags & BIO_WF_PISTOL)) return;

		for (uint i = 0; i < Count; i++)
			fireData.Damage *= (weap.LastFireTime() * 0.125);
	}
}
