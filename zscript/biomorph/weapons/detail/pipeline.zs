enum BIO_WeaponPipelineMask : uint16
{
	BIO_WPM_NONE = 0,
	BIO_WPM_FIREFUNCTOR = 1 << 0,
	BIO_WPM_FIRETYPE = 1 << 1,
	BIO_WPM_FIRECOUNT = 1 << 2,
	BIO_WPM_DAMAGEFUNCTOR = 1 << 3,
	BIO_WPM_DAMAGEVALS = 1 << 4,
	BIO_WPM_HSPREAD = 1 << 5,
	BIO_WPM_VSPREAD = 1 << 6,
	BIO_WPM_FIRETIME = 1 << 7,
	BIO_WPM_RELOADTIME = 1 << 8,
	BIO_WPM_ALERT = 1 << 9,
	BIO_WPM_ALL = uint16.MAX
}

class BIO_WeaponPipeline play
{
	// Acts like `Actor::Default`.
	readOnly<BIO_WeaponPipeline> Prototype;
	private BIO_WeaponPipelineMask Mask;

	private Ammo Magazine;
	private int AmmoUse, AmmoUseFactor, ReloadFactor;

	private BIO_FireFunctor FireFunctor;
	private Class<Actor> FireType;
	private int FireCount;
	private BIO_DamageFunctor Damage;
	private float HSpread, VSpread, Angle, Pitch;

	int AlertFlags;
	double MaxAlertDistance;

	private Array<BIO_ProjTravelFunctor> ProjTravelFunctors;
	private Array<BIO_ProjDamageFunctor> ProjDamageFunctors;
	private Array<BIO_ProjDeathFunctor> ProjDeathFunctors;

	private string Obituary;
	private Array<string> ReadoutExtra;

	void Invoke(BIO_NewWeapon weap, int fireFactor = 1, float spreadFactor = 1.0) const
	{
		for (uint i = 0; i < FireCount * fireFactor; i++)
		{
			int dmg = Damage.Invoke();

			Actor proj = FireFunctor.Invoke(weap, FireType, dmg,
				Angle + (FRandom(-HSpread, HSpread) * spreadFactor),
				Pitch + (FRandom(-VSpread, VSpread) * spreadFactor));

			if (proj == null) continue;
			proj.SetDamage(dmg);
			
			if (proj is 'BIO_Projectile')
			{
				let tProj = BIO_Projectile(proj);
				tProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				tProj.ProjTravelFunctors.Copy(ProjTravelFunctors);
				tProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnTrueProjectileFired(weap, tProj);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnTrueProjectileFired(weap, tProj);
			}
			else if (proj is 'BIO_FastProjectile')
			{
				let fProj = BIO_FastProjectile(proj);
				fProj.ProjDamageFunctors.Copy(ProjDamageFunctors);
				fProj.ProjDeathFunctors.Copy(ProjDeathFunctors);

				for (uint i = 0; i < weap.ImplicitAffixes.Size(); i++)
					weap.ImplicitAffixes[i].OnFastProjectileFired(weap, fProj);
				for (uint i = 0; i < weap.Affixes.Size(); i++)
					weap.Affixes[i].OnFastProjectileFired(weap, fProj);
			}
		}

		weap.A_AlertMonsters(MaxAlertDistance, AlertFlags);
	}

	bool DepleteAmmo() const
	{
		return true;
	}

	string GetObituary() const
	{
		return StringTable.Localize(Obituary);
	}

	void SetFireFunctor(BIO_FireFunctor fireFunc)
	{
		if (Mask & BIO_WPM_FIREFUNCTOR) return;
		FireFunctor = fireFunc;
	}

	void SetFireType(Class<Actor> fType)
	{
		if (Mask & BIO_WPM_FIRETYPE) return;
		FireType = fType;
	}

	void SetFireCount(int fCount)
	{
		if (Mask & BIO_WPM_FIRECOUNT) return;
		FireCount = fCount;
	}

