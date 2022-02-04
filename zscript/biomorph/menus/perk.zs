class BIO_PerkMenuNode
{
	Vector2 DrawPos, ScreenPos;
	bool Selected;
}

class BIO_PerkMenu : GenericMenu
{
	const VIRT_W = 640.0; const VIRT_H = 360.0;

	// Note to self: color constructor takes A, R, G, B
	const COLOR_HOVERED = Color(127, 127, 127, 127);
	const COLOR_FULLCONN_OUTER = Color(127, 130, 239, 255);
	const COLOR_FULLCONN_INNER = Color(127, 65, 255, 240);
	const COLOR_NONE = Color(0, 0, 0, 0);
	
	protected readOnly<BIO_BasePerkGraph> BasePerkGraph;
	private readOnly<BIO_PlayerPerkGraph> PlayerPerkGraph;

	private string Txt_HelpPan, Txt_Apply;
	private TextureID
		Tex_Node_Minor, Tex_NodeRing_Minor,
		Tex_Node_Major, Tex_NodeRing_Major;

	private BIO_NamedKey Key_Confirm;

	private bool Pan;
	private Vector2 Size; // Used as virtual width/height to provide zoom.
	private Vector2 ViewPosition; // Where on the whole graph is the user looking?
	protected Vector2 MousePos, LMP; // Last mouse position, used for panning

	protected Array<BIO_PerkMenuNode> NodeState;
	protected uint HoveredNode; // Defaults to `NodeState.Size()` if nothing hovered
	bool RefundMode;
	private uint SelectionSize; // How many perks selected for application/refund?

	// Parent overrides ========================================================

	override void Init(Menu parent)
	{
		super.Init(parent);

		// Localize text resources
		Txt_HelpPan = StringTable.Localize("$BIO_PERKMENU_HELP_PAN");
		Txt_Apply = BIO_Utils.Capitalize(StringTable.Localize("$BIO_APPLY"));

		// Acquire graphical resources
		Tex_Node_Minor = TexMan.CheckForTexture(
			"graphics/perknode_minor.png", TexMan.TYPE_ANY);
		Tex_NodeRing_Minor = TexMan.CheckForTexture(
			"graphics/perknode_ring_minor.png", TexMan.TYPE_ANY);
		Tex_Node_Major = TexMan.CheckForTexture(
			"graphics/perknode_major.png", TexMan.TYPE_ANY);
		Tex_NodeRing_Major = TexMan.CheckForTexture(
			"graphics/perknode_ring_major.png", TexMan.TYPE_ANY);

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
			if (!RefundMode)
				TryToggleHoveredNode();
			else
				TryToggleHoveredNode_Refund();
			break;
		default: break;
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
			LMP.X = MousePos.X;
			LMP.Y = MousePos.Y;
			MousePos.X = event.MouseX;
			MousePos.Y = event.MouseY;
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
			Size.X = Min(Size.X + 32.0, VIRT_W * 3.0);
			Size.Y = Min(Size.Y + 18.0, VIRT_H * 3.0);
			UpdateNodeState();
			break;
		case UIEvent.Type_WheelUp:
			Size.X = Max(Size.X - 32.0, VIRT_W);
			Size.Y = Max(Size.Y - 18.0, VIRT_H);
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
			else if (event.KeyString ~== "r")
				ToggleRefundMode();
			break;
		default: break;
		}

