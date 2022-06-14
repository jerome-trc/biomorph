class BIO_Rocket : BIO_Projectile
{
	Default
	{
		+DEHEXPLOSION
		+RANDOMIZE
		+ROCKETTRAIL
		+ZDOOMTRANS

		DeathSound "weapons/rocklx";
		Height 8;
		Obituary "$OB_MPROCKET";
		Radius 11;
		SeeSound "weapons/rocklf";
		Speed 20;
		Tag "$BIO_ROCKET_TAG";

		BIO_Projectile.PluralTag "$BIO_ROCKET_TAG_PLURAL";
	}

	States
	{
	Spawn:
		MISL A 1 Bright A_Travel;
		Loop;
	Death:
		MISL B 8 Bright A_ProjectileDeath;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	BrainExplode:
		MISL BC 10 Bright;
		MISL D 10 A_BrainExplode;
		Stop;
	}
}

class BIO_Minirocket : BIO_Rocket
{
	Default
	{
		Tag "$BIO_MINIROCKET_TAG";

		Height 2;
		Radius 3;
		Scale 0.3;
		Speed 50;

		BIO_Projectile.PluralTag "$BIO_MINIROCKET_TAG_PLURAL";
	}
}

class BIO_PlasmaBall : BIO_Projectile
{
	Default
	{
		+RANDOMIZE
		+ZDOOMTRANS

		Alpha 0.75;
		DeathSound "weapons/plasmax";
		Height 8;
		Obituary "$OB_MPPLASMARIFLE";
		Radius 13;
		RenderStyle 'Add';
		SeeSound "weapons/plasmaf";
		Speed 25;
		Tag "$BIO_PLASMABALL_TAG";

		BIO_Projectile.PluralTag "$BIO_PLASMABALL_TAG_PLURAL";
	}

	States
	{
	Spawn:
		PLSS A 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		PLSS B 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		Loop;
	Death:
		TNT1 A 0 A_ProjectileDeath;
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class BIO_MiniPlasmaBall : BIO_PlasmaBall
{
	Default
	{
		Scale 0.25;
		SeeSound "";
		Speed 35;
	}
}

class BIO_BFGBall : BIO_Projectile
{
	Default
	{
		+RANDOMIZE
		+ZDOOMTRANS

		Alpha 0.75;
		DeathSound "weapons/bfgx";
		Height 8;
		Obituary "$OB_MPBFG_BOOM";
		Radius 13;
		RenderStyle 'Add';
		Speed 25;
		Tag "$BIO_BFGBALL_TAG";

		BIO_Projectile.PluralTag "$BIO_BFGBALL_TAG_PLURAL";
	}

	States
	{
	Spawn:
		BFS1 A 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		BFS1 B 3 Bright A_Travel;
		#### # 3 Bright A_Travel;
		Loop;
	Death:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_ProjectileDeath;
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class BIO_MiniBFGBall : BIO_BFGBall
{
	Default
	{
		Scale 0.1;
	}
}

class BIO_PLDF_BFGSpray : BIO_PayloadDeathFunctor
{
	private readOnly<BIO_PLDF_BFGSpray> Defaults;

	int RayCount, MinDamage, MaxDamage;

	static BIO_PLDF_BFGSpray Create(int rayCount, int minDmg, int maxDmg)
	{
		let ret = new('BIO_PLDF_BFGSpray'), defs = new('BIO_PLDF_BFGSpray');

		ret.RayCount = defs.RayCount = rayCount;
		ret.MinDamage = defs.MinDamage = minDmg;
		ret.MaxDamage = defs.MaxDamage = maxDmg;
		ret.Defaults = BIO_PLDF_BFGSpray(defs.AsConst());

		return ret;
	}

	final override void InvokeSlow(BIO_Projectile proj) const
	{
		proj.A_BFGSpray(numRays: RayCount,
			defDamage: Random(MinDamage, MaxDamage) * proj.DamageMultiply);
	}

	final override void InvokeFast(BIO_FastProjectile proj) const
	{
		proj.A_BFGSpray(numRays: RayCount,
			defDamage: Random(MinDamage, MaxDamage) * proj.DamageMultiply);
	}

	final override void InvokePuff(BIO_Puff puff) const
	{
		puff.A_BFGSpray(numRays: RayCount,
			defDamage: Random(MinDamage, MaxDamage) * puff.DamageMultiply);
	}

	final override void GetDamageValues(in out Array<int> damages) const
	{
		damages.Push(MinDamage);
		damages.Push(MaxDamage);
	}

	final override void SetDamageValues(in out Array<int> damages)
	{
		MinDamage = damages[0];
		MaxDamage = damages[1];
	}

	final override BIO_PayloadDeathFunctor Copy() const
	{
		let ret = new('BIO_PLDF_BFGSpray');
		ret.RayCount = RayCount;
		ret.MinDamage = MinDamage;
		ret.MaxDamage = MaxDamage;
		return ret;
	}

	final override void Summary(in out Array<string> readout) const
	{
		string crEsc_rc = "", crEsc_min = "", crEsc_max = "";

		if (Defaults != null)
		{
			crEsc_rc = BIO_Utils.StatFontColor(RayCount, Defaults.RayCount);
			crEsc_min = BIO_Utils.StatFontColor(MinDamage, Defaults.MinDamage);
			crEsc_max = BIO_Utils.StatFontColor(MaxDamage, Defaults.MaxDamage);
		}
		else
			crEsc_rc = crEsc_min = crEsc_max = CRESC_STATMODIFIED;
		
		readout.Push(String.Format(
			StringTable.Localize("$BIO_PLDF_BFGSPRAY"),
			crEsc_rc, RayCount, crEsc_min, MinDamage, crEsc_max, MaxDamage));
	}
}

// Projectile-adjacent actors //////////////////////////////////////////////////

class BIO_BFGExtra : BFGExtra
{
	Default
	{
		Tag "$BIO_PROJEXTRA_TAG_BFGRAY";
	}
}
