class BIO_Gene : Inventory abstract
{
	meta uint LootWeight;
	property LootWeight: LootWeight;

	meta uint Limit;
	property Limit: Limit;

	// Explains in short-form and without context what the modifier does.
	meta string Summary;
	property Summary: Summary;

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

		BIO_Gene.Limit uint16.MAX;
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		// Needed for network event communication
		ChangeTID(Level.FindUniqueTID(int.MIN, int.MAX));
	}

	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher))
			return false;

		return BIO_Player(toucher).CanCarryGene(self);		
	}

	// Prevent gene pickups from being folded together.
	override bool HandlePickup(Inventory item) { return false; }

	// This gene will never drop as loot if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	static BIO_Gene FindByTID(int tid)
	{
		let iter = Level.CreateActorIterator(tid, 'BIO_Gene');
		return BIO_Gene(iter.Next());
	}

	final override string PickupMessage()
	{
		return String.Format(StringTable.Localize(PickupMsg), GetTag());
	}

	static void PlayRaritySound(uint weight)
	{
		if (weight <= LOOTWEIGHT_MIN)
			S_StartSound("bio/loot/veryrare", CHAN_AUTO);
		else if (weight <= LOOTWEIGHT_RARE)
			S_StartSound("bio/loot/rare", CHAN_AUTO);
	}
}

class BIO_ModifierGene : BIO_Gene abstract
{
	meta class<BIO_WeaponModifier> ModType;
	property ModType: ModType;

	meta BIO_WeapModRepeatRules RepeatRules;
	property RepeatRules: RepeatRules;

	Default
	{
		BIO_ModifierGene.RepeatRules BIO_WMODREPEATRULES_NONE;
	}
}

// Support genes have effects on other nodes, rather than imparting a modifier.
class BIO_SupportGene : BIO_Gene abstract
{
	abstract bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const;

	abstract string Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const;
}

// Active genes do something to the graph upon being committed, sometimes
// being destroyed in the process.
class BIO_ActiveGene : BIO_Gene abstract
{
	abstract bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const;

	abstract string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		uint node
	) const;
}

// General symbolic constants for loot weights, kept in one place.
extend class BIO_Gene
{
	const LOOTWEIGHT_MAX = 18;
	const LOOTWEIGHT_VERYCOMMON = 12;
	const LOOTWEIGHT_COMMON = 8;
	const LOOTWEIGHT_UNCOMMON = 5;
	const LOOTWEIGHT_RARE = 3;
	const LOOTWEIGHT_VERYRARE = 2;
	const LOOTWEIGHT_MIN = 1;
}
