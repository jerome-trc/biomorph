class BIO_PerkMenuNode
{
	Vector2 DrawPos, ScreenPos;
	bool Selected;
}

class BIO_PerkMenu : GenericMenu
{
	const VIRT_W = 640.0; const VIRT_H = 480.0;

	const COLOR_HOVERED = Color(127, 127, 127, 127);
	const COLOR_NONE = Color(0, 0, 0, 0);
	
	private readOnly<BIO_BasePerkGraph> BasePerkGraph;
	private readOnly<BIO_PlayerPerkGraph> PlayerPerkGraph;

	private string Txt_HelpPan, Txt_Apply;
	private TextureID Tex_Node, Tex_NodeRing;

	private BIO_NamedKey Key_Confirm;

	private bool Pan;
	private Vector2 Size; // Used as virtual width/height to provide zoom.
	private Vector2 ViewPosition; // Where on the whole graph is the user looking?
	private Vector2 MousePos, LMP; // Last mouse position, used for panning

	private Array<BIO_PerkMenuNode> NodeState;
	private uint HoveredNode; // Defaults to `NodeState.Size()` if nothing hovered
	private uint SelectionSize; // How many perks selected for application/removal?

	// Parent overrides ========================================================

	final override void Init(Menu parent)
	{
		super.Init(parent);

		// Localize text resources
		Txt_HelpPan = StringTable.Localize("$BIO_PERKMENU_HELP_PAN");
		Txt_Apply = BIO_Utils.Capitalize(StringTable.Localize("$BIO_APPLY"));

		// Acquire graphical resources
		Tex_Node = TexMan.CheckForTexture(
			"graphics/perknode.png", TexMan.TYPE_ANY);
		Tex_NodeRing = TexMan.CheckForTexture(
			"graphics/perknode_ring.png", TexMan.TYPE_ANY);

		Key_Confirm = BIO_NamedKey.Create("+use");

		Size.X = VIRT_W;
		Size.Y = VIRT_H;

		// Get the player's perk graph data
		let globals = BIO_GlobalData.Get();
		PlayerPerkGraph = globals.GetPerkGraph(Players[ConsolePlayer]).AsConst();
		BasePerkGraph = globals.GetBasePerkGraph();
		
		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
			NodeState.Push(new('BIO_PerkMenuNode'));

		UpdateNodeState();
	}

	final override bool MenuEvent(int mKey, bool fromController)
	{
		return super.MenuEvent(mKey, fromController);
	}

	final override bool MouseEvent(int type, int mX, int mY)
	{
		switch (type)
		{
		case MOUSE_Move:
			if (Pan)
			{
				ViewPosition.X = Clamp(ViewPosition.X + (LMP.X - mX),
					-(Size.X / 2), Size.X / 2);
				ViewPosition.Y = Clamp(ViewPosition.Y + (LMP.Y - mY),
					-(Size.Y / 2), Size.Y / 2);
			}
			break;
		case MOUSE_Click:
			TryToggleHoveredNode();
			break;
		default: break;
		}

		return true;
	}

