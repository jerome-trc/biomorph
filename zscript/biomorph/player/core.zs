class BIO_Player : DoomPlayer
{
	Array<BIO_PlayerFunctor> Functors[__FANDX_COUNT__];

	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	BIO_Armor EquippedArmor;

	BIO_PlayerVisual WeaponVisual;

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

	override void GiveDefaultInventory()
	{
		super.GiveDefaultInventory();
		
		// If the default inventory has been given, it's either a new game
		// or the player likely went through a death exit and had their
		// inventory cleared
		BIO_GlobalData.Get().ResetWeaponGradePrecedent();

		if (BIO_Utils.Eviternity())
		{
			A_SelectWeapon('BIO_Fist');
			TakeInventory('BIO_Pistol', 1);
			GiveInventory('BIO_EviternityPistol', 1);
			A_SelectWeapon('BIO_EviternityPistol');
		}
	}

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
			EquippedArmor.ArmorData.SaveAmount = CountInv('BasicArmor') -
				(ret * EquippedArmor.ArmorData.SavePercent * 0.01);

			if (EquippedArmor.ArmorData.SaveAmount < 1)
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
		EquippedArmor.ArmorData.SaveAmount = CountInv('BasicArmor');
		EquippedArmor.Equipped = false;

		if (broken)
		{
			for (Inventory i = Inv; i != null; i = i.Inv)
			{
				if (i != EquippedArmor) continue;

				i.Amount = 0;
				i.DepleteOrDestroy();
			}
		}

		EquippedArmor = null;
		TakeInventory('BasicArmor', BIO_Armor.INFINITE_ARMOR);
		FindInventory('BasicArmor').MaxAmount = 1;
	}

	// Used to apply armor's affixes to BasicArmor, as well as
	// opening it up to modification by passives.
	void PreArmorApply(BIO_ArmorStats armor)
	{
		armor.SavePercent = EquippedArmor.ArmorData.SavePercent;
		armor.MaxAbsorb = EquippedArmor.ArmorData.MaxAbsorb;
		armor.MaxFullAbsorb = EquippedArmor.ArmorData.MaxFullAbsorb;
		armor.SaveAmount = EquippedArmor.ArmorData.SaveAmount;

		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.PreArmorApply(self, EquippedArmor, armor);
		}
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

	void OnArmorBonusPickup(BIO_ArmorBonus bonus)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnArmorBonusPickup(self, bonus);
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

	protected void Reset()
	{
		Height = Default.Height;
		Gravity = Default.Gravity;
		Friction = Default.Friction;
		Mass = Default.Mass;
		MaxStepHeight = Default.MaxStepHeight;
		MaxSlopeSteepness = Default.MaxSlopeSteepness;

		MaxHealth = Default.MaxHealth;
		BonusHealth = Default.BonusHealth;
		Stamina = Default.Stamina;

		ForwardMove1 = Default.ForwardMove1;
		ForwardMove2 = Default.ForwardMove2;
		SideMove1 = Default.SideMove1;
		SideMove2 = Default.SideMove2;
		JumpZ = Default.JumpZ;
		UseRange = Default.UseRange;
		
		RadiusDamageFactor = Default.RadiusDamageFactor;
		SelfDamageFactor = Default.SelfDamageFactor;
		
		AirCapacity = Default.AirCapacity;

		for (uint i = 0; i < Functors.Size(); i++)
			Functors[i].Clear();
	}

	// Passive/functor manipulation ============================================

	enum FunctorArrayIndex : uint
	{
		FANDX_DAMAGETAKEN,
		FANDX_EQUIPMENT,
		FANDX_ITEMPKUP,
		FANDX_KILL,
		FANDX_POWERUP,
		FANDX_TRANSITION,
		FANDX_WEAPON,
		__FANDX_COUNT__
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
