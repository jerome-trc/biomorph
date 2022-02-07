class BIO_Bullet : BIO_Puff
{
	Default
	{
		Decal 'BulletChip';
		Tag "$BIO_BULLET_TAG";
		BIO_Puff.PluralTag "$BIO_BULLET_TAG_PLURAL";
		BIO_Puff.MetaFlags BIO_FTMF_BALLISTIC;
		BIO_Puff.ProjCounterpart 'BIO_BulletProj';
	}
}

class BIO_ShotPellet : BIO_Bullet
{
	Default
	{
		Tag "$BIO_SHOTPELLET_TAG";
		BIO_Puff.PluralTag "$BIO_SHOTPELLET_TAG_PLURAL";
		BIO_Puff.ProjCounterpart 'BIO_ShotPelletProj';
	}
}

class BIO_Slug : BIO_Bullet
{
	Default
	{
		Tag "$BIO_SLUG_TAG";
		BIO_Puff.PluralTag "$BIO_SLUG_TAG_PLURAL";
		BIO_Puff.ProjCounterpart 'BIO_SlugProj';
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

class BIO_ElectricPuff : BIO_RailPuff
{
	Default
	{
		+ALWAYSPUFF
		+PUFFONACTORS
		
		Decal 'PlasmaScorchLower1';
		RenderStyle 'Add';
		Tag "$BIO_ELECTRICPUFF_TAG_PLURAL";
		VSpeed 0.0;
		BIO_Puff.PluralTag "$BIO_ELECTRICPUFF_TAG_PLURAL";
	}

	States
	{
	Spawn:
		RZAP A 2 Bright Light("BIO_ElecPuff");
		RZAP B 2 Bright Light("BIO_ElecPuff")
			A_StartSound("bio/puff/lightning/hit",
				Random(0, 1) == 0 ? CHAN_6 : CHAN_7, volume: 0.5);
		RZAP CDEFGHI 2 Bright Light("BIO_ElecPuff");
		Stop;
	Melee:
		Goto Spawn;
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
