class BIO_Player : DoomPlayer
{
	uint MaxWeaponsHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;

	Default
	{
		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem "BIO_Pistol";
		Player.StartItem "BIO_Fist";
		Player.StartItem "Clip", 50;
		Player.StartItem "Shell", 0;
		Player.StartItem "RocketAmmo", 0;
		Player.StartItem "Cell", 0;

		BIO_Player.MaxWeaponsHeld 6;
	}
}
