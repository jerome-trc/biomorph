class BIO_StateTimeGroup
{
	string Tag;
	Array<int> Times, Minimums;

	private void Populate(state basis)
	{
		for (state s = basis; s.InStateSequence(basis); s = s.NextState)
		{
			if (s.Tics == 0) continue; // `TNT1 A 0` and the like
			if (s.bSlow) continue; 
			
			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set to 0,
			// effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			else if (s.bSlow) // States marked `Slow` are kept immutable
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	static BIO_StateTimeGroup FromState(state basis, string tag = "")
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Populate(basis);
		return ret;
	}

	static BIO_StateTimeGroup From2States(state basis1, state basis2, string tag = "")
	{
		let ret = new('Bio_StateTimeGroup');
		ret.Tag = Tag;
		ret.Populate(basis1);
		ret.Populate(basis2);
		return ret;
	}

	static BIO_StateTimeGroup FromStates(Array<state> basisArr, string tag = "")
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;

		for (uint i = 0; i < basisArr.Size(); i++)
			ret.Populate(basisArr[i]);

		return ret;
	}
}

class BIO_NewWeapon : DoomWeapon abstract
{
	mixin BIO_Gear;

	meta Class<BIO_NewWeapon> UniqueBase; property UniqueBase: UniqueBase;
	BIO_WeaponFlags BIOFlags; property Flags: BIOFlags;
	uint AffixMask; property AffixMask: AffixMask;
	int RaiseSpeed, LowerSpeed;
	property SwitchSpeeds: RaiseSpeed, LowerSpeed;

	meta Class<Ammo> MagazineType1, MagazineType2;
	property MagazineType: MagazineType1;
	property MagazineType1: MagazineType1;
	property MagazineType2: MagazineType2;
	property MagazineTypes: MagazineType1, MagazineType2;

	int MagazineSize1, MagazineSize2;
	property MagazineSize: MagazineSize1;
	property MagazineSize1: MagazineSize1;
	property MagazineSize2: MagazineSize2;
	property MagazineSizes: MagazineSize1, MagazineSize2;

	// Reloading 1 round costs ReloadFactor rounds in reserve.
	int ReloadFactor1, ReloadFactor2;
	property ReloadFactor: ReloadFactor1;
	property ReloadFactor1: ReloadFactor1;
	property ReloadFactor2: ReloadFactor2;
	property ReloadFactors: ReloadFactor1, ReloadFactor2;

	int MinAmmoReserve1, MinAmmoReserve2;
	property MinAmmoReserve: MinAmmoReserve1;
	property MinAmmoReserve1: MinAmmoReserve1;
	property MinAmmoReserve2: MinAmmoReserve2;
	property MinAmmoReserves: MinAmmoReserve1, MinAmmoReserve2;

	protected Ammo Magazine1, Magazine2;

	private uint LastPipeline;
	Array<BIO_WeaponPipeline> Pipelines;
	Array<BIO_StateTimeGroup> FireTimeGroups, ReloadTimeGroups;

	Array<BIO_NewWeaponAffix> ImplicitAffixes, Affixes;
	Array<string> StatReadout, AffixReadout;

	Default
	{
		-SPECIAL
		+DONTGIB
		+NOBLOCKMONST
		+THRUACTORS
		+USESPECIAL
		+WEAPON.ALT_AMMO_OPTIONAL
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT

		Activation
			THINGSPEC_ThingActs | THINGSPEC_ThingTargets | THINGSPEC_Switch;
		Height 8;
		Radius 16;

		Inventory.PickupMessage "";

		Weapon.BobRangeX 0.5;
        Weapon.BobRangeY 0.5;
        Weapon.BobSpeed 1.2;
        Weapon.BobStyle 'Alpha';

		BIO_NewWeapon.AffixMask BIO_WAM_NONE;
		BIO_NewWeapon.Flags BIO_WF_NONE;
		BIO_NewWeapon.Grade BIO_GRADE_NONE;
		BIO_NewWeapon.MinAmmoReserves 1, 1;
		BIO_NewWeapon.Rarity BIO_RARITY_COMMON;
		BIO_NewWeapon.ReloadFactors 1, 1;
		BIO_NewWeapon.SwitchSpeeds 6, 6;
		BIO_NewWeapon.UniqueBase '';
	}

