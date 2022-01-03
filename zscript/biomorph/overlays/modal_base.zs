
// A foundation for making simple overlays operated solely via the keyboard.
class BIO_ModalOverlay play abstract
{
	const VIRTUAL_WIDTH = 320; const VIRTUAL_HEIGHT = 240;

	const VIRTUAL_WIDTH_X2 = VIRTUAL_WIDTH * 2;
	const VIRTUAL_HEIGHT_X2 = VIRTUAL_HEIGHT * 2;

	const VIRTUAL_WIDTH_HALF = VIRTUAL_WIDTH / 2;
	const VIRTUAL_HEIGHT_HALF = VIRTUAL_HEIGHT / 2;

	protected BIO_NamedKey Key_Left, Key_Right, Key_Up, Key_Down, Key_Confirm, Key_Cancel;
	protected Array<BIO_NamedKey> SlotKeys;

	protected Font SmallFont, BigFont;

	void OnCreate()
	{
		SmallFont = Font.GetFont("SMALLFONT");
		BigFont = Font.GetFont("BIGFONT");

		Key_Left = BIO_NamedKey.Create("+moveleft");
		Key_Right = BIO_NamedKey.Create("+moveright");
		Key_Up = BIO_NamedKey.Create("+forward");
		Key_Down = BIO_NamedKey.Create("+back");
		Key_Confirm = BIO_NamedKey.Create("+use");
		Key_Cancel = BIO_NamedKey.Create("+speed");

		for (uint i = 0; i <= 9; i++)
			SlotKeys.Push(BIO_NamedKey.Create("slot " .. i));
	}

	// Returns true to indicate that the event has been consumed.
	ui bool Input(InputEvent event)
	{
		if (event.Type != InputEvent.TYPE_KEYDOWN) return false;

		if (Key_Left.Matches(event.KeyScan))
			OnKeyPressed_Left();
		else if (Key_Right.Matches(event.KeyScan))
			OnKeyPressed_Right();
		else if (Key_Up.Matches(event.KeyScan))
			OnKeyPressed_Up();
		else if (Key_Down.Matches(event.KeyScan))
			OnKeyPressed_Down();
		else if (Key_Confirm.Matches(event.KeyScan))
			OnKeyPressed_Confirm();
		else if (Key_Cancel.Matches(event.KeyScan))
			OnKeyPressed_Cancel();
		else
		{
			for (uint i = 0; i < SlotKeys.Size(); i++)
			{
				if (SlotKeys[i].Matches(event.KeyScan))
				{
					OnSlotKeyPressed(i);
					break;
				}
			}
		}

		return true;
	}

	abstract ui void Draw(RenderEvent event) const;

	protected ui virtual void OnKeyPressed_Left() {}
	protected ui virtual void OnKeyPressed_Right() {}
	protected ui virtual void OnKeyPressed_Up() {}
	protected ui virtual void OnKeyPressed_Down() {}
	protected ui virtual void OnKeyPressed_Confirm() {}
	protected ui virtual void OnKeyPressed_Cancel() {}

	protected ui virtual void OnSlotKeyPressed(uint slot) {}
}
