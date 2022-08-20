// Inventory items as proxies for key bindings to act upon the player.

class BIO_Keybind : BIO_PermanentInventory abstract
{
	Default
	{
		Inventory.RestrictedTo 'BIO_Player';
		Inventory.PickupMessage
			"If you see this message, please report a bug to RatCircus.";
	}

	protected bool Primed;

	bool IsPrimed() const { return Primed; }
	void Disarm() { Primed = false; }
}

// Making weapons try to drop themselves leads to buggy behaviour.
class BIO_WeaponDrop : BIO_Keybind
{
	final override bool Use(bool pickup)
	{
		let pawn = BIO_Player(Owner);

		let weap = BIO_Weapon(pawn.Player.ReadyWeapon);

		if (weap == null || weap is 'BIO_Unarmed')
			return false;

		if (!Primed)
		{
			int k1, k2;
			[k1, k2] = Bindings.GetKeysForCommand("use BIO_WeaponDrop");
			string prompt = String.Format(
				StringTable.Localize("$BIO_WEAPDROP_CONFIRM"),
				Keybindings.NameKeys(k1, k2)
			);
			pawn.A_Print(prompt, 3.0);
			Primed = true;
			BIO_KeybindDisarmer.Create(self);
		}
		else
		{
			// Flush confirm message off screen
			pawn.A_Print("", 0.0);
			Primed = false;

			Owner.DropInventory(weap, 1);
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
