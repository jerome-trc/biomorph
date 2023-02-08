/// A Shotgun counterpart.
class BIOM_RiotStormgun : BIOM_Weapon
{
	protected BIOM_WeapDat_RiotStormgun data;

	Default
	{
		Tag "$BIOM_RIOTSTORMGUN_TAG";
		Obituary "$BIOM_RIOTSTORMGUN_OB";

		// Inventory.Icon 'RIOTZ0';
		Inventory.PickupMessage "$BIOM_RIOTSTORMGUN_PKUP";

		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;

		BIOM_Weapon.DataClass 'BIOM_WeapDat_RiotStormgun';
		BIOM_Weapon.Grade BIOM_WEAPGRADE_3;
	}

	States
	{
		// ???
	}
}

class BIOM_WeapDat_RiotStormgun : BIOM_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
