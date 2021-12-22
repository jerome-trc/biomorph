// ???
enum BIO_DoppelAbilities : uint8
{
	BIO_DOPPF_NONE = 0,
	BIO_DOPPF_RAISE = 1 << 0,
	BIO_DOPPF_ALL = uint8.MAX
}

class BIO_Doppel : Actor
{
	private BIO_DoppelAbilities Abilities;

	Default
	{
		-COUNTKILL
		+BOSS
		+FLOORCLIP
		+JUMPDOWN
		+MISSILEEVENMORE
		+MISSILEMORE
		+NEVERRESPAWN
		+NOBLOCKMONST
		+NOFEAR
		+NOINFIGHTING
		+QUICKTORETALIATE
		+SEEINVISIBLE

		Monster;

		Health 3000;
		Height 56;
		Mass 10000;
		MaxStepHeight 64;
		MinMissileChance 50;
		Obituary "$BIO_DOPPEL_OB";
		PainChance 220;
		PainThreshold 20;
		Radius 20;
		Species 'BIO_Doppel';
		Speed 10;
		Tag "$BIO_DOPPEL_TAG";
	}
	
	States
	{
	Spawn:
		TNT1 A 0 A_Log("$BIO_DOPPEL_SPAWNED", 6.0);
	See:
	Missile:
	Heal:
	Pain:
	Death:
	XDeath:
	}

	final override void BeginPlay()
	{
		super.BeginPlay();
		Abilities = 1 << Random(0, 0);
	}
}