	bool DamageFunctorMutable() const
	{
		return Mask & BIO_WPM_DAMAGEFUNCTOR;
	}

	void SetDamageFunctor(BIO_DamageFunctor dmgFunc)
	{
		if (Mask & BIO_WPM_DAMAGEFUNCTOR) return;
		Damage = dmgFunc;
	}

	BIO_DamageFunctor GetDamageFunctor() const
	{
		if (Mask & BIO_WPM_DAMAGEFUNCTOR) return null;
		return Damage;
	}

	bool DamageMutable() const
	{
		return Mask & BIO_WPM_DAMAGEVALS;
	}

	void GetDamageValues(in out Array<int> damages) const
	{
		Damage.GetValues(damages);
	}

	void SetDamageValues(in out Array<int> damages)
	{
		if (mask & BIO_WPM_DAMAGEVALS) return;
		Damage.SetValues(damages);
	}

	void SetSpread(float hSpr, float vSpr)
	{
		if (!(Mask & BIO_WPM_HSPREAD))
			hSpread = hSpr;
		if (!(Mask & BIO_WPM_VSPREAD))
			vSpread = vSpr;
	}

	double, int GetAlertStats() const
	{
		return MaxAlertDistance, AlertFlags;
	}

	void SetAlertStats(double maxDist, int flags)
	{
		if (Mask & BIO_WPM_ALERT) return;
		MaxAlertDistance = maxDist;
		AlertFlags = flags;
	}

	void PushReadoutString(string str)
	{
		ReadoutExtra.Push(str);
	}

	void SetObituary(string obit)
	{
		Obituary = obit;
	}

	void Restrict(BIO_WeaponPipelineMask msk)
	{
		Mask = msk;
	}

	void ToString(in out Array<string> readout, uint ndx, bool alone) const
	{
		// If this is the weapon's only pipeline, the header is unnecessary
		// Otherwise tell the user which fire mode this is
		if (!alone)
		{
			string header = "";
			
			switch (ndx)
			{
			case 0:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_0");
				break;
			case 1:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_1");
				break;
			case 2:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_2");
				break;
			case 3:
				header = StringTable.Localize("$BIO_WEAP_STAT_HEADER_3");
				break;
			default:
				header = String.Format(
					StringTable.Localize("$BIO_WEAP_STAT_HEADER_DEFAULT"), ndx);
				break;
			}

			readout.Push(header);
		}

		readout.Push(FireFunctor.ToString(
			Prototype.FireFunctor.AsConst(), fireType, fireCount));
		readout.Push(Damage.ToString(
			Prototype.Damage.AsConst()));

		// Don't report spread unless it's non-trivial (weapons with true
		// projectiles are likely to have little to no spread)
		if (HSpread > 0.5)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				HSpread, Prototype.HSpread, invert: true);

			string hSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_HSPREAD"),
				fontColor, HSpread);

			readout.Push(hSpreadStr);
		}

		if (VSpread > 0.5)
		{
			string fontColor = BIO_Utils.StatFontColorF(
				HSpread, Prototype.VSpread, invert: true);

			string vSpreadStr = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_VSPREAD"),
				fontColor, VSpread);

			readout.Push(vSpreadStr);
		}

		for (uint i = 0; i < ReadoutExtra.Size(); i++)
			readout.Push(ReadoutExtra[i]);
	}
}

class BIO_DamageFunctor play abstract
{
	abstract int Invoke() const;
	abstract void Reset(readOnly<BIO_DamageFunctor> def);

	virtual void GetValues(in out Array<int> vals) const {}
	virtual void SetValues(in out Array<int> vals) {}

	// Output should be full localized.
	abstract string ToString(readOnly<BIO_DamageFunctor> def) const;

	readOnly<BIO_DamageFunctor> AsConst() const { return self; }
}

// Emits a random number between a minimum and a maximum.
class BIO_DmgFunc_Default : BIO_DamageFunctor
{
	private int Minimum, Maximum;

