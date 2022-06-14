class BIO_Bullet : BIO_Puff
{
	Default
	{
		Decal 'BulletChip';
		Tag "$BIO_BULLET_TAG";
		BIO_Puff.PluralTag "$BIO_BULLET_TAG_PLURAL";
	}
}

class BIO_ShotPellet : BIO_Bullet
{
	Default
	{
		Tag "$BIO_SHOTPELLET_TAG";
		BIO_Puff.PluralTag "$BIO_SHOTPELLET_TAG_PLURAL";
	}
}

class BIO_Slug : BIO_Bullet
{
	Default
	{
		Tag "$BIO_SLUG_TAG";
		BIO_Puff.PluralTag "$BIO_SLUG_TAG_PLURAL";
	}
}

class BIO_MeleeHit : BIO_Puff
{
	Default
	{
		Decal 'BulletChip';
		Tag "$BIO_MELEEHIT_TAG";
		BIO_Puff.PluralTag "$BIO_MELEEHIT_TAG_PLURAL";
	}
}

class BIO_DemoBullet : BIO_Bullet
{
	Default
	{
		+PUFFONACTORS
		Scale 0.2;
		Tag "$BIO_DEMOBULLET_TAG";
		BIO_Puff.PluralTag "$BIO_DEMOBULLET_TAG_PLURAL";
	}

	States
	{
	Spawn:
	Melee:
		MISL B 8 Bright;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

class BIO_DemoShotPellet : BIO_DemoBullet
{
	Default
	{
		Scale 0.1;
		Tag "$BIO_DEMOSHOTPELLET_TAG";
		BIO_Puff.PluralTag "$BIO_DEMOSHOTPELLET_TAG_PLURAL";
	}
}

class BIO_DemoSlug : BIO_DemoBullet
{
	Default
	{
		Tag "$BIO_DEMOSLUG_TAG";
		BIO_Puff.PluralTag "$BIO_DEMOSLUG_TAG_PLURAL";
	}
}

class BIO_CannonShell : BIO_DemoBullet
{
	Default
	{
		+PUFFONACTORS
		Scale 0.5;
		Tag "$BIO_CANNONSHELL_TAG";
		BIO_Puff.PluralTag "$BIO_CANNONSHELL_TAG_PLURAL";
	}
}

class BIO_Shrapnel : BulletPuff
{
	Default
	{
		+ALLOWTHRUFLAGS
		+MTHRUSPECIES
		+THRUSPECIES
		+THRUGHOST

		Species 'Player';
	}

	final override void PostBeginPlay()
	{
		super.PostBeginPlay();

		if (Deathmatch)
			bMThruSpecies = false;
	}
}

// Miscellaneous ///////////////////////////////////////////////////////////////

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

class BIO_ForceBlast : BIO_Bullet
{
	Default
	{
		+EXTREMEDEATH
		+PUFFONACTORS
		-ALLOWPARTICLES
		Alpha 0.0;
	}
}
