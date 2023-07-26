class biom_WeaponPickup : Inventory abstract
{
	protected meta biom_WeaponFamily FAMILY;
	property Family: FAMILY;

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

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);
		let pawn = biom_Player(toucher);

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

			pawn.GiveInventory(pdat.weapons[i], 1);
			defs.PlayPickupSound(toucher);
			self.PrintPickupMessage(pawn.CheckLocalView(), defs.PickupMessage());
			return;
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
		#### # 6 bright light("biom_WeaponPickup_Medium");
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
		#### # 6 bright light("biom_WeaponPickup_Small");
		loop;
	}
}

class biom_wpk_Slot3 : biom_WeaponPickup
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SHOTGUN;
	}

	States
	{
	Spawn:
		WPKP C 6;
		#### # 6 bright light("biom_WeaponPickup_Medium");
		loop;
	}
}

class biom_wpk_Slot3Super : biom_WeaponPickup
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SUPERSHOTGUN;
	}

	States
	{
	Spawn:
		WPKP D 6;
		#### # 6 bright light("biom_WeaponPickup_Medium");
		loop;
	}
}

class biom_wpk_Slot4 : biom_WeaponPickup
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_AUTOGUN;
	}

	States
	{
	Spawn:
		WPKP E 6;
		#### # 6 bright light("biom_WeaponPickup_Medium");
		loop;
	}
}

class biom_wpk_Slot5 : biom_WeaponPickup
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_LAUNCHER;
	}

	States
	{
	Spawn:
		WPKP F 6;
		#### # 6 bright light("biom_WeaponPickup_Large");
		loop;
	}
}

class biom_wpk_Slot6 : biom_WeaponPickup
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_ENERGY;
	}

	States
	{
	Spawn:
		WPKP G 6;
		#### # 6 bright light("biom_WeaponPickup_Medium");
		loop;
	}
}

class biom_wpk_Slot7 : biom_WeaponPickup
{
	Default
	{
		biom_WeaponPickup.Family BIOM_WEAPFAM_SUPER;
	}

	States
	{
	Spawn:
		WPKP H 6;
		#### # 6 bright light("biom_WeaponPickup_Large");
		loop;
	}
}

/// An indirection over [`biom_WeaponPickup`]'s children to add accompanying ammo items.
/// That class can't do it since it gets dropped if the player swaps out one of
/// their weapon types.
class biom_WeaponPickupSpawner : biom_IntangibleActor
{
	protected meta class<biom_WeaponPickup> WEAPON_CLASS;
	property WeaponClass: WEAPON_CLASS;

	/// Note that game skill factor still applies.
	protected meta class<Inventory> AMMO_CLASS;
	protected meta uint AMMO_COUNT;
	property AmmoGive: AMMO_CLASS, AMMO_COUNT;

	override void BeginPlay()
	{
		super.BeginPlay();

		Actor.Spawn(self.WEAPON_CLASS, self.pos);

		if (Self.AMMO_CLASS == null)
			return;

		let c = Self.AMMO_COUNT * G_SkillPropertyFloat(SKILLP_AMMOFACTOR);

		for (uint i = 0; i < c; ++i)
			Actor.Spawn(self.AMMO_CLASS, self.pos);

		self.Destroy();
	}
}

class biom_wpks_Shotgun : biom_WeaponPickupSpawner replaces Shotgun
{
	Default
	{
		biom_WeaponPickupSpawner.WeaponClass 'biom_wpk_Slot3';
		biom_WeaponPickupSpawner.AmmoGive 'biom_Slot3Ammo_Small', 1;
	}
}

class biom_wpks_SuperShotgun : biom_WeaponPickupSpawner replaces SuperShotgun
{
	Default
	{
		biom_WeaponPickupSpawner.WeaponClass 'biom_wpk_Slot3Super';
		biom_WeaponPickupSpawner.AmmoGive 'biom_Slot3Ammo_Small', 2;
	}
}

class biom_wpks_Chaingun : biom_WeaponPickupSpawner replaces Chaingun
{
	Default
	{
		biom_WeaponPickupSpawner.WeaponClass 'biom_wpk_Slot4';
		biom_WeaponPickupSpawner.AmmoGive 'biom_Slot4Ammo_Small', 1;
	}
}

class biom_wpks_RocketLauncher : biom_WeaponPickupSpawner replaces RocketLauncher
{
	Default
	{
		biom_WeaponPickupSpawner.WeaponClass 'biom_wpk_Slot5';
		biom_WeaponPickupSpawner.AmmoGive 'biom_Slot5Ammo_Small', 2;
	}
}

class biom_wpks_PlasmaRifle : biom_WeaponPickupSpawner replaces PlasmaRifle
{
	Default
	{
		biom_WeaponPickupSpawner.WeaponClass 'biom_wpk_Slot6';
		biom_WeaponPickupSpawner.AmmoGive 'biom_Slot67Ammo_Small', 2;
	}
}

class biom_wpks_BFG9000 : biom_WeaponPickupSpawner replaces BFG9000
{
	Default
	{
		biom_WeaponPickupSpawner.WeaponClass 'biom_wpk_Slot7';
		biom_WeaponPickupSpawner.AmmoGive 'biom_Slot67Ammo_Small', 2;
	}
}
