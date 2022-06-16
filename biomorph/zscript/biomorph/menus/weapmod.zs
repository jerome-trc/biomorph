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
}

// Class declaration, initialization, ticker.
class BIO_WeaponModMenu : GenericMenu
{
	const VIRT_W = 640.0; const VIRT_H = 360.0;

	// Note to self: color constructor takes A, R, G, B
	const COLOR_NONE = Color(0, 0, 0, 0);
	const COLOR_INVALID = Color(127, 224, 0, 0);
	const COLOR_HOVERED = Color(127, 127, 127, 127);
	const COLOR_HOVEREDINVALID = Color(127, 255, 127, 127);
	const COLOR_FULLCONN_OUTER = Color(127, 130, 239, 255);
	const COLOR_FULLCONN_INNER = Color(127, 65, 255, 240);

	private string Txt_Help_Pan, Txt_Help_ModOrder, Txt_Unmutated;
	private textureID Tex_Node;

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
		Txt_Unmutated = StringTable.Localize(
			"$BIO_MENU_WEAPMOD_UNMUTATED");

		// Acquire graphical resources
		Tex_Node = TexMan.CheckForTexture(
			"graphics/wmg_node.png", TexMan.TYPE_ANY);

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
			if (Simulator == null)
				return;
		}

		// Node connections
	
		for (uint i = 0; i < Simulator.Nodes.Size(); i++)
		{
			let node = Simulator.Nodes[i];

			for (uint j = 0; j < node.Basis.Neighbors.Size(); j++)
			{
				let o = node.Basis.Neighbors[j];
				let other = Simulator.Nodes[o];

				if (i == o)
					continue;

				if (node.IsActive() && other.IsActive())
				{
					Screen.DrawThickLine(
						NodeDrawState[i].ScreenPos.X, NodeDrawState[i].ScreenPos.Y,
						NodeDrawState[o].ScreenPos.X, NodeDrawState[o].ScreenPos.Y,
						Size.X / (Size.X * 0.15), COLOR_FULLCONN_OUTER
					);
					Screen.DrawThickLine(
						NodeDrawState[i].ScreenPos.X, NodeDrawState[i].ScreenPos.Y,
						NodeDrawState[o].ScreenPos.X, NodeDrawState[o].ScreenPos.Y,
						Size.X / (Size.X * 0.35), COLOR_FULLCONN_INNER
					);
				}
				else
				{
					Screen.DrawThickLine(
						NodeDrawState[i].ScreenPos.X, NodeDrawState[i].ScreenPos.Y,
						NodeDrawState[o].ScreenPos.X, NodeDrawState[o].ScreenPos.Y,
						Size.X / (Size.X * 0.25), COLOR_HOVERED
					);
				}
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
		Screen.DrawText(SmallFont, Font.CR_WHITE,
			NodeDrawState[0].DrawPos.X + (VIRT_W * 0.03),
			NodeDrawState[0].DrawPos.Y + (VIRT_H * 0.04),
			String.Format("%d", Simulator.Nodes[0].Basis.UUID + 1),
			DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
			DTA_KEEPRATIO, true
		);

		// Non-home nodes; frames, icons, order numbers

		for (uint i = 1; i < Simulator.Nodes.Size(); i++)
		{
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

			let gene_t = Simulator.Nodes[i].GetGeneType();

			if (gene_t != null)
			{
				Screen.DrawTexture(GetDefaultByType(gene_t).Icon, false,
					NodeDrawState[i].DrawPos.X, NodeDrawState[i].DrawPos.Y,
					DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
					DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true
				);
			}

			Screen.DrawText(SmallFont, Font.CR_WHITE,
				NodeDrawState[i].DrawPos.X + (VIRT_W * 0.03),
				NodeDrawState[i].DrawPos.Y + (VIRT_H * 0.04),
				String.Format("%d", Simulator.Nodes[i].Basis.UUID + 1),
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_KEEPRATIO, true
			);
		}

		DrawGeneInventory();

		bool noDupTooltip = false;

		if (DraggedGene != null)
		{
			Screen.DrawTexture(DraggedGeneIcon(), false,
				MousePos.X / CleanXFac, MousePos.Y / CleanYFac,
				DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
				DTA_KEEPRATIO, true, DTA_CENTEROFFSET, true
			);

			bool testNode = DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_NODE;
			uint origin = uint.MAX;

			if (testNode)
				origin = DraggedGene.Node;
			else
				origin = DraggedGene.InvSlot;

			if (ValidHoveredNode() && !Simulator.TestDuplicateAllowance(origin, testNode))
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
			if (ValidHoveredNode() &&
				Simulator.Nodes[HoveredNode].IsOccupied())
			{
				DrawModifierTooltip(HoveredNode);
			}
			else if (ValidHoveredInvSlot() &&
				Simulator.Genes[HoveredInvSlot] != null)
			{
				DrawInvSlotTooltip(HoveredInvSlot);
			}
		}
	}

	private void DrawGeneInventory() const
	{
		let pawn = BIO_Player(Players[ConsolePlayer].MO);
		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());
		Vector2 nodeSz;
		[nodeSz.X, nodeSz.Y] = TexMan.GetSize(Tex_Node);
		let genePosX = VIRT_W * 0.1, genePosY = VIRT_H * 0.2;
		uint geneC = 0;

		for (uint i = 0; i < Simulator.Genes.Size(); i++)
		{
			let drawPos = (genePosX, genePosY);

			if (++geneC == (pawn.MaxGenesHeld / 2))
			{
				genePosY = VIRT_H * 0.2;
				genePosX += VIRT_W * 0.1;
			}
			else
			{
				genePosY += VIRT_H * 0.15;
			}

			Screen.DrawTexture(Tex_Node, false,
				drawPos.X, drawPos.Y,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true, DTA_ALPHA, 0.5,
				DTA_COLOROVERLAY, HoveredInvSlot == i ? COLOR_HOVERED : COLOR_NONE
			);

			if (Simulator.Genes[i] == null)
				continue;

			let defs = GetDefaultByType(Simulator.Genes[i].GetType());

			bool isDragged =
				DraggedGene != null &&
				DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_INVSLOT &&
				DraggedGene.InvSlot == i;

			Screen.DrawTexture(defs.Icon, false,
				drawPos.X, drawPos.Y,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_ALPHA, isDragged ? 0.33 : 1.0
			);
		}
	}

	private void DrawModifierTooltip(uint node) const
	{
		let mod = Simulator.Nodes[node].GetModifier();
		Array<string> desc;
		mod.Description(desc, CurrentWeap);

		string tt = String.Format(
			"\c[White]%s\n",
			StringTable.Localize(mod.GetTag())
		);

		if (!Simulator.Nodes[node].Valid)
		{
			bool _ = false;
			string reason = "";
			[_, reason] = Simulator.Nodes[node].GetModifier()
				.Compatible(CurrentWeap);

			tt.AppendFormat(
				StringTable.Localize("$BIO_WMOD_INCOMPAT_TEMPLATE"),
				StringTable.Localize(reason)
			);
		}
		else
		{
			for (uint i = 0; i < desc.Size(); i++)
				tt.AppendFormat("\n%s", StringTable.Localize(desc[i]));
		}

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			(MousePos.X / CleanXFac) + 8, (MousePos.Y / CleanYFac) + 8, tt,
			DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
			DTA_KEEPRATIO, true
		);
	}

	private void DrawInvSlotTooltip(uint slot) const
	{
		let gene = Simulator.Genes[slot];
		let defs = GetDefaultByType(gene.GetType());
		let mod = gene.Modifier;

		Array<string> summary;
		mod.Summary(summary);

		string tt = String.Format(
			"\c[White]%s\n",
			StringTable.Localize(defs.GetTag())
		);

		for (uint i = 0; i < summary.Size(); i++)
			tt.AppendFormat("\n%s", StringTable.Localize(summary[i]));

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			(MousePos.X / CleanXFac) + 8, (MousePos.Y / CleanYFac) + 8, tt,
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
			bool fromNode = DraggedGene.Origin == BIO_WModMenu_DraggedGene.ORIGIN_NODE;
			uint origin = uint.MAX;

			if (fromNode)
				origin = DraggedGene.Node;
			else
				origin = DraggedGene.InvSlot;

			let gene_t = Simulator.GetGeneType(origin, fromNode);
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

			if (MousePos.X > realTL.X && MousePos.X < realBR.X &&
				MousePos.Y > realTL.Y && MousePos.Y < realBR.Y &&
				!Pan && i != 0) // Can't hover the home node
			{
				HoveredNode = i;
			}
		}
	}

	// Called whenever the mouse moves.
	// Determines which inventory slot is currently hovered.
	private void UpdateInvDrawState()
	{
		if (Simulator == null)
			return;

		HoveredInvSlot = Simulator.Genes.Size();

		let pawn = BIO_Player(Players[ConsolePlayer].MO);
		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());
		Vector2 nodeSz;
		[nodeSz.X, nodeSz.Y] = TexMan.GetSize(Tex_Node);
		let genePosX = VIRT_W * 0.1, genePosY = VIRT_H * 0.2;
		uint geneC = 0;

		for (uint i = 0; i < Simulator.Genes.Size(); i++)
		{
			let drawPos = (genePosX, genePosY);

			if (++geneC == (pawn.MaxGenesHeld / 2))
			{
				genePosY = VIRT_H * 0.2;
				genePosX += VIRT_W * 0.1;
			}
			else
			{
				genePosY += VIRT_H * 0.15;
			}

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

	// If dragging a gene, release it. This may be from an inventory slot to a
	// node, from one node to another node, or from a node to an inventory slot.
	// Genes can't be dragged out of inventory slots if the weapon is unmutated.
	private void OnLeftMouseButtonDown()
	{
		if (CurrentWeap.ModGraph == null)
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
			DraggedGene = new('BIO_WModMenu_DraggedGene');
			DraggedGene.Origin = BIO_WModMenu_DraggedGene.ORIGIN_NODE;
			DraggedGene.Node = HoveredNode;
			DraggedGene.InvSlot = Simulator.Genes.Size();
		}
	}

	private void OnLeftMouseButtonUp()
	{
		if (CurrentWeap.ModGraph == null || DraggedGene == null)
			return;

		if (ValidHoveredNode())
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

	// Right-clicking a node pops that gene out of it and returns it to the inventory.
	private void OnRightClick()
	{
		if (CurrentWeap.ModGraph == null)
			return;
	}
}

