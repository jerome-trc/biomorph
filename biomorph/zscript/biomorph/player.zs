class BIO_Player : DoomPlayer
{
	uint8 MaxWeaponsHeld; property MaxWeaponsHeld: MaxWeaponsHeld;
	uint8 MaxGenesHeld; property MaxGenesHeld: MaxGenesHeld;

	BIO_Weapon ExaminedWeapon;
	private uint16 ExamineTimer;

	Default
	{
		Tag "$BIO_MODTITLE";
		Species 'Player';
		BloodColor 'Cyan';

		Player.DisplayName "$BIO_MODTITLE";
		Player.SoundClass 'Biomorph';

		Player.StartItem 'Clip', 0;
		Player.StartItem 'Shell', 0;
		Player.StartItem 'RocketAmmo', 0;
		Player.StartItem 'Cell', 0;

		Player.StartItem 'BIO_WeaponDrop';

		Player.StartItem 'BIO_Fists';

		BIO_Player.MaxWeaponsHeld 8;
		BIO_Player.MaxGenesHeld 10;
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
	}

	override void GiveDefaultInventory()
	{
		super.GiveDefaultInventory();

		let globals = BIO_Global.Get();

		if (globals == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Global data has been illegally destroyed.");
			return;
		}

		let pistol_t = globals.LootWeaponType(BIO_WSCAT_PISTOL);
		GiveInventory(pistol_t, 1);
		A_SelectWeapon(pistol_t);
	}

	bool CanCarryWeapon(BIO_Weapon weap) const
	{
		return HeldWeaponCount() < MaxWeaponsHeld;
	}

	uint HeldWeaponCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
		{
			let weap = BIO_Weapon(i);

			if (weap == null || weap.Family == BIO_WEAPFAM_FIST)
				continue;

			ret++;
		}

		return ret;
	}

	bool CanCarryGene(BIO_Gene gene)
	{
		return HeldGeneCount() < MaxGenesHeld;
	}

	uint HeldGeneCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Gene')
				ret++;

		return ret;
	}

	void ExamineWeapon(BIO_Weapon weap, uint upTime)
	{
		ExaminedWeapon = weap;
		ExamineTimer = upTime;
		A_StartSound("bio/ui/beep", attenuation: 1.2);
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		let weap = BIO_Weapon(Player.ReadyWeapon);

		if (weap != null)
			weap.OnKill(killed, inflictor);
	}
}
