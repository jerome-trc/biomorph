enum BIO_PlayerPawnFlags : uint8
{
	BIO_PPF_NONE = 0,
	BIO_PPF_3XNONPISTOLWEIGHT = 1 << 0,
	BIO_PPF_3XNONMELEEWEIGHT = 1 << 1,
	BIO_PPF_ALL = uint8.MAX
}

class BIO_Player : DoomPlayer
{
	BIO_PlayerPawnFlags BIOFlags;
	property Flags: BIOFlags;

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

	BIO_Weapon ExaminedWeapon;
	private uint16 ExamineTimer;

	Default
	{
		Species 'Player';

		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem 'BIO_WeaponDrop';
		Player.StartItem 'BIO_UnequipArmor';
		Player.StartItem 'BIO_PickupHandler';

		Player.StartItem 'Clip', 35;
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
		let globals = BIO_GlobalData.Get();
		if (globals != null) globals.ResetWeaponGradePrecedent();

		if (BIO_Utils.Eviternity())
		{
			A_SelectWeapon('BIO_Fist');
			TakeInventory('BIO_Pistol', 1);
			GiveInventory('BIO_EviternityPistol', 1);
			A_SelectWeapon('BIO_EviternityPistol');
		}
		else if (BIO_Utils.Valiant())
		{
			A_SelectWeapon('BIO_Fist');
			TakeInventory('BIO_Pistol', 1);
			GiveInventory('BIO_ValiantPistol', 1);
			A_SelectWeapon('BIO_ValiantPistol');
		}
	}

	override void Tick()
	{
		super.Tick();

		if (ExaminedWeapon != null && --ExamineTimer <= 0)
		{
			ExaminedWeapon = null;
			ExamineTimer = 0;
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
		{
			let weap = BIO_Weapon(i);

			if (weap == null || weap is 'BIO_Fist') continue;

			if (BIOFlags & BIO_PPF_3XNONPISTOLWEIGHT && !(weap.BIOFlags & BIO_WF_PISTOL))
				ret += 3;
			else if (BIOFlags & BIO_PPF_3XNONMELEEWEIGHT && !(weap.bMeleeWeapon))
				ret += 3;
			else
				ret++;
		}

		return ret;
	}

	uint HeldEquipmentCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Equipment') ret++;
		
		return ret;
	}

	// Allows the HUD to retrieve both values by iterating
	// through the inventory linked list only once.
	uint, uint HeldWeaponAndEquipmentCounts() const
	{
		uint retW = 0, retE = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			if (i is 'BIO_Equipment')
			{
				retE++;
				continue;
			}

			let weap = BIO_Weapon(i);

			if (weap == null || weap is 'BIO_Fist') continue;

			if (BIOFlags & BIO_PPF_3XNONPISTOLWEIGHT && !(weap.BIOFlags & BIO_WF_PISTOL))
				retW += 3;
			else if (BIOFlags & BIO_PPF_3XNONMELEEWEIGHT && !(weap.bMeleeWeapon))
				retW += 3;
			else
				retW++;
		}

