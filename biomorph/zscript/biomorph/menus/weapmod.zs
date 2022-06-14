class BIO_WeaponModMenuNode
{
	Vector2 DrawPos, ScreenPos;
}

class BIO_WeaponModMenuInv
{
	Vector2 DrawPos;
	BIO_Gene Gene;
}

class BIO_WeaponModChange
{
	uint Node;
	int GeneTID;
}

class BIO_WeaponModMenu : GenericMenu
{
	const VIRT_W = 640.0; const VIRT_H = 360.0;

	// Note to self: color constructor takes A, R, G, B
	const COLOR_HOVERED = Color(127, 127, 127, 127);
	const COLOR_FULLCONN_OUTER = Color(127, 130, 239, 255);
	const COLOR_FULLCONN_INNER = Color(127, 65, 255, 240);
	const COLOR_NONE = Color(0, 0, 0, 0);

	private string Txt_Help_Pan, Txt_Help_ModOrder, Txt_Unmutated;
	private textureID Tex_Node;

	private Array<BIO_WeaponModMenuNode> NodeDrawState;
	private Array<BIO_WeaponModMenuInv> InvDrawState;
	private Array<BIO_WeaponModChange> PendingChanges;
	private BIO_Weapon CurrentWeap;

	private bool Pan;
	private Vector2 Size; // Used as virtual width/height to provide zoom.
	private Vector2 ViewPosition; // Where on the whole graph is the user looking?
	private Vector2 MousePos, LMP; // Last mouse position, used for panning.

