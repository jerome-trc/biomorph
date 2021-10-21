class BIO_Fist : BIO_Weapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPFIST";
		Tag "$BIO_WEAP_TAG_FIST";
		
		Weapon.SelectionOrder 3700;
		Weapon.SlotNumber 1;

		BIO_Weapon.DamageRange 2, 20;
	}

	States
	{
	Ready:
		PUNG A 1 A_WeaponReady;
		Loop;
	Deselect:
		PUNG A 1 A_BIO_Lower;
		Loop;
	Select:
		PUNG A 1 A_BIO_Raise;
		Loop;
	Fire:
		PUNG B 4;
		PUNG C 4 A_BIO_Punch;
		PUNG D 5;
		PUNG C 4;
		PUNG B 5 A_ReFire;
		Goto Ready;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(String.Format(StringTable.Localize("$BIO_STAT_FIREDATA"),
			DamageFontColor(),
			MinDamage1, MaxDamage1,
			FireCountFontColor(),
			FireCount1 == -1 ? 1 : FireCount1,
			FireTypeFontColor(),
			StringTable.Localize("$BIO_MELEE_HIT")));
	}

	action void A_BIO_Punch()
	{
		FTranslatedLineTarget t;

		int dmg = random[Punch](invoker.MinDamage1, invoker.MaxDamage1);

		if (FindInventory("PowerStrength")) dmg *= 10;

		double ang = Angle + Random2[Punch]() * (5.625 / 256);
		double pitch = AimLineAttack(ang, DEFMELEERANGE, null, 0.0, ALF_CHECK3D);

		LineAttack(ang, DEFMELEERANGE, pitch, dmg, 'Melee', "BulletPuff", LAF_ISMELEEATTACK, t);

		// Turn to face target
		if (t.LineTarget)
		{
			A_StartSound ("*fist", CHAN_WEAPON);
			Angle = t.AngleFromSource;
		}
	}
}
