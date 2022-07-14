// Note to reader: classes are defined using `extend` blocks for code folding.

class BIO_WModMenu_Node
{
	Vector2 DrawPos, ScreenPos;
}

class BIO_WModMenu_DraggedGene
{
	enum OriginType
	{
		ORIGIN_INVSLOT,
		ORIGIN_NODE
	}

	class<BIO_Gene> Type;
	OriginType Origin;
	// The following 2 fields correspond to the `Nodes` and `Genes` of
	// `BIO_WeaponModSimulator` respectively, and reflect origin.
	uint Node, InvSlot;

	uint GetOrigin() const
	{
		if (OriginIsNode())
			return Node;
		else
			return InvSlot;
	}

	bool OriginIsNode() const
	{
		return Origin == ORIGIN_NODE;
	}

	bool IsFromNode(uint node) const
	{
		return OriginIsNode() && self.Node == node;
	}

	bool IsFromInvSlot(uint slot) const
	{
		return !OriginIsNode() && self.InvSlot == slot;
	}
}

// Class declaration, constants and members, initialization, ticker.
class BIO_WeaponModMenu : GenericMenu
{
	const VIRT_W = 640.0; const VIRT_H = 360.0;

	const INVSLOT_POS_X_START = VIRT_W * 0.1;
	const INVSLOT_POS_X_END = VIRT_W - (VIRT_W * 0.1);
	const INVSLOT_POS_Y = VIRT_H - (VIRT_H * 0.1);

	// Note to self: color constructor takes A, R, G, B
	const COLOR_NONE = Color(0, 0, 0, 0);
	const COLOR_INVALID = Color(127, 224, 0, 0);
	const COLOR_HOVERED = Color(127, 127, 127, 127);
	const COLOR_HOVEREDINVALID = Color(127, 255, 127, 127);
	const COLOR_CONN = Color(127, 65, 255, 240);

	private string
		Txt_Help_Pan, Txt_Help_ModOrder, Txt_Help_Hotkeys,
		Txt_Unmutated, Txt_Mutagen;
	private textureID Tex_Node, Tex_NodeRing, Tex_InvSlot, Tex_Padlock;

	private readOnly<BIO_Weapon> CurrentWeap;
	private BIO_WeaponModSimulator Simulator;

	private Array<BIO_WModMenu_Node> NodeDrawState;

	private bool Pan;
	private Vector2 Size; // Used as virtual width/height to provide zoom.
	private Vector2 ViewPosition; // Where on the whole graph is the user looking?
	private Vector2 MousePos, LMP; // Last mouse position, used for panning.

	// Corresponds to the UUID of an element in `BIO_WeaponModSimulator::Nodes`.
	// Defaults to the size of the array if nothing hovered.
	private uint HoveredNode;
	// Corresponds to an element in `BIO_WeaponModSimulator::Genes`.
	// Defaults to the size of the array if nothing hovered.
	private uint HoveredInvSlot;
	BIO_WModMenu_DraggedGene DraggedGene;

	final override void Init(Menu parent)
	{
		super.Init(parent);

		Txt_Help_Pan = StringTable.Localize(
			"$BIO_MENU_WEAPMOD_HELP_PAN");
		Txt_Help_ModOrder = StringTable.Localize(
			"$BIO_MENU_WEAPMOD_HELP_MODORDER");
		Txt_Help_Hotkeys = StringTable.Localize(
			"$BIO_MENU_WEAPMOD_HELP_HOTKEYS");
		Txt_Unmutated = StringTable.Localize(
			"$BIO_MENU_WEAPMOD_UNMUTATED");
		Txt_Mutagen = StringTable.Localize(
			"$BIO_MENU_WEAPMOD_MUTAGEN");

		// Acquire graphical resources
		Tex_Node = TexMan.CheckForTexture(
			"graphics/wmg_node.png", TexMan.TYPE_ANY);
		Tex_NodeRing = TexMan.CheckForTexture(
			"graphics/wmg_nodering.png", TexMan.TYPE_ANY);
		Tex_InvSlot = TexMan.CheckForTexture(
			"graphics/inv_slot.png", TexMan.TYPE_ANY);
		Tex_Padlock = TexMan.CheckForTexture(
			"graphics/padlock.png", TexMan.TYPE_ANY);

		Size = (VIRT_W, VIRT_H);
		CurrentWeap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon).AsConst();

