class BIO_Player : DoomPlayer
{
	Array<BIO_DamageTakenFunctor> DamageTakenFunctors;
	Array<BIO_EquipmentFunctor> EquipmentFunctors;
	Array<BIO_ItemPickupFunctor> ItemPickupFunctors;
	Array<BIO_KillFunctor> KillFunctors;
	Array<BIO_PowerupFunctor> PowerupFunctors;
	Array<BIO_TransitionFunctor> TransitionFunctors;
	Array<BIO_WeaponFunctor> WeaponFunctors;

	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	double SlimeDamageFactor; property SlimeDamageFactor: SlimeDamageFactor;

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
		BIO_Player.SlimeDamageFactor 1.0;
	}

	// Parent overrides ========================================================

	override void GiveDefaultInventory()
	{
		super.GiveDefaultInventory();
		
		// If the default inventory has been given, it's either a new game
		// or the inventory was cleared by a death exit
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

		if (dmgType == 'Slime')
			ret *= SlimeDamageFactor;

		for (uint i = 0; i < DamageTakenFunctors.Size(); i++)
		{
			DamageTakenFunctors[i].OnDamageTaken(
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
		for (uint i = 0; i < TransitionFunctors.Size(); i++)
			TransitionFunctors[i].WorldLoaded(self, isSaveGame, isReopen);
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		let bioWeapon = BIO_Weapon(Player.ReadyWeapon);
		if (bioWeapon != null) bioWeapon.OnKill(killed, inflictor);

		for (uint i = 0; i < KillFunctors.Size(); i++)
			KillFunctors[i].OnKill(self, inflictor, killed);
	}

	void Equip(BIO_Equipment equippable)
	{
		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			EquipmentFunctors[i].OnEquip(self, equippable);

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
		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			EquipmentFunctors[i].OnUnequip(self, EquippedArmor, broken);

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
	// opening it up to modification by perks.
	void PreArmorApply(BIO_ArmorStats armor)
	{
		armor.SavePercent = EquippedArmor.ArmorData.SavePercent;
		armor.MaxAbsorb = EquippedArmor.ArmorData.MaxAbsorb;
		armor.MaxFullAbsorb = EquippedArmor.ArmorData.MaxFullAbsorb;
		armor.SaveAmount = EquippedArmor.ArmorData.SaveAmount;

		for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			EquipmentFunctors[i].PreArmorApply(self, EquippedArmor, armor);
	}

	void BeforeEachFire(in out BIO_FireData fireData)
	{
		for (uint i = 0; i < WeaponFunctors.Size(); i++)
			WeaponFunctors[i].BeforeEachFire(self, fireData);
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

	void OnArmorBonusPickup(BIO_ArmorBonus bonus)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnArmorBonusPickup(self, bonus);
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

	protected void Reset()
	{
		bDontThrust = Default.bDontThrust;
		bCantSeek = Default.bCantSeek;

		Friction = Default.Friction;
		Gravity = Default.Gravity;
		Height = Default.Height;
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
		SlimeDamageFactor = Default.SlimeDamageFactor;
		
		AirCapacity = Default.AirCapacity;

		DamageTakenFunctors.Clear();
		EquipmentFunctors.Clear();
		ItemPickupFunctors.Clear();
		KillFunctors.Clear();
		PowerupFunctors.Clear();
		TransitionFunctors.Clear();
		WeaponFunctors.Clear();
	}

	// Perk/functor manipulation ===============================================

	void PushFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		uint ndx = uint.MAX;

		if (func_t is 'BIO_DamageTakenFunctor')
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
		else if (func_t is 'BIO_EquipmentFunctor')
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
		else if (func_t is 'BIO_ItemPickupFunctor')
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
		else if (func_t is 'BIO_KillFunctor')
		{
			for (uint i = 0; i < KillFunctors.Size(); i++)
			{
				if (KillFunctors[i].GetClass() == func_t)
				{
					KillFunctors[i].Count += count;
					return;
				}
			}

			uint e = KillFunctors.Push(BIO_KillFunctor(new(func_t)));
			KillFunctors[e].Count = count;
		}
		else if (func_t is 'BIO_PowerupFunctor')
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
		else if (func_t is 'BIO_TransitionFunctor')
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
		else if (func_t is 'BIO_WeaponFunctor')
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
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to push player pawn functor of invalid type %s onto player %s",
				func_t.GetClassName(), GetTag());
			return;
		}
	}

	void PopFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		bool all = count <= 0;

		if (func_t is 'BIO_DamageTakenFunctor')
		{
			for (uint i = 0; i < DamageTakenFunctors.Size(); i++)
			{
				if (DamageTakenFunctors[i].GetClass() != func_t) continue;
				
				if (DamageTakenFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop damage-taken functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, DamageTakenFunctors[i].Count);
				}

				DamageTakenFunctors[i].Count -= (all ? DamageTakenFunctors[i].Count : count);
				
				if (DamageTakenFunctors[i].Count <= 0)
					DamageTakenFunctors.Delete(i);
				
				return;
			}
		}
		else if (func_t is 'BIO_EquipmentFunctor')
		{
			for (uint i = 0; i < EquipmentFunctors.Size(); i++)
			{
				if (EquipmentFunctors[i].GetClass() != func_t) continue;
				
				if (EquipmentFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop equipment functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, EquipmentFunctors[i].Count);
				}

				EquipmentFunctors[i].Count -= (all ? EquipmentFunctors[i].Count : count);
				
				if (EquipmentFunctors[i].Count <= 0)
					EquipmentFunctors.Delete(i);
				
				return;
			}
		}
		else if (func_t is 'BIO_ItemPickupFunctor')
		{
			for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			{
				if (ItemPickupFunctors[i].GetClass() != func_t) continue;
				
				if (ItemPickupFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop item pickup functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, ItemPickupFunctors[i].Count);
				}

				ItemPickupFunctors[i].Count -= (all ? ItemPickupFunctors[i].Count : count);
				
				if (ItemPickupFunctors[i].Count <= 0)
					ItemPickupFunctors.Delete(i);
				
				return;
			}
		}
		else if (func_t is 'BIO_KillFunctor')
		{
			for (uint i = 0; i < KillFunctors.Size(); i++)
			{
				if (KillFunctors[i].GetClass() != func_t) continue;
				
				if (KillFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop weapon functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, KillFunctors[i].Count);
				}

				KillFunctors[i].Count -= (all ? KillFunctors[i].Count : count);
				
				if (KillFunctors[i].Count <= 0)
					KillFunctors.Delete(i);
				
				return;
			}
		}
		else if (func_t is 'BIO_PowerupFunctor')
		{
			for (uint i = 0; i < PowerupFunctors.Size(); i++)
			{
				if (PowerupFunctors[i].GetClass() != func_t) continue;
				
				if (PowerupFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop powerup functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, PowerupFunctors[i].Count);
				}

				PowerupFunctors[i].Count -= (all ? PowerupFunctors[i].Count : count);
				
				if (PowerupFunctors[i].Count <= 0)
					PowerupFunctors.Delete(i);
				
				return;
			}
		}
		else if (func_t is 'BIO_TransitionFunctor')
		{
			for (uint i = 0; i < TransitionFunctors.Size(); i++)
			{
				if (TransitionFunctors[i].GetClass() != func_t) continue;
				
				if (TransitionFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop transition functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, TransitionFunctors[i].Count);
				}

				TransitionFunctors[i].Count -= (all ? TransitionFunctors[i].Count : count);
				
				if (TransitionFunctors[i].Count <= 0)
					TransitionFunctors.Delete(i);
				
				return;
			}
		}
		else if (func_t is 'BIO_WeaponFunctor')
		{
			for (uint i = 0; i < WeaponFunctors.Size(); i++)
			{
				if (WeaponFunctors[i].GetClass() != func_t) continue;
				
				if (WeaponFunctors[i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop weapon functor %s off player %s %d times, "
						"but can only do %d.", func_t.GetClassName(),
						Player.GetUserName(), count, WeaponFunctors[i].Count);
				}

				WeaponFunctors[i].Count -= (all ? WeaponFunctors[i].Count : count);
				
				if (WeaponFunctors[i].Count <= 0)
					WeaponFunctors.Delete(i);
				
				return;
			}
		}
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to pop player pawn functor of invalid type %s off player %s",
				func_t.GetClassName(), GetTag());
			return;
		}
	}
}
