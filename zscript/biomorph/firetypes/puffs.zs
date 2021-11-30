class BIO_Bullet : BIO_Puff
{
	Default
	{
		Tag "$BIO_PUFF_TAG_BULLET";
		BIO_Puff.PluralTag "$BIO_PUFF_TAG_BULLETS";
		BIO_Puff.MetaFlags BIO_FTMF_BALLISTIC;
	}
}

class BIO_ShotPellet : BIO_Bullet
{
	Default
	{
		Tag "$BIO_PUFF_TAG_SHOTPELLET";
		BIO_Puff.PluralTag "$BIO_PUFF_TAG_SHOTPELLETS";
	}
}

class BIO_Slug : BIO_Bullet
{
	Default
	{
		Tag "$BIO_PUFF_TAG_SLUG";
		BIO_Puff.PluralTag "$BIO_PUFF_TAG_SLUGS";
	}
}

class BIO_MeleeHit : BIO_Bullet
{
	Default
	{
		Tag "$BIO_PUFF_TAG_MELEEHIT";
		BIO_Puff.PluralTag "$BIO_PUFF_TAG_MELEEHITS";
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
