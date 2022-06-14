// Symbols common to weapons and accessories.
mixin class BIO_Gear
{
	meta string UniqueSuffix; property UniqueSuffix: UniqueSuffix;

	meta sound GroundHitSound; property GroundHitSound: GroundHitSound;

	private bool HitGround, PreviouslyPickedUp;

	private void OnOwnerAttach()
	{
		if (!PreviouslyPickedUp)
		{
			BIO_EventHandler.BroadcastFirstPickup(GetClassName());
		}

		PreviouslyPickedUp = true;
	}
}
