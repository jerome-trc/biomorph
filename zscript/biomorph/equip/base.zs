// Dictate what stats can be affected by affixes. If a bit is set,
// the affix should stop itself from altering that stat, or applying itself
// to a weapon which it can't even affect.
enum BIO_EquipmentAffixMask : uint
{
	BIO_EAM_NONE = 0,
	// General
	BIO_EAM_ONDAMAGETAKEN = 1 << 0,
	BIO_EAM_ONEQUIP = 1 << 1,
	BIO_EAM_ONUNEQUIP = 1 << 2,
	// Armor-related
	BIO_EAM_SAVEAMOUNT = 1 << 3,
	BIO_EAM_SAVEPERCENT = 1 << 4,
	BIO_EAM_ALL = uint.MAX
}

class BIO_Equipment : Inventory abstract
{
	mixin BIO_Gear;

	BIO_EquipmentAffixMask AffixMask; property AffixMask: AffixMask;

	string EquipMessage; property EquipMessage: EquipMessage;

	Array<BIO_EquipmentAffix> ImplicitAffixes, Affixes;
	bool Equipped;

	Default
	{
		-COUNTITEM
		+DONTGIB
		+INVENTORY.BIGPOWERUP
		+INVENTORY.INVBAR
		+NOBLOCKMONST

		Radius 20;
		Height 16;

		Inventory.InterHubAmount 1;
		Inventory.MaxAmount 1;
		Inventory.PickupMessage "";

		BIO_Equipment.AffixMask BIO_EAM_NONE;
		BIO_Equipment.Grade BIO_GRADE_NONE;
		BIO_Equipment.Rarity BIO_RARITY_MUTATED;
		BIO_Equipment.EquipMessage "$BIO_EQUIP_DEFAULT";
	}

	// Parent overrides ========================================================

	override void BeginPlay()
	{
		super.BeginPlay();
		SetTag(FullTag());
	}

	final override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher)) return false;

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return false;

		if (bioPlayer.IsFullOnEquipment()) return false;

		return true;
	}

	// Prevent armor pickups from being folded together.
	final override bool HandlePickup(Inventory item) { return false; }

	final override void AttachToOwner(Actor newOwner)
	{
		if (!PreviouslyPickedUp) RLMDangerLevel();
		PreviouslyPickedUp = true;
		super.AttachToOwner(newOwner);
	}

	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);

		if (GetClass() is 'BIO_Armor' && bioPlayer.IsWearingArmor())
		{
			bioPlayer.A_Print("$BIO_ARMOREQUIP_FAIL_ALREADYWEARING");
			return false;
		}

		bioPlayer.Equip(self);

		bioPlayer.A_Print(String.Format(
			StringTable.Localize(EquipMessage), FullTag()), 2.5);
		bioPlayer.A_StartSound(self.UseSound, CHAN_ITEM);

		return false;
	}

	override string PickupMessage()
	{
		string ret = StringTable.Localize(PickupMsg);
		string prefix = "";
		
		switch (Grade)
		{
		case BIO_GRADE_STANDARD:
			prefix = StringTable.Localize("$BIO_PKUP_STANDARD");
			break;
		default:
		case BIO_GRADE_SPECIALTY:
			prefix = StringTable.Localize("$BIO_PKUP_SPECIALTY");
			break;
		case BIO_GRADE_CLASSIFIED:
			prefix = StringTable.Localize("$BIO_PKUP_CLASSIFIED");
			break;
		}

		ret = String.Format(ret, prefix, GetTag());
		return ret;
	}

	// Virtuals/abstracts ======================================================

	// Called before the PlayerPawn's equipment pointer gets set, and any
	// related items (e.g. armor StatClass) get added to the player's inventory.
	virtual void OnEquip()
	{
		bUndroppable = true;
		bUntossable = true;

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnEquip(self);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnEquip(self);
	}

	// Called before the PlayerPawn's equipment pointer gets nullified, and any
	// related items (e.g. armor StatClass) get taken away.
	virtual void OnUnequip(bool broken)
	{
		bUndroppable = false;
		bUntossable = false;

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnUnequip(self, broken);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnUnequip(self, broken);
	}

	// If this equipment item can not be removed, the user will get
	// a message sourced from a call to this function.
	virtual string NoRemoveMessage() const
	{
		Console.Printf(Biomorph.LOGPFX_ERR .. "NoRemoveMessage() is unimplemented.");
		return "";
	}

	// Getters =================================================================

	// `GetTag()` only comes with color escape codes after `BeginPlay()`; use this
	// when derefencing defaults. Always comes with a '\c-' at the end.
	string FullTag() const
	{
		string crEsc_g = BIO_Utils.GradeColorEscapeCode(Grade);

		if (Rarity == BIO_RARITY_MUTATED)
		{
			string crEsc_r = BIO_Utils.RarityColorEscapeCode(Rarity);

			return String.Format("%s%s \c[White](%s%s\c[White])\c-",
				crEsc_g, Default.GetTag(), crEsc_r,
				StringTable.Localize("$BIO_MUTATED_CHARACTER"));
		}
		else if (Rarity == BIO_RARITY_UNIQUE)
		{
			string crEsc_r = BIO_Utils.RarityColorEscapeCode(Rarity);
			string suffix = UniqueSuffix.Length() > 0 ? " " .. UniqueSuffix : "";

			return String.Format("%s%s%s%s\c-", crEsc_r,
				Default.GetTag(), crEsc_g, suffix);
		}
		else
			return String.Format("%s%s\c-", crEsc_g, Default.GetTag());
	}

	bool HasAffixOfType(Class<BIO_EquipmentAffix> t, bool implicit = false) const
	{
		if (!implicit)
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				if (Affixes[i].GetClass() == t)
					return true;

			return false;
		}
		else
		{
			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
				if (ImplicitAffixes[i].GetClass() == t)
					return true;

			return false;
		}
	}

	readOnly<BIO_Equipment> AsConst() const { return self; }
}

