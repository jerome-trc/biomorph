/// Vanilla weapons are replaced by generic pickups that give different weapons
/// depending on what mutators have been chosen by the player touching the pickup.
class biom_WeaponPickup : Inventory abstract
{
	/// If a player touches this item while already having the weapon it would
	/// give, self-destruct after spawning `ammoCount` instances of this type.
	/// Note that game skill factor still applies.
	protected meta class<Inventory> ammoClass;
	protected meta uint ammoCount;

	/// Which weapon will this pickup try to give the player?
	protected meta biom_WeaponSlot Slot;

	property Slot: Slot;
	property AmmoGive: ammoClass, ammoCount;

	Default
	{
		+DONTGIB
		+FLOATBOB
		+FORCEXYBILLBOARD
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.NEVERRESPAWN

		Height 14.0;
		Radius 16.0;
		Scale 0.65;

		Inventory.Amount 0;
		Inventory.PickupMessage "";
		Inventory.PickupSound "";
		Inventory.RestrictedTo 'biom_Player';
	}

	/// Check if this is a Biomorph player pawn who does not already have the
	/// weapon this pickup wants to give.
	override bool CanPickup(Actor toucher)
	{
		if (!super.CanPickup(toucher))
			return false;

		let pawn = biom_Player(toucher);

		if (pawn == null)
			return false;

		return pawn.FindInventory(pawn.GetData().weapons[self.slot]) == null;
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let pawn = biom_Player(toucher);
		let weap_t = pawn.GetData().weapons[self.slot];
		let defs = GetDefaultByType(weap_t);
		self.PrintPickupMessage(pawn.CheckLocalView(), defs.PickupMessage());
		defs.PlayPickupSound(toucher);
		pawn.GiveInventory(weap_t, 1);
	}

	override bool TryPickupRestricted(in out Actor toucher)
	{
		if (self.ammoClass == null)
			return true;

		let c = Self.ammoCount * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);

		for (uint i = 0; i < c; ++i)
		{
			self.A_SpawnItemEx(
				self.ammoClass,
				FRandom(-20.0, 20.0),
				FRandom(-20.0, 20.0),
				flags: SXF_NOCHECKPOSITION
			);
		}

		self.GoAwayAndDie();
		return true;
	}
}

class biom_WeapPickup_Slot1 : biom_WeaponPickup replaces Chainsaw
{
	Default
	{
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_1;
	}

	States
	{
	Spawn:
		WPKP A 6;
		#### # 6 Bright Light("biom_WeaponPickup_Medium");
		Loop;
	}
}

class biom_WeapPickup_Slot2 : biom_WeaponPickup replaces Pistol
{
	Default
	{
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_2;
	}

	States
	{
	Spawn:
		WPKP B 6;
		#### # 6 Bright Light("biom_WeaponPickup_Small");
		Loop;
	}
}

class biom_WeapPickup_Slot3 : biom_WeaponPickup replaces Shotgun
{
	Default
	{
		biom_WeaponPickup.AmmoGive 'biom_Slot3Ammo_Small', 1;
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_3;
	}

	States
	{
	Spawn:
		WPKP C 6;
		#### # 6 Bright Light("biom_WeaponPickup_Medium");
		Loop;
	}
}

class biom_WeapPickup_Slot3Super : biom_WeaponPickup replaces SuperShotgun
{
	Default
	{
		biom_WeaponPickup.AmmoGive 'biom_Slot3Ammo_Small', 2;
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_3_SUPER;
	}

	States
	{
	Spawn:
		WPKP D 6;
		#### # 6 Bright Light("biom_WeaponPickup_Medium");
		Loop;
	}
}

class biom_WeapPickup_Slot4 : biom_WeaponPickup replaces Chaingun
{
	Default
	{
		biom_WeaponPickup.AmmoGive 'biom_Slot4Ammo_Small', 2;
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_4;
	}

	States
	{
	Spawn:
		WPKP E 6;
		#### # 6 Bright Light("biom_WeaponPickup_Medium");
		Loop;
	}
}

class biom_WeapPickup_Slot5 : biom_WeaponPickup replaces RocketLauncher
{
	Default
	{
		biom_WeaponPickup.AmmoGive 'biom_Slot5Ammo_Small', 2;
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_5;
	}

	States
	{
	Spawn:
		WPKP F 6;
		#### # 6 Bright Light("biom_WeaponPickup_Large");
		Loop;
	}
}

class biom_WeapPickup_Slot6 : biom_WeaponPickup replaces PlasmaRifle
{
	Default
	{
		biom_WeaponPickup.AmmoGive 'biom_Slot67Ammo_Small', 2;
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_6;
	}

	States
	{
	Spawn:
		WPKP G 6;
		#### # 6 Bright Light("biom_WeaponPickup_Medium");
		Loop;
	}
}

class biom_WeapPickup_Slot7 : biom_WeaponPickup replaces BFG9000
{
	Default
	{
		biom_WeaponPickup.AmmoGive 'biom_Slot67Ammo_Small', 2;
		biom_WeaponPickup.Slot BIOM_WEAPSLOT_7;
	}

	States
	{
	Spawn:
		WPKP H 6;
		#### # 6 Bright Light("biom_WeaponPickup_Large");
		Loop;
	}
}