	final override bool OnUIEvent(UIEvent event)
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
			MousePos.X = event.MouseX;
			MousePos.Y = event.MouseY;
			LMP.X = MousePos.X;
			LMP.Y = MousePos.Y;
			UpdateNodeState();
			break;
		case UIEvent.Type_LButtonDown:
			res = MouseEventBack(MOUSE_Click, event.MouseX, y);
			// Make the menu's mouse handler believe that the
			// current coordinate is outside the valid range
			if (res) y = -1;
			res |= MouseEvent(MOUSE_Click, event.MouseX, y);
			if (res)
			{
				SetCapture(true);
			}
			break;
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
			Size.X = Min(Size.X + 32.0, 1920.0);
			Size.Y = Min(Size.Y + 24.0, 1440.0);
			UpdateNodeState();
			break;
		case UIEvent.Type_WheelUp:
			Size.X = Max(Size.X - 32.0, VIRT_W);
			Size.Y = Max(Size.Y - 24.0, VIRT_H);
			UpdateNodeState();
			break;
		case UIEvent.Type_MButtonDown:
			SetCapture(true);
			Pan = true;
			break;
		case UIEvent.Type_MButtonUp:
			SetCapture(false);
			Pan = false;
			break;
		case UIEvent.Type_KeyUp:
			// TODO: Get this to check against player's defined "Use" key
			if (event.KeyString ~== "e")
				CommitSelection();
			break;
		default: break;
		}

		return false;
	}

	final override void Drawer()
	{
		super.Drawer(); // Draw the back button

		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());

		// Help text at menu's top

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(Txt_HelpPan) / 2),
			VIRT_H * 0.025, Txt_HelpPan,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);

		// Counters for perk and refund points

		string ptStr = String.Format(
			StringTable.Localize("$BIO_PERKMENU_POINTCOUNT"),
			PlayerPerkGraph.Points);

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(ptStr) / 2),
			VIRT_H * 0.05, ptStr,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);

		// Node connections

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			let ni = BasePerkGraph.Nodes[i];

			for (uint j = 0; j < BasePerkGraph.Nodes[i].Neighbors.Size(); j++)
			{
				let uuidJ = BasePerkGraph.Nodes[ni.Neighbors[j]].UUID;

				if (i == uuidJ)
					continue;

				Screen.DrawThickLine(
					NodeState[i].ScreenPos.X, NodeState[i].ScreenPos.Y,
					NodeState[uuidJ].ScreenPos.X, NodeState[uuidJ].ScreenPos.Y,
					4.0, COLOR_HOVERED);
			}
		}

		// Node frames and icons

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			Screen.DrawTexture(Tex_Node, false,
				NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_CENTEROFFSET, true,
				DTA_COLOROVERLAY, HoveredNode == i ? COLOR_HOVERED : COLOR_NONE);

			Screen.DrawTexture(BasePerkGraph.Nodes[i].Icon, false,
				NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_CENTEROFFSET, true);

			if (PlayerPerkGraph.PerkActive[i])
			{
				Screen.DrawTexture(Tex_NodeRing, false,
					NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true);
			}
			else if (NodeState[i].Selected)
			{
				Screen.DrawTexture(Tex_NodeRing, false,
					NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true,
					DTA_ALPHA, 1.0 + (Sin((MenuTime() << 16 / 4) * 0.75)));
			}
		}

		// Tooltip

		if (HoveredNode == NodeState.Size())
			return;

		string tt = BasePerkGraph.Nodes[HoveredNode].Title .. "\n\n";
		let desc = SmallFont.BreakLines(
			BasePerkGraph.Nodes[HoveredNode].Description, 240); 
		
		for (uint i = 0; i < desc.Count(); i++)
			tt.AppendFormat("%s\n", desc.StringAt(i));

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			(MousePos.X / 3.0) + 8, (MousePos.Y / 2.25) + 8, tt,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);
	}

	final override void Ticker()
	{
		if ((GameState != GS_LEVEL) || (Players[ConsolePlayer].Health <= 0))
		{
			Close();
			return;
		}
	}

	// Private implementation details ==========================================

	// Called whenever the mouse moves or the zoom level changes.
	private void UpdateNodeState()
	{
		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());

		HoveredNode = NodeState.Size();

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			let node = BasePerkGraph.Nodes[i];

			NodeState[i].DrawPos = (
				(Size.X / 2) + node.Position.X + ViewPosition.X,
				(Size.Y / 2) + node.Position.Y + ViewPosition.Y
			);

			NodeState[i].ScreenPos = Screen.VirtualToRealCoords( 
				NodeState[i].DrawPos, scrSz, Size);

			double nodeW = double(TexMan.GetSize(Tex_Node));

			Vector2
				realTL = Screen.VirtualToRealCoords(
					(NodeState[i].DrawPos.X - nodeW,
					NodeState[i].DrawPos.Y - nodeW),
					scrSz, Size),
				realBR = Screen.VirtualToRealCoords(
					(NodeState[i].DrawPos.X + nodeW,
					NodeState[i].DrawPos.Y + nodeW),
					scrSz, Size);

			if (MousePos.X > realTL.X && MousePos.X < realBR.X &&
				MousePos.Y > realTL.Y && MousePos.Y < realBR.Y &&
				!Pan && i != 0)
			{
				HoveredNode = i;
			}
		}
	}

	private void TryToggleHoveredNode()
	{
		if (HoveredNode == NodeState.Size())
			return;

		// Has the player already unlocked this perk?
		if (PlayerPerkGraph.PerkActive[HoveredNode])
			return;

		if (SelectionSize >= PlayerPerkGraph.Points)
			return;

		Array<uint> active;
		
		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			if (NodeState[i].Selected || PlayerPerkGraph.PerkActive[i])
				active.Push(i);
		}

		// Have the hovered node's dependencies been satisfied
		// by already being active or selected?
		if (!BasePerkGraph.IsAccessible(HoveredNode, active))
			return;

		// Would deselecting the hovered node leave
		// another selected node orphaned?
		if (NodeState[HoveredNode].Selected)
		{
			active.Delete(active.Find(HoveredNode));
			
			for (uint i = 1; i < BasePerkGraph.Nodes.Size(); i++)
			{
				if (i == HoveredNode)
					continue;
				
				if (!NodeState[i].Selected)
					continue;
				
				if (!BasePerkGraph.IsAccessible(i, active))
					return;
			}
		}

		MenuSound("bio/ui/beep");

		NodeState[HoveredNode].Selected = !NodeState[HoveredNode].Selected;
		
		if (NodeState[HoveredNode].Selected)
			SelectionSize++;
		else
			SelectionSize--;
	}

	private void CommitSelection()
	{
		if (SelectionSize < 1) return;

		MenuSound("bio/ui/beep");

		for (uint i = 0; i < NodeState.Size(); i++)
		{
			if (NodeState[i].Selected)
			{
				BIO_EventHandler.CommitPerk(i);
				NodeState[i].Selected = false;
			}
		}
	}
}
