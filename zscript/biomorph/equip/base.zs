class BIO_Equipment : Inventory abstract
{
	mixin BIO_Gear;

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

		Inventory.InterHubAmount 99;
		Inventory.MaxAmount 99;
		Inventory.PickupMessage "";

		BIO_Equipment.Grade BIO_GRADE_NONE;
		BIO_Equipment.EquipMessage "$BIO_EQUIP_DEFAULT";
	}

	// Parent overrides ========================================================

	override void BeginPlay()
	{
		super.BeginPlay();
		SetTag(GetColoredTag());
	}

	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher)) return false;

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return false;

		if (bioPlayer.IsFullOnEquipment()) return false;

		return true;
	}

	override bool Use(bool pickup)
	{
		let bioPlayer = BIO_PLayer(Owner);

		if (GetClass() is "BIO_Armor" && bioPlayer.IsWearingArmor())
		{
			bioPlayer.A_Print("$BIO_ARMOREQUIP_FAIL_ALREADYWEARING");
			return false;
		}

		bioPlayer.Equip(self);

		bioPlayer.A_Print(String.Format(
			StringTable.Localize(EquipMessage), GetColoredTag()), 2.5);

		return false;
	}

	override string PickupMessage()
	{
		string ret = StringTable.Localize(PickupMsg);
		string prefix = "";
		
		switch (Grade)
		{
		case BIO_GRADE_STANDARD:
			prefix = StringTable.Localize("$BIO_PICKUP_STANDARD");
			break;
		default:
		case BIO_GRADE_SPECIALTY:
			prefix = StringTable.Localize("$BIO_PICKUP_SPECIALTY");
			break;
		case BIO_GRADE_EXPERIMENTAL:
			prefix = StringTable.Localize("$BIO_PICKUP_EXPERIMENTAL");
			break;
		case BIO_GRADE_CLASSIFIED:
			prefix = StringTable.Localize("$BIO_PICKUP_CLASSIFIED");
			break;
		}

		ret = String.Format(ret, prefix, GetTag());
		return ret;
	}

	// Virtuals/abstracts ======================================================

	// Called before the PlayerPawn's equipment pointer gets set, and any
	// related items (e.g. armor StatClass) get added to the player's inventory.
	virtual void OnEquip(BIO_Player bioPlayer) const {}

	// Called before the PlayerPawn's equipment pointer gets nullified, and any
	// related items (e.g. armor StatClass) get taken away.
	virtual void OnUnequip(BIO_Player bioPlayer, bool broken) const {}

	// Called before BIO_Player checks if armor has broken, so modifying
	// BasicArmor is always valid here.
	virtual void OnDamageTaken(BIO_PLayer bioPlayer,
		Actor inflictor, Actor source, in out int damage, name dmgType) const {}

	// If this equipment item can not be removed, the user will get
	// a message sourced from a call to this function.
	virtual string NoRemoveMessage() const
	{
		Console.Printf(Biomorph.LOGPFX_ERR .. "NoRemoveMessage() is unimplemented.");
		return "";
	}
}

class BIO_Armor : BIO_Equipment abstract
{
	// If a player manages to burn all of this down I'll be amazed
	const INFINITE_ARMOR = 2147483647;

	meta Class<BIO_ArmorStats> StatClass; property StatClass: StatClass;

	Default
	{
		BIO_Equipment.EquipMessage "$BIO_EQUIP_ARMORDEFAULT";
	}

	// Generate a set of affixes for this armour.
	override void BeginPlay()
	{
		super.BeginPlay();

		uint c = 0;
		switch (Grade)
		{
		case BIO_GRADE_STANDARD: c = 1; break;
		case BIO_GRADE_SPECIALTY: c = 2; break;
		case BIO_GRADE_EXPERIMENTAL: c = 3; break;
		default: return;
		}

		for (uint i = 0; i < c; i++)
		{
			Array<BIO_EquipmentAffix> eligibles;
			BIO_GlobalData.Get().AllEligibleEquipmentAffixes(eligibles, self);
			if (eligibles.Size() < 1) return;
			uint e = Affixes.Push(eligibles[Random(0, eligibles.Size() - 1)]);
			Affixes[e].Init(self);
		}
	}
}

// Intangible items given when a BIO_Armor is used (equipped), which
// provides the actual damage mitigation to the player.
class BIO_ArmorStats : BasicArmorPickup abstract
{
	override bool Use(bool pickup)
	{
		let bioPlayer = BIO_Player(Owner);
		if (bioPlayer == null) return false;

		bioPlayer.PreBasicArmorUse(self);

		return super.Use(pickup);
	}
}