	override int Invoke() const { return Random(Minimum, Maximum); }

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDef = BIO_DmgFunc_Default(def);
		Minimum = myDef.Minimum;
		Maximum = myDef.Maximum;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Minimum, Maximum);
	}

	override void SetValues(in out Array<int> vals)
	{
		Minimum = vals[0];
		Maximum = vals[1];
	}

	void CustomSet(int minDmg, int maxDmg)
	{
		Minimum = minDmg;
		Maximum = maxDmg;
	}

	override string ToString(readOnly<BIO_DamageFunctor> def) const
	{
		let myDefs = BIO_DmgFunc_Default(def);

		string
			minClr = BIO_Utils.StatFontColor(Maximum, myDefs.Maximum),
			maxClr = BIO_Utils.StatFontColor(Minimum, myDefs.Minimum);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_DEFAULT"),
			minClr, Minimum, maxClr, Maximum);
	}
}

// Imitates the vanilla behaviour of multiplying bullet puff damage by 1D3.
class BIO_DmgFunc_1D3 : BIO_DamageFunctor
{
	private int Baseline;

	override int Invoke() const
	{
		return Baseline * Random(1, 3);
	}

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDefs = BIO_DmgFunc_1D3(def);
		Baseline = myDefs.Baseline;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	override string ToString(readOnly<BIO_DamageFunctor> def) const
	{
		let myDefs = BIO_DmgFunc_1D3(def);

		string fontColor = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			fontColor, Baseline);
	}
}

// Imitates the vanilla behaviour of multiplying projectile damage by 1D8.
class BIO_DmgFunc_1D8 : BIO_DamageFunctor
{
	private int Baseline;

	override int Invoke() const
	{
		return Baseline * Random(1, 8);
	}

	override void Reset(readOnly<BIO_DamageFunctor> def)
	{
		let myDefs = BIO_DmgFunc_1D8(def);
		Baseline = myDefs.Baseline;
	}

	override void GetValues(in out Array<int> vals) const
	{
		vals.PushV(Baseline);
	}

	override void SetValues(in out Array<int> vals)
	{
		Baseline = vals[0];
	}

	override string ToString(readOnly<BIO_DamageFunctor> def) const
	{
		let myDefs = BIO_DmgFunc_1D8(def);

		string fontColor = BIO_Utils.StatFontColor(Baseline, myDefs.Baseline);

		return String.Format(
			StringTable.Localize("$BIO_WEAP_DMGFUNC_1D3"),
			fontColor, Baseline);
	}
}

