/// The player menu is for seeing existing alterations, applying new ones,
/// and viewing lore.
class biom_PlayerMenu : biom_TooltipOptionMenu
{
	private biom_Player pawn;

	final override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		super.InitDynamic(parent, desc);
		self.mDesc.mSelectedItem = -1;

		let player = players[consolePlayer];
		self.pawn = biom_Player(player.mo);
		let pdat = biom_Global.Get().FindPlayerData(player);

		self.TooltipGeometry(0.5, 1.0, 0.75, 1.0, 0.5);
		self.TooltipAppearance("", "", "tfttbg");

		if (pdat.pendingAlterants.IsEmpty())
			return;

		{
			let item = new('OptionMenuItemStaticText');

			item.InitDirect(
				String.Format(
					StringTable.Localize("$BIOM_PLAYERMENU_BALANCE"),
					pdat.balanceMod
				),
				Font.CR_WHITE
			);

			self.mDesc.mItems.Push(item);
		}

		{
			let omi = new('biom_OptionMenuItem');
			omi.Init("$BIOM_PLAYERMENU_DISCARD", "", "biom_alter", true, Font.CR_WHITE);
			omi.WithArgs(-1, int.MAX, int.MAX);
			self.mDesc.mItems.push(omi);
		}

		{
			let item = new('OptionMenuItemStaticText');
			item.InitDirect("$BIOM_PLAYERMENU_HEADER_UPGRADES", Font.CR_GOLD);
			self.mDesc.mItems.Push(item);
		}

		for (int i = 0; i < pdat.pendingAlterants.upgrades.Size(); ++i)
		{
			let p = pdat.pendingAlterants.upgrades[i];
			self.PushAlterantOption(p, BIOM_ALTK_UPGRADE, i);
		}

		{
			let item = new('OptionMenuItemStaticText');
			item.InitDirect("$BIOM_PLAYERMENU_HEADER_SIDEGRADES", Font.CR_GOLD);
			self.mDesc.mItems.Push(item);
		}

		for (int i = 0; i < pdat.pendingAlterants.sidegrades.Size(); ++i)
		{
			let p = pdat.pendingAlterants.sidegrades[i];
			self.PushAlterantOption(p, BIOM_ALTK_SIDEGRADE, i);
		}

		{
			let item = new('OptionMenuItemStaticText');
			item.InitDirect("$BIOM_PLAYERMENU_HEADER_DOWNGRADES", Font.CR_GOLD);
			self.mDesc.mItems.Push(item);
		}

		for (int i = 0; i < pdat.pendingAlterants.downgrades.Size(); ++i)
		{
			let p = pdat.pendingAlterants.downgrades[i];
			self.PushAlterantOption(p, BIOM_ALTK_DOWNGRADE, i);
		}
	}

	final override void Ticker()
	{
		if ((gameState != GS_LEVEL) || (players[consolePlayer].health <= 0))
		{
			self.Close();
			return;
		}
	}

	private void PushAlterantOption(
		biom_PendingAlterant alter,
		biom_AlterantKind kind,
		int index
	)
	{
		let omi = new('biom_OptionMenuItem');

		int bal = 0;
		string balString;
		int fontColor = Font.CR_WHITE;

		if ((alter.inner is 'biom_PawnAlterant'))
			bal = biom_PawnAlterant(alter.inner).Balance(self.pawn.AsConst());
		else if (alter.inner is 'biom_WeaponAlterant')
			bal = biom_WeaponAlterant(alter.inner).Balance(alter.weaponData.AsConst());

		if (bal > 0)
		{
			balString = String.Format("+%d", bal);
			fontColor = Font.CR_GREEN;
		}
		else if (bal < 0)
		{
			balString = String.Format("%d", bal);
			fontColor = Font.CR_RED;
		}
		else
		{
			balString = String.Format("%d", bal);
			fontColor = Font.CR_WHITE;
		}

		let canSelect = self.pawn.GetData().balanceMod >= bal;
		omi.Init(alter.inner.Tag(), balString, "biom_alter", canSelect, fontColor);
		omi.WithArgs(kind, index, int.MAX);
		self.mDesc.mItems.push(omi);
		self.PushTooltip(alter.inner.Summary());
	}
}

class biom_OptionMenuItem : OptionMenuItem
{
	string eventName, content;
	int fontColor;
	int args[3];
	bool canSelect;

	biom_OptionMenuItem Init(
		string label,
		string content,
		string eventName,
		bool canSelect,
		int fontColor,
		bool centered = false
	)
	{
		super.Init(label, eventName, centered);
		self.content = content;
		self.eventName = eventName;
		self.canSelect = canSelect;
		return self;
	}

	biom_OptionMenuItem WithArgs(int arg0, int arg1, int arg2)
	{
		self.args[0] = arg0;
		self.args[1] = arg1;
		self.args[2] = arg2;
		return self;
	}

	final override int Draw(OptionMenuDescriptor d, int y, int indent, bool selected)
	{
		let c = self.canSelect ? Font.CR_CYAN : Font.CR_DARKGRAY;
		self.DrawLabel(indent, y, c);
		self.DrawValue(indent, y, self.fontColor, self.content);
		return indent;
	}

	final override bool Selectable()
	{
		return self.canSelect;
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
