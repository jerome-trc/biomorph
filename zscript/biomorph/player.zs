class BIO_Player : DoomPlayer
{
	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	BIO_Armor EquippedArmor;

	Default
	{
		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem "BIO_Pistol";
		Player.StartItem "BIO_Fist";

		Player.StartItem "BIO_WeaponDrop";
		Player.StartItem "BIO_UnequipArmor";

		Player.StartItem "Clip", 50;
		Player.StartItem "Shell", 0;
		Player.StartItem "RocketAmmo", 0;
		Player.StartItem "Cell", 0;

		BIO_Player.MaxWeaponsHeld 6;
		BIO_Player.MaxEquipmentHeld 3;
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
		equippable.OnEquip(self);

		if (equippable is "BIO_Armor")
		{
			EquippedArmor = BIO_Armor(equippable);
			let armor_t = (Class<BIO_Armor>)(equippable.GetClass());
			GiveInventory(GetDefaultByType(armor_t).StatClass, 1);
		}
	}

	void UnequipArmor(bool broken)
	{
		EquippedArmor.OnUnequip(self, broken);
		EquippedArmor = null;
		TakeInventory("BasicArmor", BIO_Armor.INFINITE_ARMOR);
	}

	// Allow passives to modify incoming BasicArmor.
	void PreBasicArmorUse(BIO_ArmorStats armor)
	{
		// TODO
	}

	void OnAmmoPickup(Inventory item)
	{
		// TODO
	}

	void OnHealthPickup(Inventory item)
	{
		// TODO
	}
}
