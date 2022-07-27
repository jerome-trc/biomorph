class BIORLM_OvermindPlasma : BIO_FastProjectile
{
	Default
	{
		+THRUGHOST
		+SEEKERMISSILE

		Alpha 0.95;
		DeathSound "";
		Height 6;
		Radius 6;
		RenderStyle 'Add';
		Scale 0.15;
		SeeSound "";
		Speed 60;
		Tag "$BIORLM_OVERMINDPLASMA_TAG";
		BIO_FastProjectile.PluralTag "$BIORLM_OVERMINDPLASMA_TAG_PLURAL";
	}

	States
    {
    Spawn:
        TNT1 A 0;
		TNT1 A 0 A_StartSound("spiderovermind/plasma", CHAN_AUTO, attenuation: 0.6);
    SpawnLoop:
        TNT1 A 1;
		TNT1 A 0
		{
			A_SpawnItemEx('RLSpiderOvermindPlasmaTrail',
				(0.01 * Vel.X) / -35.0,
				-(0.01 * Vel.Y) / -35.0,
				2.0 + (0.01 * Vel.Z) / -35.0,
				flags: SXF_ABSOLUTEANGLE | SXF_NOCHECKPOSITION
			);

			static const class<Actor> TRAIL_TYPES[] = {
				'RLSpiderOvermindPlasmaTrail2',
				'RLSpiderOvermindPlasmaTrail3',
				'RLSpiderOvermindPlasmaTrail4',
				'RLSpiderOvermindPlasmaTrail5',
				'RLSpiderOvermindPlasmaTrail6',
				'RLSpiderOvermindPlasmaTrail7',
				'RLSpiderOvermindPlasmaTrail8',
				'RLSpiderOvermindPlasmaTrail9',
				'RLSpiderOvermindPlasmaTrail10',
				'RLSpiderOvermindPlasmaTrail11',
				'RLSpiderOvermindPlasmaTrail12',
				'RLSpiderOvermindPlasmaTrail13',
				'RLSpiderOvermindPlasmaTrail14',
				'RLSpiderOvermindPlasmaTrail15',
				'RLSpiderOvermindPlasmaTrail16',
				'RLSpiderOvermindPlasmaTrail17'
			};

			for (uint i = 1; i < 16; i++)
			{
				A_SpawnItemEx(TRAIL_TYPES[i - 1],
					(float(i) * Vel.X) / -35.0,
					-(float(i) * Vel.Y) / -35.0,
					2.0 + (0.01 * Vel.Z) / -35.0,
					flags: SXF_ABSOLUTEANGLE | SXF_NOCHECKPOSITION
				);
			}
		}
		Loop;
    Death:
		TNT1 A 0 A_ProjectileDeath;
		TNT1 A 0 A_Jump(25, 'TimeToBeAnnoying');
		Goto DeathAnimation;
    DeathAnimation:
		TNT1 A 0 A_StartSound("spiderovermind/plasmaimpact", CHAN_AUTO, attenuation: 0.8);
        BBB3 ABCDE 4 Bright;
        Stop;
    TimeToBeAnnoying:
		TNT1 A 0 A_JumpIfTargetInLOS('CanSeeTracer', 0, JLOSF_PROJECTILE, 256);
		TNT1 A 0 A_RearrangePointers(AAPTR_DEFAULT, AAPTR_DEFAULT, AAPTR_NULL);
		TNT1 A 0 A_SeekerMissile(0.0, 0.0, SMF_LOOK, 256, 4);
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_SeekerMissile(0.0, 0.0, SMF_LOOK, 256, 4);
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_JumpIfTargetInLOS('CanSeeTracer', 0, JLOSF_PROJECTILE, 256);
		Goto DeathAnimation;
    TimeToBeAnnoying:
		TNT1 A 0 A_StartSound("rlmonsters/laserhit", CHAN_AUTO, attenuation: 1.5);
		// (Yholl): I would be greatly amused if it jumped more than once
		TNT1 A 0 A_SpawnProjectile('RLSpiderOvermindPlasma2', 0,0,0, CMF_TRACKOWNER, 0, AAPTR_TRACER);
        Stop;
    }
}

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
