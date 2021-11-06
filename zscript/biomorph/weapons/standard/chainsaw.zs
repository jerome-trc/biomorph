class BIO_Chainsaw : BIO_Weapon replaces Chainsaw
{
	mixin BIO_MeleeWeapon;

	int FireTime; property FireTimes: FireTime;

	Default
	{
		+WEAPON.MELEEWEAPON

		Obituary "$OB_MPCHAINSAW";
		Tag "$TAG_CHAINSAW";
	
		Inventory.Icon 'CSAWA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_CHAINSAW";
		
		Weapon.Kickback 0;
		Weapon.ReadySound "weapons/sawidle";
		Weapon.SelectionOrder SELORDER_CHAINSAW;
		Weapon.SlotNumber 1;
		Weapon.SlotPriority SLOTPRIO_MIN;
		Weapon.UpSound "weapons/sawup";

		BIO_Weapon.AffixMasks
			BIO_WAM_RELOADTIME | BIO_WAM_MAGSIZE,
			BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.DamageRange 2, 20;
		BIO_Weapon.FireType 'BIO_MeleeHit';
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		
		BIO_Chainsaw.FireTimes 4;
		BIO_Chainsaw.MeleeRange SAWRANGE;
		BIO_Chainsaw.LifeSteal 0.0;
	}

	States
	{
	Ready:
		SAWG CD 4 A_WeaponReady;
		Loop;
	Deselect:
		SAWG C 1 A_BIO_Deselect;
		Stop;
	Select:
		SAWG C 1 A_BIO_Select;
		Stop;
	Fire:
		SAWG AB 4
		{
			A_SetTics(invoker.FireTime);
			A_BIO_Saw();
		}
		SAWG B 0 A_ReFire;
		Goto Ready;
	Spawn:
		CSAW A 0;
		CSAW A 0 A_BIO_Spawn;
		Stop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.Push(FireTime);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime = fireTimes[0];
	}

	override void ResetStats()
	{
		super.ResetStats();

		FireTime = Default.FireTime;

		MeleeRange = Default.MeleeRange;
		LifeSteal = Default.LifeSteal;
	}

	override void UpdateDictionary()
	{
		Dict = Dictionary.Create();
		UpdateMeleeDictionary();
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout(fireTypeTag:
			GetDefaultByType('BIO_MeleeHit').CountBasedTag(FireCount1)));
		stats.Push(GenericFireTimeReadout(TrueFireTime(), "$BIO_WEAPSTAT_ATKTIME"));
	}

	override int TrueFireTime() const { return FireTime; }

	action void A_BIO_Saw(int flags = 0)
	{
		if (Player == null) return;
		FTranslatedLineTarget t;

		float range = invoker.CalcMeleeRange();
		double ang = Angle + 2.8125 * (Random2[Saw]() / 255.0);
		double slope = AimLineAttack(ang, range, t) *
			(Random2[Saw]() / 255.0);

		Actor puff;
		int actualDmg;
		[puff, actualDmg] = LineAttack(ang, range, slope, 
			Random[Saw](invoker.MinDamage1, invoker.MaxDamage1),
			'Melee', invoker.FireType1, 0, t);

		A_BIO_AlertMonsters();

		if (!t.LineTarget)
		{
			if ((flags & SF_RANDOMLIGHTMISS) && (Random[Saw]() > 64))
				player.ExtraLight = !player.ExtraLight;
			
			A_StartSound("weapons/sawfull", CHAN_WEAPON);
			return;
		}

		if (flags & SF_RANDOMLIGHTHIT)
		{
			int randVal = Random[Saw]();

			if (randVal < 64)
				player.ExtraLight = 0;
			else if (randVal < 160)
				player.ExtraLight = 1;
			else
				player.ExtraLight = 2;
		}

		if (!t.LineTarget.bDontDrain) invoker.ApplyLifeSteal(actualDmg);

		A_StartSound("weapons/sawhit", CHAN_WEAPON);
			
		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double anglediff = DeltaAngle(angle, t.angleFromSource);

			if (anglediff < 0.0)
			{
				if (anglediff < -4.5)
					angle = t.angleFromSource + 90.0 / 21;
				else
					angle -= 4.5;
			}
			else
			{
				if (anglediff > 4.5)
					angle = t.angleFromSource - 90.0 / 21;
				else
					angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			bJustAttacked = true;
	}
}