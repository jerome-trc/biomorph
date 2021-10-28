class BIO_Fist : BIO_Weapon replaces Fist
{
	mixin BIO_MeleeWeapon;

	int FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;

	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPFIST";
		Tag "$BIO_WEAP_TAG_FIST";

		Inventory.Icon "PUNGA0";
		
		Weapon.SelectionOrder 3700;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority 63.0;

		BIO_Weapon.AffixMasks
			BIO_WAM_RELOADTIME | BIO_WAM_MAGSIZE,
			BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.DamageRange 2, 20;

		BIO_Fist.FireTimes 4, 4, 5, 4, 5;
		BIO_Fist.MeleeRange DEFMELEERANGE;
		BIO_Fist.LifeSteal 0.0;
	}

	States
	{
	Ready:
		PUNG A 1 A_WeaponReady;
		Loop;
	Deselect.Loop:
		PUNG A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		PUNG A 1 A_BIO_Raise;
		Loop;
	Fire:
		PUNG B 4 A_SetTics(invoker.FireTime1);
		PUNG C 4
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Punch();
		}
		PUNG D 5 A_SetTics(invoker.FireTime3);
		PUNG C 4 A_SetTics(invoker.FireTime4);
		PUNG B 5
		{
			A_SetTics(invoker.FireTime5);
			A_ReFire();
		}
		Goto Ready;
	}

	override void GetFireTimes(in out Array<int> fireTimes) const
	{
		fireTimes.PushV(FireTime1, FireTime2, FireTime3, FireTime4, FireTime5);
	}

	override void SetFireTimes(Array<int> fireTimes)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
		FireTime3 = fireTimes[2];
		FireTime4 = fireTimes[3];
		FireTime5 = fireTimes[4];
	}

	override void GetReloadTimes(in out Array<int> _, bool _) const {}
	override void SetReloadTimes(Array<int> _, bool _) {}

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;
		FireTime3 = Default.FireTime3;
		FireTime4 = Default.FireTime4;
		FireTime5 = Default.FireTime5;

		MeleeRange = Default.MeleeRange;
		LifeSteal = Default.LifeSteal;
	}

	override void UpdateDictionary()
	{
		Dict = Dictionary.Create();
		Dict.Insert(DICTKEY_MELEERANGE, String.Format("%f", MeleeRange));
		Dict.Insert(DICTKEY_LIFESTEAL, String.Format("%f", LifeSteal));
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout(fireTypeTag: "$BIO_MELEE_HIT"));
		stats.Push(GenericFireTimeReadout(
			FireTime1 + FireTime2 + FireTime3 + FireTime4 + FireTime5,
			"$BIO_WEAPSTAT_ATKTIME"));
	}

	override int DefaultFireTime() const
	{
		return Default.FireTime1 + Default.FireTime2 + Default.FireTime3 +
			Default.FireTime4 + Default.FireTime5;
	}

	action void A_BIO_Punch()
	{
		FTranslatedLineTarget t;

		int dmg = Random[Punch](invoker.MinDamage1, invoker.MaxDamage1);

		if (FindInventory("PowerStrength")) dmg *= 10;
		
		float range = invoker.CalcMeleeRange();
		double ang = Angle + Random2[Punch]() * (5.625 / 256);
		double pitch = AimLineAttack(ang, range, null, 0.0, ALF_CHECK3D);

		Actor puff = null;
		int actualDmg = -1;

		[puff, actualDmg] = LineAttack(ang, range, pitch, dmg,
			'Melee', "BulletPuff", LAF_ISMELEEATTACK, t);

		// Turn to face target
		if (t.LineTarget)
		{
			A_StartSound("*fist", CHAN_WEAPON);
			Angle = t.AngleFromSource;
			if (!t.lineTarget.bDontDrain) invoker.ApplyLifeSteal(actualDmg);
		}
	}
}