	// Defaults to `NodeDrawState.Size()` if nothing hovered;
	// corresponds to a WMG node's UUID.
	private uint HoveredNode;
	private BIO_Gene DraggedGene;

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
		CurrentWeap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);

		RegenerateInventoryDrawState();

		if (CurrentWeap.ModGraph != null)
		{
			for (uint i = 0; i < CurrentWeap.ModGraph.Nodes.Size(); i++)
				NodeDrawState.Push(new('BIO_WeaponModMenuNode'));

			UpdateNodeDrawState();
		}
	}

	final override void Ticker()
	{
		if ((GameState != GS_LEVEL) || (Players[ConsolePlayer].Health <= 0))
		{
			Close();
			return;
		}
	}

	final override void Drawer()
	{
		super.Drawer(); // Draw the back button

		if (CurrentWeap.ModGraph == null)
		{
			Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
				VIRT_W * 0.5 - (SmallFont.StringWidth(Txt_Unmutated) / 2),
				VIRT_H * 0.5 - (SmallFont.GetHeight() / 2),
				Txt_Unmutated, DTA_KEEPRATIO, true,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
			);
			DrawGeneInventory();
			return;
		}

		let graph = CurrentWeap.ModGraph.AsConst();

		// Node connections
	
		for (uint i = 0; i < graph.Nodes.Size(); i++)
		{
			let node = graph.Nodes[i];

			for (uint j = 0; j < node.Neighbors.Size(); j++)
			{
				let o = node.Neighbors[j];
				let other = graph.Nodes[o];

				if (i == o)
					continue;

				if (node.Active() && other.Active())
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
			String.Format("%d", graph.Nodes[0].UUID + 1),
			DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
			DTA_KEEPRATIO, true
		);

		// Non-home nodes; frames, icons, order numbers

		for (uint i = 1; i < graph.Nodes.Size(); i++)
		{
			Screen.DrawTexture(Tex_Node, false,
				NodeDrawState[i].DrawPos.X, NodeDrawState[i].DrawPos.Y,
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_COLOROVERLAY, HoveredNode == i ? COLOR_HOVERED : COLOR_NONE
			);
			
			let gene_t = graph.Nodes[i].GetGeneType();

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
				String.Format("%d", graph.Nodes[i].UUID + 1),
				DTA_VIRTUALWIDTHF, Size.X, DTA_VIRTUALHEIGHTF, Size.Y,
				DTA_KEEPRATIO, true
			);
		}

		// Help text

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(Txt_Help_Pan) / 2),
			VIRT_H * 0.025, Txt_Help_Pan, DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
		);
		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			VIRT_W * 0.5 - (SmallFont.StringWidth(Txt_Help_ModOrder) / 2),
			VIRT_H * 0.05, Txt_Help_ModOrder, DTA_KEEPRATIO, true,
			DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H
		);

		DrawGeneInventory();

		if (DraggedGene != null)
		{
			Screen.DrawTexture(DraggedGene.Icon, false,
				MousePos.X / CleanXFac, MousePos.Y / CleanYFac,
				DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
				DTA_KEEPRATIO, true, DTA_CENTEROFFSET, true
			);
		}

		if (!ValidHoveredNode())
			return;

		// Tooltip

		let mod = graph.Nodes[HoveredNode].GetModifier();

		if (mod == null)
			return;

		string tt = String.Format(
			"\c[White]",
			StringTable.Localize(mod.GetTag())
		);

		Screen.DrawText(SmallFont, Font.CR_UNTRANSLATED,
			(MousePos.X / CleanXFac) + 8, (MousePos.Y / CleanYFac) + 8, tt,
			DTA_VIRTUALWIDTHF, CleanWidth, DTA_VIRTUALHEIGHTF, CleanHeight,
			DTA_KEEPRATIO, true
		);
	}

	private void DrawGeneInventory()
	{
		for (uint i = 0; i < InvDrawState.Size(); i++)
		{
			let slot = InvDrawState[i];

			if (slot.Gene == null)
			{
				RegenerateInventoryDrawState();
				break;
			}

			bool faded =
				slot.Gene.PendingApplication() ||
				slot.Gene == DraggedGene;

			Screen.DrawTexture(Tex_Node, false,
				slot.DrawPos.X, slot.DrawPos.Y,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_COLOROVERLAY, InvSlotIsHovered(i) ? COLOR_HOVERED : COLOR_NONE
			);
			Screen.DrawTexture(slot.Gene.Icon, false,
				slot.DrawPos.X, slot.DrawPos.Y,
				DTA_VIRTUALWIDTHF, VIRT_W, DTA_VIRTUALHEIGHTF, VIRT_H,
				DTA_CENTEROFFSET, true, DTA_KEEPRATIO, true,
				DTA_ALPHA, faded ? 0.3 : 1.0
			);
		}
	}

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

			if (CurrentWeap.ModGraph != null)
			{
				for (uint i = 0; i < InvDrawState.Size(); i++)
				{
					if (!InvSlotIsHovered(i))
						continue;

					if (InvDrawState[i].Gene.PendingApplication())
						continue;

					DraggedGene = InvDrawState[i].Gene;
				}
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

			if (DraggedGene != null)
				ReleaseDraggedGene();

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
			if (ValidHoveredNode())
			{
				for (uint i = 0; i < PendingChanges.Size(); i++)
				{
					if (PendingChanges[i].Node != HoveredNode)
						continue;

					if (TryRemoveGene(HoveredNode, PendingChanges[i].GeneTID))
						MenuSound("bio/ui/cancel");
					break;
				}
			}

			break;
		case UIEvent.Type_KeyUp:
			if (event.KeyString ~== "e")
				TryCommitChanges();

			break;
		default: break;
		}

		return false;
	}

	final override bool MenuEvent(int mKey, bool fromController)
	{
		if (super.MenuEvent(mKey, fromController))
		{
			OnMenuClose();
			return true;
		}

		return false;
	}

	// Extract the weapon modifier pointer out of the relevant gene and insert it
	// into the graph node, then reset the weapon and apply the graph again.
	private void AddGene(uint node, int geneTID)
	{
		let change = new('BIO_WeaponModChange');
		change.Node = node;
		change.GeneTID = geneTID;
		PendingChanges.Push(change);

		BIO_EventHandler.AddGene(node, geneTID);
		BIO_EventHandler.RefreshWeapon();
	}

	// Wraps `RemoveGene()`, but performs some preliminary checks first. A gene
	// can't be removed from a node with no gene in it, and a gene can't be removed
	// if any other nodes pending gene insertion would become disconnected first.
	// Returns `true` if gene removal succeeds.
	private bool TryRemoveGene(uint node, int geneTID)
	{
		let graph = CurrentWeap.ModGraph;

		if (!graph.Nodes[node].Active())
			return false;

		for (uint i = 1; i < graph.Nodes.Size(); i++)
		{
			if (!graph.Nodes[i].Active() || i == node)
				continue;

			if (!graph.NodeAccessible(i))
				return false;
		}

		RemoveGene(node, geneTID);
		return true;
	}

	// Extract the weapon modifier pointer out of the relevant graph node and
	// re-insert it into the gene, then reset the weapon and apply the graph again.
	private void RemoveGene(uint node, int geneTID)
	{
		for (uint i = 0; i < PendingChanges.Size(); i++)
		{
			if (PendingChanges[i].Node == node && 
				PendingChanges[i].GeneTID == geneTID)
			{
				PendingChanges.Delete(i);
				break;
			}
		}

		BIO_EventHandler.RemoveGene(node, geneTID);
		BIO_EventHandler.RefreshWeapon();
	}

	// Send a network event which removes any applied genes from the player's
	// inventory, as well as consuming the requisite quantity of mutagen.
	private void TryCommitChanges()
	{
		let mutaC = Players[ConsolePlayer].MO.CountInv('BIO_Muta_General');

		if (mutaC < CurrentWeap.ModCost)
		{
			// TODO: Failure beep, maybe a message
			return;
		}

		for (uint i = 0; i < PendingChanges.Size(); i++)
			BIO_EventHandler.CommitGene(PendingChanges[i].GeneTID);

		MenuSound("bio/mutation/general");
		PendingChanges.Clear();
	}

	// Undo un-committed changes.
	private void OnMenuClose()
	{
		for (uint i = 0; i < PendingChanges.Size(); i++)
		{
			BIO_EventHandler.RemoveGene(
				PendingChanges[i].Node,
				PendingChanges[i].GeneTID
			);
		}

		PendingChanges.Clear();
	}

	// Called whenever the mouse moves or the zoom level changes.
	private void UpdateNodeDrawState()
	{
		if (CurrentWeap.ModGraph == null)
			return;

		let graph = CurrentWeap.ModGraph.AsConst();
		HoveredNode = NodeDrawState.Size();

		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());

		Vector2 nodeSz;
		[nodeSz.X, nodeSz.Y] = TexMan.GetSize(Tex_Node);

		for (uint i = 0; i < graph.Nodes.Size(); i++)
		{
			let node = graph.Nodes[i];

			NodeDrawState[i].DrawPos = (
				(Size.X / 2) + (node.PosX * 72) + ViewPosition.X,
				(Size.Y / 2) + (node.PosY * 72) + ViewPosition.Y
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

	private void RegenerateInventoryDrawState()
	{
		InvDrawState.Clear();

		let pawn = BIO_Player(Players[ConsolePlayer].MO);

		let genePosX = VIRT_W * 0.1, genePosY = VIRT_H * 0.2;
		uint geneC = 0;

		for (Inventory i = pawn.Inv; i != null; i = i.Inv)
		{
			let gene = BIO_Gene(i);

			if (gene == null)
				continue;

			let slot = new('BIO_WeaponModMenuInv');
			slot.DrawPos = (genePosX, genePosY);
			slot.Gene = gene;
			InvDrawState.Push(slot);

			if (++geneC == (pawn.MaxGenesHeld / 2))
			{
				genePosY = VIRT_H * 0.2;
				genePosX += VIRT_W * 0.1;
			}
			else
			{
				genePosY += VIRT_H * 0.15;
			}
		}
	}

	private void ReleaseDraggedGene()
	{
		let gene = DraggedGene;
		DraggedGene = null;

		if (!ValidHoveredNode())
			return;

		let node = CurrentWeap.ModGraph.Nodes[HoveredNode];

		if (node.Active()) // Is the node already occupied?
			return;

		bool accessible = false;

		for (uint i = 0; i < node.Neighbors.Size(); i++)
		{
			let n = node.Neighbors[i];
			let neighbor = CurrentWeap.ModGraph.Nodes[n];

			if (neighbor.Active())
			{
				accessible = true;
				break;
			}
		}

		if (!accessible)
			return;

		// Would inserting this gene violate a multiple-allowance rule?
		if (!CurrentWeap.ModGraph.TestDuplicateAllowance(gene))
			return;

		MenuSound("bio/ui/beep");
		AddGene(HoveredNode, gene.TID);
	}

	private bool InvSlotIsHovered(uint i) const
	{
		let slot = InvDrawState[i];

		Vector2 scrSz = (Screen.GetWidth(), Screen.GetHeight());

		Vector2 nodeSz;
		[nodeSz.X, nodeSz.Y] = TexMan.GetSize(Tex_Node);

		Vector2
			realTL = Screen.VirtualToRealCoords(
				(slot.DrawPos.X - (nodeSz.X * 0.5),
				slot.DrawPos.Y - (nodeSz.Y * 0.5)),
				scrSz, (VIRT_W, VIRT_H), handleAspect: false
			),
			realBR = Screen.VirtualToRealCoords(
				(slot.DrawPos.X + (nodeSz.X * 0.5),
				slot.DrawPos.Y + (nodeSz.Y * 0.5)),
				scrSz, (VIRT_W, VIRT_H), handleAspect: false
			);

		return
			MousePos.X > realTL.X && MousePos.X < realBR.X &&
			MousePos.Y > realTL.Y && MousePos.Y < realBR.Y;
	}

	private bool ValidHoveredNode() const
	{
		return HoveredNode < NodeDrawState.Size();
	}
}
