class BIO_Affix play abstract
{
	const CRESC_POSITIVE = "\cd"; // Green
	const CRESC_NEGATIVE = "\cg"; // Red
	const CRESC_NEUTRAL = "\cc"; // Grey
	const CRESC_MIXED = "\cf"; // Gold

	// If returning `true`, this affix can be added to a loot item's explicit
	// array, or rolled from a randomizer or adder mutagen.
	virtual bool CanGenerate() const { return true; }

	// If returning `true`, this affix can be added to a corrupted loot item's
	// implicit array, or rolled as a possible outcome by a corrupting mutagen.
	virtual bool CanGenerateImplicit() const { return false; }

	// If returning `true`, mutagens and the loot generator can not add this affix
	// to an item explicitly if it already has the affix implicitly, and vice-versa.
	virtual bool ImplicitExplicitExclusive() const { return false; }

	// Higher return value = higher priority = nearer to array front.
	virtual int OrderPriority() const { return 0; }

	// Output should be fully localized.
	abstract string GetTag() const;
}

enum BIO_WeaponAffixFlags : uint
{
	BIO_WAF_NONE = 0,
	BIO_WAF_ALL = uint.MAX,
	BIO_WAF_FIRECOUNT = 1 << 0,
	BIO_WAF_DAMAGE = 1 << 1,
	BIO_WAF_SPREAD = 1 << 2,
	BIO_WAF_FIRETIME = 1 << 3,
	BIO_WAF_RELOADTIME = 1 << 4,
	BIO_WAF_PROJSPEED = 1 << 5,
	BIO_WAF_PROJACCEL = 1 << 6,
	BIO_WAF_MAGSIZE = 1 << 7,
	BIO_WAF_ADDSGRAVITY = 1 << 8,
	BIO_WAF_ADDSBOUNCE = 1 << 9,
	BIO_WAF_ADDSSEEKING = 1 << 10,
	BIO_WAF_CRITCHANCE = 1 << 11
}

class BIO_WeaponAffix : BIO_Affix abstract
{
	abstract bool Compatible(readOnly<BIO_Weapon> weap) const;

	virtual void Init(readOnly<BIO_Weapon> weap) {}

	virtual void CustomInit(readOnly<BIO_Weapon> weap, Dictionary dict)
	{
		Console.Printf(Biomorph.LOGPFX_INFO ..
			"Weapon affix %s has no custom initialiser.", GetClassName());
	}
	virtual void Apply(BIO_Weapon weap) const {}

	virtual void OnTick(BIO_Weapon weap) {}

	// Modify only the fire count or the critical flag here;
	// everything else gets overwritten afterwards.
	virtual void BeforeAllFire(BIO_Weapon weap, in out BIO_FireData fireData) const {}
	
	// Modifying `FireCount` here does nothing, since it is overwritten afterwards.
	virtual void BeforeEachFire(BIO_Weapon weap, in out BIO_FireData fireData) const {}

	virtual void OnTrueProjectileFired(BIO_Weapon weap,
		BIO_Projectile proj) const {}	
	virtual void OnFastProjectileFired(BIO_Weapon weap,
		BIO_FastProjectile proj) const {}
	virtual void OnPuffFired(BIO_Weapon weap,
		BIO_Puff puff) const {}

	// Be aware that this is called on the readied weapon, which may not be the
	// weapon which fired the projectile that dealt the kill. Plan accordingly.
	virtual void OnKill(BIO_Weapon weap, Actor killed, Actor inflictor) const {}

	// In the baseline mod, this is only applicable to pistols.
	// Called before the weapon pipeline's firing loop begins.
	virtual void OnCriticalShot(BIO_Weapon weap, in out BIO_FireData fireData) const {}

	virtual void OnPickup(BIO_Weapon weap) const {}
	virtual void OnMagLoad(BIO_Weapon weap, bool secondary, in out int diff) const {}
	virtual void OnDrop(BIO_Weapon weap, BIO_Player dropper) const {}

	abstract void ToString(in out Array<string> strings,
		readOnly<BIO_Weapon> weap) const;
	
	// The reroll mutagen can't be used on a weapon if none of its
	// affixes have any stats which may be different if re-randomized.
	abstract bool SupportsReroll(readOnly<BIO_Weapon> weap) const;

	abstract BIO_WeaponAffixFlags GetFlags() const;
}

class BIO_EquipmentAffix : BIO_Affix abstract
{
	abstract void Init(readOnly<BIO_Equipment> equip);
	abstract bool Compatible(readOnly<BIO_Equipment> equip) const;

	virtual void OnEquip(BIO_Equipment equip) const {}
	virtual void OnUnequip(BIO_Equipment equip, bool broken) const {}
	virtual void PreArmorApply(BIO_Armor armor, in out BIO_ArmorData stats) const {}

	virtual void OnDamageTaken(BIO_Equipment equip, Actor inflictor,
		Actor source, in out int damage, name dmgType) const {}

	// Output should be fully localized.
	abstract void ToString(in out Array<string> strings,
		readOnly<BIO_Equipment> equip) const;
}
