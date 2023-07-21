/// Where the player applies new mutators.
class biom_MutationMenu : GenericMenu
{
	/// An initial value for `Self::size::x`.
	const DEFAULT_VIRT_WIDTH = 640.0;
	/// An initial value for `Self::size::y`.
	const DEFAULT_VIRT_HEIGHT = 360.0;

	/// Overlay for node frames.
	const COLOR_HOVERED = Color(127, 127, 127, 127);

	private Font tooltipFont;
	private textureID nodeTexture;

	private readonly<biom_PlayerData> data;
	private array<biom_MutMenuNodeRing> rings;

	private bool panning;
	/// Used as virtual width/height to provide zooming.
	private Vector2 virtDims;
	/// Where on the whole tree is the user looking?
	private Vector2 viewPos;

	private Vector2 mousePos;
	/// Used for panning.
	private Vector2 prevMousePos;
	/// Alias into `Self::rings::nodes`. Is `null` if nothing is hovered.
	private biom_MutMenuNode hoveredNode;

	/// Alter configuration and acquire graphics resources.
	final override void Init(Menu parent)
	{
		super.Init(parent);

		self.DontDim = true;
		self.virtDims = (DEFAULT_VIRT_WIDTH, DEFAULT_VIRT_HEIGHT);

		self.tooltipFont = 'JenocideFontRed';

		self.nodeTexture = TexMan.CheckForTexture(
			"graphics/node.png",
			TexMan.TYPE_ANY
		);

		let globals = biom_Global.Get();
		self.data = globals.GetPlayerData(consolePlayer);
	}

	final override void Ticker()
	{
		if ((gameState != GS_LEVEL) || (players[consolePlayer].health <= 0))
		{
			self.Close();
			return;
		}
	}

	final override void Drawer()
	{
		super.Drawer(); // Draw the back button.

		self.UpdateNodeState();

		Screen.Dim(
			Color(255, 0, 0, 0),
			0.2,
			0, 0,
			Screen.GetWidth(), Screen.GetHeight()
		);

		// Root node

		Screen.DrawTexture(
			self.nodeTexture,
			false,
			self.rings[0].nodes[0].drawPos.x, self.rings[0].nodes[0].drawPos.y,
			DTA_VIRTUALWIDTHF, self.virtDims.x,
			DTA_VIRTUALHEIGHTF, self.virtDims.y,
			DTA_CENTEROFFSET, true,
			DTA_KEEPRATIO, true
		);

		// TODO: What icon does the root node use?

		for (int r = 1; r < self.rings.Size(); ++r)
		{
			let ring = self.rings[r];

			for (int n = 0; n < ring.nodes.Size(); ++n)
			{
				let node = self.data.mutTree[r].nodes[n];
				let rNode = ring.nodes[n];
				let overlay = Color(0, 0, 0, 0);

				if (self.hoveredNode == rNode)
					overlay = COLOR_HOVERED;

				Screen.DrawTexture(
					self.nodeTexture,
					false,
					rNode.drawPos.x, rNode.drawPos.y,
					DTA_VIRTUALWIDTHF, self.virtDims.x,
					DTA_VIRTUALHEIGHTF, self.virtDims.y,
					DTA_CENTEROFFSET, true,
					DTA_KEEPRATIO, true,
					DTA_COLOROVERLAY, overlay,
					DTA_ALPHA, node.active ? 1.0 : 0.5
				);

				let icon = node.mutator.Icon();

				if (!icon.IsNull() && icon.IsValid())
				{
					Screen.DrawTexture(
						icon,
						false,
						rNode.drawPos.x, rNode.drawPos.y,
						DTA_VIRTUALWIDTHF, self.virtDims.x,
						DTA_VIRTUALHEIGHTF, self.virtDims.y,
						DTA_CENTEROFFSET, true,
						DTA_KEEPRATIO, true
					);
				}
			}
		}

		if (self.hoveredNode != null)
		{
			let tooltip = String.Format(
				"%s\n\n%s",
				StringTable.Localize(self.hoveredNode.data.mutator.Tag()),
				StringTable.Localize(self.hoveredNode.data.mutator.Summary())
			);

			let lines = self.tooltipFont.BreakLines(tooltip, 224);
			string text = "";
			int maxWidth = 0;

			for (uint i = 0; i < lines.Count(); i++)
			{
				text.AppendFormat("%s\n", lines.StringAt(i));
				maxWidth = Max(maxWidth, lines.StringWidth(i));
			}

			text.DeleteLastCharacter();

			let dpx = (self.mousePos.x / cleanXFac) + 8;
			let twac = maxWidth * cleanXFac;

			if ((Screen.GetWidth() - (dpx * cleanXFac)) < twac)
			{
				dpx -= maxWidth;
				dpx -= 8;
			}

			let dpy = (self.mousePos.y / cleanYFac) + 8;
			let height = self.tooltipFont.GetHeight() * (lines.Count() + 1);
			let thac = height * cleanYFac;

			if ((Screen.GetHeight() - (dpy * cleanYFac)) < thac)
			{
				dpy -= height;
				dpy -= 8;
			}

			Screen.DrawText(
				self.tooltipFont, Font.CR_UNTRANSLATED,
				dpx, dpy,
				text,
				DTA_VIRTUALWIDTHF, cleanWidth,
				DTA_VIRTUALHEIGHTF, cleanHeight,
				DTA_KEEPRATIO, true
			);
		}
	}

