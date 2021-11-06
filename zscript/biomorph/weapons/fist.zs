class BIO_Fist : BIO_MeleeWeapon replaces Fist
{
	int FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;
	property FireTimes: FireTime1, FireTime2, FireTime3, FireTime4, FireTime5;

	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPFIST";
		Tag "$BIO_WEAP_TAG_FIST";

		Inventory.Icon 'PUNGA0';
		
		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority 1.0;

		BIO_Weapon.AffixMasks BIO_WAM_MAGAZINELESS, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.DamageRange 2, 20;
		BIO_Weapon.FireType 'BIO_MeleeHit';

		BIO_Fist.FireTimes 4, 4, 5, 4, 5;
	}

	States
	{
	Ready:
		PUNG A 1 A_WeaponReady;
		Loop;
	Deselect:
		PUNG A 0 A_BIO_Deselect;
		Loop;
	Select:
		PUNG A 0 A_BIO_Select;
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

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;
		FireTime3 = Default.FireTime3;
		FireTime4 = Default.FireTime4;
		FireTime5 = Default.FireTime5;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout(fireTypeTag:
			GetDefaultByType('BIO_MeleeHit').CountBasedTag(FireCount1)));
		stats.Push(GenericFireTimeReadout(TrueFireTime(), "$BIO_WEAPSTAT_ATKTIME"));
		stats.Push(
			String.Format(
				StringTable.Localize("$BIO_WEAPSTAT_BERSERKMULTI"),
				900));
	}

	override int TrueFireTime() const
	{
		return FireTime1 + FireTime2 + FireTime3 + FireTime4 + FireTime5;
	}

	action void A_BIO_Punch()
	{
		FTranslatedLineTarget t;

		int dmg = Random[Punch](invoker.MinDamage1, invoker.MaxDamage1);

		if (FindInventory('PowerStrength', true)) dmg *= 10;
		
		double ang = Angle + Random2[Punch]() * (5.625 / 256);
		double pitch = AimLineAttack(ang, invoker.MeleeRange1, null, 0.0, ALF_CHECK3D);

		Actor puff = null;
		int actualDmg = -1;

		[puff, actualDmg] = LineAttack(ang, invoker.MeleeRange1, pitch, dmg,
			'Melee', invoker.FireType1, LAF_ISMELEEATTACK, t);

		// Turn to face target
		if (t.LineTarget)
		{
			A_StartSound("*fist", CHAN_WEAPON);
			Angle = t.AngleFromSource;
			if (!t.lineTarget.bDontDrain) invoker.ApplyLifeSteal(actualDmg);
		}
	}
}