		if (CurrentWeap.ModGraph != null)
			BIO_EventHandler.WeapModSim_Start();
	}

	final override void Ticker()
	{
		if ((GameState != GS_LEVEL) || (Players[ConsolePlayer].Health <= 0))
		{
			Close();
			return;
		}

		if (CurrentWeap.ModGraph != null && Simulator == null)
		{
			Simulator = BIO_WeaponModSimulator.Get(
				BIO_Weapon(Players[ConsolePlayer].ReadyWeapon),
				fallible: true
			);

			if (Simulator == null)
				return;

			for (uint i = 0; i < Simulator.Nodes.Size(); i++)
				NodeDrawState.Push(new('BIO_WModMenu_Node'));

			UpdateNodeDrawState();
			UpdateInvDrawState();
		}
	}
}

// Drawer and its helpers.
extend class BIO_WeaponModMenu
{
	final override void Drawer()
	{
		super.Drawer(); // Draw the back button

		if (CurrentWeap.ModGraph == null)
		{
			let lines = SmallFont.BreakLines(Txt_Unmutated, int(VIRT_W * 0.3));

			for (uint i = 0; i < lines.Count(); i++)
			{
				let htOffs = SmallFont.GetHeight() * i;

				Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
					VIRT_W * 0.5 - (lines.StringWidth(i) / 2),
					(VIRT_H * 0.5 - (SmallFont.GetHeight() / 2)) + htOffs,
					lines.StringAt(i), DTA_KEEPRATIO, true,
					DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
				);
			}

			return;
		}
		else
		{
			// Waiting for the playsim to finish constructing the simulator
			if (Simulator == null)
				return;
		}

		// Node connections

		Array<uint> iConnsDrawn, oConnsDrawn;

		for (uint i = 0; i < Simulator.Nodes.Size(); i++)
		{
			let node = Simulator.Nodes[i];

			for (uint j = 0; j < node.Basis.Neighbors.Size(); j++)
			{
				let o = node.Basis.Neighbors[j];
				let other = Simulator.Nodes[o];

				if (i == o)
					continue;

				bool alreadyDrawn = false;

				for (uint k = 0; k < iConnsDrawn.Size(); k++)
					if (iConnsDrawn[k] == o && iConnsDrawn[k] == i)
					{
						alreadyDrawn = true;	
						break;
					}

				if (alreadyDrawn)
					continue;

				DrawNodeConnection(
					NodeDrawState[i].ScreenPos,
					NodeDrawState[o].ScreenPos,
					node.IsActive() && other.IsActive()
				);

				iConnsDrawn.Push(i);
				oConnsDrawn.Push(o);
			}
		}

		// Home node; frame, icon, order number

		Screen.DrawTexture(Tex_Node, false,
			NodeDrawState[0].DrawPos.X, NodeDrawState[0].DrawPos.Y,
			DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
			DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true
		);
		Screen.DrawTexture(CurrentWeap.Icon, false,
			NodeDrawState[0].DrawPos.X, NodeDrawState[0].DrawPos.Y,
			DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
			DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true
		);

		// Non-home nodes; frames, icons, order numbers

		for (uint i = 1; i < Simulator.Nodes.Size(); i++)
		{
			if (Simulator.Nodes[i].IsMorph() &&
				!Simulator.Nodes[i].MorphRecipe.Eligible(Simulator.AsConst()))
			{
				continue;
			}

			let overlay = COLOR_NONE;

			if (HoveredNode == i)
			{
				if (Simulator.Nodes[i].Valid)
					overlay = COLOR_HOVERED;
				else
					overlay = COLOR_HOVEREDINVALID;
			}
			else
			{
				if (!Simulator.Nodes[i].Valid)
					overlay = COLOR_INVALID;
			}

			Screen.DrawTexture(Tex_Node, false,
				NodeDrawState[i].DrawPos.X, NodeDrawState[i].DrawPos.Y,
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_COLOROVERLAY, overlay
			);

			if (Simulator.Nodes[i].IsMorph())
			{
				Screen.DrawTexture(Tex_NodeRing, false,
					NodeDrawState[i].DrawPos.X, NodeDrawState[i].DrawPos.Y,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
					DTA_ALPHA, 1.0 + (Sin((MenuTime() << 16 / 4) * 0.75))
				);
			}

			let icon = Simulator.Nodes[i].GetIcon();

			if (!icon.IsNull())
			{
				bool isDragged = DraggedGene != null && DraggedGene.IsFromNode(i);

				Screen.DrawTexture(icon, false,
					NodeDrawState[i].DrawPos.X, NodeDrawState[i].DrawPos.Y,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
					DTA_ALPHA, isDragged ? 0.33 : 1.0
				);
			}

			if (Simulator.Nodes[i].IsMorph())
				continue;

			Screen.DrawText(SmallFont, Font.CR_WHITE,
				NodeDrawState[i].DrawPos.X + (VIRT_W * 0.03),
				NodeDrawState[i].DrawPos.Y + (VIRT_H * 0.04),
				String.Format("%d", Simulator.Nodes[i].Basis.UUID),
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_KEEPRATIO, true
			);

			if (Simulator.Nodes[i].Repeating())
			{
				Screen.DrawText(SmallFont, Font.CR_GREEN,
					NodeDrawState[i].DrawPos.X + (VIRT_W * 0.03),
					NodeDrawState[i].DrawPos.Y + (VIRT_H * 0.01),
					String.Format("x%d", Simulator.Nodes[i].Multiplier),
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_KEEPRATIO, true
				);
			}

			if (Simulator.Nodes[i].Basis.IsLocked())
			{
				Screen.DrawTexture(Tex_Padlock, false,
					NodeDrawState[i].DrawPos.X + (VIRT_W * 0.035),
					NodeDrawState[i].DrawPos.Y - (VIRT_H * 0.07),
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true
				);
			}
		}

		DrawGeneInventory();
		DrawHelpText();
		DrawMutagenInfo();

		bool noDupTooltip = false;

		if (DraggedGene != null)
		{
			Screen.DrawTexture(DraggedGeneIcon(), false,
				MousePos.X / CleanXFac, MousePos.Y / CleanYFac,
				DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
				DTA_KEEPRATIO, true, DTA_CENTEROFFSET, true
			);

			bool dupAllowed = Simulator.TestDuplicateAllowance(
				DraggedGene.GetOrigin(),
				DraggedGene.OriginIsNode()
			);

			if (ValidHoveredNode() && !dupAllowed)
			{
				noDupTooltip = true;

				Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
					(MousePos.X / CleanXFac) + 8, (MousePos.Y / CleanYFac) + 8,
					StringTable.Localize("$BIO_MENU_WEAPMOD_NODUP"),
					DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
					DTA_KEEPRATIO, true
				);
			}
		}

		if (!noDupTooltip)
		{
			if (ValidHoveredNode() && Simulator.Nodes[HoveredNode].HasTooltip())
			{
				DrawTooltip(Simulator.GetNodeTooltip(HoveredNode));
			}
			else if (ValidHoveredInvSlot() &&
				Simulator.Genes[HoveredInvSlot] != null)
			{
				DrawTooltip(Simulator.GetGeneSlotTooltip(HoveredInvSlot));
			}
		}
	}

	private void DrawNodeConnection(Vector2 pos1, Vector2 pos2, bool bothActive) const
	{
		if (!bothActive)
		{
			Screen.DrawThickLine(
				pos1.X, pos1.Y, pos2.X, pos2.Y,
				Size.X / (Size.X * 0.25), COLOR_HOVERED
			);
			return;
		}

		let count = 16;
		let diff = (pos2 - pos1) / double(count);
		bool vert = diff.X == 0.0;
		Vector2 drawPos = (pos1.X, pos1.Y);
		let len = vert ? Log(Size.X) * 0.4 : Log(Size.Y) * 0.4;
		let thickness = vert ? Log(Size.X) : Log(Size.Y);

		// TODO:
		// - Make this look better at lower zoom levels
		// - Learn maths and create a nicer wave
		// - Fancier coloration?

		for (uint i = 0; i < count; i++)
		{
			let l = 5.0 * len * Sin((i + MenuTime()) * 6);

			if (vert)
			{
				Screen.DrawThickLine(
					drawPos.X - l, drawPos.Y,
					drawPos.X + l, drawPos.Y,
					thickness, COLOR_CONN
				);

				drawPos.Y += diff.Y;
			}
			else
			{
				Screen.DrawThickLine(
					drawPos.X, drawPos.Y - l,
					drawPos.X, drawPos.Y + l,
					thickness, COLOR_CONN
				);

				drawPos.X += diff.X;
			}
		}
	}

	private void DrawGeneInventory() const
	{
		let genePosX = INVSLOT_POS_X_START;

		for (uint i = 0; i < Simulator.Genes.Size(); i++)
		{
			let drawPos = (InvSlotDrawPosition(i), INVSLOT_POS_Y);

			Screen.DrawTexture(Tex_InvSlot, false,
				drawPos.X, drawPos.Y,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true, DTA_ALPHA, 0.5,
				DTA_COLOROVERLAY, HoveredInvSlot == i ? COLOR_HOVERED : COLOR_NONE
			);

			if (Simulator.Genes[i] == null)
				continue;

			let defs = GetDefaultByType(Simulator.Genes[i].GetType());

			bool isDragged = DraggedGene != null && DraggedGene.IsFromInvSlot(i);

			Screen.DrawTexture(defs.Icon, false,
				drawPos.X, drawPos.Y,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_ALPHA, isDragged ? 0.33 : 1.0
			);
		}
	}

	private void DrawHelpText() const
	{
		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			0.0 + (VIRT_W * 0.05),
			VIRT_H * 0.025,
			Txt_Help_Pan,
			DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
		);
		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			0.0 + (VIRT_W * 0.05),
			VIRT_H * 0.05,
			Txt_Help_ModOrder,
			DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
		);
		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			0.0 + (VIRT_W * 0.05),
			VIRT_H * 0.075,
			Txt_Help_Hotkeys,
			DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
		);
	}

	private void DrawMutagenInfo() const
	{
		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			0.0 + (VIRT_W * 0.05),
			VIRT_H * 0.125,
			String.Format(
				Txt_Mutagen,
				Players[ConsolePlayer].MO.CountInv('BIO_Muta_General'),
				Simulator.CommitCost()
			),
			DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
		);
	}

	private void DrawTooltip(string tooltip)
	{
		let lines = SmallFont.BreakLines(tooltip, 224);
		string text = "";
		int maxWidth = 0;

		for (uint i = 0; i < lines.Count(); i++)
		{
			text.AppendFormat("%s\n", lines.StringAt(i));
			maxWidth = Max(maxWidth, lines.StringWidth(i));
		}

		text.DeleteLastCharacter();

		let dpx = (MousePos.X / CleanXFac) + 8;
		let twac = maxWidth * CleanXFac;

		if ((Screen.GetWidth() - (dpx * CleanXFac)) < twac)
		{
			dpx -= maxWidth;
			dpx -= 8;
		}

		let dpy = (MousePos.Y / CleanYFac) + 8;
		let height = SmallFont.GetHeight() * (lines.Count() + 1);
		let thac = height * CleanYFac;

		if ((Screen.GetHeight() - (dpy * CleanYFac)) < thac)
		{
			dpy -= height;
			dpy -= 8;
		}

		Screen.DrawText(
			SmallFont, Font.CR_UNTRANSLATED,
			dpx, dpy,
			text,
			DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
			DTA_KEEPRATIO, true
		);
	}
}