class BIO_FireFunctor play abstract
{
	abstract Actor Invoke(BIO_NewWeapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const;

	// Output is fully localized.
	protected static string FireTypeTag(Class<Actor> fireType, int count)
	{
		if (fireType is 'BIO_Projectile')
		{
			let defs = GetDefaultByType((Class<BIO_Projectile>)(fireType));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (fireType is 'BIO_FastProjectile')
		{
			let defs = GetDefaultByType((Class<BIO_FastProjectile>)(fireType));
		
			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (fireType is 'BIO_RailPuff')
		{
			let defs = GetDefaultByType((Class<BIO_RailPuff>)(fireType));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else if (fireType is 'BIO_RailSpawn')
		{
			let defs = GetDefaultByType((Class<BIO_RailSpawn>)(fireType));

			switch (count)
			{
			case -1:
			case 1: return defs.GetTag();
			default: return StringTable.Localize(defs.PluralTag);
			}
		}
		else
			return StringTable.Localize(GetDefaultByType(fireType).GetTag());
	}

	abstract string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const;

	readOnly<BIO_FireFunctor> AsConst() const { return self; }
}

class BIO_FireFunc_Default : BIO_FireFunctor
{
	override Actor Invoke(BIO_NewWeapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		return weap.A_FireProjectile(fireType, angle, useAmmo: false, pitch);
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WEAP_FIREFUNC_DEFAULT"),
			fireCount, FireTypeTag(fireType, fireCount));
	}
}

class BIO_FireFunc_Rail : BIO_FireFunctor
{
	int SpawnOffsXY, Flags;
	color Color1, Color2;

	override Actor Invoke(BIO_NewWeapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		Class<Actor> puff_t = null, spawnClass = null;

		if (fireType is 'BIO_RailPuff')
		{
			puff_t = fireType;
			spawnClass = GetDefaultByType((Class<BIO_RailPuff>)(fireType)).SpawnClass;
		}
		else if (fireType is 'BIO_RailSpawn')
		{
			spawnClass = fireType;
			puff_t = GetDefaultByType((Class<BIO_RailSpawn>)(fireType)).PuffType;
		}

		weap.A_RailAttack(dmg,
			spawnOfs_xy: SpawnOffsXY,
			useAmmo: false,
			color1: Color1,
			color2: Color2,
			flags: Flags,
			puffType: puff_t,
			spread_xy: angle,
			spread_z: pitch,
			spawnClass: spawnClass
		);

		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		Class<Actor> puff_t = null, spawnClass = null;

		if (fireType is 'BIO_RailPuff')
		{
			puff_t = fireType;
			spawnClass = GetDefaultByType((Class<BIO_RailPuff>)(fireType)).SpawnClass;
		}
		else if (fireType is 'BIO_RailSpawn')
		{
			spawnClass = fireType;
			puff_t = GetDefaultByType((Class<BIO_RailSpawn>)(fireType)).PuffType;
		}

		if (puff_t != null && spawnClass != null)
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL"), fireCount,
				FireTypeTag(puff_t, fireCount), FireTypeTag(spawnClass, fireCount));
		}
		else if (puff_t == null)
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL_NOPUFF"),
				fireCount, FireTypeTag(spawnClass, fireCount));
		}
		else if (spawnClass == null)
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL_NOSPAWN"),
				fireCount, FireTypeTag(puff_t, fireCount));
		}
		else
		{
			return String.Format(
				StringTable.Localize("$BIO_WEAP_FIREFUNC_RAIL_NOTHING"),
				fireCount);
		}
	}
}

class BIO_FireFunc_Melee : BIO_FireFunctor abstract
{
	float Range, Lifesteal;

	protected void ApplyLifeSteal(BIO_NewWeapon weap, int dmg)
	{
		let lsp = Min(Lifesteal, 1.0);
		let given = int(float(dmg) * lsp);
		weap.Owner.GiveBody(given, weap.Owner.GetMaxHealth(true) + 100);
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WEAP_FIREFUNC_MELEE"),
			fireCount);
	}
}

class BIO_FireFunc_Fist : BIO_FireFunc_Melee
{
	override Actor Invoke(BIO_NewWeapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		FTranslatedLineTarget t;

		if (weap.Owner.FindInventory('PowerStrength', true)) dmg *= 10;
		
		double ang = Angle + Random2[Punch]() * (5.625 / 256);
		double ptch = weap.AimLineAttack(ang, Range, null, 0.0, ALF_CHECK3D);

		Actor puff = null;
		int actualDmg = -1;

		[puff, actualDmg] = weap.LineAttack(ang, Range, ptch, dmg,
			'Melee', fireType, LAF_ISMELEEATTACK, t);

		// Turn to face target
		if (t.LineTarget)
		{
			weap.A_StartSound("*fist", CHAN_WEAPON);
			Angle = t.AngleFromSource;
			if (!t.lineTarget.bDontDrain) ApplyLifeSteal(weap, actualDmg);
		}

		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return StringTable.Localize("$BIO_WEAP_FIREFUNC_FIST");
	}
}

