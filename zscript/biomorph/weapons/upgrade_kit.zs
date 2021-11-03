// Weapon upgrade kits sometimes spawn alongside big ammo pickups and are used
// to convert weapons to their higher-grade variants.
class BIO_WeaponUpgradeKit : Inventory
{
	Default
	{
		+DONTGIB
		+INVENTORY.INVBAR

		Height 16;
		Radius 20;
		Tag "$BIO_WUK_TAG";

		Inventory.InterHubAmount 8;
        Inventory.MaxAmount 8;
		Inventory.PickupMessage "$BIO_WUK_PICKUP";
	}

	States
	{
	Spawn:
		WUPK AB 6;
		Loop;
	}

	override bool CanPickup(Actor toucher)
	{
		if (!super.CanPickup(toucher)) return false;
		return BIO_Player(toucher) != null;
	}

	override bool Use(bool pickup)
	{
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);
		if (weap == null)
		{
			Owner.A_Print("$BIO_WUK_FAIL_NULLWEAP", 4.0);
			return false;
		}

		if (weap.Rarity == BIO_RARITY_UNIQUE)
		{
			Owner.A_Print("$BIO_WUK_FAIL_UNIQUE", 4.0);
			return false;
		}

		EventHandler.SendNetworkEvent(BIO_EventHandler.EVENT_WUKOVERLAY);
		return false;
	}
}

class BIO_WeaponUpgradeKitSpawner : Actor
{
	Default
	{
		-SOLID
		+DONTSPLASH
		+NOBLOCKMAP
		+NOTELEPORT
		+NOTIMEFREEZE
		+NOTONAUTOMAP

		Radius 16;
		Height 8;
		Speed 15;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 1
		{
			for (uint i = 0; i < 40; i++)
				A_Wander();
			Actor.Spawn('BIO_WeaponUpgradeKit', Pos);
		}
		Stop;
	}
}