// Event handling.
extend class BIO_WeaponModMenu
{
	// Closing the menu cleans up after any un-committed changes.
	final override bool MenuEvent(int mKey, bool fromController)
	{
		if (super.MenuEvent(mKey, fromController))
		{
			if (Simulator != null)
				BIO_EventHandler.WeapModSim_Stop();

			return true;
		}

		return false;
	}

	// Handles panning.
	final override bool MouseEvent(int type, int mX, int mY)
	{
		switch (type)
		{
		case MOUSE_Move:
			if (Pan)
			{
				ViewPosition.X = Clamp(ViewPosition.X + (LMP.X - mX),
					-(VIRT_W * 2), VIRT_W * 2);
				ViewPosition.Y = Clamp(ViewPosition.Y + (LMP.Y - mY),
					-(VIRT_H * 2), VIRT_H * 3);
			}
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
			LMP.X = MousePos.X;
			LMP.Y = MousePos.Y;
			MousePos.X = event.MouseX;
			MousePos.Y = event.MouseY;
			UpdateNodeDrawState();
			UpdateInvDrawState();
			break;
		case UIEvent.Type_LButtonDown:
			res = MouseEventBack(MOUSE_Click, event.MouseX, y);
			// Make the menu's mouse handler believe that the
			// current coordinate is outside the valid range
			if (res) 
				y = -1;

			res |= MouseEvent(MOUSE_Click, event.MouseX, y);

			if (res)
				SetCapture(true);

			OnLeftMouseButtonDown();
			break;
		case UIEvent.Type_LButtonUp:
			if (mMouseCapture)
			{
				SetCapture(false);
				res = MouseEventBack(MOUSE_Release, event.MouseX, y);
				if (res) y = -1;	
				res |= MouseEvent(MOUSE_Release, event.MouseX, y);
			}

			OnLeftMouseButtonUp();
			break;
		case UIEvent.Type_WheelDown:
			Size.X = Min(Size.X + 32.0, VIRT_W * 3.0);
			Size.Y = Min(Size.Y + 18.0, VIRT_H * 3.0);
			UpdateNodeDrawState();
			break;
		case UIEvent.Type_WheelUp:
			Size.X = Max(Size.X - 32.0, VIRT_W);
			Size.Y = Max(Size.Y - 18.0, VIRT_H);
			UpdateNodeDrawState();
			break;
		case UIEvent.Type_MButtonDown:
			SetCapture(true);
			Pan = true;
			break;
		case UIEvent.Type_MButtonUp:
			SetCapture(false);
			Pan = false;
			break;
		case UIEvent.Type_RButtonUp:
			OnRightClick();
			break;
		case UIEvent.Type_KeyUp:
			if (event.KeyString ~== "e")
				TryCommitChanges();
			else if (event.KeyString ~== "r")
				TryRevertChanges();

			break;
		default: break;
		}

		return false;
	}
}