struct BIO_ArmorData
{
	double SavePercent;
	int MaxAbsorb, MaxFullAbsorb, SaveAmount;
}

class BIO_Armor : BIO_Equipment abstract
{
	// If a player manages to burn all of this down I'll be amazed
	const INFINITE_ARMOR = int.MAX;

	meta Class<BIO_ArmorStats> StatClass; property StatClass: StatClass;
	BIO_ArmorData ArmorData;

	Default
	{
		BIO_Equipment.EquipMessage "$BIO_EQUIP_ARMORDEFAULT";
	}

	// Generate a set of affixes for this armour.
	final override void BeginPlay()
	{
		super.BeginPlay();

		uint c = 0;
		switch (Grade)
		{
		case BIO_GRADE_STANDARD: c = 1; break;
		case BIO_GRADE_SPECIALTY: c = 2; break;
		case BIO_GRADE_CLASSIFIED: c = 3; break;
		default: return;
		}

		for (uint i = 0; i < c; i++)
		{
			Array<BIO_EquipmentAffix> eligibles;
			BIO_GlobalData.Get().AllEligibleEquipmentAffixes(eligibles, AsConst());
			if (eligibles.Size() < 1) return;
			uint e = Affixes.Push(eligibles[Random(0, eligibles.Size() - 1)]);
			Affixes[e].Init(AsConst());
		}

		let statDefs = GetDefaultByType(StatClass);
		ArmorData.SavePercent = statDefs.SavePercent;
		ArmorData.MaxAbsorb = statDefs.MaxAbsorb;
		ArmorData.MaxFullAbsorb = statDefs.MaxFullAbsorb;
		ArmorData.SaveAmount = statDefs.SaveAmount;

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].PreArmorApply(self, ArmorData);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].PreArmorApply(self, ArmorData);
	}

	// Does not check if already in perfect condition.
	// TODO: Armor grade, intrinsic properties, affixes 
	// decide if armor can be repaired
	bool Reparable() const { return true; }
}

// Intangible items given when a BIO_Armor is used (equipped), which
// provides the actual damage mitigation to the player.
class BIO_ArmorStats : BasicArmorPickup abstract
{
	final override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		bioPlayer.PreArmorApply(self);

		return super.Use(pickup);
	}
}
