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
			EquippedArmor.Equipped = true;
			let armor_t = (Class<BIO_Armor>)(equippable.GetClass());
			GiveInventory(GetDefaultByType(armor_t).StatClass, 1);
		}
	}

	void UnequipArmor(bool broken)
	{
		EquippedArmor.OnUnequip(self, broken);
		EquippedArmor.Equipped = false;
		EquippedArmor = null;
		TakeInventory("BasicArmor", BIO_Armor.INFINITE_ARMOR);
		FindInventory("BasicArmor").MaxAmount = 1;
	}

	// Used to apply armor's affixes to BasicArmor, as well as opening it up to 
	// modification by passives.
	void PreBasicArmorUse(BIO_ArmorStats armor)
	{
		for (uint i = 0; i < EquippedArmor.ImplicitAffixes.Size(); i++)
			EquippedArmor.ImplicitAffixes[i].OnArmorEquip(EquippedArmor, armor);

		for (uint i = 0; i < EquippedArmor.Affixes.Size(); i++)
			EquippedArmor.Affixes[i].OnArmorEquip(EquippedArmor, armor);

		// TODO: Player passive effects
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