// Introspective helpers.
extend class BIO_WeaponModMenu
{
	private textureID DraggedGeneIcon()
	{
		textureID ret;
		ret.SetNull();

		if (DraggedGene != null)
		{
			let gene_t = Simulator.GetGeneType(
				DraggedGene.GetOrigin(),
				DraggedGene.OriginIsNode()
			);
			ret = GetDefaultByType(gene_t).Icon;
		}

		return ret;
	}

	private bool ValidHoveredNode() const
	{
		return HoveredNode < NodeDrawState.Size();
	}

	private bool ValidHoveredInvSlot() const
	{
		return HoveredInvSlot < Simulator.Genes.Size();
	}
}

// Helpers for operating the menu.
extend class BIO_WeaponModMenu
{
	// Called whenever the mouse moves or the zoom level changes.
	// Updates the data used to inform `Drawer()` as to how to render nodes,
	// and determines which node is currently hovered, if any.
	private void UpdateNodeDrawState()
	{
		if (Simulator == null)
			return;

		HoveredNode = NodeDrawState.Size();

		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());

		Vector2 nodeSz;
		[nodeSz.X, nodeSz.Y] = TexMan.GetSize(Tex_Node);

		for (uint i = 0; i < Simulator.Nodes.Size(); i++)
		{
			let node = Simulator.Nodes[i];

			NodeDrawState[i].DrawPos = (
				(Size.X / 2) + (node.Basis.PosX * 72) + ViewPosition.X,
				(Size.Y / 2) + (node.Basis.PosY * 72) + ViewPosition.Y
			);

			NodeDrawState[i].ScreenPos = Screen.VirtualToRealCoords( 
				NodeDrawState[i].DrawPos, scrSz, Size, handleAspect: false);

			Vector2
				realTL = Screen.VirtualToRealCoords(
					(NodeDrawState[i].DrawPos.X - (nodeSz.X * 0.5),
					NodeDrawState[i].DrawPos.Y - (nodeSz.Y * 0.5)),
					scrSz, Size, handleAspect: false
				),
				realBR = Screen.VirtualToRealCoords(
					(NodeDrawState[i].DrawPos.X + (nodeSz.X * 0.5),
					NodeDrawState[i].DrawPos.Y + (nodeSz.Y * 0.5)),
					scrSz, Size, handleAspect: false
				);

			if (Simulator.Nodes[i].IsMorph() &&
				!Simulator.Nodes[i].MorphRecipe.Eligible(Simulator.AsConst()))
			{
				continue;
			}

			if (MousePos.X > realTL.X && MousePos.X < realBR.X &&
				MousePos.Y > realTL.Y && MousePos.Y < realBR.Y &&
				!Pan && i != 0) // Can't hover the home node
			{
				HoveredNode = i;
			}
		}
	}

	private double InvSlotDrawPosition(uint slot) const
	{
		let ret = INVSLOT_POS_X_START;
		let interval = INVSLOT_POS_X_END - INVSLOT_POS_X_START;
		interval /= (Simulator.Genes.Size() - 1);
		ret += (slot * interval);
		return ret;
	}

	// Called whenever the mouse moves.
	// Determines which inventory slot is currently hovered.
	private void UpdateInvDrawState()
	{
		if (Simulator == null)
			return;

		HoveredInvSlot = Simulator.Genes.Size();

		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());
		Vector2 nodeSz;
		[nodeSz.X, nodeSz.Y] = TexMan.GetSize(Tex_Node);

		for (uint i = 0; i < Simulator.Genes.Size(); i++)
		{
			let drawPos = (InvSlotDrawPosition(i), INVSLOT_POS_Y);

			Vector2
				realTL = Screen.VirtualToRealCoords(
					(drawPos.X - (nodeSz.X * 0.5),
					drawPos.Y - (nodeSz.Y * 0.5)),
					scrSz, (VIRT_W, VIRT_H), handleAspect: false
				),
				realBR = Screen.VirtualToRealCoords(
					(drawPos.X + (nodeSz.X * 0.5),
					drawPos.Y + (nodeSz.Y * 0.5)),
					scrSz, (VIRT_W, VIRT_H), handleAspect: false
				);

			if (MousePos.X > realTL.X && MousePos.X < realBR.X &&
				MousePos.Y > realTL.Y && MousePos.Y < realBR.Y)
			{
				HoveredInvSlot = i;
				break;
			}
		}
	}

	// Try to attach a gene to the mouse to be dragged.
	private void OnLeftMouseButtonDown()
	{
		if (CurrentWeap.ModGraph == null)
			return;

		if (DraggedGene != null)
			return;

		if (ValidHoveredInvSlot() && Simulator.Genes[HoveredInvSlot] != null)
		{
			// Inventory slots take precedence, being drawn above the nodes
			DraggedGene = new('BIO_WModMenu_DraggedGene');
			DraggedGene.Origin = BIO_WModMenu_DraggedGene.ORIGIN_INVSLOT;
			DraggedGene.Node = Simulator.Nodes.Size();
			DraggedGene.InvSlot = HoveredInvSlot;
		}
		else if (ValidHoveredNode() && Simulator.Nodes[HoveredNode].IsOccupied())
		{
			if (Simulator.Nodes[HoveredNode].Basis.IsLocked())
				return;

			DraggedGene = new('BIO_WModMenu_DraggedGene');
			DraggedGene.Origin = BIO_WModMenu_DraggedGene.ORIGIN_NODE;
			DraggedGene.Node = HoveredNode;
			DraggedGene.InvSlot = Simulator.Genes.Size();
		}
	}

	// If dragging a gene, release it. This may be from an inventory slot to a
	// node, from one node to another node, or from a node to an inventory slot.
	private void OnLeftMouseButtonUp()
	{
		if (CurrentWeap.ModGraph == null)
			return;

		if (DraggedGene != null)
		{
			ReleaseDraggedGene();
			return;
		}

		if (ValidHoveredNode() && Simulator.Nodes[HoveredNode].IsMorph())
			TryRunWeaponMorph(HoveredNode);
	}

	private void ReleaseDraggedGene()
	{
		if (ValidHoveredNode() && !Simulator.Nodes[HoveredNode].Basis.IsLocked())
		{
			if (DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_INVSLOT)
				TryInsertGeneFromInventory(HoveredNode, DraggedGene.InvSlot);
			else if (DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_NODE)
				TryMoveGeneBetweenNodes(DraggedGene.Node, HoveredNode);
		}
		else if (ValidHoveredInvSlot())
		{
			if (DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_INVSLOT)
				TryMoveGeneBetweenInventorySlots(DraggedGene.InvSlot, HoveredInvSlot);
			else if (DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_NODE)
				TryExtractGeneFromNode(DraggedGene.Node, HoveredInvSlot);
		}

		// If neither of the above are valid, put the gene back where it started
		DraggedGene = null;
	}

	// Right-clicking a node pops that gene out of it and returns it to the first
	// open slot in the inventory.
	private void OnRightClick()
	{
		if (CurrentWeap.ModGraph == null)
			return;

		if (!ValidHoveredNode())
			return;

		if (Simulator.InventoryFull())
			return;

		TryExtractGeneFromNode(HoveredNode, Simulator.FirstOpenInventorySlot());
	}
}

