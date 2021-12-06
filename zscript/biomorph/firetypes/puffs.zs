class BIO_Bullet : BIO_Puff
{
	Default
	{
		Tag "$BIO_BULLET_TAG";
		BIO_Puff.PluralTag "$BIO_BULLETS_TAG";
		BIO_Puff.MetaFlags BIO_FTMF_BALLISTIC;
		BIO_Puff.ProjCounterpart 'BIO_BulletProj';
	}
}

class BIO_ShotPellet : BIO_Bullet
{
	Default
	{
		Tag "$BIO_SHOTPELLET_TAG";
		BIO_Puff.PluralTag "$BIO_SHOTPELLETS_TAG";
		BIO_Puff.ProjCounterpart 'BIO_ShotPelletProj';
	}
}

class BIO_Slug : BIO_Bullet
{
	Default
	{
		Tag "$BIO_SLUG_TAG";
		BIO_Puff.PluralTag "$BIO_SLUGS_TAG";
		BIO_Puff.ProjCounterpart 'BIO_SlugProj';
	}
}

class BIO_MeleeHit : BIO_Bullet
{
	Default
	{
		Tag "$BIO_MELEEHIT_TAG";
		BIO_Puff.PluralTag "$BIO_MELEEHITS_TAG";
	}
}

class BIO_Shrapnel : BulletPuff
{
	Default
	{
		+ALLOWTHRUFLAGS
		+MTHRUSPECIES
		+THRUGHOST
	}

	final override void PostBeginPlay()
	{
		super.PostBeginPlay();
		if (Deathmatch) bMTHRUSPECIES = false;
	}
}

// Miscellaneous ===============================================================

class BIO_NullPuff : BulletPuff
{
	Default
	{
		+BLOODLESSIMPACT
		+NODAMAGETHRUST
		+NOTELEPORT
		+PAINLESS
		+THRUACTORS

		Decal '';
	}

	States
	{
	Spawn:
	Melee:
		TNT1 A 5;
		Stop;
	}
}