	States
	{
	Select.Loop:
		#### # 1 A_BIO_Raise;
		Loop;
	Deselect.Loop:
		#### # 1 A_BIO_Lower;
		Loop;
	Spawn.Common:
		#### # 4;
		#### # 1 A_GroundHit;
		Goto Spawn.Common + 1;
	Spawn.Mutated:
		#### # 4;
		#### # 1
		{
			A_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_GroundHit;
		#### # 1 Bright
		{
			A_GroundHit();
			A_SetTranslation('BIO_Mutated');
		}
		#### ##### 1 Bright A_GroundHit;
		Goto Spawn.Mutated + 1;
	Spawn.Unique:
		#### # 4;
		#### # 1
		{
			A_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_GroundHit;
		#### # 1 Bright
		{
			A_GroundHit();
			A_SetTranslation('BIO_Unique');
		}
		#### ##### 1 Bright A_GroundHit;
		Goto Spawn.Unique + 1;
	}

	// Parent overrides ========================================================

	override void BeginPlay()
	{
		super.BeginPlay();
		SetTag(GetColoredTag());

		if (Abs(Vel.Z) <= 0.01)
		{
			bSpecial = true;
			bThruActors = false;
			HitGround = true;
		}
	}

	// The player can't pick up a weapon if they're full on them,
	// or already have one of this class.
	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher)) return false;

		let bioPlayer = BIO_Player(toucher);
		if (bioPlayer == null) return false;

		if (bioPlayer.IsFullOnWeapons()) return false;

