class BIO_Player : DoomPlayer
{	
	Array<BIO_Passive> Passives;
	Array<BIO_PlayerFunctor> Functors[FUNCTOR_ARRAY_LENGTH];

	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	BIO_Armor EquippedArmor;

	Default
	{
		Species 'Player';

		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem 'BIO_WeaponDrop';
		Player.StartItem 'BIO_UnequipArmor';

		Player.StartItem 'Clip', 50;
		Player.StartItem 'Shell', 0;
		Player.StartItem 'RocketAmmo', 0;
		Player.StartItem 'Cell', 0;

		Player.StartItem 'BIO_Pistol';
		Player.StartItem 'BIO_Fist';

		BIO_Player.MaxWeaponsHeld 6;
		BIO_Player.MaxEquipmentHeld 3;
	}

	// Parent overrides ========================================================

	final override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, name dmgType)
	{
		int ret = super.TakeSpecialDamage(inflictor, source, damage, dmgType);

		for (uint i = 0; i < Functors[FANDX_DAMAGETAKEN].Size(); i++)
		{
			BIO_DamageTakenFunctor(Functors[FANDX_DAMAGETAKEN][i]).OnDamageTaken(
				self, inflictor, source, damage, dmgType);
		}

		if (EquippedArmor != null)
		{
			if (CountInv('BasicArmor') < 1)
			{
				UnequipArmor(true);
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
			if (i is 'BIO_Weapon' && !(i is 'BIO_Fist')) ret++; 

		return ret;
	}

	uint HeldEquipmentCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Equipment') ret += i.Amount;
		
		return ret;
	}

	bool IsFullOnWeapons() const { return HeldWeaponCount() >= MaxWeaponsHeld; }
	bool IsFullOnEquipment() const { return HeldEquipmentCount() >= MaxEquipmentHeld; }

	// Setters =================================================================

	void WorldLoaded(bool isSaveGame, bool isReopen)
	{
		for (uint i = 0; i < Functors[FANDX_TRANSITION].Size(); i++)
		{
			BIO_TransitionFunctor(Functors[FANDX_TRANSITION][i])
				.WorldLoaded(self, isSaveGame, isReopen);
		}
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		let bioWeapon = BIO_Weapon(Player.ReadyWeapon);
		if (bioWeapon != null) bioWeapon.OnKill(killed, inflictor);

		for (uint i = 0; i < Functors[FANDX_KILL].Size(); i++)
		{
			BIO_KillFunctor(Functors[FANDX_KILL][i])
				.OnKill(self, inflictor, killed);
		}
	}

	void Equip(BIO_Equipment equippable)
	{
		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.OnEquip(self, equippable);
		}

		equippable.OnEquip();

		if (equippable is 'BIO_Armor')
		{
			EquippedArmor = BIO_Armor(equippable);
			EquippedArmor.Equipped = true;
			let armor_t = (Class<BIO_Armor>)(equippable.GetClass());
			GiveInventory(GetDefaultByType(armor_t).StatClass, 1);
		}
	}

	void UnequipArmor(bool broken)
	{
		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.OnUnequip(self, EquippedArmor, broken);
		}

		EquippedArmor.OnUnequip(broken);
		EquippedArmor.Equipped = false;
		EquippedArmor = null;
		TakeInventory('BasicArmor', BIO_Armor.INFINITE_ARMOR);
		FindInventory('BasicArmor').MaxAmount = 1;
	}

	// Used to apply armor's affixes to BasicArmor, as well as
	// opening it up to modification by passives.
	void PreArmorApply(BIO_ArmorStats armor)
	{
		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.PreArmorApply(self, EquippedArmor, armor);
		}

		EquippedArmor.PreArmorApply(self, armor);
	}

	void OnHealthPickup(Inventory item)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnHealthPickup(self, item);
		}
	}

	void OnAmmoPickup(Inventory item)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnAmmoPickup(self, item);
		}
	}

	void OnBackpackPickup(BIO_Backpack bkpk)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnBackpackPickup(self, bkpk);
		}
	}

	void OnPowerupPickup(Inventory item)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnPowerupPickup(self, item);
		}
	}

	void OnMapPickup(Allmap map)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnMapPickup(self, map);
		}
	}

	void OnPowerupAttach(Powerup power)
	{
		for (uint i = 0; i < Functors[FANDX_POWERUP].Size(); i++)
		{
			BIO_PowerupFunctor(Functors[FANDX_POWERUP][i])
				.OnPowerupAttach(self, power);
		}
	}

	void OnPowerupDetach(Powerup power)
	{
		for (uint i = 0; i < Functors[FANDX_POWERUP].Size(); i++)
		{
			BIO_PowerupFunctor(Functors[FANDX_POWERUP][i])
				.OnPowerupDetach(self, power);
		}
	}

	// Passive/functor manipulation ============================================

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

	enum FunctorArrayIndex : uint
	{
		FANDX_DAMAGETAKEN,
		FANDX_EQUIPMENT,
		FANDX_ITEMPKUP,
		FANDX_KILL,
		FANDX_POWERUP,
		FANDX_TRANSITION,
		FANDX_WEAPON,
		FUNCTOR_ARRAY_LENGTH
	}

	void PushFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		uint ndx = uint.MAX;

		if (func_t is 'BIO_DamageTakenFunctor')
			ndx = FANDX_DAMAGETAKEN;
		else if (func_t is 'BIO_EquipmentFunctor')
			ndx = FANDX_EQUIPMENT;
		else if (func_t is 'BIO_ItemPickupFunctor')
			ndx = FANDX_ITEMPKUP;
		else if (func_t is 'BIO_KillFunctor')
			ndx = FANDX_KILL;
		else if (func_t is 'BIO_PowerupFunctor')
			ndx = FANDX_POWERUP;
		else if (func_t is 'BIO_TransitionFunctor')
			ndx = FANDX_TRANSITION;
		else if (func_t is 'BIO_WeaponFunctor')
			ndx = FANDX_WEAPON;
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to push player pawn functor of invalid type %s onto player %s",
				func_t.GetClassName(), GetTag());
			return;
		}

		for (uint i = 0; i < Functors[ndx].Size(); i++)
		{
			if (Functors[ndx][i].GetClass() == func_t)
			{
				Functors[ndx][i].Count += count;
				return;
			}
		}

		uint e = Functors[ndx].Push(BIO_PlayerFunctor(new(func_t)));
		Functors[ndx][e].Count = count;
	}

	void PopFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		uint ndx = uint.MAX;

		if (func_t is 'BIO_DamageTakenFunctor')
			ndx = FANDX_DAMAGETAKEN;
		else if (func_t is 'BIO_EquipmentFunctor')
			ndx = FANDX_EQUIPMENT;
		else if (func_t is 'BIO_ItemPickupFunctor')
			ndx = FANDX_ITEMPKUP;
		else if (func_t is 'BIO_KillFunctor')
			ndx = FANDX_KILL;
		else if (func_t is 'BIO_PowerupFunctor')
			ndx = FANDX_POWERUP;
		else if (func_t is 'BIO_TransitionFunctor')
			ndx = FANDX_TRANSITION;
		else if (func_t is 'BIO_WeaponFunctor')
			ndx = FANDX_WEAPON;
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to pop player pawn functor of invalid type %s off player %s",
				func_t.GetClassName(), GetTag());
			return;
		}

		{
			bool all = count <= 0;

			for (uint i = 0; i < Functors[ndx].Size(); i++)
			{
				if (Functors[ndx][i].GetClass() != func_t) continue;
				
				if (Functors[ndx][i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop functor %s off player %s %d times, but can only do %d.",
						func_t.GetClassName(), GetTag(), count, Functors[ndx][i].Count);
				}

				Functors[ndx][i].Count -= (all ? Functors[ndx][i].Count : count);
				if (Functors[ndx][i].Count <= 0) Functors[ndx].Delete(i);
				return;
			}
		}
	}
}
