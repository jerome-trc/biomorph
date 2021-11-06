mixin class BIO_MeleeWeaponCommon
{
	float MeleeRange1, MeleeRange2;

	property MeleeRange: MeleeRange1;
	property MeleeRange1: MeleeRange1;
	property MeleeRange2: MeleeRange2;
	property MeleeRanges: MeleeRange1, MeleeRange2;

	float LifeSteal1, LifeSteal2;

	property LifeSteal: LifeSteal1;
	property LifeSteal1: LifeSteal1;
	property LifeSteal2: LifeSteal2;
	property LifeSteals: LifeSteal1, LifeSteal2;

	override void ResetStats()
	{
		super.ResetStats();
		MeleeRange1 = Default.MeleeRange1;
		MeleeRange2 = Default.MeleeRange2;
		LifeSteal1 = Default.LifeSteal1;
		LifeSteal2 = Default.LifeSteal2;
	}

	protected void ApplyLifeSteal(int dmg, bool secondary = false)
	{
		let fDmg = float(dmg);
		float lsp = !secondary ? LifeSteal1 : LifeSteal2;
		Owner.GiveBody(int(fDmg * Min(lsp, 1.0)), Owner.GetMaxHealth(true) + 100);
	}
}

class BIO_MeleeWeapon : BIO_Weapon abstract
{
	mixin BIO_MeleeWeaponCommon;

	Default
	{
		BIO_MeleeWeapon.MeleeRanges DEFMELEERANGE, DEFMELEERANGE;
		BIO_MeleeWeapon.LifeSteals 0.0, 0.0;
	}
}

class BIO_DualMeleeWeapon : BIO_DualWieldWeapon abstract
{
	mixin BIO_MeleeWeaponCommon;

	Default
	{
		BIO_DualMeleeWeapon.MeleeRanges DEFMELEERANGE, DEFMELEERANGE;
		BIO_DualMeleeWeapon.LifeSteals 0.0, 0.0;
	}
}
