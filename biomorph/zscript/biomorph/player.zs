class biom_Player : DoomPlayer
{
	protected readonly<biom_PlayerData> data;

	uint8 weaponCapacity;
	property WeaponCapacity: weaponCapacity;

	private biom_WeaponFamily weaponsFound;

	Default
	{
		Tag "$BIOM_PAWN_DISPLAYNAME";
		Species 'Player';
		BloodColor 'Cyan';

		Player.DisplayName "$BIOM_PAWN_DISPLAYNAME";
		Player.SoundClass 'biomorph';
		Player.ViewHeight 48.0;

		Player.StartItem 'biom_Slot3Ammo', 0;
		Player.StartItem 'biom_Slot4Ammo', 0;
		Player.StartItem 'biom_Slot5Ammo', 0;
		Player.StartItem 'biom_Slot67Ammo', 0;

		Player.StartItem 'biom_ServicePistol';
		Player.StartItem 'biom_Unarmed';

		biom_Player.WeaponCapacity 8;
	}

	/// Inversely proportional to added movement inertia;
	/// lower number means less slippery.
	const DECEL_MULT = 0.85;

	override void PostBeginPlay()
	{
		super.PostBeginPlay();

		self.data = biom_Global.Get().FindPlayerData(self.player);
		self.weaponsFound = BIOM_WEAPFAM_SIDEARM;

		Biomorph.Assert(
			self.data != null,
			"Failed to get pawn data in `biom_Player::PostBeginPlay`."
		);
	}

	override void Tick()
	{
		super.Tick();

		// Code below courtesy of Nash Muhandes
		// https://forum.zdoom.org/viewtopic.php?f=105&t=35761

		if (self.pos.Z ~== self.floorZ || self.bOnMObj)
		{
			// Bump up the player's speed to compensate for the deceleration
			// TODO (NASH): math here is shit and wrong, please fix
			double s = 1.0 + (1.0 - DECEL_MULT);
			self.speed = s * 2.2;

			// Decelerate the player, if not in pain
			self.vel.X *= DECEL_MULT;
			self.vel.Y *= DECEL_MULT;

			// Make the view bobbing match the player's movement
			self.viewBob = DECEL_MULT;
		}

		if (!self.player.onGround || self.vel.Length() < 0.1)
			return;

		// Periodic footstep sounds. Math below courtesy of Marrub
		// See DoomRL_Arsenal.pk3/scripts/DRLALIB_Misc.acs, "RLGetStepSpeed"

		float v = (Abs(self.vel.X), Abs(self.vel.Y)).Length();
		float mul = Clamp(1.0 - (v / 24.0), 0.35, 1.0);
		let interval = int(10.0 * (mul + 0.6));

		if ((Level.MapTime % interval) != 0)
			return;

		self.A_StartSound("biom/pawn/footstep/normal", CHAN_AUTO);
	}

	override void PreTravelled()
	{
		super.PreTravelled();

		// Suppress death exists if the user prefers to do so.
		// This block below is courtesy of Marisa the Magician.
		// See SWWMGZ's counterpart: `Demolitionist::PreTravelled`.
		// Used under the MIT License.
		// https://github.com/OrdinaryMagician/swwmgz_m/blob/master/LICENSE.code
		if ((self.player != null) &&
			(self.player.PlayerState == PST_DEAD))
		{
			self.player.Resurrect();

			self.player.DamageCount = 0;
			self.player.BonusCount = 0;
			self.player.PoisonCount = 0;
			self.roll = 0;

			if (self.special1 > 2)
				self.special1 = 0;
		}
	}

	override void ClearInventory()
	{
		super.ClearInventory();

		for (int i = 0; i < self.data.weapons.Size(); ++i)
			self.TakeInventory(self.data.weapons[i], 1);

		self.weaponsFound = BIOM_WEAPFAM_SIDEARM;

		let bArmor = BasicArmor(self.FindInventory('BasicArmor'));
		bArmor.savePercent = 0;
		bArmor.armorType = 'None';
		textureID nullTexID;
		nullTexID.SetNull();
		bArmor.icon = nullTexID;
	}

	void OnWeaponFound(biom_WeaponFamily wf)
	{
		self.weaponsFound |= wf;
	}

	readonly<biom_PlayerData> GetData() const
	{
		return self.data;
	}

	biom_WeaponFamily GetWeaponsFound() const
	{
		return self.weaponsFound;
	}

	/// The status bar needs `GetData` to be `const` but weapon attach-to-owner
	/// code runs before `EventHandler::NewGame` and `PlayerPawn::PostBeginPlay`,
	/// so it needs special handling.
	readonly<biom_PlayerData> GetOrInitData()
	{
		if (self.data == null)
			self.data = biom_Global.Get().FindPlayerData(self.player);

		return self.data;
	}

	readonly<biom_Player> AsConst() const
	{
		return self;
	}
}

class biom_PlayerPistolStart : biom_Player
{
	Default
	{
		Player.DisplayName "$BIOM_PAWN_DISPLAYNAME_LAPSING";
	}

	override void PreTravelled()
	{
		super.PreTravelled();
		self.ClearInventory();
		self.GiveDefaultInventory();
		self.A_SetHealth(self.GetMaxHealth());
	}
}
