// Derived from https://forum.zdoom.org/viewtopic.php?f=105&t=71169
class BIO_ToggleInventory : Inventory
{
	private bool Active;
	private int Clock;

	meta class<Powerup> Type;
	property Type: Type;

	// Time in tics (or negative values for seconds) it takes to deplete 1 unit.
	private int DepleteTics;
	property DepleteTics: DepleteTics;
	// Time in tics (or negative values for seconds) it takes to regenerate 1 unit.
	// 0 implies no regeneration.
	private int RegenTics;
	property RegenTics: RegenTics;

	meta sound ActivateSound, DeactivateSound, DepletedSound;
	property ActivateSound: ActivateSound;
	property DeactivateSound: DeactivateSound;
	property DepletedSound: DepletedSound;

	meta bool
		CheckFloorRegen, // Only regenerate the powerup if the player is on the ground.
		ActiveOnly; // Powerup can only be activated, not deactivated.
	property CheckFloorRegen: CheckFloorRegen;
	property ActiveOnly: ActiveOnly;

	Default
	{
		+INVENTORY.INVBAR;
		+INVENTORY.KEEPDEPLETED;

		Inventory.Amount 100;  
		Inventory.MaxAmount 100;
		Inventory.InterHubAmount 100;
		BIO_ToggleInventory.DepleteTics -1;
		BIO_ToggleInventory.RegenTics -3;
	}

	override void AttachToOwner(actor other)
	{
		super.AttachToOwner(other);

		if (DepleteTics < 0)
			DepleteTics = (-DepleteTics) * TICRATE;

		if (RegenTics < 0)
			RegenTics = (-RegenTics) * TICRATE;
	}

	override void DoEffect()
	{
		if (!Active)
			return;

		if (Amount >= 1)
			return;

		Owner.TakeInventory(Type, 1);
		Active = false;
		Owner.A_StartSound(DepletedSound, CHAN_AUTO);

		if (!bKeepDepleted)
			DepleteOrDestroy();
				return;

		if (Active && !Owner.CountInv(Type))
			Active = false;

		// Deplete/regenerate the amount if
		// `Clock` is equal to `DepletionTics`/`RegenTics`.
		if (Active && ++Clock == DepleteTics)
		{
			Clock = 0;
			Amount = Max(Amount - 1, 0);
			return;
		}

		if (!Active && Amount < MaxAmount && RegenTics && ++Clock == RegenTics)
		{
			Clock = 0;

			// For preventing regeneration while falling (good for jetpacks and stuff)
			if (CheckFloorRegen && !Owner.Player.OnGround)
				return;

			Amount = Min(Amount + 1, MaxAmount);
				return;
		}
	}

	override bool Use(bool pickup)
	{
		if (Amount < 1)
			return false;

		if (Active)
		{
			if (ActiveOnly)
				return false;

			Owner.TakeInventory(Type, 1);
			DeactivatePowerup();
		}
		else
		{
			GiveToggleablePowerup();
			ActivatePowerup();
		}

		Clock = 0;
		Active = !Active;
		return false;
	}

	void GiveToggleablePowerup()
	{
		Owner.GiveInventory(Type, 1);
		let i = Powerup(Owner.FindInventory(Type));

		// Note: '0x7FFFFFFD' instead of '0x7FFFFFFF' to work with PowerTimeFreezer.
		if(i)
			i.EffectTics = 0x7FFFFFFD;
	}

	virtual void ActivatePowerup()
	{
		Owner.A_StartSound(ActivateSound, CHAN_AUTO);
	}

	virtual void DeactivatePowerup()
	{
		Owner.A_StartSound(DeactivateSound, CHAN_AUTO);
	}
}
