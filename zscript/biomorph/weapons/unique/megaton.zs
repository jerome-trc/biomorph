// Unique Incursion Shotgun, inspired by DRLA's Frag Shotgun, and named after 
// the DRLA weapon off which the Incursion Shotgun itself is based. Can switch
// via Zoom input to feeding bullets instead of shells.
class BIO_Megaton : BIO_IncursionShotgun
{
	protected bool ClipFed;

	Default
	{
		Tag "$BIO_MEGATON_TAG";

		Inventory.PickupMessage "$BIO_MEGATON_PKUP";

		Weapon.AmmoType2 'Clip'; // Only for the status bar display
		Weapon.SelectionOrder SELORDER_SSG_CLSF;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED_UNIQUE;

		BIO_Weapon.MagazineType 'BIO_MAG_Megaton';
		BIO_Weapon.Rarity BIO_RARITY_UNIQUE;
		BIO_Weapon.UniqueBase 'BIO_IncursionShotgun';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_ShotPellet', 9, 8, 18, 3.8, 1.9)
			.FireSound("bio/weap/incursion/fire")
			.CustomReadout(StringTable.Localize(
				"$BIO_INCURSIONSHOTGUN_QUAD"))
			.CustomReadout(StringTable.Localize(
				"$BIO_MEGATON_DETAIL"))
			.CustomReadout(StringTable.Localize(
				"$BIO_MEGATON_HOWTO"))
			.Build());
	}
	
	States
	{
	Ready:
		INCU A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Zoom:
		INCU A 3 Offset(0, 32 + 3) A_SetReloadTime(0);
		INCU A 3 Offset(0, 32 + 6) A_SetReloadTime(1);
		INCU A 2 Offset(0, 32 + 9) A_SetReloadTime(2);
		INCU A 3 Offset(0, 32 + 6)
		{
			A_SetReloadTime(3);
			A_EmptyMagazine();
			invoker.ClipFed = !invoker.ClipFed;
			if (invoker.ClipFed)
			{
				invoker.AmmoType1 = 'Clip';
				invoker.ReloadCost1 = 10;
			}
			else
			{
				invoker.AmmoType1 = invoker.Default.AmmoType1;
				invoker.ReloadCost1 = invoker.Default.ReloadCost1;
			}
			A_LoadMag();
			A_StartSound("bio/weap/incursion/reload", CHAN_7);
		}
		INCU A 3 Offset(0, 32 + 3) A_SetReloadTime(4);
		Goto Ready;
	}
}

class BIO_MAG_Megaton : Ammo { mixin BIO_Magazine; }