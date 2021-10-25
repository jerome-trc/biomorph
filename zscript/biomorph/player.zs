class BIO_Player : DoomPlayer
{
	Array<BIO_Passive> Passives;

	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	BIO_Armor EquippedArmor;

	Default
	{
		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem "BIO_WeaponDrop";
		Player.StartItem "BIO_UnequipArmor";

		Player.StartItem "Clip", 50;
		Player.StartItem "Shell", 0;
		Player.StartItem "RocketAmmo", 0;
		Player.StartItem "Cell", 0;

		Player.StartItem "BIO_Pistol";
		Player.StartItem "BIO_Fist";

		BIO_Player.MaxWeaponsHeld 6;
		BIO_Player.MaxEquipmentHeld 3;
	}

	// Parent overrides ========================================================

	override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, name dmgType)
	{
		int ret = super.TakeSpecialDamage(inflictor, source, damage, dmgType);

		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].OnDamageTaken(self, inflictor, source, damage, dmgType);

		if (EquippedArmor != null)
		{
			EquippedArmor.OnDamageTaken(inflictor, source, damage, dmgType);

			if (CountInv("BasicArmor") < 1)
				UnequipArmor(true);
			// TODO: Armor break sound
		}

		return ret;
	}

	// Getters =================================================================

	bool IsWearingArmor() const { return EquippedArmor != null; }

	uint HeldWeaponCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is "BIO_Weapon" && !(i is "BIO_Fist")) ret++; 

		return ret;
	}

	uint HeldEquipmentCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is "BIO_Equipment") ret += i.Amount;
		
		return ret;
	}

	bool IsFullOnWeapons() const { return HeldWeaponCount() >= MaxWeaponsHeld; }
	bool IsFullOnEquipment() const { return HeldEquipmentCount() >= MaxEquipmentHeld; }

	// Setters =================================================================

	void Equip(BIO_Equipment equippable)
	{
		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].OnEquip(self, equippable);

		equippable.OnEquip();

		if (equippable is "BIO_Armor")
		{
			EquippedArmor = BIO_Armor(equippable);
			EquippedArmor.Equipped = true;
			let armor_t = (Class<BIO_Armor>)(equippable.GetClass());
			GiveInventory(GetDefaultByType(armor_t).StatClass, 1);
		}
	}

	void UnequipArmor(bool broken)
	{
		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].OnUnequip(self, EquippedArmor, broken);

		EquippedArmor.OnUnequip(broken);
		EquippedArmor.Equipped = false;
		EquippedArmor = null;
		TakeInventory("BasicArmor", BIO_Armor.INFINITE_ARMOR);
		FindInventory("BasicArmor").MaxAmount = 1;
	}

	// Used to apply armor's affixes to BasicArmor, as well as
	// opening it up to modification by passives.
	void PreArmorApply(BIO_ArmorStats armor)
	{
		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].PreArmorApply(self, EquippedArmor, armor);

		for (uint i = 0; i < EquippedArmor.ImplicitAffixes.Size(); i++)
			EquippedArmor.ImplicitAffixes[i].PreArmorApply(EquippedArmor, armor);

		for (uint i = 0; i < EquippedArmor.Affixes.Size(); i++)
			EquippedArmor.Affixes[i].PreArmorApply(EquippedArmor, armor);
	}

	void OnAmmoPickup(Inventory item)
	{
		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].OnAmmoPickup(self, item);
	}

	void OnHealthPickup(Inventory item)
	{
		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].OnHealthPickup(self, item);
	}

	void OnBackpackPickup(BIO_Backpack bkpk)
	{
		for (uint i = 0; i < Passives.Size(); i++)
			Passives[i].OnBackpackPickup(self, bkpk);
	}
}
