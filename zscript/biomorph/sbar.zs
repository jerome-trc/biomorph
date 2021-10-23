class BIO_StatusBar : BaseStatusBar
{
	private HUDFont Font_HUD, Font_Index, Font_Amount, Font_Small;
	private InventoryBarState InvBarState;

	const WEAPINFO_X = -22; // Leave room for keys at top-right corner
	const ARMORINFO_X = 4;

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
		
		DrawArmorDetails();

		if (deathmatch)
		{
			DrawString(Font_HUD, FormatNumber(CPlayer.FragCount, 3),
				(-3, 1), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
		}
		else
			DrawFullscreenKeys();
		
		if (isInventoryBarVisible())
			DrawInventoryBar(InvBarState, (0, 0), 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW);

		int invY = -20;
		DrawWeaponAndAmmoDetails(invY);
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

	private void DrawArmorDetails()
	{
		let armor = CPlayer.MO.FindInventory("BasicArmor");
		if (armor == null || armor.Amount <= 0) return;

		DrawInventoryIcon(armor, (20, -22));
		DrawString(Font_HUD, FormatNumber(armor.Amount, 3),
			(44, -36), 0, Font.CR_DARKGREEN);
		DrawString(Font_Small, FormatNumber(GetArmorSavePercent(), 3),
			(18, -30), 0, Font.CR_WHITE);

		let bioPlayer = BIO_Player(CPlayer.MO);
		if (bioPlayer == null) return;

		let bioArmor = bioPlayer.EquippedArmor;
		if (bioArmor == null) return;

		int affixY = -54;
		
		for (uint i = bioArmor.Affixes.Size() - 1; i >= 0; i--)
		{
			DrawString(Font_Small, bioArmor.Affixes[i].ToString(),
				(ARMORINFO_X, affixY), 0, Font.CR_WHITE);
			
			affixY -= 8;
		}

		affixY -= 8;

		for (uint i = bioArmor.ImplicitAffixes.Size() - 1; i >= 0; i--)
		{
			DrawString(Font_Small, bioArmor.ImplicitAffixes[i].ToString(),
				(ARMORINFO_X, affixY), 0, Font.CR_WHITE);
			
			affixY -= 8;
		}
	}

	private void DrawWeaponAndAmmoDetails(in out int invY)
	{
		BIO_Weapon weap = BIO_Weapon(CPlayer.ReadyWeapon);
		if (weap == null) return;

		Ammo mag1 = null, mag2 = null;
		[mag1, mag2] = weap.GetMagazines();
		Inventory ammoItem1, ammoItem2;
		[ammoItem1, ammoItem2] = GetCurrentAmmo();

		if (ammoItem1 != null)
		{
			DrawInventoryIcon(ammoItem1, (-14, -4));
			if (mag1.bIgnoreSkill)
			{
				DrawString(Font_HUD,
					String.Format("%s / %s / %s",
						FormatNumber(mag1.Amount, 3, 6),
						FormatNumber(ammoItem1.Amount, 3, 6),
						FormatNumber(ammoItem1.MaxAmount, 3, 6)),
					(-30, -16), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			}
			else
			{
				DrawString(Font_HUD,
					String.Format("%s / %s",
						FormatNumber(ammoItem1.Amount, 3, 6),
						FormatNumber(ammoItem1.MaxAmount, 3, 6)),
					(-30, -16), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			}
			
			invY -= 20;
		}
		
		if (ammoItem2 != null)
		{
			DrawInventoryIcon(ammoItem2, (-14, -24));
			if (mag2.bIgnoreSkill)
			{
				DrawString(Font_HUD,
					String.Format("%s / %s / %s",
						FormatNumber(mag2.Amount, 3, 6),
						FormatNumber(ammoItem2.Amount, 3, 6),
						FormatNumber(ammoItem2.MaxAmount, 3, 6)),
					(-30, -36), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			}
			else
			{
				DrawString(Font_HUD,
					String.Format("%s / %s",
						FormatNumber(ammoItem2.Amount, 3, 6),
						FormatNumber(ammoItem2.MaxAmount, 3, 6)),
					(-30, -36), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			}

			invY -= 20;
		}

		if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.MO.InvSel != null)
		{
			DrawInventoryIcon(CPlayer.MO.InvSel, (-14, invY));
			DrawString(Font_HUD, FormatNumber(CPlayer.MO.InvSel.Amount, 3),
				(-30, invY - 16), DI_TEXT_ALIGN_RIGHT);
		}

		// Leave room for automap timers
		int weapInfoY = 18;

		DrawString(Font_Small, weap.GetTag(), (WEAPINFO_X, weapInfoY),
			DI_TEXT_ALIGN_RIGHT, BIO_Utils.GradeFontColor(weap.Grade));

		// Blank line between weapon's tag and its stats
		weapInfoY += 16;

		Array<string> stats;
		weap.StatsToString(stats);

		for (uint i = 0; i < stats.Size(); i++)
		{
			DrawString(Font_Small, stats[i], (WEAPINFO_X, weapInfoY),
				DI_TEXT_ALIGN_RIGHT, Font.CR_UNTRANSLATED);

			weapInfoY += 8;
		}

		weapInfoY += 8; // Blank line between stats and affixes

		for (uint i = 0; i < weap.Affixes.Size(); i++)
		{
			DrawString(Font_Small, weap.Affixes[i].ToString(weap),
				(WEAPINFO_X, weapInfoY), DI_TEXT_ALIGN_RIGHT,
				Font.CR_WHITE);
			weapInfoY += 8;
		}
	}
}