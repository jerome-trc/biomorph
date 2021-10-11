class BIO_StatusBar : BaseStatusBar
{
	private HUDFont Font_HUD, Font_Index, Font_Amount, Font_Small;
	private InventoryBarState InvBarState;

	const WEAPINFO_X = -22; // Leave room for keys at top-right corner

	override void Init()
	{
		super.Init();
		SetSize(32, 320, 200);

		Font fnt = "BIGFONT";
		Font_HUD = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 1, 1);
		fnt = "INDEXFONT_DOOM";
		Font_Index = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		Font_Amount = HUDFont.Create("INDEXFONT");
		Font_Small = HUDFont.Create("SMALLFONT");
		InvBarState = InventoryBarState.Create();
	}

	override void Draw(int state, double ticFrac)
	{
		super.Draw(state, ticFrac);
		BeginHUD();
		DrawFullscreenHUD();
	}

	protected void DrawFullscreenHUD()
	{
		Vector2 iconbox = (40, 20);

		let berserk = CPlayer.MO.FindInventory("PowerStrength");
		DrawImage(berserk ? "PSTRA0" : "MEDIA0", (20, -2));
		DrawString(Font_HUD,
			String.Format("%s / %s",
				FormatNumber(CPlayer.Health, 3, 5),
				FormatNumber(CPlayer.MO.GetMaxHealth(true), 3, 5)), 
			(44, -16), 0, Font.CR_DARKRED);
		
		let armor = CPlayer.MO.FindInventory("BasicArmor");
		if (armor != null && armor.Amount > 0)
		{
			DrawInventoryIcon(armor, (20, -22));
			DrawString(Font_HUD, FormatNumber(armor.Amount, 3), (44, -36), 0, Font.CR_DARKGREEN);
		}

		Inventory ammotype1, ammotype2;
		[ammotype1, ammotype2] = GetCurrentAmmo();
		int invY = -20;
		if (ammotype1 != null)
		{
			DrawInventoryIcon(ammotype1, (-14, -4));
			DrawString(Font_HUD,
				String.Format("%s / %s",
					FormatNumber(ammotype1.Amount, 3, 6),
					FormatNumber(ammotype1.MaxAmount, 3, 6)),
				(-30, -16), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			invY -= 20;
		}

		if (ammotype2 != null && ammotype2 != ammotype1)
		{
			DrawInventoryIcon(ammotype2, (-14, invY + 17));
			DrawString(Font_HUD,
				String.Format("%s / %s",
					FormatNumber(ammotype2.Amount, 3, 6),
					FormatNumber(ammotype2.MaxAmount, 3, 6)),
				(-30, invY), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			invY -= 20;
		}

		if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.MO.InvSel != null)
		{
			DrawInventoryIcon(CPlayer.MO.InvSel, (-14, invY));
			DrawString(Font_HUD, FormatNumber(CPlayer.MO.InvSel.Amount, 3), (-30, invY - 16), DI_TEXT_ALIGN_RIGHT);
		}

		if (deathmatch)
			DrawString(Font_HUD, FormatNumber(CPlayer.FragCount, 3), (-3, 1), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
		else
			DrawFullscreenKeys();
		
		if (isInventoryBarVisible())
			DrawInventoryBar(InvBarState, (0, 0), 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW);

		// Leave room for automap timers
		int weapInfoY = 18;
	
		// Biomorph weapon information
		// BIO_Weapon weap = BIO_Weapon(CPlayer.ReadyWeapon);
		// if (weap)
		// {
		// 	DrawString(Font_Small, weap.GetTag(),
		// 		(WEAPINFO_X, weapInfoY), DI_TEXT_ALIGN_RIGHT, Font.CR_BROWN
		// 	);

		// 	weapInfoY += 8;

		// 	for (uint i = 0; i < weap.FireData.Size(); i++)
		// 	{
		// 		DrawString(Font_Small, weap.Firedata[i].ToString(),
		// 			(WEAPINFO_X, weapInfoY), DI_TEXT_ALIGN_RIGHT,
		// 			weap.FireData[i].IsUnmodified() ? Font.CR_WHITE : Font.CR_SAPPHIRE);
		// 		weapInfoY += 8;
		// 	}

		// 	for (uint i = 0; i < weap.FireTimes.Size(); i++)
		// 	{
		// 		DrawString(Font_Small, weap.FireTimes[i].ToString(),
		// 			(WEAPINFO_X, weapInfoY), DI_TEXT_ALIGN_RIGHT,
		// 			weap.FireTimes[i].IsUnmodified() ? Font.CR_WHITE : Font.CR_SAPPHIRE);
		// 		weapInfoY += 8;
		// 	}

		// 	for (uint i = 0; i < weap.Spread.Size(); i++)
		// 	{
		// 		DrawString(Font_Small, weap.Spread[i].ToString(),
		// 			(WEAPINFO_X, weapInfoY), DI_TEXT_ALIGN_RIGHT,
		// 			weap.Spread[i].IsUnmodified() ? Font.CR_WHITE : Font.CR_SAPPHIRE);
		// 		weapInfoY += 8;
		// 	}

		// 	weapInfoY += 8; // Blank line between stats and affixes

		// 	for (uint i = 0; i < weap.Affixes.Size(); i++)
		// 	{
		// 		DrawString(Font_Small, weap.Affixes[i].ToString(weap),
		// 			(WEAPINFO_X, weapInfoY), DI_TEXT_ALIGN_RIGHT,
		// 			weap.Affixes[i].GetFontColour()
		// 		);
		// 		weapInfoY += 8;
		// 	}
		// }
	}
	
	protected virtual void DrawFullscreenKeys()
	{
		// Draw the keys. This does not use a special draw function like SBARINFO
		// because the specifics will be different for each mod so it's easier to
		// copy or reimplement the following piece of code instead of trying to 
		// write a complicated all-encompassing solution.
		Vector2 keypos = (-10, 2);
		int rowc = 0;
		double roww = 0;
		for (let i = CPlayer.MO.Inv; i != null; i = i.Inv)
		{
			if (i is "Key" && i.Icon.IsValid())
			{
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
	}
}