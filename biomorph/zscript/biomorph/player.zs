// Note to reader: classes are defined using `extend` blocks for code folding.

class BIO_Player : DoomPlayer
{
	uint8 MaxWeaponsHeld; property MaxWeaponsHeld: MaxWeaponsHeld;
	uint8 MaxGenesHeld; property MaxGenesHeld: MaxGenesHeld;

	BIO_Perk Perks[4];

	BIO_Weapon ExaminedWeapon;
	private uint16 ExamineTimer;

	private Array<BIO_Magazine> Magazines;

	Default
	{
		Tag "$BIO_MODTITLE";
		Species 'Player';
		BloodColor 'Cyan';

		Player.DisplayName "$BIO_MODTITLE";
		Player.SoundClass 'biomorph';

		Player.StartItem 'Clip', 0;
		Player.StartItem 'Shell', 0;
		Player.StartItem 'RocketAmmo', 0;
		Player.StartItem 'Cell', 0;

		Player.StartItem 'BIO_WeaponDrop';

		BIO_Player.MaxWeaponsHeld 8;
		BIO_Player.MaxGenesHeld 10;
	}

	void ExamineWeapon(BIO_Weapon weap)
	{
		ExaminedWeapon = weap;
		ExamineTimer = TICRATE * 5;
		A_StartSound("bio/ui/beep", attenuation: 1.2);
	}
}

// General introspection.
extend class BIO_Player
{
	uint HeldWeaponCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			let weap = BIO_Weapon(i);

			if (weap == null || weap.Family == BIO_WEAPFAM_UNARMED)
				continue;

			ret++;
		}

		return ret;
	}

	uint HeldGeneCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Gene')
				ret++;

		return ret;
	}

	uint HeldPerkCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Perk')
				ret++;

		return ret;
	}

	// For use by the HUD, to not have to iterate over the linked list thrice.
	uint, uint, uint InventoryCounts() const
	{
		uint ret1 = 0, ret2 = 0, ret3 = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			let weap = BIO_Weapon(i);

			if (weap != null && weap.Family != BIO_WEAPFAM_UNARMED)
				ret1++;
			else if (i is 'BIO_Gene')
				ret2++;
			else if (i is 'BIO_Perk')
				ret3++;
		}

		return ret1, ret2, ret3;
	}
}

// Parent overrides.
extend class BIO_Player
{
	override void BeginPlay()
	{
		super.BeginPlay();
		GenerateMagazines();
	}

	// How much to reduce the slippery movement.
	// Lower number = less slippery.
	const DECEL_MULT = 0.85;

	override void Tick()
	{
		super.Tick();

		if (ExaminedWeapon != null && --ExamineTimer <= 0)
		{
			ExaminedWeapon = null;
			ExamineTimer = 0;
		}

		for (uint i = 0; i < Magazines.Size(); i++)
			Magazines[i].Tick(self);

		// Code below courtesy of Nash Muhandes
		// https://forum.zdoom.org/viewtopic.php?f=105&t=35761

		if (Pos.Z ~== FloorZ || bOnMObj)
		{
			// Bump up the player's speed to compensate for the deceleration
			// TODO (Nash): math here is shit and wrong, please fix
			double s = 1.0 + (1.0 - DECEL_MULT);
			Speed = s * 2.0;

			// Decelerate the player, if not in pain
			Vel.X *= DECEL_MULT;
			Vel.Y *= DECEL_MULT;

			// Make the view bobbing match the player's movement
			ViewBob = DECEL_MULT;
		}

		if (!Player.OnGround || Vel.Length() < 0.1)
			return;

		// Math below courtesy of Marrub
		// See DoomRL_Arsenal.pk3/scripts/DRLALIB_Misc.acs, "RLGetStepSpeed"

		float v = (Abs(Vel.X), Abs(Vel.Y)).Length();
		float mul = Clamp(1.0 - (v / 24.0), 0.35, 1.0);
		let interval = int(10.0 * (mul + 0.6));

		if ((Level.MapTime % interval) != 0)
			return;

		A_StartSound("bio/pawn/footstep/normal", CHAN_AUTO);
	}

	override void ClearInventory()
	{
		if (BIO_CVar.InvClear_Always(Player))
			super.ClearInventory();
	}

	override void GiveDefaultInventory()
	{
		// When the player submits input after dying:
		// 1. Global data gets destroyed
		// 2. A fraction of a second passes in which the engine calls this
		// 3. Whatever the engine did is overriden because the last save gets loaded
		// I don't know why things work this way but it has to get handled
		if (BIO_Global.Get() == null)
			return;

		if (FindInventory('BIO_WeaponDrop'))
		{
			// The player has already had their inventory initialised for the
			// first time, but the map has attempted to force a reset
			GiveInventory('BIO_Unarmed', 1);
			GiveRandomStartingPistol();
			return;
		}

		if (BIO_CVar.InvClear_Never(Player))
			return;

		super.GiveDefaultInventory();
		GiveInventory('BIO_Unarmed', 1);
		GiveRandomStartingPistol();
	}

	override int TakeSpecialDamage(
		Actor inflictor, Actor source, int damage, name dmgType
	)
	{
		let ret = super.TakeSpecialDamage(inflictor, source, damage, dmgType);

		for (uint i = 0; i < Perks.Size(); i++)
			if (Perks[i] != null)
				Perks[i].OnDamageTaken(self, inflictor, source, ret, dmgType);

		return ret;
	}

	override void PreTravelled()
	{
		super.PreTravelled();

		// This block courtesy of Marisa the Magician
		// See SWWMGZ's counterpart: `Demolitionist::PreTravelled`
		// Provided under the MIT License
		// https://github.com/OrdinaryMagician/swwmgz_m/blob/master/LICENSE.code
		if ((Player != null) &&
			(Player.PlayerState == PST_DEAD) &&
			!BIO_CVar.InvClear_Always(Player))
		{
			Player.Resurrect();

			Player.DamageCount = 0;
			Player.BonusCount = 0;
			Player.PoisonCount = 0;
			Roll = 0;

			if (Special1 > 2)
				Special1 = 0;
		}

		if (!BIO_CVar.InvClear_IfScheduled(Player))
			return;

		let globals = BIO_Global.Get();

		let
			resetAmmo = globals.ResetPlayerAmmo(Player),
			resetArmor = globals.ResetPlayerArmor(Player),
			resetHealth = globals.ResetPlayerHealth(Player),
			resetWeaps = globals.ResetPlayerWeapons(Player);

		Array<Inventory> toDestroy;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			if (resetAmmo)
			{
				if (i is 'Ammo' || i is 'BackpackItem')
					toDestroy.Push(i);
			}

			if (resetWeaps && i is 'Weapon')
				toDestroy.Push(i);
		}

		for (uint i = 0; i < toDestroy.Size(); i++)
		{
			let item = toDestroy[i];

			if (item is 'Ammo')
			{
				item.MaxAmount = item.Default.MaxAmount;

				if (item is 'BIO_Magazine')
					item.Destroy();
				else
					item.Amount = 0;
			}
			else if (item is 'Weapon' || item is 'BackpackItem')
			{
				item.Destroy();
			}
		}

		if (resetHealth)
			Player.Health = Health = SpawnHealth();

		if (resetArmor)
		{
			let arm = BasicArmor(FindInventory('BasicArmor'));
			arm.Amount = 0;
			arm.SavePercent = 0;
			arm.ArmorType = 'None';
			arm.BonusCount = 0;
			arm.ActualSaveAmount = 0;
		}

		if (resetWeaps)
		{
			GiveInventory('BIO_Unarmed', 1);
			GiveRandomStartingPistol();
		}

		// Re-setup ammo and magazine pointers
		if (resetAmmo)
		{
			for (Inventory i = Inv; i != null; i = i.Inv)
			{
				let weap = BIO_Weapon(i);

				if (weap == null)
					continue;

				if (weap.ModGraph == null)
				{
					weap.SetupAmmo();
					weap.SetupMagazines();
				}
				else
				{
					BIO_WeaponModSimulator.Create(weap).CommitAndClose();
				}
			}
		}
	}
}

