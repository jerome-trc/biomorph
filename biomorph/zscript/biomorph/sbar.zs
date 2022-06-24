class BIO_StatusBar : BaseStatusBar
{
	private CVar InvBarSlots, NotifyLineCount;
	private CVar HUDWeapOffsX, HUDWeapOffsY, HUDExamOffsX, HUDExamOffsY;

	private BIO_Player BIOPlayer;

	private HUDFont Font_HUD, Font_Index, Font_Amount, Font_Small;
	private InventoryBarState InvBarState;

	final override void Init()
	{
		if (BIO_debug)
			Console.Printf(Biomorph.LOGPFX_DEBUG .. "Initialising status bar...");

		super.Init();
		SetSize(32, 320, 200);

		Font fnt = 'BIGFONT';
		Font_HUD = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 1, 1);
		fnt = 'INDEXFONT_DOOM';
		Font_Index = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		Font_Amount = HUDFont.Create('INDEXFONT');
		Font_Small = HUDFont.Create('SMALLFONT');
		InvBarState = InventoryBarState.Create();
	}

	final override void AttachToPlayer(PlayerInfo player)
	{
		super.AttachToPlayer(player);

		NotifyLineCount = CVar.GetCVar("con_notifylines", CPlayer);
		InvBarSlots = CVar.GetCVar("BIO_invbarslots", CPlayer);
		HUDWeapOffsX = CVar.GetCVar("BIO_hudweap_offsx", CPlayer);
		HUDWeapOffsY = CVar.GetCVar("BIO_hudweap_offsy", CPlayer);
		HUDExamOffsX = CVar.GetCVar("BIO_hudexam_offsx", CPlayer);
		HUDExamOffsY = CVar.GetCVar("BIO_hudexam_offsy", CPlayer);
		BIOPlayer = BIO_Player(CPlayer.MO);
	}

	final override void Draw(int state, double ticFrac)
	{
		super.Draw(state, ticFrac);
		BeginHUD();

		Vector2 iconbox = (40, 20);

		let berserk = CPlayer.MO.FindInventory('PowerStrength', true);
		DrawImage(berserk ? 'PSTRA0' : 'MEDIA0', (20, -2));
		DrawString(Font_HUD,
			String.Format("%s / %s",
				FormatNumber(CPlayer.Health, 3, 5),
				FormatNumber(CPlayer.MO.GetMaxHealth(true), 3, 5)), 
			(44, -16), 0, Font.CR_DARKRED);

		let armor = CPlayer.MO.FindInventory('BasicArmor');

		if (armor != null && armor.Amount > 0)
		{
			DrawInventoryIcon(armor, (20, -22));

			DrawString(Font_HUD, FormatNumber(armor.Amount, 3),
				(44, -36), 0, Font.CR_DARKGREEN);
			DrawString(Font_Small, FormatNumber(GetArmorSavePercent(), 3) .. "%",
				(14, -30), 0, Font.CR_WHITE);

		}

		if (deathmatch)
		{
			DrawString(Font_HUD, FormatNumber(CPlayer.FragCount, 3),
				(-3, 1), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
		}
		else
		{
			// Draw the keys. This does not use a special draw function like 
			// SBARINFO because the specifics will be different for each mod 
			// so it's easier to copy or reimplement the following piece of code
			// instead of trying to write a complicated all-encompassing solution.
			Vector2 keypos = (-10, 2);
			int rowc = 0;
			double roww = 0;
			for (let i = CPlayer.MO.Inv; i != null; i = i.Inv)
			{
				if (!(i is 'Key') || !i.Icon.IsValid()) continue;

				DrawTexture(i.Icon, keypos, DI_SCREEN_RIGHT_TOP | DI_ITEM_LEFT_TOP);
				Vector2 size = TexMan.GetScaledSize(i.Icon);
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

		if (isInventoryBarVisible())
		{
			DrawInventoryBar(InvBarState, (0, 0), InvBarSlots.GetInt(),
				DI_SCREEN_CENTER_BOTTOM, HX_SHADOW);
		}

		DrawWeaponDetails(BIO_Weapon(CPlayer.ReadyWeapon), false);

		if (BIOPlayer.ExaminedWeapon != null)
			DrawWeaponDetails(BIOPlayer.ExaminedWeapon, true);

		int invY = -20;
		DrawAmmoDetails(invY);

		if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.MO.InvSel != null)
		{
			DrawInventoryIcon(CPlayer.MO.InvSel, (-22, invY + 12));
			DrawString(Font_HUD, FormatNumber(CPlayer.MO.InvSel.Amount, 3),
				(-40, invY - 10), DI_TEXT_ALIGN_RIGHT);

			invY -= 40;
		}

		let hwc = BIOPlayer.HeldWeaponCount();

		DrawImage('PISTA0', (-24, invY + 12));
		DrawString(Font_Small,
			String.Format("%d / %d", hwc, BIOPlayer.MaxWeaponsHeld),
			(-44, invY), DI_TEXT_ALIGN_RIGHT,
			hwc < BIOPlayer.MaxWeaponsHeld ? Font.CR_WHITE : Font.CR_YELLOW);
	
		let hgc = BIOPlayer.HeldGeneCount();

		DrawImage("graphics/gene.png", (-24, invY -12));
		DrawString(Font_Small,
			String.Format("%d / %d", hgc, BIOPlayer.MaxGenesHeld),
			(-44, invY - 24), DI_TEXT_ALIGN_RIGHT,
			hgc < BIOPlayer.MaxGenesHeld ? Font.CR_WHITE : Font.CR_YELLOW);
	}

	private void DrawAmmoDetails(in out int invY) const
	{
		BIO_Weapon weap = BIO_Weapon(CPlayer.ReadyWeapon);
		if (weap == null) return;

		Ammo mag1 = null, mag2 = null;
		[mag1, mag2] = weap.GetMagazines();
		Inventory ammoItem1, ammoItem2;
		[ammoItem1, ammoItem2] = GetCurrentAmmo();

		if (mag1 != null && mag1 != ammoItem1)
		{
			if (!(mag1 is 'BIO_MagazineETM'))
				DrawAmmoItemInfo(mag1, weap.MagazineSize1, invY);
			else
				DrawETMMagazineInfo(BIO_MagazineETM(mag1),
					weap.MagazineSize1 / GameTicRate, invY
				);

			invY -= 20;
		}

		if (mag2 != null && mag2 != ammoItem2)
		{
			if (!(mag2 is 'BIO_MagazineETM'))
				DrawAmmoItemInfo(mag2, weap.MagazineSize2, invY);
			else
				DrawETMMagazineInfo(BIO_MagazineETM(mag2),
					weap.MagazineSize2 / GameTicRate, invY
				);

			invY -= 20;
		}

		if (ammoItem1 != null)
		{
			DrawAmmoItemInfo(ammoItem1, ammoItem1.MaxAmount, invY);
			invY -= 20;
		}

		if (ammoItem2 != null && (ammoItem1 != ammoItem2))
		{
			DrawAmmoItemInfo(ammoItem2, ammoItem2.MaxAmount, invY);
			invY -= 20;
		}
	}

	private void DrawAmmoItemInfo(Inventory mag, int maxAmount, int invY)
	{
		DrawInventoryIcon(mag, (-16, invY + 16));

		DrawString(Font_HUD,
			String.Format("%s / %s",
				FormatNumber(mag.Amount, 3, 6),
				FormatNumber(maxAmount, 3, 6)
			),
			(-36, invY + 4), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD
		);
	}

	private void DrawETMMagazineInfo(BIO_MagazineETM mag, int maxAmount, int invY)
	{
		DrawInventoryIcon(mag, (-16, invY + 16));

		let powup = BIO_EnergyToMatterPowerup(
			BIOPlayer.FindInventory(mag.PowerupType)
		);

		DrawString(Font_HUD,
			String.Format("%s / %s",
				powup != null ?
					FormatNumber(powup.EffectTics / GameTicRate, 3, 6) :
					FormatNumber(0, 3, 6),
				FormatNumber(maxAmount, 3, 6)
			),
			(-36, invY + 4), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD
		);
	}

	// Draw powerup icons at top left, along with the 
	// durations remaining on their effects in seconds.
	final override void DrawPowerups()
	{
		int yPos = 0;

		for (Inventory i = CPlayer.MO.Inv; i != null; i = i.Inv)
		{
			int yOffs = NotifyLineCount.GetInt() * 16;
			let powup = Powerup(i);

			if (powup == null || !powup.Icon || powup is 'PowerStrength')
				continue;

			DrawInventoryIcon(powup, (20, yOffs + yPos));
			yPos += 8;
			int secs = powup.EffectTics / GameTicRate;
			DrawString(Font_Small, FormatNumber(secs, 1, 3),
				(19, yOffs + yPos), DI_TEXT_ALIGN_CENTER, Font.CR_WHITE);
			yPos += 32;
		}
	}

	private void DrawWeaponDetails(BIO_Weapon weap, bool leftSide) const
	{
		if (weap == null) return;

		int align, xPos;

		if (!leftSide)
		{
			align = DI_TEXT_ALIGN_RIGHT;
			xPos = HUDWeapOffsX.GetInt();
		}
		else
		{
			align = DI_TEXT_ALIGN_LEFT;
			xPos = HUDExamOffsX.GetInt();
		}

		// Leave room for automap timers
		int weapInfoY = leftSide ? HUDExamOffsY.GetInt() : HUDWeapOffsY.GetInt();

		DrawInventoryIcon(weap, (xPos, weapInfoY),
			!leftSide ?
				DI_SCREEN_RIGHT_TOP | DI_ITEM_RIGHT_TOP :
				DI_SCREEN_LEFT_TOP | DI_ITEM_LEFT_TOP);

		weapInfoY += 32;

		DrawString(Font_Small, weap.GetTag(), (xPos, weapInfoY),
			align, Font.CR_UNTRANSLATED);

		// Blank line between weapon's tag and its summary
		weapInfoY += 32;

		Array<string> weapStrings;
		weap.Summary(weapStrings);

		for (uint i = 0; i < weapStrings.Size(); i++)
		{
			DrawString(Font_Small, weapStrings[i], (xPos, weapInfoY),
				align, Font.CR_UNTRANSLATED);

			weapInfoY += 8;
		}
	}
}
