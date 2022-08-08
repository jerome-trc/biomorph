/*
The event handler checks for these, and replaces them with a random loot weapon
type from the associated spawn category.

Vanilla weapons were previously changed directly into Biomorph weapons by the
spawn event handler, but this let certain DEHACKED pickups slip past until they
got touched, giving the player a weapon they were never supposed to even encounter
(see the Super Shotgun in Ancient Aliens MAP20 as an example).
*/

class BIO_WeaponReplacer : BIO_IntangibleActor abstract
{
	meta BIO_WeaponSpawnCategory SpawnCategory;
	property SpawnCategory: SpawnCategory;
}

class BIO_WeaponReplacer_Shotgun : BIO_WeaponReplacer replaces Shotgun
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_SHOTGUN;
	}
}

class BIO_WeaponReplacer_Chaingun : BIO_WeaponReplacer replaces Chaingun
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_CHAINGUN;
	}
}

class BIO_WeaponReplacer_SSG : BIO_WeaponReplacer replaces SuperShotgun
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_SSG;
	}
}

class BIO_WeaponReplacer_RocketLauncher : BIO_WeaponReplacer replaces RocketLauncher
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_RLAUNCHER;
	}
}

class BIO_WeaponReplacer_PlasRifle : BIO_WeaponReplacer replaces PlasmaRifle
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_PLASRIFLE;
	}
}

class BIO_WeaponReplacer_BFG9000 : BIO_WeaponReplacer replaces BFG9000
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_BFG9000;
	}
}

class BIO_WeaponReplacer_Chainsaw : BIO_WeaponReplacer replaces Chainsaw
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_CHAINSAW;
	}
}

class BIO_WeaponReplacer_Pistol : BIO_WeaponReplacer replaces Pistol
{
	Default
	{
		BIO_WeaponReplacer.SpawnCategory BIO_WSCAT_PISTOL;
	}
}
