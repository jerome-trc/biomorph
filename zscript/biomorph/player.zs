class BIO_Player : DoomPlayer
{	
	Array<BIO_Passive> Passives;

	Array<BIO_TransitionFunctor> TransitionFunctors;
	Array<BIO_DamageTakenFunctor> DamageTakenFunctors;
	Array<BIO_ItemPickupFunctor> ItemPickupFunctors;
	Array<BIO_PowerupFunctor> PowerupFunctors;
	Array<BIO_WeaponFunctor> WeaponFunctors;
	Array<BIO_EquipmentFunctor> EquipmentFunctors;

	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	BIO_Armor EquippedArmor;

	Default
	{
		Species "Player";

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

		for (uint i = 0; i < DamageTakenFunctors.Size(); i++)
			DamageTakenFunctors[i].OnDamageTaken(self, inflictor, source, damage, dmgType);

		if (EquippedArmor != null)
		{
			if (CountInv("BasicArmor") < 1)
			{
				UnequipArmor(true);
				Console.Printf("Breaking armor at %d", CountInv("BasicArmor"));
			}
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

	void WorldLoaded(bool isSaveGame, bool isReopen)
	{
		for (uint i = 0; i < TransitionFunctors.Size(); i++)
			TransitionFunctors[i].WorldLoaded(self, isSaveGame, isReopen);
	}

	void Equip(BIO_Equipment equippable)
	{
		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			EquipmentFunctors[i].OnEquip(self, equippable);

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
		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			EquipmentFunctors[i].OnUnequip(self, EquippedArmor, broken);

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
		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			EquipmentFunctors[i].PreArmorApply(self, EquippedArmor, armor);

		EquippedArmor.PreArmorApply(self, armor);
	}

	void OnHealthPickup(Inventory item)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnHealthPickup(self, item);
	}

	void OnAmmoPickup(Inventory item)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnAmmoPickup(self, item);
	}

	void OnBackpackPickup(BIO_Backpack bkpk)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnBackpackPickup(self, bkpk);
	}

	void OnPowerupPickup(Inventory item)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnPowerupPickup(self, item);
	}

	void OnMapPickup(Allmap map)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnMapPickup(self, map);
	}

	void OnPowerupAttach(Powerup power)
	{
		for (uint i = 0; i < PowerupFunctors.Size(); i++)
			PowerupFunctors[i].OnPowerupAttach(self, power);
	}

	void OnPowerupDetach(Powerup power)
	{
		for (uint i = 0; i < PowerupFunctors.Size(); i++)
			PowerupFunctors[i].OnPowerupDetach(self, power);
	}

	// Passive/functor boilerplate =============================================

	void PushPassive(Class<BIO_Passive> pasv_t, uint count = 1)
	{
		for (uint i = 0; i < Passives.Size(); i++)
		{
			if (Passives[i].GetClass() == pasv_t)
			{
				Passives[i].Count += count;
				Passives[i].Apply(self);
				return;
			}
		}

		uint e = Passives.Push(BIO_Passive(new(pasv_t)));
		Passives[e].Count = count;
		Passives[e].Apply(self);
	}

	void PopPassive(Class<BIO_Passive> pasv_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < Passives.Size(); i++)
		{
			if (Passives[i].GetClass() != pasv_t) continue;

			if (Passives[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop passive %s off player %s %d times, but can only do %d.",
					pasv_t.GetClassName(), GetTag(), count, Passives[i].Count);
			}

			Passives[i].Remove(self);
			Passives[i].Count -= (all ? Passives[i].Count : count);
			if (Passives[i].Count <= 0) Passives.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, pasv_t.GetClassName(), GetTag());
	}

	void PushFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		if (func_t is "BIO_TransitionFunctor")
			PushTransitionFunctor((Class<BIO_TransitionFunctor>)(func_t), count);
		else if (func_t is "BIO_DamageTakenFunctor")
			PushDamageTakenFunctor((Class<BIO_DamageTakenFunctor>)(func_t), count);
		else if (func_t is "BIO_ItemPickupFunctor")
			PushItemPickupFunctor((Class<BIO_ItemPickupFunctor>)(func_t), count);
		else if (func_t is "BIO_PowerupFunctor")
			PushPowerupFunctor((Class<BIO_PowerupFunctor>)(func_t), count);
		else if (func_t is "BIO_WeaponFunctor")
			PushWeaponFunctor((Class<BIO_WeaponFunctor>)(func_t), count);
		else if (func_t is "BIO_EquipmentFunctor")
			PushEquipmentFunctor((Class<BIO_EquipmentFunctor>)(func_t), count);
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to push player pawn functor of invalid type %s onto player %s",
				func_t.GetClassName(), GetTag());
		}
	}

	protected void PushTransitionFunctor(
		Class<BIO_TransitionFunctor> func_t, uint count = 1)
	{
		for (uint i = 0; i < TransitionFunctors.Size(); i++)
		{
			if (TransitionFunctors[i].GetClass() == func_t)
			{
				TransitionFunctors[i].Count += count;
				return;
			}
		}

		uint e = TransitionFunctors.Push(BIO_TransitionFunctor(new(func_t)));
		TransitionFunctors[e].Count = count;
	}
	
	protected void PushDamageTakenFunctor(
		Class<BIO_DamageTakenFunctor> func_t, uint count = 1)
	{
		for (uint i = 0; i < DamageTakenFunctors.Size(); i++)
		{
			if (DamageTakenFunctors[i].GetClass() == func_t)
			{
				DamageTakenFunctors[i].Count += count;
				return;
			}
		}

		uint e = DamageTakenFunctors.Push(BIO_DamageTakenFunctor(new(func_t)));
		DamageTakenFunctors[e].Count = count;
	}

	protected void PushItemPickupFunctor(
		Class<BIO_ItemPickupFunctor> func_t, uint count = 1)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
		{
			if (ItemPickupFunctors[i].GetClass() == func_t)
			{
				ItemPickupFunctors[i].Count += count;
				return;
			}
		}

		uint e = ItemPickupFunctors.Push(BIO_ItemPickupFunctor(new(func_t)));
		ItemPickupFunctors[e].Count = count;
	}

	protected void PushPowerupFunctor(
		Class<BIO_PowerupFunctor> func_t, uint count = 1)
	{
		for (uint i = 0; i < PowerupFunctors.Size(); i++)
		{
			if (PowerupFunctors[i].GetClass() == func_t)
			{
				PowerupFunctors[i].Count += count;
				return;
			}
		}

		uint e = PowerupFunctors.Push(BIO_PowerupFunctor(new(func_t)));
		PowerupFunctors[e].Count = count;
	}

	protected void PushWeaponFunctor(
		Class<BIO_WeaponFunctor> func_t, uint count = 1)
	{
		for (uint i = 0; i < WeaponFunctors.Size(); i++)
		{
			if (WeaponFunctors[i].GetClass() == func_t)
			{
				WeaponFunctors[i].Count += count;
				return;
			}
		}

		uint e = WeaponFunctors.Push(BIO_WeaponFunctor(new(func_t)));
		WeaponFunctors[e].Count = count;
	}

	protected void PushEquipmentFunctor(
		Class<BIO_EquipmentFunctor> func_t, uint count = 1)
	{
		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
		{
			if (EquipmentFunctors[i].GetClass() == func_t)
			{
				EquipmentFunctors[i].Count += count;
				return;
			}
		}

		uint e = EquipmentFunctors.Push(BIO_EquipmentFunctor(new(func_t)));
		EquipmentFunctors[e].Count = count;
	}

	void PopFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		if (func_t is "BIO_TransitionFunctor")
			PopTransitionFunctor((Class<BIO_TransitionFunctor>)(func_t), count);
		else if (func_t is "BIO_DamageTakenFunctor")
			PopDamageTakenFunctor((Class<BIO_DamageTakenFunctor>)(func_t), count);
		else if (func_t is "BIO_ItemPickupFunctor")
			PopItemPickupFunctor((Class<BIO_ItemPickupFunctor>)(func_t), count);
		else if (func_t is "BIO_PowerupFunctor")
			PopPowerupFunctor((Class<BIO_PowerupFunctor>)(func_t), count);
		else if (func_t is "BIO_WeaponFunctor")
			PopWeaponFunctor((Class<BIO_WeaponFunctor>)(func_t), count);
		else if (func_t is "BIO_EquipmentFunctor")
			PopEquipmentFunctor((Class<BIO_EquipmentFunctor>)(func_t), count);
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to pop player pawn functor of invalid type %s off player %s",
				func_t.GetClassName(), GetTag());
		}
	}

	void PopTransitionFunctor(Class<BIO_TransitionFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < TransitionFunctors.Size(); i++)
		{
			if (TransitionFunctors[i].GetClass() != func_t) continue;
			
			if (TransitionFunctors[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop functor %s off player %s %d times, but can only do %d.",
					func_t.GetClassName(), GetTag(), count, TransitionFunctors[i].Count);
			}

			TransitionFunctors[i].Count -= (all ? TransitionFunctors[i].Count : count);
			if (TransitionFunctors[i].Count <= 0) TransitionFunctors.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, func_t.GetClassName(), GetTag());
	}

	void PopDamageTakenFunctor(Class<BIO_DamageTakenFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < DamageTakenFunctors.Size(); i++)
		{
			if (DamageTakenFunctors[i].GetClass() != func_t) continue;
			
			if (DamageTakenFunctors[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop functor %s off player %s %d times, but can only do %d.",
					func_t.GetClassName(), GetTag(), count, DamageTakenFunctors[i].Count);
			}

			DamageTakenFunctors[i].Count -= (all ? DamageTakenFunctors[i].Count : count);
			if (DamageTakenFunctors[i].Count <= 0) DamageTakenFunctors.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, func_t.GetClassName(), GetTag());
	}

	void PopItemPickupFunctor(Class<BIO_ItemPickupFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
		{
			if (ItemPickupFunctors[i].GetClass() != func_t) continue;
			
			if (ItemPickupFunctors[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop functor %s off player %s %d times, but can only do %d.",
					func_t.GetClassName(), GetTag(), count, ItemPickupFunctors[i].Count);
			}

			ItemPickupFunctors[i].Count -= (all ? ItemPickupFunctors[i].Count : count);
			if (ItemPickupFunctors[i].Count <= 0) ItemPickupFunctors.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, func_t.GetClassName(), GetTag());
	}

	void PopPowerupFunctor(Class<BIO_PowerupFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < PowerupFunctors.Size(); i++)
		{
			if (PowerupFunctors[i].GetClass() != func_t) continue;
			
			if (PowerupFunctors[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop functor %s off player %s %d times, but can only do %d.",
					func_t.GetClassName(), GetTag(), count, PowerupFunctors[i].Count);
			}

			PowerupFunctors[i].Count -= (all ? PowerupFunctors[i].Count : count);
			if (PowerupFunctors[i].Count <= 0) PowerupFunctors.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, func_t.GetClassName(), GetTag());
	}

	void PopWeaponFunctor(Class<BIO_WeaponFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < WeaponFunctors.Size(); i++)
		{
			if (WeaponFunctors[i].GetClass() != func_t) continue;
			
			if (WeaponFunctors[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop functor %s off player %s %d times, but can only do %d.",
					func_t.GetClassName(), GetTag(), count, WeaponFunctors[i].Count);
			}

			WeaponFunctors[i].Count -= (all ? WeaponFunctors[i].Count : count);
			if (WeaponFunctors[i].Count <= 0) WeaponFunctors.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, func_t.GetClassName(), GetTag());
	}

	void PopEquipmentFunctor(Class<BIO_EquipmentFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
		{
			if (EquipmentFunctors[i].GetClass() != func_t) continue;
			
			if (EquipmentFunctors[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop functor %s off player %s %d times, but can only do %d.",
					func_t.GetClassName(), GetTag(), count, EquipmentFunctors[i].Count);
			}

			EquipmentFunctors[i].Count -= (all ? EquipmentFunctors[i].Count : count);
			if (EquipmentFunctors[i].Count <= 0) EquipmentFunctors.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, func_t.GetClassName(), GetTag());
	}
}
