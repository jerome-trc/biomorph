// Symbols common to weapons and equippables like armour.

// Used as a measure of the quality of the gear item at a baseline.
enum BIO_Grade : uint8
{
	BIO_GRADE_NONE,
	BIO_GRADE_SURPLUS, // Unused placeholder
	BIO_GRADE_STANDARD,
	BIO_GRADE_SPECIALTY,
	BIO_GRADE_CLASSIFIED
}

// Used to differentiate between a gear item with no affixes, a gear item
// with randomly-generated affixes, and a gear item with unique affixes.
enum BIO_Rarity : uint8
{
	BIO_RARITY_NONE,
	BIO_RARITY_COMMON,
	BIO_RARITY_MUTATED,
	BIO_RARITY_UNIQUE
}

const CRESC_STATDEFAULT = "\c[White]";
const CRESC_STATMODIFIED = "\c[Cyan]";
const CRESC_STATBETTER = "\c[Green]";
const CRESC_STATWORSE = "\c[Red]";

mixin class BIO_Gear
{
	meta BIO_Grade Grade; property Grade: Grade;
	BIO_Rarity Rarity; property Rarity: Rarity;
	meta string UniqueSuffix; property UniqueSuffix: UniqueSuffix;

	meta sound GroundHitSound; property GroundHitSound: GroundHitSound;

	private bool HitGround, PreviouslyPickedUp;

	bool NoImplicitAffixes() const { return ImplicitAffixes.Size() < 1; }
	bool NoExplicitAffixes() const { return Affixes.Size() < 1; }
	bool NoAffixes() const { return NoImplicitAffixes() && NoExplicitAffixes(); }

	private void OnOwnerAttach()
	{
		if (!PreviouslyPickedUp)
		{
			DRLMDangerLevel();
			BIO_EventHandler.BroadcastFirstPickup(GetClassName());
		}

		PreviouslyPickedUp = true;
	}

	void DRLMDangerLevel() const
	{
		if (Rarity == BIO_RARITY_UNIQUE)
			BIO_Utils.DRLMDangerLevel(1);
	}
}
