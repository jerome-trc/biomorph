class BIO_Player : DoomPlayer
{
	Default
	{
		Species 'Player';
		Player.DisplayName "$BIO_MODTITLE";

		Player.StartItem 'Clip', 0;
		Player.StartItem 'Shell', 0;
		Player.StartItem 'RocketAmmo', 0;
		Player.StartItem 'Cell', 0;
	}

	// How much to reduce the slippery movement.
	// Lower number = less slippery.
	const DECEL_MULT = 0.85;

	override void Tick()
	{
		super.Tick();

		// Code below courtesy of Nash Muhandes
		// https://forum.zdoom.org/viewtopic.php?f=105&t=35761

		if (Pos.Z ~== FloorZ || bOnMObj)
		{
			// Bump up the player's speed to compensate for the deceleration
			// TODO (NASH): math here is shit and wrong, please fix
			double s = 1.0 + (1.0 - DECEL_MULT);
			A_SetSpeed(s * 2);

			// Decelerate the player, if not in pain
			Vel.X *= DECEL_MULT;
			Vel.Y *= DECEL_MULT;

			// Make the view bobbing match the player's movement
			ViewBob = DECEL_MULT;
		}
	}
}
