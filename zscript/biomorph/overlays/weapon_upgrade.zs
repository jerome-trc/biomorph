class BIO_WeaponUpgradeOverlay : BIO_ModalOverlay
{
	private string Help_0, Help_1;

	private Array<TextureWrapper> WeaponTextures;
	private Array<BIO_WeaponUpgrade> Choices;
	private ui uint SelectedWeapon;

	static BIO_WeaponUpgradeOverlay Create(Array<BIO_WeaponUpgrade> options)
	{
		let ret = new('BIO_WeaponUpgradeOverlay');
		ret.OnCreate();

		ret.Help_0 = String.Format(StringTable.Localize("$BIO_WUK_UIHELP_0"),
			ret.Key_Left.KeyName, ret.Key_Right.KeyName);
		
		ret.Help_1 = String.Format(StringTable.Localize("$BIO_WUK_UIHELP_1"),
			ret.Key_Confirm.KeyName, ret.Key_Cancel.KeyName);

		for (uint i = 0; i < options.Size(); i++)
		{
			let defs = GetDefaultByType(options[i].Output);
			ret.WeaponTextures.Push(TextureWrapper.FromID(defs.Icon));
			ret.Choices.Push(options[i]);
		}

		return ret;
	}

	final override void OnKeyPressed_Left()
	{
		SelectedWeapon = Max(SelectedWeapon - 1, 0);
		S_StartSound("bio/ui/beep", CHAN_AUTO);
	}
	
	final override void OnKeyPressed_Right()
	{
		SelectedWeapon = Min(SelectedWeapon + 1, Choices.Size() - 1);
		S_StartSound("bio/ui/beep", CHAN_AUTO);
	}

	final override void OnKeyPressed_Confirm()
	{
		EventHandler.SendNetworkEvent(
			BIO_EventHandler.EVENT_WEAPUPGRADE .. ":" .. 
			Choices[SelectedWeapon].Output.GetClassName(),
			Choices[SelectedWeapon].KitCost);
	}

	final override void OnKeyPressed_Cancel()
	{
		EventHandler.SendNetworkEvent(
			BIO_EventHandler.EVENT_WEAPUPGRADE .. ":_");
		S_StartSound("bio/ui/cancel", CHAN_AUTO);
	}

	const X_OFFS = VIRTUAL_WIDTH * 0.1;
	const WEAPICONHEIGHT = VIRTUAL_HEIGHT * 0.725;

	final override void Draw(RenderEvent event) const
	{
		int realTic = double(GameTic) + event.FracTic;
		double selectedAlpha = 1.0 + (Sin((realTic << 16 / 4) * 0.75));
		int fontH = SmallFont.GetHeight();

		// The tag of the selected output weapon

		string tag = GetDefaultByType(Choices[SelectedWeapon].Output).GetColoredTag();

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRTUAL_WIDTH_X2 * 0.5 - (SmallFont.StringWidth(tag) / 2),
			VIRTUAL_HEIGHT_X2 * 0.79,
			tag, DTA_VIRTUALWIDTH, VIRTUAL_WIDTH_X2, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT_X2);

		// Upgrade kit cost for current selection

		string cost = String.Format(
			StringTable.Localize("$BIO_WUK_UIKITCOST"),
			Choices[SelectedWeapon].KitCost);

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRTUAL_WIDTH_X2 * 0.5 - (SmallFont.StringWidth(cost) / 2),
			VIRTUAL_HEIGHT_X2 * 0.815,
			cost, DTA_VIRTUALWIDTH, VIRTUAL_WIDTH_X2, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT_X2);

		// Help text

		double txtY = VIRTUAL_HEIGHT_X2 * 0.85;

		Screen.DrawText(SmallFont, Font.CR_GOLD,
			VIRTUAL_WIDTH - (SmallFont.StringWidth(Help_0) / 2), txtY, Help_0,
			DTA_VIRTUALWIDTH, VIRTUAL_WIDTH_X2, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT_X2);
		txtY += fontH + (fontH / 4);
		Screen.DrawText(SmallFont, Font.CR_GOLD,
			VIRTUAL_WIDTH - (SmallFont.StringWidth(Help_1) / 2), txtY, Help_1,
			DTA_VIRTUALWIDTH, VIRTUAL_WIDTH_X2, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT_X2);

		// Draw the selected weapon in the center of the screen

		Screen.DrawTexture(WeaponTextures[SelectedWeapon].ID,
			false, VIRTUAL_WIDTH * 0.5, WEAPICONHEIGHT,
			DTA_VIRTUALWIDTH, VIRTUAL_WIDTH, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT,
			DTA_CENTEROFFSET, true, DTA_ALPHA, selectedAlpha);

		for (uint i = SelectedWeapon - 1; i >= 0; i--)
		{
			Screen.DrawTexture(WeaponTextures[i].ID, false,
				VIRTUAL_WIDTH * 0.5 - (X_OFFS * (SelectedWeapon - i)), WEAPICONHEIGHT,
				DTA_VIRTUALWIDTH, VIRTUAL_WIDTH, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT,
				DTA_CENTEROFFSET, true);
		}

		for (uint i = SelectedWeapon + 1; i < Choices.Size(); i++)
		{
			Screen.DrawTexture(WeaponTextures[i].ID, false,
				VIRTUAL_WIDTH * 0.5 + (X_OFFS * (i - SelectedWeapon)), WEAPICONHEIGHT,
				DTA_VIRTUALWIDTH, VIRTUAL_WIDTH, DTA_VIRTUALHEIGHT, VIRTUAL_HEIGHT,
				DTA_CENTEROFFSET, true);
		}
	}
}