// Helpers for operating the modification simulator.
extend class BIO_WeaponModMenu
{
	private void TryInsertGeneFromInventory(uint node, uint slot)
	{
		if (Simulator.Genes[slot] == null)
			return;

		if (!Simulator.NodeAccessible(node))
			return;

		MenuSound("bio/ui/beep");
		BIO_EventHandler.WeapModSim_InsertGeneFromInventory(node, slot);
		BIO_EventHandler.WeapModSim_Run();
	}

	private void TryMoveGeneBetweenNodes(uint fromNode, uint toNode)
	{
		if (Simulator.Nodes[fromNode].Gene == null)
			return;

		if (fromNode == toNode)
			return;

		if (!Simulator.NodeAccessible(toNode))
			return;

		// `toNode` can be filled; this causes a swap
		MenuSound("bio/ui/beep");
		BIO_EventHandler.WeapModSim_MoveGeneBetweenNodes(fromNode, toNode);
		BIO_EventHandler.WeapModSim_Run();
	}
	
	private void TryMoveGeneBetweenInventorySlots(uint fromSlot, uint toSlot)
	{
		if (Simulator.Genes[fromSlot] == null)
			return;

		if (fromSlot == toSlot)
			return;

		// `toSlot` can be filled; this causes a swap
		MenuSound("bio/ui/beep");
		BIO_EventHandler.WeapModSim_MoveGeneBetweenInventorySlots(fromSlot, toSlot);
		BIO_EventHandler.WeapModSim_Run();
	}

	private void TryExtractGeneFromNode(uint node, uint slot)
	{
		if (Simulator.Nodes[node].Gene == null)
			return;

		MenuSound("bio/ui/beep");
		BIO_EventHandler.WeapModSim_ExtractGeneFromNode(node, slot);
		BIO_EventHandler.WeapModSim_Run();
	}

	// Send a network event which removes any applied genes from the player's
	// inventory, as well as consuming the requisite quantity of mutagen.
	// TODO: Failure beep, maybe messaging too.
	private void TryCommitChanges()
	{
		let mutaC = Players[ConsolePlayer].MO.CountInv('BIO_Muta_General');

		if (mutaC < CurrentWeap.ModCost)
			return;

		if (!Simulator.IsValid())
			return;

		BIO_EventHandler.WeapModSim_Commit();
		MenuSound("bio/mutation/general");
	}
}
