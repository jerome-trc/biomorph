class biom_Puff : BulletPuff abstract
{
	Default
	{
		-ALLOWPARTICLES
		-RANDOMIZE

		+ALLOWTHRUFLAGS
		+BLOODSPLATTER
		+FORCEXYBILLBOARD
		+HITTRACER
		+MTHRUSPECIES
		+NOTELEPORT
		+PUFFGETSOWNER
		+THRUSPECIES
		+THRUGHOST
	}
}

// Derived /////////////////////////////////////////////////////////////////////

class biom_BFGRay : biom_Puff
{
	Default
	{
		-NOEXTREMEDEATH
		+ALWAYSPUFF
		+FORCEXYBILLBOARD
		+MTHRUSPECIES
		+PUFFGETSOWNER

		DamageType 'BFG';
		Decal 'BFGLighting';
	}
}

class biom_BitecastPuff : biom_BFGRay
{
	Default
	{
		+EXTREMEDEATH
	}

	States
	{
	Spawn:
	XDeath:
	Melee:
	Crash:
		TNT1 A 0;
		TNT1 A 0
		{
			let tex = TexMan.CheckForTexture('BFS1A0');

			A_Explode(250, 256, 0, 1, 256);

			if (BIOM_quake)
			{
				A_Quake(1, 16, 0, 2048, "");
				A_Quake(4, 12, 0, 1024, "");
				A_Quake(8, 8, 0, 512, "");
			}

			for (uint i = 0; i < 6; ++i)
				A_BiteCastParticle(tex, "ffffff", Random(10, 70), Random(1, 10));

			for (uint i = 0; i < 12; ++i)
				A_BiteCastParticle(tex, "d979d9", Random(35, 105), Random(1, 20));

			for (uint i = 0; i < 14; ++i)
				A_BiteCastParticle(tex, "f999f9", Random(35, 105), Random(1, 20));

			for (uint i = 0; i < 8; ++i)
				A_BiteCastParticle(tex, "ffffff", Random(10, 70), Random(1, 10));
		}
		stop;
	}

	protected action void A_BiteCastParticle(
		TextureID texture,
		color tint,
		uint lifetime,
		uint size
	)
	{
		A_SpawnParticleEx(
			tint,
			texture,
			style: STYLE_SHADED,
			flags: SPF_FULLBRIGHT | SPF_RELATIVE,
			lifetime: lifetime,
			size: size,
			angle: FRandom(0, 360),
			// All offsets and accelerations are 0.
			velX: FRandom(0.2, 12.0),
			velY: FRandom(-0.2, 0.2),
			velZ: FRandom(-6.0, 6.0),
			startAlphaF: 0.98,
			sizeStep: -1
		);
	}
}

/// The baseline `BulletPuff` but with added spark particles.
class biom_Bullet : biom_Puff
{
	protected meta uint MIN_SPARKS, MAX_SPARKS;
	property Sparks: MIN_SPARKS, MAX_SPARKS;

	Default
	{
		-ALLOWPARTICLES

		Decal 'BulletChip';
		biom_Bullet.Sparks 5, 7;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 {
			let tex = TexMan.CheckForTexture('PUFFA0');

			for (uint i = 0; i < Random(invoker.MIN_SPARKS, invoker.MAX_SPARKS); ++i)
			{
				A_SpawnParticleEx(
					"ffffff",
					tex,
					style: STYLE_NONE,
					flags: SPF_FULLBRIGHT,
					size: 8,
					velX: FRandom(-24.0, 24.0),
					velY: FRandom(-24.0, 24.0),
					velZ: FRandom(0.0, 8.0),
					accelZ: -9.81,
					sizeStep: -1
				);
			}
		}
		goto super::Spawn;
	}
}

/// Reduces the number of sparks emitted by [`biom_Bullet`],
/// to offset the increased number of puffs emitted by shell-firing weapons.
class biom_ShotPellet : biom_Bullet
{
	Default
	{
		biom_Bullet.Sparks 2, 4;
	}
}
