/// The baseline `BulletPuff` but with added spark particles.
class biom_BulletPuff : BulletPuff
{
	Default
	{
		-ALLOWPARTICLES
	}

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 {
			let tex = TexMan.CheckForTexture('PUFFA0');

			for (uint i = 0; i < Random(6, 8); ++i) {
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