		return false;
	}

	override void Drawer()
	{
		super.Drawer(); // Draw the back button

		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());

		// Node connections

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			let ni = BasePerkGraph.Nodes[i];

			for (uint j = 0; j < BasePerkGraph.Nodes[i].Neighbors.Size(); j++)
			{
				let uuidJ = BasePerkGraph.Nodes[ni.Neighbors[j]].UUID;

				if (i == uuidJ)
					continue;

				if ((PlayerPerkGraph.PerkActive[i] || NodeState[i].Selected) &&
					(PlayerPerkGraph.PerkActive[uuidJ] || NodeState[uuidJ].Selected))
				{
					Screen.DrawThickLine(
						NodeState[i].ScreenPos.X, NodeState[i].ScreenPos.Y,
						NodeState[uuidJ].ScreenPos.X, NodeState[uuidJ].ScreenPos.Y,
						Size.X / (Size.X * 0.15), COLOR_FULLCONN_OUTER);
					
					Screen.DrawThickLine(
						NodeState[i].ScreenPos.X, NodeState[i].ScreenPos.Y,
						NodeState[uuidJ].ScreenPos.X, NodeState[uuidJ].ScreenPos.Y,
						Size.X / (Size.X * 0.35), COLOR_FULLCONN_INNER);
				}
				else
				{
					Screen.DrawThickLine(
						NodeState[i].ScreenPos.X, NodeState[i].ScreenPos.Y,
						NodeState[uuidJ].ScreenPos.X, NodeState[uuidJ].ScreenPos.Y,
						Size.X / (Size.X * 0.25), COLOR_HOVERED);
				}
			}
		}

		// Node frames and icons

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			TextureID frame, ring;
			
			switch (BasePerkGraph.Nodes[i].Category)
			{
			default:
			case BIO_PRKCAT_MINOR:
				frame = Tex_Node_Minor;
				ring = Tex_NodeRing_Minor;
				break;
			case BIO_PRKCAT_MAJOR:
				frame = Tex_Node_Major;
				ring = Tex_NodeRing_Major;
				break;
			}

			Screen.DrawTexture(frame, false,
				NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_COLOROVERLAY, HoveredNode == i ? COLOR_HOVERED : COLOR_NONE);

			if (NodeState[i].Selected)
			{
				Screen.DrawTexture(ring, false,
					NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
					DTA_ALPHA, 1.0 + (Sin((MenuTime() << 16 / 4) * 0.75)));
			}
			else if (PlayerPerkGraph.PerkActive[i])
			{
				Screen.DrawTexture(ring, false,
					NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y);
			}

			// Draw node icon at half alpha if it isn't currently accessible

			bool accessible = false;

			for (uint j = 0; j < BasePerkGraph.Nodes[i].Neighbors.Size(); j++)
			{
				let nid = BasePerkGraph.Nodes[i].Neighbors[j];
				
				if (PlayerPerkGraph.PerkActive[nid] || NodeState[nid].Selected)
				{
					accessible = true;
					break;
				}
			}

			if (accessible)
			{
				Screen.DrawTexture(BasePerkGraph.Nodes[i].Icon, false,
					NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y);
			}
			else
			{
				Screen.DrawTexture(BasePerkGraph.Nodes[i].Icon, false,
					NodeState[i].DrawPos.X, NodeState[i].DrawPos.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_ALPHA, 0.3);
			}
		}

		// Help text at menu's top

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(Txt_HelpPan) / 2),
			VIRT_H * 0.025, Txt_HelpPan, DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);

		// Counters for perk and refund points

		string ptStr = String.Format(
			StringTable.Localize("$BIO_PERKMENU_POINTCOUNT"),
			PlayerPerkGraph.Points);

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(ptStr) / 2),
			VIRT_H * 0.05, ptStr, DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);

		string refundStr = String.Format(
			StringTable.Localize("$BIO_PERKMENU_REFUNDCOUNT"),
			PlayerPerkGraph.Refunds);

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(refundStr) / 2),
			VIRT_H * 0.075, refundStr, DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);

		if (RefundMode)
		{
			string refundHelp = StringTable.Localize("$BIO_PERKMENU_HELP_REFUND");

			Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
				VIRT_W * 0.5 - (SmallFont.StringWidth(refundHelp) / 2),
				VIRT_H * 0.1, refundHelp, DTA_KEEPRATIO, true,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H);
		}

		// Tooltip

		if (HoveredNode == NodeState.Size())
			return;

		string tt = BasePerkGraph.Nodes[HoveredNode].Tag .. "\n\n";
		let desc = SmallFont.BreakLines(
			BasePerkGraph.Nodes[HoveredNode].Description, 240); 
		
		for (uint i = 0; i < desc.Count(); i++)
			tt.AppendFormat("%s\n", desc.StringAt(i));

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			(MousePos.X / CleanXFac) + 8, (MousePos.Y / CleanYFac) + 8, tt,
			DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
			DTA_KEEPRATIO, true);
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

	private void ToggleRefundMode()
	{
		MenuSound("bio/ui/beep");

		RefundMode = !RefundMode;

		for (uint i = 0; i < NodeState.Size(); i++)
			NodeState[i].Selected = false;

		SelectionSize = 0;
	}

	// Called whenever the mouse moves or the zoom level changes.
	protected void UpdateNodeState()
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
				NodeState[i].DrawPos, scrSz, Size, handleAspect: false);

			TextureID frame;

			switch (BasePerkGraph.Nodes[i].Category)
			{
			default:
			case BIO_PRKCAT_MINOR:
				frame = Tex_Node_Minor;
				break;
			case BIO_PRKCAT_MAJOR:
				frame = Tex_Node_Major;
				break;
			}

			Vector2 nodeSz;
			[nodeSz.X, nodeSz.Y] = TexMan.GetSize(frame);

			Vector2
				realTL = Screen.VirtualToRealCoords(
					(NodeState[i].DrawPos.X - (nodeSz.X * 0.5),
					NodeState[i].DrawPos.Y - (nodeSz.Y * 0.5)),
					scrSz, Size, handleAspect: false),
				realBR = Screen.VirtualToRealCoords(
					(NodeState[i].DrawPos.X + (nodeSz.X * 0.5),
					NodeState[i].DrawPos.Y + (nodeSz.Y * 0.5)),
					scrSz, Size, handleAspect: false);

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

		if (!NodeState[HoveredNode].Selected &&
			SelectionSize >= PlayerPerkGraph.Points)
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

		// Would deselecting the hovered node leave another selected node orphaned?
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

	private void TryToggleHoveredNode_Refund()
	{
		if (HoveredNode == NodeState.Size())
			return;
		
		// Has the player unlocked this perk?
		if (!PlayerPerkGraph.PerkActive[HoveredNode])
			return;

		if (!NodeState[HoveredNode].Selected &&
			SelectionSize >= PlayerPerkGraph.Refunds)
			return;
		
		Array<uint> active;
		
		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			if (!NodeState[i].Selected || PlayerPerkGraph.PerkActive[i])
				active.Push(i);
		}

		// Would refunding the hovered node leave another active node orphaned?
		if (!NodeState[HoveredNode].Selected)
		{
			active.Delete(active.Find(HoveredNode));

			for (uint i = 1; i < BasePerkGraph.Nodes.Size(); i++)
			{
				if (i == HoveredNode)
					continue;
				
				if (NodeState[i].Selected)
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

		BIO_EventHandler.ResetPlayer();

		for (uint i = 0; i < NodeState.Size(); i++)
		{
			if (NodeState[i].Selected)
			{
				if (!RefundMode)
					BIO_EventHandler.AddPerk(i);
				else
					BIO_EventHandler.RefundPerk(i);

				NodeState[i].Selected = false;
			}
		}

		BIO_EventHandler.CommitPerks();
	}
}

