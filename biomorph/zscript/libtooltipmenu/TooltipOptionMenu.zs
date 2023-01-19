// TooltipOptionMenu -- a drop-in replacement for OptionMenu with tooltip support.
// Released under the MIT license; see COPYING.md for details.
//
// To use this, declare your option menu in MENUDEF as normal, but add:
//   class TF_TooltipOptionMenu
// You can then use the "Tooltip", "TooltipGeometry", and "TooltipAppearance"
// menu pseudo-items to add and configure tooltips.
// For details, see the included README.

class BIO_TooltipOptionMenu : OptionMenu {
  mixin BIO_TooltipMenu;

  void InitDynamic(Menu parent, OptionMenuDescriptor desc) {
    desc.mItems.Clear();
    self.tooltip_settings = GetDefaults();
    super.Init(parent, desc);
  }

  override void Init(Menu parent, OptionMenuDescriptor desc) {
    super.Init(parent, desc);
    self.tooltip_settings = GetDefaults();
    if (desc.mItems.size() == 0) return;

    // If there's already a TooltipHolder in tail position, we've already been
    // initialized and just need to retrieve our saved tooltips from it.
    let tail = OptionMenuItemBIO_TooltipHolder(desc.mItems[desc.mItems.size()-1]);
    if (tail) {
      tooltips.copy(tail.tooltips);
      return;
    }

    // Steal the descriptor's list of menu items, then rebuild it containing
    // only the items we want to display.
    array<OptionMenuItem> items;
    items.Move(desc.mItems);

    // Start of tooltip block, i.e. index of the topmost menu item the next
    // tooltip will attach to.
    int startblock = -1;
    // Whether we're building a run of tooltips or processing non-tooltip menu
    // items.
    bool tooltip_mode = true;
    for (uint i = 0; i < items.size(); ++i) {
      if (items[i] is "OptionMenuItemBIO_Tooltip") {
        let tt = OptionMenuItemBIO_Tooltip(items[i]);
        if (tt.tooltip == "" && !tooltip_mode) {
          // Explicit marker that the above items should have no tooltips.
          startblock = desc.mItems.size();
        } else {
          AddTooltip(startblock, desc.mItems.size()-1, tt.tooltip);
          tooltip_mode = true;
        }
      } else if (items[i] is "OptionMenuItemBIO_TooltipGeometry") {
        OptionMenuItemBIO_TooltipGeometry(items[i]).CopyTo(tooltip_settings);
      } else if (items[i] is "OptionMenuItemBIO_TooltipAppearance") {
        OptionMenuItemBIO_TooltipAppearance(items[i]).CopyTo(tooltip_settings);
      } else {
        if (tooltip_mode) {
          // Just finished a run of tooltips.
          startblock = desc.mItems.size();
          tooltip_mode = false;
        }
        desc.mItems.push(items[i]);
      }
    }

    // Store our tooltips inside the menu descriptor so we can recover them when
    // the menu is redisplayed.
    desc.mItems.push(OptionMenuItemBIO_TooltipHolder(new("OptionMenuItemBIO_TooltipHolder").Init(tooltips)));
  }
}

class OptionMenuItemBIO_TooltipHolder : OptionMenuItem {
  mixin BIO_TooltipHolder;
}

class OptionMenuItemBIO_Tooltip : OptionMenuItem {
  mixin BIO_TooltipItem;
}

class OptionMenuItemBIO_TooltipGeometry : OptionMenuItem {
  mixin BIO_TooltipGeometry;
}

class OptionMenuItemBIO_TooltipAppearance : OptionMenuItem {
  mixin BIO_TooltipAppearance;
}