// Magazine management.
extend class BIO_Player
{
	BIO_Magazine GetMagazine(
		class<BIO_Weapon> weap_t,
		class<BIO_Magazine> mag_t,
		bool secondary
	) const
	{
		for (uint i = 0; i < Magazines.Size(); i++)
		{
			if (Magazines[i].GetClass() == mag_t &&
				Magazines[i].GetWeaponType() == weap_t &&
				Magazines[i].IsSecondary() == secondary)
			{
				return Magazines[i];
			}
		}

		return null;
	}

	private void GenerateMagazines()
	{
		for (uint i = 0; i < AllActorClasses.Size(); i++)
		{
			let weap_t = (class<BIO_Weapon>)(AllActorClasses[i]);

			if (weap_t == null || weap_t.IsAbstract())
				continue;

			let defs = GetDefaultByType(weap_t);

			if (defs.MagazineFlags & BIO_MAGF_NORMAL_1)
				Magazines.Push(BIO_NormalMagazine.Create(weap_t, false));
			if (defs.MagazineFlags & BIO_MAGF_NORMAL_2)
				Magazines.Push(BIO_NormalMagazine.Create(weap_t, true));

			if (defs.MagazineFlags & BIO_MAGF_RECHARGING_1)
				Magazines.Push(BIO_RechargingMagazine.Create(weap_t, false));
			if (defs.MagazineFlags & BIO_MAGF_RECHARGING_2)
				Magazines.Push(BIO_RechargingMagazine.Create(weap_t, true));

			if (defs.MagazineFlags & BIO_MAGF_ETMF_1)
				Magazines.Push(BIO_ETMFMagazine.Create(weap_t, false));
			if (defs.MagazineFlags & BIO_MAGF_ETMF_2)
				Magazines.Push(BIO_ETMFMagazine.Create(weap_t, true));
		}
	}
}

// Callbacks.
extend class BIO_Player
{
	void PrePowerupHandlePickup(Powerup handler, Powerup other)
	{
		for (uint i = 0; i < Perks.Size(); i++)
			if (Perks[i] != null)
				Perks[i].PrePowerupHandlePickup(self, handler, other);
	}

	void PrePowerupAttach(Powerup power)
	{
		for (uint i = 0; i < Perks.Size(); i++)
			if (Perks[i] != null)
				Perks[i].PrePowerupAttach(self, power);
	}

	void PrePowerupDetach(Powerup power)
	{
		for (uint i = 0; i < Perks.Size(); i++)
			if (Perks[i] != null)
				Perks[i].PrePowerupDetach(self, power);
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		let weap = BIO_Weapon(Player.ReadyWeapon);

		if (weap != null)
			weap.OnKill(killed, inflictor);
	}
}

// Helper functions.
extend class BIO_Player
{
	protected void GiveRandomStartingPistol()
	{
		let pistol_t = BIO_Global.Get().LootWeaponType(BIO_WSCAT_PISTOL);
		GiveInventory(pistol_t, 1);
		let pistol = FindInventory(pistol_t);
		Player.ReadyWeapon = Player.PendingWeapon = Weapon(pistol);
	}
}
