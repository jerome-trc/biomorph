// Unique Incursion Shotgun, inspired by DRLA's Frag Shotgun, and named after the
// DRLA weapon off which the Incursion Shotgun itself is based. Can switch via
// Zoom input to feeding bullets instead of shells.
class BIO_Megaton : BIO_IncursionShotgun
{
	protected bool ClipFed;

	Default
	{
		Tag "$BIO_WEAP_TAG_MEGATON";

		Inventory.PickupMessage "$BIO_WEAP_PKUP_MEGATON";

		Weapon.AmmoType2 'Clip'; // Only for the status bar display
		Weapon.SelectionOrder SELORDER_SSG - 90;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED + 0.1;

		BIO_Weapon.DamageRange 8, 18;
		BIO_Weapon.MagazineType 'BIO_MAG_Megaton';
		BIO_Weapon.Rarity BIO_RARITY_UNIQUE;
		BIO_Weapon.Spread 3.8, 1.9;
		BIO_Weapon.UniqueBase 'BIO_IncursionShotgun';
	}
	
	States
	{
	Ready:
		INCU A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Zoom:
		INCU A 3 Offset(0, 32 + 3) A_SetTics(invoker.ReloadTime1);
		INCU A 3 Offset(0, 32 + 6) A_SetTics(invoker.ReloadTime2);
		INCU A 2 Offset(0, 32 + 9) A_SetTics(invoker.ReloadTime3);
		INCU A 3 Offset(0, 32 + 6)
		{
			A_SetTics(invoker.ReloadTime4);
			A_EmptyMagazine();
			invoker.ClipFed = !invoker.ClipFed;
			if (invoker.ClipFed)
			{
				invoker.AmmoType1 = 'Clip';
				invoker.ReloadFactor1 = 10;
			}
			else
			{
				invoker.AmmoType1 = invoker.Default.AmmoType1;
				invoker.ReloadFactor1 = invoker.Default.ReloadFactor1;
			}
			A_LoadMag();
			A_StartSound("weapons/incursionreload", CHAN_7);
		}
		INCU A 3 Offset(0, 32 + 3) A_SetTics(invoker.ReloadTime5);
		Goto Ready;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		super.StatsToString(stats);
		stats.Push(StringTable.Localize("$BIO_WEAPSTAT_MEGATON_DETAIL"));
		stats.Push(StringTable.Localize("$BIO_WEAPSTAT_MEGATON_HOWTO"));
	}
}

class BIO_MAG_Megaton : Ammo { mixin BIO_Magazine; }