// Helpers for operating the modification simulator.
extend class BIO_WeaponModMenu
{
	private void TryInsertGeneFromInventory(uint node, uint slot)
	{
		if (Simulator.Genes[slot] == null || node == 0)
			return;

		if (!Simulator.NodeAccessible(node))
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_INSERTFAIL_INACCESSIBLE")
			);
			MenuSound("bio/ui/fail");
			return;
		}

		MenuSound("bio/ui/beep");

		if (Simulator.Nodes[node].IsOccupied())
			BIO_EventHandler.WeapModSim_SwapNodeAndSlot(node, slot);
		else
			BIO_EventHandler.WeapModSim_InsertGeneFromInventory(node, slot);

		BIO_EventHandler.WeapModSim_Run();
	}

	private void TryMoveGeneBetweenNodes(uint fromNode, uint toNode)
	{
		if (!Simulator.Nodes[fromNode].IsOccupied() ||
			fromNode == toNode || toNode == 0)
		{
			return;
		}

		if (!Simulator.NodeAccessible(toNode))
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_INSERTFAIL_INACCESSIBLE")
			);
			MenuSound("bio/ui/fail");
			return;
		}

		if (Simulator.MoveCausesDisconnection(fromNode, toNode))
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_EXTRACTFAIL_ORPHANNODES")
			);
			MenuSound("bio/ui/fail");
			return;
		}

		// `toNode` can be filled; this causes a swap
		MenuSound("bio/ui/beep");
		BIO_EventHandler.WeapModSim_MoveGeneBetweenNodes(fromNode, toNode);
		BIO_EventHandler.WeapModSim_Run();
	}
	
	private void TryMoveGeneBetweenInventorySlots(uint fromSlot, uint toSlot)
	{
		if (Simulator.Genes[fromSlot] == null ||
			Simulator.Genes[toSlot] != null ||
			fromSlot == toSlot)
		{
			return;
		}

		// `toSlot` can be filled; this causes a swap
		MenuSound("bio/ui/beep");
		BIO_EventHandler.WeapModSim_MoveGeneBetweenInventorySlots(fromSlot, toSlot);
		BIO_EventHandler.WeapModSim_Run();
	}

	private void TryExtractGeneFromNode(uint node, uint slot)
	{
		if (!Simulator.Nodes[node].IsOccupied())
			return;

		if (!Simulator.CanRemoveGeneFrom(node))
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_EXTRACTFAIL_ORPHANNODES")
			);
			MenuSound("bio/ui/fail");
			return;
		}

		MenuSound("bio/ui/beep");

		if (Simulator.Genes[slot] != null)
			BIO_EventHandler.WeapModSim_SwapNodeAndSlot(node, slot);
		else
			BIO_EventHandler.WeapModSim_ExtractGeneFromNode(node, slot);

		BIO_EventHandler.WeapModSim_Run();
	}

	// Send a network event which removes any applied genes from the player's
	// inventory, as well as consuming the requisite quantity of mutagen.
	private void TryCommitChanges()
	{
		let cost = Simulator.CommitCost();
		let mutaC = Players[ConsolePlayer].MO.CountInv('BIO_Muta_General');

		if (cost <= 0)
			return; // Nothing to commit

		if (mutaC < cost)
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_COMMITFAIL_MUTACOST")
			);
			MenuSound("bio/ui/fail");
			return;	
		}

		if (!Simulator.IsValid())
		{
			MenuSound("bio/ui/fail");
			return;			
		}

		BIO_EventHandler.WeapModSim_Commit();
		MenuSound("bio/mutation/general");
	}

	private void TryRevertChanges()
	{
		if (Simulator.AnyPendingGraphChanges())
			MenuSound("bio/ui/cancel");

		BIO_EventHandler.WeapModSim_Revert();
	}

	private void TryRunWeaponMorph(uint node) const
	{
		let mutaC = Players[ConsolePlayer].MO.CountInv('BIO_Muta_General');

		if (mutaC < Simulator.MorphCost(node))
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_MORPHFAIL_MUTACOST")
			);
			MenuSound("bio/ui/fail");
			return;
		}

		if (!Simulator.IsValid())
		{
			Console.Printf(
				StringTable.Localize("$BIO_MENU_WEAPMOD_MORPHFAIL_INVALID")
			);
			MenuSound("bio/ui/fail");
			return;
		}

		BIO_EventHandler.WeapModSim_Morph(node);
		MenuSound("bio/mutation/general");
		Close();
	}
}
