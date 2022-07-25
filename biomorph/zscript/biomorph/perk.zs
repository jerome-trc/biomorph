class BIO_Perk : Inventory abstract
{
	mixin BIO_Rarity;

	const LOOTWEIGHT_MAX = 7;
	const LOOTWEIGHT_COMMON = 5;
	const LOOTWEIGHT_RARE = 3;
	const LOOTWEIGHT_MIN = 1;

	meta uint LootWeight; property LootWeight: LootWeight;
	meta string Summary; property Summary: Summary;

	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.BIGPOWERUP
		+INVENTORY.INVBAR
		+NOBLOCKMONST

		Height 16.0;
		Radius 20.0;
		Tag "$BIO_PERK_TAG";

		Inventory.InterHubAmount 1;
		Inventory.MaxAmount 1;
		Inventory.PickupMessage "$BIO_PERK_PKUP";
		Inventory.RestrictedTo 'BIO_Player';
	}

	final override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher))
			return false;

		let pawn = BIO_Player(toucher);
		return pawn.HeldPerkCount() < pawn.Perks.Size();
	}

	// Prevent perk pickups from being folded together.
	final override bool HandlePickup(Inventory _) { return false; }

	final override string PickupMessage()
	{
		return String.Format(StringTable.Localize(PickupMsg), GetTag());
	}

	final override bool Use(bool pickup)
	{
		if (IsEquipped())
			Unequip();
		else
			Equip();

		return false;
	}

	void Equip()
	{
		let pawn = BIO_Player(Owner);

		for (uint i = 0; i < pawn.Perks.Size(); i++)
			if (pawn.Perks[i] == null)
			{
				pawn.Perks[i] = self;
				break;	
			}

		bUndroppable = true;
		bUntossable = true;

		pawn.A_StartSound("bio/ui/beep");

		pawn.A_Print(
			String.Format(
				StringTable.Localize("$BIO_PERK_EQUIPTEMPLATE"),
				StringTable.Localize("$BIO_PERK_FLAVOR"),
				GetTag(),
				StringTable.Localize(Summary)
			)
		);
	}

	void Unequip()
	{
		let pawn = BIO_Player(Owner);

		for (uint i = 0; i < pawn.Perks.Size(); i++)
			if (pawn.Perks[i] == self)
			{
				pawn.Perks[i] = null;
				break;	
			}

		bUndroppable = false;
		bUntossable = false;

		pawn.A_StartSound("bio/ui/cancel");

		pawn.A_Print(
			String.Format(
				StringTable.Localize("$BIO_PERK_UNEQUIPTEMPLATE"),
				StringTable.Localize("$BIO_PERK_FLAVOR"),
				GetTag()
			)
		);
	}

	bool IsEquipped() const
	{
		if (Owner == null)
			return false;

		let pawn = BIO_Player(Owner);

		for (uint i = 0; i < pawn.Perks.Size(); i++)
			if (pawn.Perks[i] == self)
				return true;
	
		return false;
	}

	// This perk will not be added to loot tables if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	// Equipped behaviour virtuals /////////////////////////////////////////////

	virtual void OnDamageTaken(
		BIO_Player pawn, Actor inflictor, Actor source,
		in out int damage, name dmgType
	) const {}

	virtual void PrePowerupHandlePickup(
		BIO_Player pawn,
		Powerup handler, Powerup other
	) const {}
	virtual void PrePowerupAttach(
		BIO_Player pawn,
		Powerup power
	) const {}
	virtual void PrePowerupDetach(
		BIO_Player pawn,
		Powerup power
	) const {}
}

class BIO_Perk_PowerupDuration : BIO_Perk
{
	Default
	{
		Tag "$BIO_PERK_POWERUPDURATION_TAG";
		Inventory.Icon 'PERKA0';
		Inventory.PickupMessage "$BIO_PERK_POWERUPDURATION_PKUP";
		BIO_Perk.LootWeight LOOTWEIGHT_COMMON;
		BIO_Perk.Summary "$BIO_PERK_POWERUPDURATION_SUMM";
	}

	States
	{
	Spawn:
		PERK A 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
	}

	final override void PrePowerupHandlePickup(
		BIO_Player pawn,
		Powerup handler, Powerup other
	) const
	{
		other.EffectTics *= 1.5;
	}

	final override void PrePowerupAttach(BIO_Player pawn, Powerup power) const
	{
		power.EffectTics *= 1.5;
	}
}

class BIO_Perk_SlimeResist : BIO_Perk
{
	Default
	{
		Tag "$BIO_PERK_SLIMERESIST_TAG";
		Inventory.Icon 'PERKB0';
		Inventory.PickupMessage "$BIO_PERK_SLIMERESIST_PKUP";
		BIO_Perk.LootWeight LOOTWEIGHT_COMMON;
		BIO_Perk.Summary "$BIO_PERK_SLIMERESIST_SUMM";
	}

	States
	{
	Spawn:
		PERK B 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override void OnDamageTaken(
		BIO_Player pawn, Actor inflictor, Actor source,
		in out int damage, name dmgType
	) const
	{
		if (dmgType == 'Slime')
			damage *= 0.5;
	}
}
