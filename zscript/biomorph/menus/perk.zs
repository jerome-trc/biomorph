class BIO_PerkMenu : GenericMenu
{
	const VIRT_W = 640; const VIRT_H = 480;

	private BIO_PerkGraph PerkGraph;

	string HelpText_Pan;
	private TextureID NodeFrame;

	private bool Pan;
	private Vector2 Size; // Used as virtual width/height to provide zoom.
	private Vector2 ViewPosition; // Where on the whole graph is the user looking?
	private Vector2 LMP; // Last mouse position, used for panning

	override void Init(Menu parent)
	{
		super.Init(parent);

		// Localize text resources
		HelpText_Pan = StringTable.Localize("$BIO_PERK_UIHELP_PAN");

		// Acquire graphical resources
		NodeFrame = TexMan.CheckForTexture(
			"graphics/perknodeframe.png", TexMan.TYPE_ANY);

		Size.X = VIRT_W;
		Size.Y = VIRT_H;

		// Get the player's perk graph data
		let globals = BIO_GlobalData.Get();
		PerkGraph = globals.GetPerkGraph(Players[ConsolePlayer]);
	}

	override bool MenuEvent(int mKey, bool fromController)
	{
		return super.MenuEvent(mKey, fromController);
	}

	override bool MouseEvent(int type, int mX, int mY)
	{
		if (type == MOUSE_Move && Pan)
		{
			ViewPosition.X = Clamp(ViewPosition.X + (LMP.X - mX),
				-(Size.X / 2), Size.X / 2);
			ViewPosition.Y = Clamp(ViewPosition.Y + (LMP.Y - mY),
				-(Size.Y / 2), Size.Y / 2);
		}
		return true;
	}

	override bool OnUIEvent(UIEvent event)
	{
		int y = event.MouseY;
		bool res = false;

		switch (event.Type)
		{
		case UIEvent.Type_MouseMove:
			BackbuttonTime = 4 * GameTicRate;
			if (mMouseCapture || m_use_mouse == 1)
			{
				if (MouseEventBack(MOUSE_Move, event.MouseX, y))
					y = -1;	
				
				MouseEvent(MOUSE_Move, event.MouseX, y);
			}
			LMP.X = event.MouseX;
			LMP.Y = event.MouseY;
			break;
		case UIEvent.Type_LButtonDown:
			res = MouseEventBack(MOUSE_Click, event.MouseX, y);
			// make the menu's mouse handler believe that the current coordinate is outside the valid range
			if (res) y = -1;	
			res |= MouseEvent(MOUSE_Click, event.MouseX, y);
			if (res)
			{
				SetCapture(true);
			}
		case UIEvent.Type_LButtonUp:
			if (mMouseCapture)
			{
				SetCapture(false);
				res = MouseEventBack(MOUSE_Release, event.MouseX, y);
				if (res) y = -1;	
				res |= MouseEvent(MOUSE_Release, event.MouseX, y);
			}
			break;
		case UIEvent.Type_WheelDown:
			Size.X = Min(Size.X + 32, 1920);
			Size.Y = Min(Size.Y + 24, 1440);
			break;
		case UIEvent.Type_WheelUp:
			Size.X = Max(Size.X - 32, 640);
			Size.Y = Max(Size.Y - 24, 480);
			break;
		case UIEvent.Type_MButtonDown:
			SetCapture(true);
			Pan = true;
			break;
		case UIEvent.Type_MButtonUp:
			SetCapture(false);
			Pan = false;
			break;
		default:
			break;
		}

		return false;
	}

	override bool OnInputEvent(InputEvent event)
	{
		return super.OnInputEvent(event);
	}

	override void Drawer()
	{
		super.Drawer(); // Draw the back button

		// Help text

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(HelpText_Pan) / 2),
			VIRT_H * 0.025, HelpText_Pan,
			DTA_VIRTUALWIDTH, VIRT_W, DTA_VIRTUALHEIGHT, VIRT_H);

		// Nodes

		for (uint i = 0; i < PerkGraph.Nodes.Size(); i++)
		{
			let node = PerkGraph.Nodes[i];

			int x = Size.X, y = Size.Y;

			Screen.DrawTexture(NodeFrame, false,
				(x / 2) + node.Position.X + ViewPosition.X,
				(y / 2) + node.Position.Y + ViewPosition.Y,
				DTA_VIRTUALWIDTH, x, DTA_VIRTUALHEIGHT, y,
				DTA_CENTEROFFSET, true);
		}
	}

	override void Ticker()
	{
		if ((GameState != GS_LEVEL) || (Players[ConsolePlayer].Health <= 0))
		{
			Close();
			return;
		}
	}
}
