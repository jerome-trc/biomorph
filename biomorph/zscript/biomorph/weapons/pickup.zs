class biom_WeaponPickup : Inventory abstract
{
	protected meta biom_WeaponFamily FAMILY;
	property Family: FAMILY;

	/// Note that game skill factor still applies.
	protected meta class<Inventory> AMMO_CLASS;
	protected meta uint AMMO_COUNT;
	property AmmoGive: AMMO_CLASS, AMMO_COUNT;

	Default
	{
		+DONTGIB
		+FLOATBOB
		+FORCEXYBILLBOARD
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.NEVERRESPAWN

		Height 14.0;
		Radius 16.0;
		Scale 0.9;

		Inventory.Amount 0;
		Inventory.PickupMessage "";
		Inventory.PickupSound "";
		Inventory.RestrictedTo 'biom_Player';
	}

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (Self.AMMO_CLASS == null)
			return;

		let c = Self.AMMO_COUNT * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);

		for (uint i = 0; i < c; ++i)
			Actor.Spawn(self.AMMO_CLASS, self.pos);
	}

	final override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		let pawn = biom_Player(toucher);

		if ((pawn.GetWeaponsFound() & self.FAMILY) != 0)
			return;

		pawn.OnWeaponFound(self.family);

		let pdat = pawn.GetData();

		for (int i = 0; i < pdat.weapons.Size(); ++i)
		{
			if (pdat.weapons[i] is 'biom_Unarmed')
				continue;

			let defs = GetDefaultByType(pdat.weapons[i]);

			if (defs.FAMILY != self.FAMILY)
				continue;

			if (pawn.FindInventory(pdat.weapons[i]) != null)
				continue;

			biom_Weapon.GiveTo(pawn, defs);

			if (!CVar.GetCVar("neverswitchonpickup", pawn.player).GetBool())
				pawn.A_SelectWeapon(pdat.weapons[i]);
		}
	}
}

class biom_wpk_Slot1 : biom_WeaponPickup replaces Chainsaw
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_MELEE;
	}

	States
	{
	Spawn:
		WPKP A 6;
		#### # 6 bright light("biom_WeaponPickupSlot1");
		loop;
	}
}

class biom_wpk_Slot2 : biom_WeaponPickup replaces Pistol
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SIDEARM;
	}

	States
	{
	Spawn:
		WPKP B 6;
		#### # 6 bright light("biom_WeaponPickupSlot2");
		loop;
	}
}

class biom_wpk_Slot3 : biom_WeaponPickup replaces Shotgun
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SHOTGUN;
		biom_WeaponPickup.AmmoGive 'biom_Slot3AmmoSmall', 1;
	}

	States
	{
	Spawn:
		WPKP C 6;
		#### # 6 bright light("biom_WeaponPickupSlot3");
		loop;
	}
}

class biom_wpk_Slot3Super : biom_WeaponPickup replaces SuperShotgun
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SUPERSHOTGUN;
		biom_WeaponPickup.AmmoGive 'biom_Slot3AmmoSmall', 2;
	}

	States
	{
	Spawn:
		WPKP D 6;
		#### # 6 bright light("biom_WeaponPickupSlot3Super");
		loop;
	}
}

class biom_wpk_Slot4 : biom_WeaponPickup replaces Chaingun
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_AUTOGUN;
		biom_WeaponPickup.AmmoGive 'biom_Slot4AmmoSmall', 1;
	}

	States
	{
	Spawn:
		WPKP E 6;
		#### # 6 bright light("biom_WeaponPickupSlot4");
		loop;
	}
}

class biom_wpk_Slot5 : biom_WeaponPickup replaces RocketLauncher
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_LAUNCHER;
		biom_WeaponPickup.AmmoGive 'biom_Slot5AmmoSmall', 2;
	}

	States
	{
	Spawn:
		WPKP F 6;
		#### # 6 bright light("biom_WeaponPickupSlot5");
		loop;
	}
}

class biom_wpk_Slot6 : biom_WeaponPickup replaces PlasmaRifle
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_ENERGY;
		biom_WeaponPickup.AmmoGive 'biom_Slot67AmmoSmall', 2;
	}

	States
	{
	Spawn:
		WPKP G 6;
		#### # 6 bright light("biom_WeaponPickupSlot6");
		loop;
	}
}

class biom_wpk_Slot7 : biom_WeaponPickup replaces BFG9000
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SUPER;
		biom_WeaponPickup.AmmoGive 'biom_Slot67AmmoSmall', 2;
	}

	States
	{
	Spawn:
		WPKP H 6;
		#### # 6 bright light("biom_WeaponPickupSlot7");
		loop;
	}
}
