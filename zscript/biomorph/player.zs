class BIO_Player : DoomPlayer
{
	uint MaxWeaponsHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;

	Default
	{
		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem "BIO_Pistol";
		Player.StartItem "BIO_Fist";
		Player.StartItem "BIO_WeaponDrop";
		Player.StartItem "Clip", 50;
		Player.StartItem "Shell", 0;
		Player.StartItem "RocketAmmo", 0;
		Player.StartItem "Cell", 0;

		BIO_Player.MaxWeaponsHeld 6;
	}

	uint HeldWeaponCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is "BIO_Weapon" && !(i is "BIO_Fist")) ret++; 

		return ret;
	}

	bool IsFullOnWeapons() const { return HeldWeaponCount() >= MaxWeaponsHeld; }
}

}