	/// Handles panning.
	final override bool MouseEvent(int type, int mX, int mY)
	{
		switch (type)
		{
		case MOUSE_MOVE:
			if (self.panning)
			{
				self.viewPos.x = Clamp(
					self.viewPos.x + (self.prevMousePos.x - mX),
					-(DEFAULT_VIRT_WIDTH * 2),
					DEFAULT_VIRT_WIDTH * 2
				);

				self.viewPos.y = Clamp(
					self.viewPos.y + (self.prevMousePos.y - mY),
					-(DEFAULT_VIRT_HEIGHT * 2),
					DEFAULT_VIRT_HEIGHT * 3
				);
			}

			break;
		default:
			break;
		}

		return true;
	}

	/// Mouse movement, buttons, and wheel, as well as keyboard input.
	/// - Scroll wheel events change zoom level.
	final override bool OnUIEvent(UIEvent event)
	{
		int y = event.mouseY;
		let res = false;

		switch (event.Type)
		{
		case UIEvent.TYPE_MOUSEMOVE:
			BackbuttonTime = 4 * GameTicRate;

			if (mMouseCapture || m_use_mouse == 1)
			{
				if (self.MouseEventBack(MOUSE_MOVE, event.mouseX, y))
					y = -1;

				self.MouseEvent(MOUSE_MOVE, event.mouseX, y);
			}

			self.prevMousePos.x = self.mousePos.x;
			self.prevMousePos.y = self.mousePos.y;
			self.mousePos.x = event.mouseX;
			self.mousePos.y = event.mouseY;

			break;
		case UIEvent.TYPE_LBUTTONDOWN:
			res = self.MouseEventBack(MOUSE_CLICK, event.mouseX, y);
			// Make the menu's mouse handler believe that the
			// current coordinate is outside the valid range.
			if (res)
				y = -1;

			res |= self.MouseEvent(MOUSE_CLICK, event.mouseX, y);

			if (res)
				self.SetCapture(true);

			break;
		case UIEvent.TYPE_LBUTTONUP:
			if (self.mMouseCapture)
			{
				self.SetCapture(false);
				res = self.MouseEventBack(MOUSE_RELEASE, event.mouseX, y);
				if (res) y = -1;
				res |= self.MouseEvent(MOUSE_RELEASE, event.mouseX, y);
			}

			break;
		case UIEvent.TYPE_WHEELDOWN:
			self.virtDims.x = Min(self.virtDims.x + 32.0, DEFAULT_VIRT_WIDTH * 3.0);
			self.virtDims.y = Min(self.virtDims.y + 18.0, DEFAULT_VIRT_HEIGHT * 3.0);
			break;
		case UIEvent.TYPE_WHEELUP:
			self.virtDims.x = Max(self.virtDims.x - 32.0, DEFAULT_VIRT_WIDTH);
			self.virtDims.y = Max(self.virtDims.y - 18.0, DEFAULT_VIRT_HEIGHT);
			break;
		case UIEvent.TYPE_MBUTTONDOWN:
			self.SetCapture(true);
			self.panning = true;
			break;
		case UIEvent.TYPE_MBUTTONUP:
			self.SetCapture(false);
			self.panning = false;
			break;
		default:
			break;
		}

		return false;
	}