		return true;
	}

	// Prevents picking up a weapon if one weapon of that class is already held.
	override bool HandlePickup(Inventory item)
	{
		if (item.GetClass() == self.GetClass()) return true;
		return super.HandlePickup(item);
	}

	// For now, weapons cannot be cannibalised for ammunition.
	override bool TryPickupRestricted(in out Actor toucher) { return false; }

	override string PickupMessage()
	{
		string ret = String.Format(StringTable.Localize(PickupMsg), GetTag());
		ret = ret .. " [\cn" .. SlotNumber .. "\c-]";
		return ret;
	}

	override void AttachToOwner(Actor newOwner)
	{
		if (!PreviouslyPickedUp) RLMDangerLevel();
		PreviouslyPickedUp = true;

		// Weapon::AttachToOwner() calls AddAmmo() for both types, which we
		// don't want. This next bit is silly, but beats re-implementing
		// that function (and having to watch if it changes upstream)
		AmmoGive1 = AmmoGive2 = 0;
		super.AttachToOwner(newOwner);
		AmmoGive1 = Default.AmmoGive1;
		AmmoGive2 = Default.AmmoGive2;

		BIO_GlobalData.Get().OnWeaponAcquired(Grade);

		if (Pipelines.Size() < 1) Init();
		
		// Get a pointer to primary ammo (which is either AmmoType1 or
		// MagazineType1). If it isn't found, generate and attach it
		if (Magazine1 == null && AmmoType1 != null)
		{
			Magazine1 =
				MagazineType1 != null ?
				Ammo(FindInventory(MagazineType1)) :
				Ammo(FindInventory(AmmoType1));

			if (Magazine1 == null)
			{
				Magazine1 = Ammo(Actor.Spawn(MagazineType1));
				Magazine1.Amount = Max(Default.MagazineSize1, 0);
				Magazine1.AttachToOwner(newOwner);
			}
		}

		// Same for secondary:
		if (Magazine2 == null && AmmoType2 != null)
		{
			Magazine2 =
				MagazineType2 != null ?
				Ammo(FindInventory(MagazineType2)) :
				Ammo(FindInventory(AmmoType2));

			if (Magazine2 == null)
			{
				Magazine2 = Ammo(Actor.Spawn(MagazineType2));
				Magazine2.Amount = Max(Default.MagazineSize2, 0);
				Magazine2.AttachToOwner(newOwner);
			}
		}

		if (MagazineType1 == MagazineType2) Magazine2 = Magazine1;
	}

	override void OnDrop(Actor dropper)
	{
		super.OnDrop(dropper);
		HitGround = false;
	}

	override void Activate(Actor activator)
	{
		super.Activate(activator);
		
		let bioPlayer = BIO_Player(activator);
		if (bioPlayer == null) return;

		if (Pipelines.Size() < 1) Init();

		string output = GetTag() .. "\n\n";

		for (uint i = 0; i < StatReadout.Size(); i++)
			output.AppendFormat("%s\n", StatReadout[i]);

		if (AffixReadout.Size() > 0)
		{
			output = output .. "\n";

			for (uint i = 0; i < AffixReadout.Size(); i++)
				output.AppendFormat("\cj%s\n", AffixReadout[i]);
		}

		output.DeleteLastCharacter();
		bioPlayer.A_Print(output, 5.0);
	}

	override bool DepleteAmmo(bool altFire, bool checkEnough, int ammoUse)
	{
		if (sv_infiniteammo || (Owner.FindInventory('PowerInfiniteAmmo', true) != null))
			return true;

		if (checkEnough && !CheckAmmo(altFire ? AltFire : PrimaryFire, false, false, ammoUse))
			return false;

		if (!altFire)
		{
			if (Magazine1 != null)
			{
				if (ammoUse >= 0)
					Magazine1.Amount -= ammoUse;
				else
					Magazine1.Amount -= AmmoUse1;
			}

			if (bPRIMARY_USES_BOTH && Magazine2 != null)
				Magazine2.Amount -= AmmoUse2;
		}
		else
		{
			if (Magazine2 != null)
				Magazine2.Amount -= AmmoUse2;
			if (bALT_USES_BOTH && Magazine1 != null)
				Magazine1.Amount -= AmmoUse1;
		}

		if (Magazine1 != null && Magazine1.Amount < 0)
			Magazine1.Amount = 0;

		if (Magazine2 != null && Magazine2.Amount < 0)
			Magazine2.Amount = 0;
		
		return true;
	}

	override string GetObituary(Actor victim, Actor inflictor, Name mod, bool playerAtk)
	{
		return Pipelines[LastPipeline].GetObituary();
	}

	// Virtuals and abstracts ==================================================

	abstract void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const;
	abstract void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const;
	virtual void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const {}

	virtual void OnDeselect() {}
	virtual void OnSelect() {}

	/*	The first return value indicates if the mutagen should reset the weapon's
		stats, set the corrupted flag, and try for a generic corruption effect.
		The second return value indicates if the mutagen should be consumed.
	*/
	virtual bool, bool OnCorrupt() { return true, true; }

	// Called after all other weapon details have been drawn.
	virtual ui void DrawToHUD(BIO_StatusBar sbar) const {}

	// Actions =================================================================

	protected action bool A_BIO_Fire(uint pipeline = 0, int fireFactor = 1,
		float spreadFactor = 1.0)
	{
		invoker.LastPipeline = pipeline;

		bool secAmmo = invoker.Pipelines[pipeline].UsesSecondaryMagazine();

		if (!invoker.DepleteAmmo(secAmmo, true,
			!secAmmo ? invoker.AmmoUse1 : invoker.AmmoUse2 * fireFactor))
			return false;

		invoker.Pipelines[pipeline].Invoke(invoker, fireFactor, spreadFactor);
		return true;
	}

	// If no argument is given, try to reload as much of the magazine as 
	// possible. Otherwise, try to reload the given amount of rounds.
	action void A_LoadMag(uint amt = 0, bool secondary = false)
	{
		Ammo magItem = null, reserveAmmo = null;
		int factor = -1, magSize = -1, reserve = -1;
		
		if (!secondary)
		{
			magItem = invoker.Magazine1;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType1));
			magSize = invoker.MagazineSize1;
			factor = invoker.ReloadFactor1;
			reserve = reserveAmmo.Amount / factor;
		}
		else
		{
			magItem = invoker.Magazine2;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType2));
			magSize = invoker.MagazineSize2;
			factor = invoker.ReloadFactor2;
			reserve = reserveAmmo.Amount / factor;
		}

		let diff = Min(reserve, amt > 0 ? amt : magSize - magItem.Amount);
		magItem.Amount += diff;

		int subtract = diff * factor;
		reserveAmmo.Amount -= subtract;
	}

	protected action state A_AutoReload(bool secondary = false,
		bool single = false, int min = -1)
	{
		if (invoker.SufficientAmmo(secondary))
			return state(null);
		
		if (min == -1) min = !secondary ? invoker.AmmoUse1 : invoker.AmmoUse2;
		
		if ((!secondary ? invoker.Magazine1 : invoker.Magazine2).Amount >= min)
			return state(null);

		let cv = BIO_CVar.AutoReload(Player);

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && single))
			return ResolveState('Reload');
		else
			return ResolveState('Ready');
	}

	protected action void A_EmptyMagazine(bool secondary = false)
	{
		Ammo magItem = null, reserveAmmo = null;
		int factor = -1;

		if (!secondary)
		{
			magItem = invoker.Magazine1;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType1));
			factor = invoker.ReloadFactor1;
		}
		else
		{
			magItem = invoker.Magazine2;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType2));
			factor = invoker.ReloadFactor2;
		}

		reserveAmmo.Amount += magItem.Amount * factor;
		magItem.Amount -= magItem.Amount;
	}

	/*	Call from the weapon's Spawn state, after two frames of the weapon's 
		pickup sprite (each 0 tics long). Puts the weapon into a new loop with
		appropriate behaviour for its rarity (e.g., blinking cyan if mutated).
	*/
	protected action state A_BIO_Spawn()
	{
		if (invoker.Rarity == BIO_RARITY_UNIQUE)
			return ResolveState('Spawn.Unique');
		else if (invoker.Affixes.Size() > 0)
			return ResolveState('Spawn.Mutated');
		else
			return ResolveState('Spawn.Common');
	}

	/*	Call from the weapon's Deselect state, during one frame of the weapon's
		ready sprite (0 tics long). Runs a callback and puts the weapon in a 
		lowering loop.
	*/
	protected action state A_BIO_Deselect()
	{
		invoker.OnDeselect();
		return ResolveState('Deselect.Loop');
	}

	/*	Call from the weapon's Select state, during one frame of the weapon's
		ready sprite (0 tics long). Runs a callback and puts the weapon in a 
		raising loop.
	*/
	protected action state A_BIO_Select()
	{
		invoker.OnSelect();
		return ResolveState('Select.Loop');
	}

	protected action void A_GroundHit()
	{
		if (Abs(Vel.Z) <= 0.01 && !invoker.HitGround)
		{
			A_StartSound("bio/weap/gundrop_0");
			A_ScaleVelocity(0.5);
			bSpecial = true;
			bThruActors = false;
			invoker.HitGround = true;
		}
	}

	protected action void A_SetFireTime(
		uint ndx, uint grp = 0, int modifier = 0)
	{
		A_SetTics(modifier + invoker.FireTimeGroups[grp].Times[ndx]);
	}

	protected action void A_SetReloadTime(
		uint ndx, uint grp = 0, int modifier = 0)
	{
		A_SetTics(modifier + invoker.ReloadTimeGroups[grp].Times[ndx]);
	}

	protected action void A_PresetRecoil(Class<BIO_RecoilThinker> recoil_t,
		float scale = 1.0, bool invert = false)
	{
		BIO_RecoilThinker.Create(recoil_t, BIO_NewWeapon(invoker), scale, invert);
	}

	protected action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	protected action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }

	// Getters =================================================================

	Ammo, Ammo GetMagazines() const { return Magazine1, Magazine2; }

	bool MagazineEmpty(bool secondary = false) const
	{
		return !secondary ? Magazine1.Amount <= 0 : Magazine2.Amount <= 0;
	}

	bool MagazineFull(bool secondary = false) const
	{
		return !secondary ?
			Magazine1.Amount >= MagazineSize1 :
			Magazine2.Amount >= MagazineSize2;
	}

	bool SufficientAmmo(bool secondary = false, int multi = 1) const
	{
		if (!secondary)
		{
			if (Magazine1.Amount < (AmmoUse1 * multi)) return false;
			return true;
		}
		else
		{
			if (Magazine2.Amount < (AmmoUse2 * multi)) return false;
			return true;
		}
	}

	bool CanReload(bool secondary = false) const
	{
		Ammo magItem = null, reserveAmmo = null;
		int factor = -1, magSize = -1, minReserve = -1;
		
		if (!secondary)
		{
			magItem = Magazine1;
			reserveAmmo = Ammo(Owner.FindInventory(AmmoType1));
			magSize = MagazineSize1;
			factor = ReloadFactor1;
			minReserve = MinAmmoReserve1;
		}
		else
		{
			magItem = Magazine2;
			reserveAmmo = Ammo(Owner.FindInventory(AmmoType2));
			magSize = MagazineSize2;
			factor = ReloadFactor2;
			minReserve = MinAmmoReserve2;
		}

		int minAmt = minReserve * factor;

		// Insufficient reserves
		if (reserveAmmo == null || reserveAmmo.Amount < minAmt)
			return false;

		// Magazine's already full
		if (magItem.Amount >= magSize)
			return false;

		return true;
	}

	bool DamageMutable() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DamageMutable())
				return true;

		return false;
	}

	bool DealsAnyDamage() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DealsAnyDamage())
				return true;

		return false;
	}

	// Modifying ===============================================================

	private void Teardown()
	{
		Pipelines.Clear();
		FireTimeGroups.Clear();
		ReloadTimeGroups.Clear();
	}

	private void Init()
	{
		Teardown();

		InitPipelines(Pipelines);
		InitFireTimes(FireTimeGroups);
		InitReloadTimes(ReloadTimeGroups);

		// Inform pipelines of their indices
		for (uint i = 0; i < Pipelines.Size(); i++)
			Pipelines[i].Index = i;

		OnWeaponChange();
	}

	private void Reset()
	{
		Teardown();

		InitPipelines(Pipelines);
		InitFireTimes(FireTimeGroups);
		InitReloadTimes(ReloadTimeGroups);

		bNoAutoFire = Default.bNoAutoFire;
		bNoAlert = Default.bNoAlert;
		bNoAutoAim = Default.bNoAutoAim;
		bMeleeWeapon = Default.bMeleeWeapon;

		AmmoUse1 = Default.AmmoUse1;
		AmmoUse2 = Default.AmmoUse2;

		BobRangeX = Default.BobRangeX;
		BobRangeY = Default.BobRangeY;
		BobSpeed = Default.BobSpeed;
		BobStyle = Default.BobStyle;
		KickBack = Default.KickBack;

		BIOFlags = Default.BIOFlags;
		
		RaiseSpeed = Default.RaiseSpeed;
		LowerSpeed = Default.LowerSpeed;
		
		ReloadFactor1 = Default.ReloadFactor1;
		ReloadFactor2 = Default.ReloadFactor2;

		MinAmmoReserve1 = Default.MinAmmoReserve1;
		MinAmmoReserve2 = Default.MinAmmoReserve2;

		// Inform pipelines of their indices
		for (uint i = 0; i < Pipelines.Size(); i++)
			Pipelines[i].Index = i;
	}

	void OnWeaponChange()
	{
		Array<BIO_WeaponPipeline> pplDefs;
		Array<BIO_StateTimeGroup> fireTimeDefs, reloadTimeDefs;

		self.Default.InitPipelines(pplDefs);
		self.Default.InitFireTimes(fireTimeDefs);
		self.Default.InitReloadTimes(reloadTimeDefs);

		StatReadout.Clear();

		for (uint i = 0; i < Pipelines.Size(); i++)
			Pipelines[i].ToString(StatReadout, Pipelines.Size() == 1);

		for (uint i = 0; i < FireTimeGroups.Size(); i++)
		{
			int total = BIO_Utils.IntArraySum(FireTimeGroups[i].Times),
				totalDef = BIO_Utils.IntArraySum(fireTimeDefs[i].Times);

			string str = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_FIRETIME"),
				BIO_Utils.StatFontColor(total, totalDef),
				float(total) / float(TICRATE));

			string grpTag = StringTable.Localize(FireTimeGroups[i].Tag);

			if (grpTag.Length() > 1)
				str.AppendFormat(" (\c[Yellow]%s\c[MidGrey])", grpTag);

			StatReadout.Push(str);
		}

		for (uint i = 0; i < ReloadTimeGroups.Size(); i++)
		{
			int total = BIO_Utils.IntArraySum(ReloadTimeGroups[i].Times),
				totalDef = BIO_Utils.IntArraySum(reloadTimeDefs[i].Times);

			string str = String.Format(
				StringTable.Localize("$BIO_WEAP_STAT_RELOADTIME"),
				BIO_Utils.StatFontColor(total, totalDef),
				float(total) / float(TICRATE));

			string grpTag = StringTable.Localize(ReloadTimeGroups[i].Tag);

			if (grpTag.Length() > 1)
				str.AppendFormat(" (\c[Yellow]%s\c[MidGrey])", grpTag);

			StatReadout.Push(str);
		}

		AffixReadout.Clear();

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ToString(AffixReadout, self);

		// Blank line between implicit and explicit affixes
		if (ImplicitAffixes.Size() > 0)
			AffixReadout.Push("");

		if (BIOFlags & BIO_WF_AFFIXESHIDDEN)
			AffixReadout.Push("\cg" .. StringTable.Localize("$BIO_AFFIXESUNKNOWN"));
		else
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].ToString(AffixReadout, self);
		}
	}