class BIO_PerkDebugMenu : BIO_PerkMenu
{
	private uint AttachedNode;

	final override void Init(Menu parent)
	{
		super.Init(parent);
		AttachedNode = NodeState.Size();
	}

	final override void Drawer()
	{
		super.Drawer();

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			Screen.DrawText(SmallFont, Font.CR_WHITE,
				NodeState[i].ScreenPos.X, NodeState[i].ScreenPos.Y,
				String.Format("%d, %d",
					BasePerkGraph.Nodes[i].Position.X,
					BasePerkGraph.Nodes[i].Position.Y));
		}
	}

	final override bool OnUIEvent(UIEvent event)
	{
		bool ret = super.OnUIEvent(event);

		switch (event.Type)
		{
		case UIEvent.Type_MouseMove:
			if (AttachedNode != NodeState.Size())
			{
				BasePerkGraph.Nodes[AttachedNode].Position +=
					(MousePos.X - LMP.X, MousePos.Y - LMP.Y);
			}
			break;
		case UIEvent.Type_RButtonDown:
			if (HoveredNode != NodeState.Size())
				AttachedNode = HoveredNode;

			break;
		case UIEvent.Type_RButtonUp:
			AttachedNode = NodeState.Size();
			break;
		case UIEvent.Type_KeyUp:
			if (event.KeyString ~== "l")
			{
				string output = Biomorph.LOGPFX_DEBUG .. "Node names and positions:";
				
				for (uint i = 1; i < NodeState.Size(); i++)
				{
					output.AppendFormat("\n\t%s (%d, %d)",
						BasePerkGraph.Nodes[i].Tag,
						BasePerkGraph.Nodes[i].Position.X,
						BasePerkGraph.Nodes[i].Position.Y);
				}

				Console.Printf(output);
			}
			break;
		default: break;
		}

		UpdateNodeState();
		return ret;
	}
}
