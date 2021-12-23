// Inventory items as proxies for key bindings to act upon the player.

class BIO_Keybind : Inventory abstract
{
	protected bool Primed;

	Default
	{
		Inventory.Icon 'TNT1A0';
		Inventory.InterHubAmount 1;
		Inventory.MaxAmount 1;
		Inventory.PickupMessage
			"If you're seeing this message, things might break.";

		-COUNTITEM
		+INVENTORY.KEEPDEPLETED
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Loop;
	}

	bool IsPrimed() const { return Primed; }
	void Disarm() { Primed = false; }
}

// Making weapons try to drop themselves leads to buggy behaviour.
class BIO_WeaponDrop : BIO_Keybind
{
	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		let weap = BIO_Weapon(bioPlayer.Player.ReadyWeapon);
		if (weap == null || weap.Grade == BIO_GRADE_NONE) return false;

		if (!Primed)
		{
			int k1, k2;
			[k1, k2] = Bindings.GetKeysForCommand("use BIO_WeaponDrop");
			string prompt = String.Format(
				StringTable.Localize("$BIO_WEAPDROP_CONFIRM"),
				Keybindings.NameKeys(k1, k2));
			bioPlayer.A_Print(prompt, 3.0);
			Primed = true;
			BIO_KeybindDisarmer.Create(self);
		}
		else
		{
			// Flush confirm message off screen
			bioPlayer.A_Print("", 0.0);
			Owner.DropInventory(weap, 1);
			Primed = false;
		}

		return false;
	}
}

class BIO_UnequipArmor : BIO_Keybind
{
	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		let armor = bioPlayer.EquippedArmor;
		if (armor == null)
		{
			A_Print("$BIO_ARMORUNEQUIP_FAIL_NOARMOR");
			return false;
		}
		
		if (!Primed)
		{
			int k1, k2;
			[k1, k2] = Bindings.GetKeysForCommand("use BIO_UnequipArmor");
			string prompt = String.Format(
				StringTable.Localize("$BIO_ARMORUNEQUIP_CONFIRM"),
				Keybindings.NameKeys(k1, k2));
			bioPlayer.A_Print(prompt, 3.0);
			Primed = true;
			BIO_KeybindDisarmer.Create(self);
		}
		else
		{
			bioPlayer.A_Print(String.Format(
				StringTable.Localize("$BIO_ARMORUNEQUIP"),
				bioPlayer.EquippedArmor.GetTag()));
			bioPlayer.UnequipArmor(false);
			Primed = false;
		}

		return false;
	}
}

class BIO_KeybindDisarmer : Thinker
{
	private BIO_Keybind ToDisarm;
	private int Lifetime;

	static BIO_KeybindDisarmer Create(BIO_Keybind toDisarm)
	{
		let ret = new('BIO_KeybindDisarmer');
		ret.ToDisarm = toDisarm;
		return ret;
	}

	final override void Tick()
	{
		super.Tick();
		
		if (Lifetime++ >= TICRATE * 3)
		{
			ToDisarm.Disarm();
			if (!bDestroyed) Destroy();
			return;
		}
	}
}