	/// Called each frame before all other render operations.
	/// - Determines which node is currently hovered, if any.
	/// - Creates or removes render nodes, if necessary.
	private void UpdateNodeState()
	{
		self.hoveredNode = null;
		let screenDims = (Screen.GetWidth(), Screen.GetHeight());

		Vector2 nodeDims;
		[nodeDims.x, nodeDims.y] = TexMan.GetSize(self.nodeTexture);

		if (self.rings.Size() != self.data.mutTree.Size())
			self.rings.Resize(self.data.mutTree.Size());

		for (int r = 0; r < self.data.mutTree.Size(); ++r)
		{
			if (self.rings[r] == null)
				self.rings[r] = new('biom_MutMenuNodeRing');

			let layer = self.data.mutTree[r];
			let ring = self.rings[r];

			if (ring.nodes.Size() < layer.nodes.Size())
				ring.nodes.Resize(layer.nodes.Size());

			let radius = (M_PI / 180.0) * float(r) * 4096.0;
			let eachAng = 360.0 / float(ring.nodes.Size());
			let arcLen = radius * eachAng;

			for (int n = 0; n < layer.nodes.Size(); ++n)
			{
				if (self.rings[r].nodes[n] == null)
				{
					self.rings[r].nodes[n] = new('biom_MutMenuNode');
					self.rings[r].nodes[n].data = layer.nodes[n];
				}

				let node = layer.nodes[n];
				let rNode = ring.nodes[n];

				let ang = eachAng * float(n);
				let x = Cos(ang) * radius;
				let y = Sin(ang) * radius;

				rNode.drawPos = (
					(self.virtDims.x / 2) + x + self.viewPos.x,
					(self.virtDims.y / 2) + y + self.viewPos.y
				);

				rNode.screenPos = Screen.VirtualToRealCoords(
					rNode.drawPos,
					screenDims,
					self.virtDims,
					handleAspect: false
				);

				Vector2
					realTL = Screen.VirtualToRealCoords(
						(rNode.drawPos.x - (nodeDims.x * 0.5),
						rNode.drawPos.y - (nodeDims.y * 0.5)),
						screenDims,
						self.virtDims,
						handleAspect: false
					),
					realBR = Screen.VirtualToRealCoords(
						(rNode.drawPos.x + (nodeDims.x * 0.5),
						rNode.drawPos.y + (nodeDims.y * 0.5)),
						screenDims,
						self.virtDims,
						handleAspect: false
					);

				if (
					self.mousePos.x > realTL.x && self.mousePos.x < realBR.x &&
					self.mousePos.y > realTL.y && self.mousePos.y < realBR.y &&
					!self.panning &&
					!(r == 0 && n == 0) // Can't hover the home node.
				)
				{
					self.hoveredNode = rNode;
				}
			}
		}
	}
}

/// Rendering state.
/// Maps to a `biom_MutatorNodeLayer` in `biom_PlayerData::mutTree`.
class biom_MutMenuNodeRing
{
	array<biom_MutMenuNode> nodes;
}

/// Rendering state.
/// Maps to a `biom_MutatorNode` in `biom_MutatorNodeLayer::nodes`.
class biom_MutMenuNode
{
	biom_MutatorNode data;
	Vector2 drawPos;
	Vector2 screenPos;
}
