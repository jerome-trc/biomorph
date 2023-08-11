/// The player menu is for seeing existing alterations, applying new ones,
/// and viewing lore.
class biom_PlayerMenu : biom_TooltipOptionMenu
{
	final override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		super.InitDynamic(parent, desc);

		let player = players[consolePlayer];
		let pdat = biom_Global.Get().FindPlayerData(player);

		self.TooltipGeometry(0.5, 1.0, 0.75, 1.0, 0.5);
		self.TooltipAppearance("", "", "tfttbg");

		if (pdat.pendingAlterants.IsEmpty())
			return;

		{
			let item = new('OptionMenuItemStaticText');

			item.InitDirect(
				String.Format("$BIOM_PLAYERMENU_BALANCE", pdat.balanceMod),
				Font.CR_CYAN
			);

			self.mDesc.mItems.Push(item);
		}

		{
			let item = new('OptionMenuItemStaticText');
			item.InitDirect("$BIOM_PLAYERMENU_HEADER_UPGRADES", Font.CR_GOLD);
			self.mDesc.mItems.Push(item);
		}

		for (int i = 0; i < pdat.pendingAlterants.upgrades.Size(); ++i)
			self.PushAlterantOption(pdat.pendingAlterants.upgrades[i], 2, i);

		{
			let item = new('OptionMenuItemStaticText');
			item.InitDirect("$BIOM_PLAYERMENU_HEADER_SIDEGRADES", Font.CR_GOLD);
			self.mDesc.mItems.Push(item);
		}

		for (int i = 0; i < pdat.pendingAlterants.sidegrades.Size(); ++i)
			self.PushAlterantOption(pdat.pendingAlterants.sidegrades[i], 1, i);

		{
			let item = new('OptionMenuItemStaticText');
			item.InitDirect("$BIOM_PLAYERMENU_HEADER_DOWNGRADES", Font.CR_GOLD);
			self.mDesc.mItems.Push(item);
		}

		for (int i = 0; i < pdat.pendingAlterants.downgrades.Size(); ++i)
			self.PushAlterantOption(pdat.pendingAlterants.downgrades[i], 0, i);

		self.mDesc.mSelectedItem = -1;
	}

	final override void Ticker()
	{
		if ((gameState != GS_LEVEL) || (players[consolePlayer].health <= 0))
		{
			self.Close();
			return;
		}
	}

	final override bool MenuEvent(int key, bool fromController)
	{
		if (key == Menu.MKEY_BACK)
			EventHandler.SendNetworkEvent("biom_alter", -1);

		return super.MenuEvent(key, fromController);
	}

	/// `kind` is 0 for downgrades, 1 for sidegrades, and 2 for upgrades.
	private void PushAlterantOption(biom_Alterant alter, int kind, int index)
	{
		let omi = new('biom_OptionMenuItem');

		string b;
		let bal = alter.Balance();
		int c = Font.CR_WHITE;

		if (bal > 0)
		{
			b = String.Format("+%d", bal);
			c = Font.CR_GREEN;
		}
		else if (bal < 0)
		{
			b = String.Format("-%d", bal);
			c = Font.CR_RED;
		}
		else
		{
			b = String.Format("%d", bal);
			c = Font.CR_WHITE;
		}

		omi.Init(alter.Tag(), b, "biom_alter", c);
		omi.WithArgs(kind, index, 0);
		self.mDesc.mItems.push(omi);
		self.PushTooltip(alter.Summary());
	}
}

class biom_OptionMenuItem : OptionMenuItem
{
	string eventName, content;
	int fontColor;
	int args[3];

	biom_OptionMenuItem Init(
		string label,
		string content,
		string eventName,
		int fontColor,
		bool centered = false
	)
	{
		super.Init(label, eventName, centered);
		self.content = content;
		self.eventName = eventName;
		return self;
	}

	biom_OptionMenuItem WithArgs(int arg0, int arg1, int arg2)
	{
		self.args[0] = arg0;
		self.args[1] = arg1;
		self.args[2] = arg2;
		return self;
	}

	override int Draw(OptionMenuDescriptor d, int y, int indent, bool selected)
	{
		self.DrawLabel(indent, y, self.fontColor);
		self.DrawValue(indent, y, self.fontColor, self.content);
		return indent;
	}

	final override bool MenuEvent(int key, bool fromController)
	{
		if (key != Menu.MKEY_ENTER)
			return super.MenuEvent(key, fromController);

		EventHandler.SendNetworkEvent(self.eventName, self.args[0], self.args[1], self.args[2]);
		Menu.MenuSound("menu/choose");
		Menu.GetCurrentMenu().Close();
		return true;
	}
}
