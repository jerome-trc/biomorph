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

	// Duplicates the behavior of `Inventory::PlayPickupSound()`.
	private void PlayCollectedSound(Actor collector)
	{
		double atten = bNoAttenPickupSound ? ATTN_NONE : ATTN_NORM;
		int chan;
		int flags = 0;

		if (collector != null && collector.CheckLocalView())
		{
			chan = CHAN_ITEM;
			flags = CHANF_NOPAUSE | CHANF_MAYBE_LOCAL;
		}
		else
		{
			chan = CHAN_ITEM;
			flags = CHANF_MAYBE_LOCAL;
		}

		collector.A_StartSound("bio/countitem", chan, flags, 1, atten);
	}

	private void MarkAsCollected(Actor collector)
	{
		PlayCollectedSound(collector);
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
