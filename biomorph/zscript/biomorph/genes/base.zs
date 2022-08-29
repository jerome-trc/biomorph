class BIO_Gene : Inventory abstract
{
	mixin BIO_Rarity;

	meta uint LootWeight;
	property LootWeight: LootWeight;

	meta bool LockOnCommit;
	property LockOnCommit: LockOnCommit;

	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR // Just for the sake of being able to drop them

		Tag "$BIO_GENE_TAG";
		Height 16;
        Radius 20;
		Scale 0.75;

		Inventory.PickupMessage "$BIO_GENE_PKUP";
		Inventory.RestrictedTo 'BIO_Player';
	}

	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher))
			return false;

		let pawn = BIO_Player(toucher);
		return pawn.HeldGeneCount() < pawn.MaxGenesHeld;		
	}

	// Prevent gene pickups from being folded together.
	override bool HandlePickup(Inventory item) { return false; }


	final override string PickupMessage()
	{
		return String.Format(StringTable.Localize(PickupMsg), GetTag());
	}
	
	// Virtuals/abstracts //////////////////////////////////////////////////////

	// This gene will never drop as loot if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	abstract uint Limit() const;

	// Explains in short-form and without context what this gene does.
	abstract string Summary() const;
}

class BIO_ModifierGene : BIO_Gene abstract
{
	meta class<BIO_WeaponModifier> ModType;
	property ModType: ModType;

	final override uint Limit() const
	{
		return BIO_Global.Get().GetWeaponModifierByType(ModType).Limit();
	}

	final override string Summary() const
	{
		return BIO_Global.Get().GetWeaponModifierByType(ModType).Summary();
	}
}

// Support genes have effects on other nodes, rather than imparting a modifier.
class BIO_SupportGene : BIO_Gene abstract
{
	meta uint LimitProp;
	property Limit: LimitProp;

	meta string SummaryProp;
	property Summary: SummaryProp;

	Default
	{
		BIO_SupportGene.Limit uint16.MAX;
	}

	abstract bool, string Compatible(BIO_GeneContext context) const;
	abstract string Apply(BIO_GeneContext context) const;

	final override uint Limit() const { return LimitProp; }
	final override string Summary() const { return SummaryProp; }
}

// Active genes do something to the graph upon being committed, sometimes
// being destroyed in the process.
class BIO_ActiveGene : BIO_Gene abstract
{
	meta uint LimitProp;
	property Limit: LimitProp;

	meta string SummaryProp;
	property Summary: SummaryProp;

	Default
	{
		BIO_ActiveGene.Limit uint16.MAX;
	}

	abstract bool, string Compatible(BIO_GeneContext context) const;

	abstract string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const;

	final override uint Limit() const { return LimitProp; }
	final override string Summary() const { return SummaryProp; }
}

// General symbolic constants for loot weights, kept in one place.
extend class BIO_Gene
{
	const LOOTWEIGHT_MAX = 18;
	const LOOTWEIGHT_VERYCOMMON = 14;
	const LOOTWEIGHT_COMMON = 10;
	const LOOTWEIGHT_UNCOMMON = 6;
	const LOOTWEIGHT_RARE = 3;
	const LOOTWEIGHT_VERYRARE = 2;
	const LOOTWEIGHT_MIN = 1;
}

struct BIO_GeneContext
{
	readOnly<BIO_WeaponModSimulator> Sim;
	readOnly<BIO_Weapon> Weap;

	// More specifically, the node's UUID.
	uint Node;
	// Loaded with `BIO_WMS_Node::Multiplier`.
	uint NodeCount;
	// Total number of times this gene type is present on the graph,
	// including the gene receiving the argument.
	uint TotalCount;
	// If true, this is the first time this gene has been hit
	// during a compatibility check or application.
	bool First;

	bool IsLastNode() const { return Node == Sim.RealNodeSize() - 1; }
}