class BIO_FireFunc_Chainsaw : BIO_FireFunc_Melee
{
	override Actor Invoke(BIO_NewWeapon weap, Class<Actor> fireType,
		int dmg, float angle, float pitch) const
	{
		int flags = 0; // TODO: Sort this out
		FTranslatedLineTarget t;

		double ang = Angle + 2.8125 * (Random2[Saw]() / 255.0);
		double slope = weap.AimLineAttack(ang, Range, t) *
			(Random2[Saw]() / 255.0);

		Actor puff = null;
		int actualDmg = 0;
		[puff, actualDmg] = weap.LineAttack(ang, Range, slope, dmg,
			'Melee', fireType, 0, t);

		if (!t.LineTarget)
		{
			if ((flags & SF_RANDOMLIGHTMISS) && (Random[Saw]() > 64))
				weap.Player.ExtraLight = !weap.Player.ExtraLight;
			
			weap.A_StartSound("weapons/sawfull", CHAN_WEAPON);
			return null;
		}

		if (flags & SF_RANDOMLIGHTHIT)
		{
			int randVal = Random[Saw]();

			if (randVal < 64)
				weap.Player.ExtraLight = 0;
			else if (randVal < 160)
				weap.Player.ExtraLight = 1;
			else
				weap.Player.ExtraLight = 2;
		}

		if (!t.LineTarget.bDontDrain) ApplyLifeSteal(weap, actualDmg);

		weap.A_StartSound("weapons/sawhit", CHAN_WEAPON);
			
		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double angleDiff = weap.DeltaAngle(angle, t.angleFromSource);

			if (angleDiff < 0.0)
			{
				if (angleDiff < -4.5)
					angle = t.angleFromSource + 90.0 / 21;
				else
					angle -= 4.5;
			}
			else
			{
				if (angleDiff > 4.5)
					angle = t.angleFromSource - 90.0 / 21;
				else
					angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			weap.bJustAttacked = true;

		return null;
	}

	override string ToString(readOnly<BIO_FireFunctor> def,
		Class<Actor> fireType, int fireCount) const
	{
		return StringTable.Localize("$BIO_WEAP_FIREFUNC_CHAINSAW");
	}
}

class BIO_WeaponPipelineBuilder play
{
	private BIO_WeaponPipeline Pipeline;

	static BIO_WeaponPipelineBuilder Create()
	{
		let ret = new('BIO_WeaponPipelineBuilder');
		ret.Pipeline = new('BIO_WeaponPipeline');
		return ret;
	}

	BIO_WeaponPipelineBuilder BasicProjectilePipeline(Class<Actor> fireType,
		int fireCount, int minDamage, int maxDamage, float hSpread, float vSpread)
	{
		Pipeline.SetFireFunctor(new('BIO_FireFunc_Default'));
		Pipeline.SetFireType(fireType);
		Pipeline.SetFireCount(fireCount);

		let dmgFunc = new('BIO_DmgFunc_Default');
		dmgFunc.CustomSet(minDamage, maxDamage);
		Pipeline.SetDamageFunctor(dmgFunc);

		Pipeline.SetSpread(hSpread, vSpread);
		return self;
	}

	BIO_WeaponPipelineBuilder Ammo(Class<Ammo> ammo_t, Class<Ammo> magazine_t,
		int ammoUse = 1, int ammoUseFactor = 1, int reloadFactor = 1)
	{
		return self;
	}

	BIO_WeaponPipelineBuilder Alert(double maxDist, int flags)
	{
		Pipeline.SetAlertStats(maxDist, flags);
		return self;
	}

	// Argument should be fully localized.
	BIO_WeaponPipelineBuilder CustomReadout(string str)
	{
		Pipeline.PushReadoutString(str);
		return self;
	}

	// Argument should be non-localized.
	BIO_WeaponPipelineBuilder Obituary(string obit)
	{
		Pipeline.SetObituary(obit);
		return self;
	}

	BIO_WeaponPipelineBuilder Restrictions(BIO_WeaponPipelineMask mask)
	{
		Pipeline.Restrict(mask);
		return self;
	}

	BIO_WeaponPipeline Build() const
	{
		return Pipeline;
	}
}