/* 
	// Does not alter stats, and does not apply the newly-added affixes.
	// Returns `false` if there are no compatible affixes to add.
	bool AddRandomAffix()
	{
		Array<BIO_NewWeaponAffix> eligibles;

		if (!BIO_GlobalData.Get().AllEligibleWeaponAffixes(eligibles, self))
			return false;

		if (Rarity == BIO_RARITY_COMMON)
		{
			Rarity = BIO_RARITY_MUTATED;
			SetTag(Default.GetTag());
			SetTag(GetColoredTag());
		}

		uint e = Affixes.Push(eligibles[Random(0, eligibles.Size() - 1)]);
		Affixes[e].Init(self);
		return true;
	}

	// Affects explicit affixes only.
	void RandomizeAffixes()
	{
		Reset();

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].Apply(self);

		uint c = Random(2, MAX_AFFIXES);

		for (uint i = 0; i < c; i++)
		{
			if (AddRandomAffix())
				Affixes[Affixes.Size() - 1].Apply(self);
		}
	}
 */

	// Utility =================================================================

	void ApplyLifeSteal(float percent, int dmg) const
	{
		let lsp = Min(percent, 1.0);
		let given = int(float(dmg) * lsp);
		Owner.GiveBody(given, Owner.GetMaxHealth(true) + 100);
	}

	// Substitutes for attack actions ==========================================

	// (The crime part, where we imitate several gzdoom.pk3 functions because
	// their semantics cave in if called from outside the weapon's state machine.)

	Actor BIO_FireProjectile(Class<Actor> proj_t, double angle = 0,
		double spawnofs_xy = 0, double spawnheight = 0,
		int flags = 0, double pitch = 0)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle - 90.0;
		Vector2 ofs = AngleToVector(ang, spawnofs_xy);
		double shootangle = Owner.Angle;

		if (flags & FPF_AIMATANGLE) shootangle += angle;

		// Temporarily adjusts the pitch
		double playerPitch = Owner.Pitch;
		Owner.Pitch += pitch;
		let misl = Owner.SpawnPlayerMissile(proj_t, shootangle, ofs.X, ofs.Y,
			spawnheight, t, false, (flags & FPF_NOAUTOAIM) != 0);
		Owner.Pitch = playerPitch;

		// Automatic handling of seeker missiles
		if (misl != null)
		{
			if (flags & FPF_TRANSFERTRANSLATION)
				misl.Translation = Translation;
			if (t.LineTarget && !t.Unlinked && misl.bSeekerMissile)
				misl.Tracer = t.LineTarget;

			if (!(flags & FPF_AIMATANGLE))
			{
				// This original implementation is to aim straight ahead and then offset
				// the angle from the resulting direction. 
				misl.Angle += angle;
				misl.VelFromAngle(misl.Vel.XY.Length());
			}
		}
		return misl;
	}

	void BIO_FireBullets(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, Class<Actor> puff_t, int flags = 1, double range = 0.0,
		Class<Actor> missile = null, double spawnHeight = 32.0, double spawnOfs_xy = 0.0)
	{
		int i;
		double bangle, bslope = 0.0;
		int laflags = (flags & FBF_NORANDOMPUFFZ)? LAF_NORANDOMPUFFZ : 0;
		FTranslatedLineTarget t;

		if (range == 0)	range = PLAYERMISSILERANGE;

		if (!(flags & FBF_NOFLASH)) BIO_Player(Owner).PlayAttacking2();
		if (!(flags & FBF_NOPITCH)) bslope = BulletSlope();

		bangle = Angle;

		Owner.A_StartSound(AttackSound, CHAN_WEAPON);

		if ((numBullets == 1 && !Player.Refire) || numBullets == 0)
		{
			int damage = bulletDmg;

			if (!(flags & FBF_NORANDOM))
				damage *= random[cabullet](1, 3);

			let puff = LineAttack(bangle, range, bslope, damage, 'Hitscan', puff_t, laflags, t);

			if (missile != null)
			{
				bool temp = false;
				double ang = Angle - 90;
				Vector2 ofs = AngleToVector(ang, Spawnofs_xy);
				Actor proj = SpawnPlayerMissile(missile, bangle, ofs.X, ofs.Y, Spawnheight);
				if (proj)
				{
					if (!puff)
					{
						temp = true;
						puff = LineAttack(bangle, range, bslope, 0, 'Hitscan', puff_t, laflags | LAF_NOINTERACT, t);
					}
					AimBulletMissile(proj, puff, flags, temp, false);
					if (t.unlinked)
					{
						// Arbitary portals will make angle and pitch calculations unreliable.
						// So use the angle and pitch we passed instead.
						proj.Angle = bangle;
						proj.Pitch = bslope;
						proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
					}
				}
			}
		}
		else 
		{
			if (numbullets < 0)
				numbullets = 1;

			for (i = 0; i < numbullets; i++)
			{
				double pangle = bangle;
				double slope = bslope;

				if (flags & FBF_EXPLICITANGLE)
				{
					pangle += spread_xy;
					slope += spread_z;
				}
				else
				{
					pangle += spread_xy * Random2[cabullet]() / 255.;
					slope += spread_z * Random2[cabullet]() / 255.;
				}

				int damage = bulletDmg;

				if (!(flags & FBF_NORANDOM))
					damage *= random[cabullet](1, 3);

				let puff = LineAttack(pangle, range, slope, damage, 'Hitscan', puff_t, laflags, t);

				if (missile != null)
				{
					bool temp = false;
					double ang = Angle - 90;
					Vector2 ofs = AngleToVector(ang, Spawnofs_xy);
					Actor proj = SpawnPlayerMissile(missile, bangle, ofs.X, ofs.Y, Spawnheight);
					if (proj)
					{
						if (!puff)
						{
							temp = true;
							puff = LineAttack(bangle, range, bslope, 0, 'Hitscan', puff_t, laflags | LAF_NOINTERACT, t);
						}
						AimBulletMissile(proj, puff, flags, temp, false);
						if (t.unlinked)
						{
							// Arbitary portals will make angle and pitch calculations unreliable.
							// So use the angle and pitch we passed instead.
							proj.Angle = bangle;
							proj.Pitch = bslope;
							proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
						}
					}
				}
			}
		}
	}

	void BIO_RailAttack(int damage, int spawnOffs_xy = 0, color color1 = 0,
		color color2 = 0, int flags = 0, double maxDiff = 0,
		class<Actor> puff_t = 'BulletPuff', double spread_xy = 0,
		double spread_z = 0, double range = 0, int duration = 0,
		double sparsity = 1.0, double driftSpeed = 1.0,
		class<Actor> spawnClass = 'None', double spawnOffs_z = 0,
		int spiraloffset = 270, int limit = 0)
	{
		if (range == 0) range = 8192;
		if (sparsity == 0) sparsity = 1.0;

		if (!(flags & RGF_EXPLICITANGLE))
		{
			spread_xy = spread_xy * Random2[CRailgun]() / 255.0;
			spread_z = spread_z * Random2[CRailgun]() / 255.0;
		}

		FRailParams p;
		p.Damage = damage;
		p.Offset_xy = spawnOffs_xy;
		p.Offset_z = spawnOffs_z;
		p.Color1 = color1;
		p.Color2 = color2;
		p.MaxDiff = maxDiff;
		p.Flags = flags;
		p.Puff = puff_t;
		p.AngleOffset = spread_xy;
		p.PitchOffset = spread_z;
		p.Distance = range;
		p.Duration = duration;
		p.Sparsity = sparsity;
		p.Drift = driftSpeed;
		p.SpawnClass = spawnClass;
		p.SpiralOffset = spiralOffset;
		p.Limit = limit;
		Owner.RailAttack(p);
	}

	void BIO_Saw(Class<Actor> puff_t, int dmg, float angle,
		float range, float lifestealPercent)
	{
		int flags = 0; // TODO: Sort this out
		FTranslatedLineTarget t;

		double ang = angle + 2.8125 * (Random2[Saw]() / 255.0);
		double slope = Owner.AimLineAttack(ang, range, t) *
			(Random2[Saw]() / 255.0);

		Actor puff = null;
		int actualDmg = 0;
		[puff, actualDmg] = Owner.LineAttack(ang, range, slope, dmg,
			'Melee', puff_t, 0, t);

		if (!t.LineTarget)
		{
			if ((flags & SF_RANDOMLIGHTMISS) && (Random[Saw]() > 64))
				Player.ExtraLight = !Player.ExtraLight;
			
			Owner.A_StartSound("weapons/sawfull", CHAN_WEAPON);
			return;
		}

		if (flags & SF_RANDOMLIGHTHIT)
		{
			int randVal = Random[Saw]();

			if (randVal < 64)
				Player.ExtraLight = 0;
			else if (randVal < 160)
				Player.ExtraLight = 1;
			else
				Player.ExtraLight = 2;
		}

		if (!t.LineTarget.bDontDrain)
			ApplyLifeSteal(lifestealPercent, actualDmg);

		Owner.A_StartSound("weapons/sawhit", CHAN_WEAPON);

		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double angleDiff = DeltaAngle(Owner.Angle, t.angleFromSource);

			if (angleDiff < 0.0)
			{
				if (angleDiff < -4.5)
					Owner.Angle = t.angleFromSource + 90.0 / 21;
				else
					Owner.Angle -= 4.5;
			}
			else
			{
				if (angleDiff > 4.5)
					Owner.Angle = t.angleFromSource - 90.0 / 21;
				else
					Owner.Angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			bJustAttacked = true;
	}
}