		return retW, retE;
	}

	bool IsFullOnWeapons() const { return HeldWeaponCount() >= MaxWeaponsHeld; }
	bool IsFullOnEquipment() const { return HeldEquipmentCount() >= MaxEquipmentHeld; }

	bool CanCarryWeapon(BIO_Weapon weap) const
	{
		if (BIOFlags & BIO_PPF_3XNONPISTOLWEIGHT && !(weap.BIOFlags & BIO_WF_PISTOL))
			return HeldWeaponCount() < (MaxWeaponsHeld - 3);
		else if (BIOFlags & BIO_PPF_3XNONMELEEWEIGHT && !(weap.bMeleeWeapon))
			return HeldWeaponCount() < (MaxWeaponsHeld - 3);
		else
			return HeldWeaponCount() < MaxWeaponsHeld;
	}

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
			FindInventory('BasicArmor').MaxAmount = EquippedArmor.ArmorData.MaxAmount;
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

	void OnFirstBackpackPickup(BIO_Backpack bkpk)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnFirstBackpackPickup(self, bkpk);
	}

	void OnSubsequentBackpackPickup(BIO_Backpack bkpk)
	{
		for (uint i = 0; i < ItemPickupFunctors.Size(); i++)
			ItemPickupFunctors[i].OnSubsequentBackpackPickup(self, bkpk);
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

	void Reset()
	{
		bDontThrust = Default.bDontThrust;
		bCantSeek = Default.bCantSeek;
		BIOFlags = Default.BIOFlags;

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

		bool hasBackpack = FindInventory('BIO_Backpack', true) != null;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			if (!(i is 'Ammo')) continue;

			i.MaxAmount = !hasBackpack ? i.Default.MaxAmount : Ammo(i).BackpackMaxAmount;
		}

		MaxWeaponsHeld = Default.MaxWeaponsHeld;
		MaxEquipmentHeld = Default.MaxEquipmentHeld;

		DamageTakenFunctors.Clear();
		EquipmentFunctors.Clear();
		ItemPickupFunctors.Clear();
		KillFunctors.Clear();
		PowerupFunctors.Clear();
		TransitionFunctors.Clear();
		WeaponFunctors.Clear();

		let evh = BIO_EventHandler(EventHandler.Find('BIO_EventHandler'));
		SetMapSensitiveDefaults(evh.GetContextFlags());
	}

	void SetMapSensitiveDefaults(BIO_EventHandlerContextFlags ctxtFlags)
	{
		if (ctxtFlags & BIO_EHCF_VALIANT)
		{
			let clipItem = Ammo(FindInventory('Clip'));

			if (clipItem.MaxAmount < 300)
				clipItem.MaxAmount = 300;
			else
				return;

			if (clipItem.BackpackMaxAmount < 600)
				clipItem.BackpackMaxAmount = 600;
		}
	}

	void ApplyPerks()
	{
		Array<BIO_Perk> arr, temp;
		BIO_GlobalData.Get().GetPlayerPerkObjects(Player, arr);		
		temp.Move(arr);

		while (temp.Size() > 0)
		{
			int highest = int.MIN;
			uint highest_idx = uint.MAX;

			for (uint i = 0; i < temp.Size(); i++)
			{
				int prio = temp[i].OrderPriority();

				if (prio > highest)
				{
					highest = prio;
					highest_idx = i;
				}
			}

			arr.Push(temp[highest_idx]);
			temp.Delete(highest_idx);
		}

		for (uint i = 0; i < arr.Size(); i++)
			arr[i].Apply(self);

		// Deal with possible consequences of perk refunds

		int
			hwc = HeldWeaponCount() - MaxWeaponsHeld,
			hec = HeldEquipmentCount() - MaxEquipmentHeld;

		Array<Inventory> toDrop;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			if (i is 'BIO_Weapon' && !(i is 'BIO_Fist') && hwc > 0)
			{
				toDrop.Push(i);
				hwc--;
			}
			else if (i is 'BIO_Equipment' && hec > 0)
			{
				toDrop.Push(i);
				hec--;
			}
			else if (i is 'Ammo')
			{
				let ammoItem = Ammo(i);
				int diff = ammoItem.Amount - ammoItem.MaxAmount;

				while (diff > 0)
				{
					DropInventory(ammoItem, ammoItem.Default.Amount);
					diff -= ammoItem.Default.Amount;
				}
			}
		}

		for (uint i = 0; i < toDrop.Size(); i++)
			DropInventory(toDrop[i], 1);
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

	// Miscellaneous ===========================================================

	void ExamineWeapon(BIO_Weapon weap, uint upTime)
	{
		ExaminedWeapon = weap;
		ExamineTimer = upTime;
		A_StartSound("bio/ui/beep", attenuation: 1.2);
	}
}

class BIO_PickupHandler : BIO_PermanentInventory
{
	final override bool HandlePickup(Inventory item)
	{
		// DEHACKED sometimes creates proxies for vanilla weapons which
		// the event handler doesn't replace, allowing pickups which shouldn't
		// technically be possible (see Ancient Aliens' SSG for an example).

		static const Class<Weapon> VANILLA_WEAPS[] = {
			'Pistol',
			'Shotgun',
			'SuperShotgun',
			'Chaingun',
			'RocketLauncher',
			'PlasmaRifle',
			'BFG9000'
		};

		for (uint i = 0; i < VANILLA_WEAPS.Size(); i++)
		{
			if (item.GetClass() != VANILLA_WEAPS[i]) continue;

			string bioEquiv_tn = "BIO_" .. VANILLA_WEAPS[i].GetClassName();
			Actor.Spawn(bioEquiv_tn, item.Pos);
			item.bPickupGood = true;
			item.GoAwayAndDie();
			return true;
		}

		return false;
	}
}

class BIO_Antigen : Inventory
{
	Default
    {
		-COUNTITEM
		+DONTGIB
		+INVENTORY.INVBAR

		Height 16;
        Radius 20;
		Tag "$BIO_ANTIGEN_TAG";

		Inventory.Icon 'ANTGB0';
		Inventory.InterHubAmount 9999;
        Inventory.MaxAmount 9999;
		Inventory.PickupMessage "$BIO_ANTIGEN_PKUP";
		Inventory.UseSound "bio/muta/use/undo";
    }

	States
	{
	Spawn:
		ANTG A 6;
		ANTG B 6 Bright Light("BIO_Muta_Reset");
		Loop;
	}

	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);

		if (bioPlayer == null)
		{
			Owner.A_Print("$BIO_ANTIGEN_FAIL_NONBIOMORPH", 4.0);
			return false;
		}

		BIO_GlobalData.Get().GetPerkGraph(Owner.Player).Refunds++;
		Owner.A_Print("$BIO_ANTIGEN_USE");
		return true;
	}
}
