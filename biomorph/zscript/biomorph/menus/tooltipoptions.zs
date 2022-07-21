// TooltipOptionsMenu -- a drop-in replacement for OptionsMenu with tooltip support.
// See https://github.com/ToxicFrog/laevis/tree/main/libtooltipmenu

/*  Copyright © 2022 Rebecca "ToxicFrog" Kelly
 
	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
	the Software, and to permit persons to whom the Software is furnished to do so,
	subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

class BIO_TooltipOptionMenu : OptionMenu {
	array<string> tooltips;

	override void Init(Menu parent, OptionMenuDescriptor desc) {
		super.Init(parent, desc);

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
			if (items[i] is 'OptionMenuItemBIOTooltip') {
				let tt = OptionMenuItemBIOTooltip(items[i]);
				if (tt.tooltip == "" && !tooltip_mode) {
					// Explicit marker that the above items should have no tooltips.
					startblock = desc.mItems.size();
				} else {
					AddTooltip(startblock, desc.mItems.size()-1, tt.tooltip);
					tooltip_mode = true;
				}
			} else {
				if (tooltip_mode) {
					// Just finished a run of tooltips.
					startblock = desc.mItems.size();
					tooltip_mode = false;
				}
				desc.mItems.push(items[i]);
			}
		}
	}

	void AddTooltip(uint first, uint last, string tooltip) {
		if (first < 0) ThrowAbortException("Tooltip must have at least one menu item preceding it!");
		while (tooltips.size() <= last) {
			tooltips.push("");
		}
		for (uint i = first; i <= last; ++i) {
			if (tooltips[i].length() > 0) {
				tooltips[i] = tooltips[i].."\n"..tooltip;
			} else {
				tooltips[i] = tooltip;
			}
		}
	}

	override void Drawer() {
		super.Drawer();
		let selected = mDesc.mSelectedItem;
		if (selected >= 0 && selected < tooltips.size() && tooltips[selected].length() > 0) {
			DrawTooltip(tooltips[selected]);
		}
	}

	// TODO: support for arbitrary positioning & background textures using a
	// TooltipConfig menu pseudoitem.
	void DrawTooltip(string tt) {
		let lines = newsmallfont.BreakLines(tt, screen.GetWidth()/3);
		let lh = newsmallfont.GetHeight();
		for (uint i = 0; i < lines.count(); ++i) {
			screen.DrawText(
				newsmallfont, Font.CR_WHITE,
				newsmallfont.GetCharWidth(0x20), lh/2+i*lh, lines.StringAt(i));
		}
	}
}

// Prefix the keyword with "BIO" so as not to hit a redefinition error when
// trying to load this with Laevis.
class OptionMenuItemBIOTooltip : OptionMenuItem {
	string tooltip;

	OptionMenuItemBIOTooltip Init(string tooltip) {
		self.tooltip = tooltip.filter();
		super.init("", "");
		return self;
	}
}
