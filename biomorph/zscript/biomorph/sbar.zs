class biom_StatusBar : BaseStatusBar
{
	private CVar invBarSlots, notifyLineCount;
	private biom_Player pawn;
	private InventoryBarState invBarState;

	private HUDFont fontBig, fontIndex, fontSmall;
	private HUDFont fontDoomBig, fontDoomIndex, fontDoomAmount;

	/// Resource acquisition.
	final override void Init()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Initialising status bar...");

		super.Init();
		self.SetSize(32, 320, 200);

		Font fnt = 'JENOBIG';
		self.fontBig = HUDFont.Create(fnt, fnt.GetCharWidth("0"), MONO_CELLLEFT, 1, 1);
		self.fontIndex = HUDFont.Create('INDEXFONT');
		self.fontSmall = HUDFont.Create('JenocideFontRed');

		Font fntd = 'HUDFONT_DOOM';
		self.fontDoomBig = HUDFont.Create(fntd, fntd.GetCharWidth("0"), MONO_CELLLEFT, 1, 1);
		fntd = 'INDEXFONT_DOOM';
		self.fontDoomIndex = HUDFont.Create(fntd, fntd.GetCharWidth("0"), MONO_CELLLEFT);
		self.fontDoomAmount = HUDFont.Create('INDEXFONT');

		self.invBarState = InventoryBarState.Create();
	}

	/// Acquire a pre-downcast player pawn pointer and CVar handles.
	final override void AttachToPlayer(PlayerInfo player)
	{
		super.AttachToPlayer(player);

		self.pawn = biom_Player(self.cPlayer.mo);

		if (self.cPlayer.mo != null && self.pawn == null)
		{
			ThrowAbortException(
				Biomorph.LOGPFX_ERR ..
				"\nFailed to attach HUD to a Biomorph-class player."
				"\nTry the PawnPatch."
				"\nIf errors continue after that, report a bug to RatCircus."
			);
		}

		self.notifyLineCount = CVar.GetCVar("con_notifylines", self.cPlayer);
		self.invBarSlots = CVar.GetCVar("BIOM_invbarslots", self.cPlayer);
	}

	final override void Draw(int state, double ticFrac)
	{
		super.Draw(state, ticFrac);

		if (state == HUD_STATUSBAR)
		{
			self.BeginStatusBar();
			self.DrawMainBar(ticFrac);
			return;
		}

		self.BeginHUD();

		let berserk = self.pawn.FindInventory('PowerStrength', true) != null;

		self.DrawImage('graphics/pulse_small.png', (20, -2));

		self.DrawString(
			self.fontBig,
			String.Format(
				"\c[LightBlue]%s \c[White]/ \c[LightBlue]%s",
				FormatNumber(self.cPlayer.Health, 3, 5),
				FormatNumber(self.pawn.GetMaxHealth(true), 3, 5)
			),
			(44, -18),
			DI_NONE,
			Font.CR_UNTRANSLATED
		);

		if (berserk)
			self.DrawString(self.fontBig, "!", (34, -18), DI_NONE, Font.CR_DARKRED);

		let armor = self.cPlayer.mo.FindInventory('BasicArmor');

		if (armor != null && armor.Amount > 0)
		{
			self.DrawInventoryIcon(armor, (20, -22));

			self.DrawString(
				self.fontBig,
				String.Format(
					"\c[DarkGreen]%s \c[White]/ \c[DarkGreen]%s",
					FormatNumber(armor.amount, 3),
					FormatNumber(armor.maxAmount, 3)
				),
				(44, -36),
				DI_NONE,
				Font.CR_UNTRANSLATED
			);
			self.DrawString(
				self.fontSmall,
				FormatNumber(self.GetArmorSavePercent(), 3) .. "%",
				(14, -30),
				DI_NONE,
				Font.CR_WHITE
			);
		}

		self.DrawFullscreenKeys();

		int invY = -20;

		let weap = biom_Weapon(self.cPlayer.readyWeapon);

		if (weap != null)
		{
			self.DrawAmmoDetails(weap, invY);
			weap.DrawToHUD(self);
		}

		if (self.IsInventoryBarVisible())
		{
			self.DrawInventoryBar(
				self.invBarState, (0, -32), self.invBarSlots.GetInt(),
				DI_SCREEN_CENTER_BOTTOM, HX_SHADOW
			);
		}
		else if (!Level.noInventoryBar && self.pawn.invSel != null)
		{
			self.DrawInventoryIcon(self.pawn.invSel, (-22, invY + 12));
			self.DrawString(
				self.fontBig,
				FormatNumber(self.pawn.invSel.amount, 3),
				(-40, invY - 10),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_WHITE
			);

			invY -= 40;
		}

		self.DrawString(
			self.fontSmall,
			String.Format(
				"\c[White]%s: \c-%s\c[White] / \c-%s",
				StringTable.Localize("$BIOM_SBAR_MONSTERCOUNTERPFX"),
				FormatNumber(Level.killed_Monsters, 1, 5),
				FormatNumber(Level.total_Monsters, 1, 5)
			),
			(200, -26),
			DI_NONE,
			Level.killed_Monsters >= Level.total_Monsters ?
				Font.CR_GREEN :
				Font.CR_WHITE
		);
		self.DrawString(
			self.fontSmall,
			String.Format(
				"\c[White]%s: \c-%s\c[White] / \c-%s",
				StringTable.Localize("$BIOM_SBAR_ITEMCOUNTERPFX"),
				FormatNumber(Level.found_Items, 1, 5),
				FormatNumber(Level.total_Items, 1, 5)
			),
			(200, -18),
			DI_NONE,
			Level.found_Items >= Level.total_Items ?
				Font.CR_GREEN :
				Font.CR_WHITE
		);
		self.DrawString(
			self.fontSmall,
			String.Format(
				"\c[White]%s: \c-%s\c[White] / \c-%s",
				StringTable.Localize("$BIOM_SBAR_SECRETCOUNTERPFX"),
				FormatNumber(Level.found_Secrets, 1, 2),
				FormatNumber(Level.total_Secrets, 1, 2)
			),
			(200, -10),
			DI_NONE,
			Level.found_Secrets >= Level.total_Secrets ?
				Font.CR_GREEN :
				Font.CR_WHITE
		);

		self.DrawString(
			self.fontSmall,
			"ARMS:",
			(270, -10),
			DI_NONE,
			Font.CR_WHITE
		);

		let weapsFound = self.pawn.GetWeaponsFound();

		static const string STRINGS[] = {
			"\c[Red]1",
			"\c[Orange]2",
			"\c[Yellow]3",
			"\c[Green]3S",
			"\c[Cyan]4",
			"\c[LightBlue]5",
			"\c[Purple]6",
			"\c[Pink]7"
		};

		for (int i = 0; i <= 7; ++i)
		{
			let carried = (weapsFound & (1 << i)) != 0;

			self.DrawString(
				self.fontSmall,
				STRINGS[i],
				(300 + ((1 + i) * 16), -10),
				DI_TEXT_ALIGN_CENTER,
				Font.CR_UNTRANSLATED,
				alpha: carried ? 1.0 : 0.33
			);
		}
	}

	/// Draw powerup icons at top left, along with the
	/// durations remaining on their effects in seconds.
	final override void DrawPowerups()
	{
		int yPos = 0;

		for (Inventory i = self.cPlayer.mo.Inv; i != null; i = i.Inv)
		{
			int yOffs = self.notifyLineCount.GetInt() * 16;
			let powup = Powerup(i);

			if (powup == null ||
				powup.icon.IsNull() ||
				!powup.icon.Exists() ||
				!powup.icon.IsValid())
				continue;

			self.DrawInventoryIcon(powup, (20, yOffs + yPos));
			yPos += 8;
			int secs = powup.EffectTics / GameTicRate;

			self.DrawString(
				self.fontSmall,
				FormatNumber(secs, 1, 3),
				(19, yOffs + yPos),
				DI_TEXT_ALIGN_CENTER,
				Font.CR_WHITE
			);

			yPos += 32;
		}
	}

	/// From gzdoom.pk3.
	private void DrawFullscreenKeys()
	{
		// (GZ) Draw the keys. This does not use a special draw function like SBARINFO
		// because the specifics will be different for each mod so it's easier to
		// copy or reimplement the following piece of code instead of trying to
		// write a complicated all-encompassing solution.

		vector2 keypos = (-10, 2);
		int rowc = 0;
		double roww = 0;

		for (let i = self.cPlayer.mo.inv; i != null; i = i.inv)
		{
			if (i is 'Key' && i.icon.IsValid())
			{
				self.DrawTexture(i.icon, keypos, DI_SCREEN_RIGHT_TOP | DI_ITEM_LEFT_TOP);
				Vector2 size = TexMan.GetScaledSize(i.icon);
				keypos.Y += size.Y + 2;
				roww = max(roww, size.X);

				if (++rowc == 3)
				{
					keypos.Y = 2;
					keypos.X -= roww + 2;
					roww = 0;
					rowc = 0;
				}
			}
		}
	}

	void DrawAmmoDetails(biom_Weapon weap, in out int invY)
	{
		biom_Magazine mag;

		if (weap.GetMagazine(mag))
		{
			self.DrawString(
				self.fontBig,
				String.Format(
					"%s / %s",
					FormatNumber(mag.current, 3, 6),
					FormatNumber(mag.max, 3, 6)
				),
				(-36, invY + 4),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);

			invY -= 20;
		}

		if (weap.ammo1 != null)
		{
			self.DrawInventoryIcon(weap.ammo1, (-16, invY + 16));

			self.DrawString(
				self.fontBig,
				String.Format(
					"%s / %s",
					FormatNumber(weap.ammo1.amount, 3, 6),
					FormatNumber(weap.ammo1.maxAmount, 3, 6)
				),
				(-36, invY + 4),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);

			invY -= 20;
		}

		if (weap.ammo2 != null && weap.ammo2 != weap.ammo1)
		{
			self.DrawInventoryIcon(weap.ammo2, (-16, invY + 16));

			self.DrawString(
				self.fontBig,
				String.Format(
					"%s / %s",
					FormatNumber(weap.ammo2.amount, 3, 6),
					FormatNumber(weap.ammo2.maxAmount, 3, 6)
				),
				(-36, invY + 4),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);
		}

		{
			invY -= 12;

			let s3 = self.pawn.FindInventory('biom_Slot4Ammo');

			self.DrawString(
				self.fontSmall,
				"BULLETS",
				(-56, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);
			self.DrawString(
				self.fontSmall,
				String.Format(
					"%s\c[MidGrey]/\c[White]%s",
					FormatNumber(s3.amount, 3, 6),
					FormatNumber(s3.maxAmount, 3, 6)
				),
				(-8, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_WHITE
			);
		}

		{
			invY -= 12;

			let s3 = self.pawn.FindInventory('biom_Slot3Ammo');

			self.DrawString(
				self.fontSmall,
				"SHELLS",
				(-56, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);
			self.DrawString(
				self.fontSmall,
				String.Format(
					"%s\c[MidGrey]/\c[White]%s",
					FormatNumber(s3.amount, 3, 6),
					FormatNumber(s3.maxAmount, 3, 6)
				),
				(-8, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_WHITE
			);
		}

		{
			invY -= 12;

			let s3 = self.pawn.FindInventory('biom_Slot5Ammo');

			self.DrawString(
				self.fontSmall,
				"GRENADES",
				(-56, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);
			self.DrawString(
				self.fontSmall,
				String.Format(
					"%s\c[MidGrey]/\c[White]%s",
					FormatNumber(s3.amount, 3, 6),
					FormatNumber(s3.maxAmount, 3, 6)
				),
				(-8, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_WHITE
			);
		}

		{
			invY -= 12;

			let s3 = self.pawn.FindInventory('biom_Slot67Ammo');

			self.DrawString(
				self.fontSmall,
				"NANO",
				(-56, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_GOLD
			);
			self.DrawString(
				self.fontSmall,
				String.Format(
					"%s\c[MidGrey]/\c[White]%s",
					FormatNumber(s3.amount, 3, 6),
					FormatNumber(s3.maxAmount, 3, 6)
				),
				(-8, invY),
				DI_TEXT_ALIGN_RIGHT,
				Font.CR_WHITE
			);
		}

		invY -= 20;
	}
}

// The Doom status bar is left as-is; this code is a nearly-verbatim copy-paste
// from gzdoom.pk3/zscript/ui/statusbar/doom_sbar.zs.
extend class biom_StatusBar
{
	private void DrawMainBar(double ticFrac)
	{
		self.DrawImage('STBAR', (0, 168), DI_ITEM_OFFSETS);
		self.DrawImage('STTPRCNT', (90, 171), DI_ITEM_OFFSETS);
		self.DrawImage('STTPRCNT', (221, 171), DI_ITEM_OFFSETS);

		Inventory a1 = self.GetCurrentAmmo();

		if (a1 != null)
		{
			self.DrawString(
				self.fontDoomBig,
				FormatNumber(a1.amount, 3),
				(44, 171),
				DI_TEXT_ALIGN_RIGHT | DI_NOSHADOW
			);
		}

		self.DrawString(
			self.fontDoomBig,
			FormatNumber(self.cPlayer.health, 3),
			(90, 171),
			DI_TEXT_ALIGN_RIGHT | DI_NOSHADOW
		);

		self.DrawString(
			self.fontDoomBig,
			FormatNumber(self.GetArmorAmount(), 3),
			(221, 171),
			DI_TEXT_ALIGN_RIGHT | DI_NOSHADOW
		);

		self.DrawBarKeys();
		self.DrawBarAmmo();

		if (deathmatch || teamplay)
		{
			DrawString(
				self.fontDoomBig,
				FormatNumber(self.cPlayer.fragCount, 3),
				(138, 171),
				DI_TEXT_ALIGN_RIGHT
			);
		}
		else
		{
			DrawBarWeapons();
		}

		if (multiplayer)
		{
			DrawImage(
				'STFBANY',
				(143, 168),
				DI_ITEM_OFFSETS | DI_TRANSLATABLE
			);
		}

		if (self.cPlayer.mo.invSel != null && !Level.noInventoryBar)
		{
			self.DrawInventoryIcon(self.cPlayer.mo.invSel, (160, 198), DI_DIMDEPLETED);

			if (self.cPlayer.mo.invSel.amount > 1)
			{
				self.DrawString(
					self.fontDoomAmount,
					FormatNumber(self.cPlayer.mo.invSel.amount),
					(175, 198 - self.fontDoomIndex.mFont.GetHeight()),
					DI_TEXT_ALIGN_RIGHT,
					Font.CR_GOLD
				);
			}
		}
		else
		{
			self.DrawTexture(GetMugShot(5), (143, 168), DI_ITEM_OFFSETS);
		}
		if (self.IsInventoryBarVisible())
		{
			self.DrawInventoryBar(self.invBarState, (48, 169), 7, DI_ITEM_LEFT_TOP);
		}
	}

	private void DrawBarKeys() const
	{
		bool locks[6];
		string image;

		for(int i = 0; i < 6; i++)
			locks[i] = self.cPlayer.mo.CheckKeys(i + 1, false, true);

		if (locks[1] && locks[4])
			image = 'STKEYS6';
		else if (locks[1])
			image = 'STKEYS0';
		else if (locks[4])
			image = 'STKEYS3';

		self.DrawImage(image, (239, 171), DI_ITEM_OFFSETS);

		if (locks[2] && locks[5])
			image = 'STKEYS7';
		else if (locks[2])
			image = 'STKEYS1';
		else if (locks[5])
			image = 'STKEYS4';
		else
			image = "";

		self.DrawImage(image, (239, 181), DI_ITEM_OFFSETS);

		if (locks[0] && locks[3])
			image = 'STKEYS8';
		else if (locks[0])
			image = 'STKEYS2';
		else if (locks[3])
			image = 'STKEYS5';
		else
			image = "";

		self.DrawImage(image, (239, 191), DI_ITEM_OFFSETS);
	}

	private void DrawBarAmmo() const
	{
		int amt1 = 0, maxamt = 0;

		[amt1, maxamt] = self.GetAmount('biom_Slot4Ammo');
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(amt1, 3),
			(288, 173),
			DI_TEXT_ALIGN_RIGHT
		);
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(maxamt, 3),
			(314, 173),
			DI_TEXT_ALIGN_RIGHT
		);

		[amt1, maxamt] = self.GetAmount('biom_Slot3Ammo');
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(amt1, 3),
			(288, 179),
			DI_TEXT_ALIGN_RIGHT
		);
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(maxamt, 3),
			(314, 179),
			DI_TEXT_ALIGN_RIGHT
		);

		[amt1, maxamt] = self.GetAmount('biom_Slot5Ammo');
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(amt1, 3),
			(288, 185),
			DI_TEXT_ALIGN_RIGHT
		);
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(maxamt, 3),
			(314, 185),
			DI_TEXT_ALIGN_RIGHT
		);

		[amt1, maxamt] = self.GetAmount('biom_Slot67Ammo');
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(amt1, 3),
			(288, 191),
			DI_TEXT_ALIGN_RIGHT
		);
		self.DrawString(
			self.fontDoomIndex,
			FormatNumber(maxamt, 3),
			(314, 191),
			DI_TEXT_ALIGN_RIGHT
		);
	}

	protected virtual void DrawBarWeapons()
	{
		self.DrawImage('STARMS', (104, 168), DI_ITEM_OFFSETS);

		self.DrawImage(
			self.cPlayer.HasWeaponsInSlot(2) ? 'STYSNUM2' : 'STGNUM2',
			(111, 172),
			DI_ITEM_OFFSETS
		);
		self.DrawImage(
			self.cPlayer.HasWeaponsInSlot(3) ? 'STYSNUM3' : 'STGNUM3',
			(123, 172),
			DI_ITEM_OFFSETS
		);
		self.DrawImage(
			self.cPlayer.HasWeaponsInSlot(4) ? 'STYSNUM4' : 'STGNUM4',
			(135, 172),
			DI_ITEM_OFFSETS
		);
		self.DrawImage(
			self.cPlayer.HasWeaponsInSlot(5) ? 'STYSNUM5' : 'STGNUM5',
			(111, 182),
			DI_ITEM_OFFSETS
		);
		self.DrawImage(
			self.cPlayer.HasWeaponsInSlot(6) ? 'STYSNUM6' : 'STGNUM6',
			(123, 182),
			DI_ITEM_OFFSETS
		);
		self.DrawImage(
			self.cPlayer.HasWeaponsInSlot(7) ? 'STYSNUM7' : 'STGNUM7',
			(135, 182),
			DI_ITEM_OFFSETS
		);
	}
}
