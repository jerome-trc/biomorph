class BIORLM_TristarBall : BIO_Projectile
{
	Default
	{
		+NOTIMEFREEZE
		+THRUGHOST
		+BLOODSPLATTER

		Alpha 0.85;
		DeathSound "";
		DeathType "PlasmaExplosion";
		Decal "EnemyBlueBFGLightning";
		Height 8;
		PainType "PlasmaExplosion";
		Radius 13;
		Scale 0.25;
		SeeSound "";
		Speed 20;
		Tag "$BIORLM_TRISTARBALL_TAG";
		BIO_Projectile.PluralTag "$BIORLM_TRISTARBALL_TAG_PLURAL";
	}

	States
	{
	Spawn:
		PULS CDEFED 2 Bright A_Travel;
		Goto Spawn;
	Death:
		TNT1 A 0
		{
			A_ProjectileDeath();

			if (CallACS("DRLA_MonsterQuake") == 0)
			{
				A_Quake(1, 8, 0, 512, "");
				A_Quake(5, 8, 0, 256, "");
			}

			A_StartSound(
				"rlmonsters/tristarblasterhit", CHANF_DEFAULT, CHAN_AUTO, 1, 0.6
			);
			A_StartSound(
				"rlmonsters/tristarblasterhit", CHANF_DEFAULT, CHAN_AUTO, 0.05, 0.15
			);
			A_SetScale(1);
		}
		PEXP AB 4 Bright;
		PEXP CD 3 Bright;
		PEXP EF 2 Bright;
		Stop;
	}
}
