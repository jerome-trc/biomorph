class BIO_NamedKey
{
	int ScanCode_0, ScanCode_1;
	string KeyName;

	void Init(string cmd)
	{
		[ScanCode_0, ScanCode_1] = Bindings.GetKeysForCommand(cmd);
		
		Array<string> parts;
		KeyName = Bindings.GetBinding(ScanCode_0);
		Bindings.NameKeys(ScanCode_0, ScanCode_1).Split(parts, ", ");

		if (parts.Size() == 0)
			KeyName = StringTable.Localize("$BIO_UNASSIGNED_KEY");
		else if (parts.Size() == 1)
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			KeyName = "\cn" .. parts[0] .. "\c-";
		}
		else
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			parts[1].Replace("\cm", "");
			parts[1].Replace("\c-", "");
			KeyName = String.Format("\cn%s\c-/\cn%s\c-", parts[0], parts[1]);
		}
	}

	void Recolor(string escCode)
	{
		Array<string> parts;
		KeyName = Bindings.GetBinding(ScanCode_0);
		Bindings.NameKeys(ScanCode_0, ScanCode_1).Split(parts, ", ");

		if (parts.Size() == 0)
			KeyName = StringTable.Localize("$BIO_UNASSIGNED_KEY");
		else if (parts.Size() == 1)
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			KeyName = escCode .. parts[0] .. "\c-";
		}
		else
		{
			parts[0].Replace("\cm", "");
			parts[0].Replace("\c-", "");
			parts[1].Replace("\cm", "");
			parts[1].Replace("\c-", "");
			KeyName = String.Format("%s%s\c-/\%s%s\c-",
				escCode, parts[0], escCode, parts[1]);
		}
	}
	
	bool Matches(int code) const { return code == ScanCode_0 || code == ScanCode_1; }
}

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

		Key_Left = new("BIO_NamedKey");
		Key_Left.Init("+moveleft");
		Key_Right = new("BIO_NamedKey");
		Key_Right.Init("+moveright");
		Key_Up = new("BIO_NamedKey");
		Key_Up.Init("+forward");
		Key_Down = new("BIO_NamedKey");
		Key_Down.Init("+back");

		Key_Confirm = new("BIO_NamedKey");
		Key_Confirm.Init("+use");
		Key_Cancel = new("BIO_NamedKey");
		Key_Cancel.Init("+speed");

		for (uint i = 0; i <= 9; i++)
		{
			uint end = SlotKeys.Push(new("BIO_NamedKey"));
			SlotKeys[end].Init("slot " .. i);
		}
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
