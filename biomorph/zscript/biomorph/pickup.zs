mixin class BIO_Pickup
{
	Default
	{
		+DONTGIB
	}

	meta string PartialPickupMessage;
	property PartialPickupMessage: PartialPickupMessage;
	meta string CollectedMessage;
	property CollectedMessage: CollectedMessage;

	private void MarkAsCollected(Actor collector)
	{
		PrintPickupMessage(collector.CheckLocalView(), CollectedMessage);
		bCountItem = false;
		Level.Found_Items++;
		A_SetTranslation('BIO_Pkup_Counted');
	}

	private void OnPartialPickup(Actor picker)
	{
		if (PickupFlash != null)
			Actor.Spawn(PickupFlash, Pos, ALLOW_REPLACE);

		// Special check so voodoo dolls picking up items cause the
		// real player to make noise
		if (picker.Player != null)
			PlayPickupSound(picker.Player.MO);
		else
			PlayPickupSound(picker);

		PrintPickupMessage(picker.CheckLocalView(), PartialPickupMessage);

		if (Amount <= (Default.Amount * 0.25))
			A_SetTranslation('BIO_Pkup_25');
		else if (Amount <= (Default.Amount * 0.5))
			A_SetTranslation('BIO_Pkup_50');
		else if (Amount <= (Default.Amount * 0.75))
			A_SetTranslation('BIO_Pkup_75');
	}
}
