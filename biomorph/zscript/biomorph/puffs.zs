/// The baseline `BulletPuff` but with added spark particles.
class biom_Bullet : BulletPuff
{
	protected meta uint MIN_SPARKS, MAX_SPARKS;
	property Sparks: MIN_SPARKS, MAX_SPARKS;

	Default
	{
		-ALLOWPARTICLES

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
