class BIO_StateTimeGroup
{
	string Tag;
	bool Melee;
	Array<int> Times, Minimums;

	int TotalTime() const
	{
		int ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Times[i];

		return ret;
	}

	// Used for checking if fire/reload time affixes are compatible,
	// and the allowances on the reductions they impart.
	int PossibleReduction() const
	{
		int ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Max(Times[i] - Minimums[i], 0);

		return ret;
	}

	private void Populate(state basis)
	{
		Array<state> done;

		for (state s = basis; s.InStateSequence(basis); s = s.NextState)
		{
			if (done.Find(s) != done.Size())
				return; // Infinite loop protection

			if (s.Tics == 0)
				continue; // `TNT1 A 0` and the like

			done.Push(s);
			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set  
			// to 0, effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			// States marked `Slow` are kept immutable
			else if (s.bSlow)
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	private void RangePopulate(state from, state to)
	{
		for (state s = from; s.InStateSequence(from); s = s.NextState)
		{
			if (s.DistanceTo(to) <= 0)
				return;

			if (s.Tics == 0)
				continue; // `TNT1 A 0` and the like

			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set  
			// to 0, effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			// States marked `Slow` are kept immutable
			else if (s.bSlow)
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	string GetTagAsQualifier(string parenthClr = "\c[White]") const
	{
		if (Tag.Length() < 1)
			return "";
		else
			return String.Format("%s(\c[Yellow]%s%s)",
				parenthClr, StringTable.Localize(Tag), parenthClr);
	}

	// Add the tic times from all states in a contiguous sequence from `basis`
	// to this group. Beware that this will skip labels, and treats
	// `Goto MyState; MyState:` as contiguous. `tag` should be a string ID.
	static BIO_StateTimeGroup FromState(
		state basis, string tag = "", bool melee = false)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Melee = melee;
		ret.Populate(basis);
		return ret;
	}

	// `tag` should be a string ID.
	static BIO_StateTimeGroup FromStates(
		Array<state> basisArr, string tag = "", bool melee = false)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Melee = melee;

		for (uint i = 0; i < basisArr.Size(); i++)
			ret.Populate(basisArr[i]);

		return ret;
	}

	// Does the same thing as `FromState()`, but stops adding times 
	// upon arriving at `to`. `tag` should be a string ID.
	static BIO_StateTimeGroup FromStateRange(
		state from, state to, string tag = "", bool melee = false)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Melee = melee;
		ret.RangePopulate(from, to);
		return ret;
	}
}

class BIO_Weapon : DoomWeapon abstract
{
	mixin BIO_Gear;

	meta Class<BIO_Weapon> UniqueBase; property UniqueBase: UniqueBase;
	meta BIO_PlayerVisual PlayerVisual; property PlayerVisual: PlayerVisual;

	BIO_WeaponFlags BIOFlags; property Flags: BIOFlags;
	BIO_WeaponAffixMask AffixMask; property AffixMask: AffixMask;

	uint MaxAffixes; property MaxAffixes: MaxAffixes;

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

	// To reload a round, `ReloadCost` gets taken from reserve and `ReloadOutput`
	// gets added to the magazine. Has no effect on magazineless weapons.
	uint8 ReloadCost1, ReloadCost2, ReloadOutput1, ReloadOutput2;
	
	property ReloadCost: ReloadCost1;
	property ReloadCost1: ReloadCost1;
	property ReloadCost2: ReloadCost2;
	property ReloadCosts: ReloadCost1, ReloadCost2;

	property ReloadOutput: ReloadOutput1;
	property ReloadOutput1: ReloadOutput1;
	property ReloadOutput2: ReloadOutput2;
	property ReloadOutputs: ReloadOutput1, ReloadOutput2;

	property ReloadRatio: ReloadCost1, ReloadOutput1;
	property ReloadRatio1: ReloadCost1, ReloadOutput1;
	property ReloadRatio2: ReloadCost2, ReloadOutput2;

	// Reloading is only possible if `MinAmmoReserve * ReloadCost` rounds
	// are held in reserve. Has no effect on magazineless weapons.
	int MinAmmoReserve1, MinAmmoReserve2;
	property MinAmmoReserve: MinAmmoReserve1;
	property MinAmmoReserve1: MinAmmoReserve1;
	property MinAmmoReserve2: MinAmmoReserve2;
	property MinAmmoReserves: MinAmmoReserve1, MinAmmoReserve2;

	// If this weapon is standard grade and this field is true, it won't be
	// destroyed if the players drains both its `AmmoGive` values.
	meta bool ScavengePersist; property ScavengePersist: ScavengePersist;

	Array<BIO_WeaponPipeline> Pipelines;
	Array<BIO_StateTimeGroup> FireTimeGroups, ReloadTimeGroups;
	Dictionary Userdata; // Your derived weapon must instantiate this itself.
	
	protected Ammo Magazine1, Magazine2;
	protected bool Zoomed;
	private uint8 LastPipeline;

	Array<BIO_WeaponAffix> ImplicitAffixes, Affixes;
	Array<string> StatReadout, AffixReadout;

	Default
	{
		-SPECIAL
		+DONTGIB
		+NOBLOCKMONST
		+THRUACTORS
		+WEAPON.ALT_AMMO_OPTIONAL
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT

		Height 8;
		Radius 16;

		Inventory.PickupMessage "";

		Weapon.BobRangeX 0.5;
        Weapon.BobRangeY 0.5;
        Weapon.BobSpeed 1.2;
        Weapon.BobStyle 'Alpha';

		BIO_Weapon.AffixMask BIO_WAM_NONE;
		BIO_Weapon.Flags BIO_WF_NONE;
		BIO_Weapon.Grade BIO_GRADE_NONE;
		BIO_Weapon.GroundHitSound "bio/weap/gundrop_0";
		BIO_Weapon.MaxAffixes DEFAULT_MAX_AFFIXES;
		BIO_Weapon.MinAmmoReserves 1, 1;
		BIO_Weapon.PlayerVisual BIO_PVIS_RIFLE;
		BIO_Weapon.Rarity BIO_RARITY_COMMON;
		BIO_Weapon.ReloadRatio1 1, 1;
		BIO_Weapon.ReloadRatio2 1, 1;
		BIO_Weapon.SwitchSpeeds 6, 6;
		BIO_Weapon.UniqueBase '';
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
		#### # 10;
		#### # 1 A_GroundHit;
		Goto Spawn.Common + 1;
	Spawn.Mutated:
		#### # 10;
		#### # 1
		{
			A_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_GroundHit;
		#### # 1 Bright Light("BIO_MutatedLoot")
		{
			A_GroundHit();
			A_SetTranslation(invoker.MUTATED_SPAWN_TRANS[invoker.Affixes.Size()]);
		}
		#### ##### 1 Bright Light("BIO_MutatedLoot") A_GroundHit;
		Goto Spawn.Mutated + 1;
	Spawn.Unique:
		#### # 10;
		#### # 1
		{
			A_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_GroundHit;
		#### # 1 Bright Light("BIO_UniqueLoot")
		{
			A_GroundHit();
			A_SetTranslation('BIO_Unique');
		}
		#### ##### 1 Bright Light("BIO_UniqueLoot") A_GroundHit;
		Goto Spawn.Unique + 1;
	}

	// Parent overrides ========================================================

	override void BeginPlay()
	{
		super.BeginPlay();
		SetTag(FullTag());

		// So that pre-placed weapons don't make a cacophony at level start
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

		// Gearbox calls this function on every weapon prototype when changing
		// levels; if one of those checks returns false (i.e. when player
		// is at weapon capacity) then that weapon can't be displayed
		if (Level == null) return true;

		if (!bioPlayer.CanCarryWeapon(self))
		{
			if (!BIO_Utils.IntelligentSupplies())
				return false;
			else
				return bioPlayer.FindInventory(GetClass());
		}

		return true;
	}

	final override bool HandlePickup(Inventory item)
	{
		let weap = BIO_Weapon(item);
		
		if (weap == null || item.GetClass() != self.GetClass())
			return false;

		if (MaxAmount > 1)
			return Inventory.HandlePickup(item);

		if (AmmoType1 != null || AmmoType2 != null)
		{
			int amt1 = Owner.CountInv(AmmoType1), amt2 = Owner.CountInv(AmmoType2);
			weap.bPickupGood = weap.PickupForAmmo(self);
			int given1 = Owner.CountInv(AmmoType1) - amt1,
				given2 = Owner.CountInv(AmmoType2) - amt2;
			weap.AmmoGive1 -= given1;
			weap.AmmoGive2 -= given2;
			weap.bPickupGood &= weap.ScavengingDestroys();
			if (!bQuiet && (given1 > 0 || given2 > 0))
			{
				PrintPickupMessage(Owner.CheckLocalView(), PickupMessage());
				PlayPickupSound(Owner.Player.MO);
			}
		}

		return true;
	}

	final override bool TryPickupRestricted(in out Actor toucher)
	{
		if (AmmoType1 == null && AmmoType2 == null)
			return false;
		
		// Weapon has ammo types but default ammogives are both 0
		if (AmmoGive1 <= 0 && AmmoGive1 <= 0)
			return false;

		int given1 = 0, given2 = 0;

		if (AmmoType1 != null)
		{
			int amt = toucher.CountInv(AmmoType1);
			toucher.GiveInventory(AmmoType1,
				AmmoGive1 * G_SkillPropertyFloat(SKILLP_AMMOFACTOR));
			given1 = toucher.CountInv(AmmoType1) - amt;
			AmmoGive1 -= given1;
		}

		if (AmmoType2 != null)
		{
			int amt = toucher.CountInv(AmmoType2);
			toucher.GiveInventory(AmmoType2,
				AmmoGive2 * G_SkillPropertyFloat(SKILLP_AMMOFACTOR));
			given2 = toucher.CountInv(AmmoType2) - amt;
			AmmoGive2 -= given2;
		}

		if (ScavengingDestroys())
		{
			GoAwayAndDie();
			return true;
		}

		return given1 > 0 || given2 > 0;
	}

	override void DoPickupSpecial(Actor toucher)
	{
		super.DoPickupSpecial(toucher);

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnPickup(self);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnPickup(self);
	}

	override string PickupMessage()
	{
		// Is this weapon being scavenged for ammo?
		if (InStateSequence(CurState, FindState('HoldAndDestroy')) || Owner == null)
			return String.Format(StringTable.Localize("$BIO_SCAVENGED"), GetTag());

		string ret = "";

		if (Rarity == BIO_RARITY_UNIQUE)
		{
			string suffix = "";

			if (UniqueSuffix.Length() > 0)
				suffix = StringTable.Localize(UniqueSuffix);
			else if (UniqueBase != null)
				suffix = GetDefaultByType(UniqueBase).FullTag();
			else
				suffix = StringTable.Localize("$BIO_WEAPON");

			ret = String.Format(StringTable.Localize(PickupMsg),
				"\c[Orange]" .. Default.GetTag() .. "\c-", suffix);
		}
		else
			ret = String.Format(StringTable.Localize(PickupMsg), GetTag());

		ret = ret .. " [\cn" .. SlotNumber .. "\c-]";
		return ret;
	}

	final override void AttachToOwner(Actor newOwner)
	{
		if (!PreviouslyPickedUp) DRLMDangerLevel();
		PreviouslyPickedUp = true;

		int 
			prevAmmo1 = newOwner.CountInv(AmmoType1),
			prevAmmo2 = newOwner.CountInv(AmmoType2);

		super.AttachToOwner(newOwner);
		AmmoGive1 -= (newOwner.CountInv(AmmoType1) - prevAmmo1);
		AmmoGive2 -= (newOwner.CountInv(AmmoType2) - prevAmmo2);

		let globals = BIO_GlobalData.Get();
		if (globals != null)
			globals.OnWeaponAcquired(Grade);

		Init();

		// Get a pointer to primary ammo (which is either `AmmoType1` or
		// `MagazineType1`). If it isn't found, generate and attach it
		if (Magazine1 == null && AmmoType1 != null)
		{
			Magazine1 = MagazineType1 != null ?
				Ammo(newOwner.FindInventory(MagazineType1)) :
				Ammo(newOwner.FindInventory(AmmoType1));

			if (Magazine1 == null)
			{
				Magazine1 = Ammo(Actor.Spawn(MagazineType1));
				Magazine1.AttachToOwner(newOwner);
			}

			if (Default.MagazineSize1 != 0)
				Magazine1.Amount = Max(Default.MagazineSize1, 0);
		}

		// Same for secondary:
		if (Magazine2 == null && AmmoType2 != null)
		{
			Magazine2 = MagazineType2 != null ?
				Ammo(newOwner.FindInventory(MagazineType2)) :
				Ammo(newOwner.FindInventory(AmmoType2));

			if (Magazine2 == null)
			{
				Magazine2 = Ammo(Actor.Spawn(MagazineType2));
				Magazine2.AttachToOwner(newOwner);
			}

			if (Default.MagazineSize2 != 0)
				Magazine2.Amount = Max(Default.MagazineSize2, 0);
		}

		if (MagazineType1 == MagazineType2) Magazine2 = Magazine1;
	}

	override void OnDrop(Actor dropper)
	{
		super.OnDrop(dropper);
		HitGround = false;

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnDrop(self, BIO_Player(dropper));
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnDrop(self, BIO_Player(dropper));
	}

	// The parent variant of this function clears both `AmmoGive` fields to
	// prevent exploitation; Biomorph solves this problem differently.
	// This overrides fixes dropped weapons being impossible to scavenge as such.
	final override Inventory CreateTossable(int amt)
	{
		int ag1 = AmmoGive1, ag2 = AmmoGive2;
		let ret = Weapon(super.CreateTossable(amt));
		ret.AmmoGive1 = ag1;
		ret.AmmoGive2 = ag2;
		return ret;
	}

	final override bool Used(Actor user)
	{
		let bioPlayer = BIO_Player(user);
		if (bioPlayer == null) return false;
		Init();

		// Scale message uptime off of number of characters in both readouts
		int upTime = TICRATE;

		for (uint i = 0; i < StatReadout.Size(); i++)
			upTime += StatReadout[i].Length();
		for (uint i = 0; i < AffixReadout.Size(); i++)
			upTime += AffixReadout[i].Length();

		bioPlayer.ExamineWeapon(self, Max(TICRATE, upTime * 0.33));

		// Don't consume the interaction so players can open doors and so on
		return false;
	}

	final override bool DepleteAmmo(bool altFire, bool checkEnough, int ammoUse)
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

	final override string GetObituary(Actor victim, Actor inflictor, name mod, bool playerAtk)
	{
		string ret = "";
		
		if (Pipelines.Size() > LastPipeline)
			ret = Pipelines[LastPipeline].GetObituary();
		
		// Pipeline has no obituary; fall back to the weapon's
		if (ret.Length() < 1) ret = Obituary;
		// Weapon has no obituary; fall back to something generic
		if (ret.Length() < 1) ret = "$BIO_OB_GENERIC"; 

		return ret;
	}

	override void Tick()
	{
		super.Tick();
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnTick(self);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnTick(self);
	}

	// Virtuals and abstracts ==================================================

	abstract void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const;
	virtual void InitImplicitAffixes(in out Array<BIO_WeaponAffix> affixes) const {}
	abstract void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const;
	virtual void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const {}

	// Each is called once before starting its respective loop.
	virtual void OnDeselect()
	{
		let dropper = BIO_WeaponDrop(Owner.FindInventory('BIO_WeaponDrop'));
		
		if (dropper.IsPrimed())
		{
			// Flush confirmation message off screen
			Owner.A_Print("", 0.0);
			dropper.Disarm();
		}
	}
	
	virtual void OnSelect()
	{
		BIO_Player(Owner).WeaponVisual = PlayerVisual;
	}

	/*	The first return value indicates if the mutagen should reset the weapon's
		stats, set the corrupted flag, and try for a generic corruption effect.
		The second return value indicates if the mutagen should be consumed.
	*/
	virtual bool, bool OnCorrupt() { return true, true; }

	// Called after all other weapon details have been drawn.
	virtual ui void DrawToHUD(readOnly<BIO_StatusBar> sbar) const {}

	// Actions =================================================================

	// `fireFactor` multiplies fired count and ammo usage.
	protected action bool A_BIO_Fire(uint pipeline = 0, int fireFactor = 1,
		float spreadFactor = 1.0)
	{
		invoker.LastPipeline = pipeline;

		bool secAmmo = invoker.Pipelines[pipeline].UsesSecondaryAmmo();

		if (!invoker.DepleteAmmo(secAmmo, true,
			!secAmmo ? invoker.AmmoUse1 * fireFactor : invoker.AmmoUse2 * fireFactor))
			return false;

		invoker.Pipelines[pipeline].Invoke(invoker, fireFactor, spreadFactor);
		return true;
	}

	protected action void A_FireSound(int channel = CHAN_WEAPON,
		int flags = CHANF_DEFAULT, double volume = 1.0,
		double attenuation = ATTN_NORM, uint pipeline = 0)
	{
		A_StartSound(invoker.Pipelines[pipeline].GetFireSound(),
			channel, CHANF_DEFAULT, volume, attenuation);
	}

	// If no argument is given, try to reload as much of the magazine as 
	// possible. Otherwise, try to reload the given amount of rounds.
	action void A_LoadMag(uint amt = 0, bool secondary = false)
	{
		Ammo magItem = null, reserveAmmo = null;
		int cost = -1, output = -1, magSize = -1, reserve = -1;
		
		if (!secondary)
		{
			magItem = invoker.Magazine1;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType1));
			magSize = invoker.MagazineSize1;
			cost = invoker.ReloadCost1;
			output = invoker.ReloadOutput1;
			reserve = reserveAmmo.Amount / cost;
		}
		else
		{
			magItem = invoker.Magazine2;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType2));
			magSize = invoker.MagazineSize2;
			cost = invoker.ReloadCost2;
			output = invoker.ReloadOutput2;
			reserve = reserveAmmo.Amount / cost;
		}

		int diff = Min(reserve, amt > 0 ? amt : magSize - magItem.Amount);

		for (uint i = 0; i < invoker.ImplicitAffixes.Size(); i++)
			invoker.ImplicitAffixes[i].OnMagLoad(invoker, secondary, diff);
		for (uint i = 0; i < invoker.Affixes.Size(); i++)
			invoker.Affixes[i].OnMagLoad(invoker, secondary, diff);

		int subtract = diff * cost;
		magItem.Amount += (diff * output);
		reserveAmmo.Amount -= subtract;
	}

	// Conventionally called on a `TNT1 A 0` state at the
	// very beginning of a fire/altfire state.
	protected action state A_BIO_CheckAmmo(
		bool secondary = false, int multi = 1, bool single = false)
	{
		if (invoker.SufficientAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
		{
			state dfs = ResolveState('Dryfire');
			
			if (dfs != null)
				return dfs;
			else
				return ResolveState('Ready');
		}

		let cv = BIO_CVar.AutoReloadPre(Player);

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && single))
			return ResolveState('Reload');
		else
		{
			state dfs = ResolveState('Dryfire');
			
			if (dfs != null)
				return dfs;
			else
				return ResolveState('Ready');
		}
	}

	// To be called at the end of a fire/altfire state.
	protected action state A_AutoReload(
		bool secondary = false, int multi = 1, bool single = false)
	{
		if (invoker.SufficientAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
			return state(null);
		
		let cv = BIO_CVar.AutoReloadPost(Player);

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && single))
			return ResolveState('Reload');
		else
			return state(null);
	}

	// Clear the magazine and return rounds in it to the reserve, with
	// consideration given to the relevant reload ratio.
	protected action void A_EmptyMagazine(bool secondary = false)
	{
		Ammo magItem = null, reserveAmmo = null;
		int cost = -1, output = -1;

		if (!secondary)
		{
			magItem = invoker.Magazine1;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType1));
			cost = invoker.ReloadCost1;
			output = invoker.ReloadOutput1;
		}
		else
		{
			magItem = invoker.Magazine2;
			reserveAmmo = Ammo(invoker.Owner.FindInventory(invoker.AmmoType2));
			cost = invoker.ReloadCost2;
			output = invoker.ReloadOutput2;
		}

		reserveAmmo.Amount += (magItem.Amount / output) * cost;
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
			A_StartSound(invoker.GroundHitSound);
			A_ScaleVelocity(0.5);
			bSpecial = true;
			bThruActors = false;
			invoker.HitGround = true;
		}
	}

	protected action void A_SetFireTime(
		uint ndx, uint grp = 0, int modifier = 0)
	{
		A_SetTics(Max(modifier + invoker.FireTimeGroups[grp].Times[ndx], 0));
	}

	protected action void A_SetReloadTime(
		uint ndx, uint grp = 0, int modifier = 0)
	{
		A_SetTics(modifier + invoker.ReloadTimeGroups[grp].Times[ndx]);
	}

	protected action void A_PresetRecoil(Class<BIO_RecoilThinker> recoil_t,
		float scale = 1.0, bool invert = false)
	{
		BIO_RecoilThinker.Create(recoil_t, BIO_Weapon(invoker), scale, invert);
	}

	// Shunt the wielder in a direction.
	protected action void A_Pushback(float xVelMult, float zVelMult)
	{
		// Don't apply any if the wielding player isn't on the ground
		if (invoker.Owner.Pos.Z > invoker.Owner.FloorZ) return;

		A_ChangeVelocity(
			Cos(invoker.Pitch) * -xVelMult, 0.0,
			Sin(invoker.Pitch) * zVelMult, CVF_RELATIVE);
	}

	protected action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	protected action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }

	// Getters =================================================================

	// `GetTag()` only comes with color escape codes after `BeginPlay()`; use this
	// when derefencing defaults. Always comes with a '\c-' at the end.
	string FullTag() const
	{
		string crEsc_g = BIO_Utils.GradeColorEscapeCode(Grade);

		if (Rarity == BIO_RARITY_MUTATED)
		{
			string crEsc_r = BIO_Utils.RarityColorEscapeCode(Rarity);

			return String.Format("%s%s \c[White](%s%s\c[White])\c-",
				crEsc_g, Default.GetTag(), crEsc_r,
				StringTable.Localize("$BIO_MUTATED_CHARACTER"));
		}
		else if (Rarity == BIO_RARITY_UNIQUE)
		{
			string crEsc_r = BIO_Utils.RarityColorEscapeCode(Rarity);
			string suffix = "";
			
			if (UniqueSuffix.Length() > 0)
				suffix = " " .. StringTable.Localize(UniqueSuffix);
			else if (UniqueBase != null)
				suffix = " " .. GetDefaultByType(UniqueBase).GetTag();

			return String.Format("%s%s%s%s\c-", crEsc_r,
				Default.GetTag(), crEsc_g, suffix);
		}
		else
			return String.Format("%s%s\c-", crEsc_g, Default.GetTag());
	}

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
		int cost = -1, magSize = -1, minReserve = -1;
		
		if (!secondary)
		{
			magItem = Magazine1;
			reserveAmmo = Ammo(Owner.FindInventory(AmmoType1));
			magSize = MagazineSize1;
			cost = ReloadCost1;
			minReserve = MinAmmoReserve1;
		}
		else
		{
			magItem = Magazine2;
			reserveAmmo = Ammo(Owner.FindInventory(AmmoType2));
			magSize = MagazineSize2;
			cost = ReloadCost2;
			minReserve = MinAmmoReserve2;
		}

		int minAmt = minReserve * cost;

		// Insufficient reserves
		if (reserveAmmo == null || reserveAmmo.Amount < minAmt)
			return false;

		// Magazine's already full
		if (magItem.Amount >= magSize)
			return false;

		return true;
	}

	BIO_WeaponPipeline LastPipelineFired() const { return Pipelines[LastPipeline]; }
	uint LastPipelineFiredIndex() const { return LastPipeline; }

	int LastFireTime() const
	{
		int ret = 0;
		uint mask = Pipelines[LastPipeline].GetFireTimeBits();

		for (uint i = 0; i < 8; i++)
		{
			if (mask & (1 << i))
				ret += FireTimeGroups[i].TotalTime();
		}

		return ret;
	}

	// See biomorph/gear.zs for more affix checking functions

	bool FullOnAffixes() const { return Affixes.Size() >= MaxAffixes; }

	bool HasAffixOfType(Class<BIO_WeaponAffix> t, bool implicit = false) const
	{
		if (!implicit)
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				if (Affixes[i].GetClass() == t)
					return true;
		}
		else
		{
			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
				if (ImplicitAffixes[i].GetClass() == t)
					return true;
		}

		return false;
	}

	BIO_WeaponAffix GetAffixByType(
		Class<BIO_WeaponAffix> t, bool implicit = false) const
	{
		if (!implicit)
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				if (Affixes[i].GetClass() == t)
					return Affixes[i];
		}
		else
		{
			for (uint i = 0; i < ImplicitAffixes.Size(); i++)
				if (ImplicitAffixes[i].GetClass() == t)
					return ImplicitAffixes[i];
		}

		return null;
	}

	bool AnyAffixesAddGravity() const
	{
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			if (ImplicitAffixes[i].GetFlags() & BIO_WAF_ADDSGRAVITY)
				return true;

		return false;
	}

	// Returns `true` if any of this weapon's pipelines
	// fires a `BIO_Projectile` or `BIO_FastProjectile`.
	bool FiresProjectile() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].FiresProjectile())
				return true;

		return false;
	}

	bool FiresTrueProjectile() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].FiresTrueProjectile())
				return true;

		return false;
	}

	// Returns `true` if any of this weapon's pipelines has a 
	// fire functor inheriting from `BIO_FireFunc_Melee`.
	bool HasMeleePipeline() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].IsMelee())
				return true;

		return false;
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

	bool DealsAnySplashDamage() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].Splashes())
				return true;

		return false;
	}

	bool HasAnySpread() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].HasAnySpread())
				return true;

		return false;
	}

	bool HasScatteringPipeline() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
		{
			if (Pipelines[i].GetCombinedSpread() >= 5.5 &&
				Pipelines[i].GetFireCount() > 3)
				return true;
		}

		return false;
	}

	int GetFireTime(uint ndx, uint grp = 0) const
	{
		return FireTimeGroups[grp].Times[ndx];
	}

	bool FireTimesMutable() const
	{
		if (AffixMask & BIO_WAM_FIRETIME) return false;
		if (FireTimeGroups.Size() < 1) return false;

		// State sequences can't have all of their tic times reduced to 0.
		// Fire rate-affecting affixes must know in advance if
		// they can even have any effect, given this caveat.
		for (uint i = 0; i < FireTimeGroups.Size(); i++)
			if (FireTimeGroups[i].PossibleReduction() > 1)
				return true;

		return false;
	}

	bool ReloadTimesMutable() const
	{
		if (AffixMask & BIO_WAM_FIRETIME) return false;
		if (ReloadTimeGroups.Size() < 1) return false;

		// State sequences can't have all of their tic times reduced to 0.
		// Reload speed-affecting affixes must know in advance if
		// they can even have any effect, given this caveat.
		for (uint i = 0; i < ReloadTimeGroups.Size(); i++)
			if (ReloadTimeGroups[i].PossibleReduction() > 1)
				return true;

		return false;
	}
	
	// Returns 0 for magazineless or ammoless weapons.
	uint ShotsPerMagazine(bool secondary = false) const
	{
		if (!secondary && AmmoType1 != null && AmmoUse1 > 0 && MagazineType1 != null)
			return Floor(float(MagazineSize1) / float(AmmoUse1));
		else if (secondary && AmmoType2 != null && AmmoUse2 > 0 && MagazineType2 != null)
			return Floor(float(MagazineSize2) / float(AmmoUse2));
		else
			return 0;
	}

	bool Ammoless() const
	{
		return
			AmmoType1 == null && AmmoType2 == null &&
			AmmoUse1 <= 0 && AmmoUse2 <= 0 &&
			MagazineType1 == null && MagazineType2 == null;
	}

	bool MagazineSizeMutable(bool secondary = false) const
	{
		if (!secondary)
		{
			if (MagazineType1 == null || MagazineType1 == AmmoType1)
				return false;

			if (MagazineSize1 <= 0)
				return false;

			if (AffixMask & BIO_WAM_MAGSIZE_1)
				return false;
		}
		else
		{
			if (MagazineType2 == null || MagazineType2 == AmmoType2)
				return false;

			if (MagazineSize2 <= 0)
				return false;

			if (AffixMask & BIO_WAM_MAGSIZE_2)
				return false;
		}

		return true;
	}

	private bool ScavengingDestroys() const
	{
		return
			(AmmoType1 != null || AmmoType2 != null) &&
			AmmoGive1 <= 0 && AmmoGive2 <= 0 &&
			!ScavengePersist &&
			Grade == BIO_GRADE_STANDARD && Rarity == BIO_RARITY_COMMON;
	}

	readOnly<BIO_Weapon> AsConst() const { return self; }

	// Modifying ===============================================================

	// Any time you make a change to a weapon, ensure you call `OnChange()`
	// afterwards. Note that this does not apply to `BIO_WeaponAffix::Apply()`.

	// Latching; will never re-initialise.
	void Init()
	{
		if (Pipelines.Size() > 0 || FireTimeGroups.Size() > 0 ||
			ReloadTimeGroups.Size() > 0 || ImplicitAffixes.Size() > 0)
			return;

		InitPipelines(Pipelines);
		InitFireTimes(FireTimeGroups);
		InitReloadTimes(ReloadTimeGroups);
		InitImplicitAffixes(ImplicitAffixes);

		OnChange();
	}

	// Does not apply any affixes, or affect rarity.
	void Reset()
	{
		Pipelines.Clear();
		FireTimeGroups.Clear();
		ReloadTimeGroups.Clear();
		ImplicitAffixes.Clear();

		InitPipelines(Pipelines);
		InitFireTimes(FireTimeGroups);
		InitReloadTimes(ReloadTimeGroups);
		InitImplicitAffixes(ImplicitAffixes);

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
		
		RaiseSpeed = Default.RaiseSpeed;
		LowerSpeed = Default.LowerSpeed;

		MagazineSize1 = Default.MagazineSize1;
		MagazineSize2 = Default.MagazineSize2;
		
		ReloadCost1 = Default.ReloadCost1;
		ReloadOutput1 = Default.ReloadOutput1;
		ReloadCost2 = Default.ReloadCost2;
		ReloadOutput2 = Default.ReloadOutput2;

		MinAmmoReserve1 = Default.MinAmmoReserve1;
		MinAmmoReserve2 = Default.MinAmmoReserve2;

		Array<BIO_WeaponPipeline> pplDefs;
		InitPipelines(pplDefs);

		// Inform pipelines of their defaults
		for (uint i = 0; i < Pipelines.Size(); i++)
			Pipelines[i].Defaults = pplDefs[i].AsConst();
	}

	// Does not alter stats, and does not apply the newly-added affixes.
	// Returns `false` if there are no compatible affixes to add.
	bool AddRandomAffix()
	{
		Array<Class<BIO_WeaponAffix> > eligibles;

		if (!BIO_GlobalData.Get().EligibleWeaponAffixes(eligibles, AsConst()))
			return false;

		uint r = Random[BIO_Afx](0, eligibles.Size() - 1);
		uint e = Affixes.Push(BIO_WeaponAffix(new(eligibles[r])));
		Affixes[e].Init(AsConst());
		return true;
	}

	// Affects explicit affixes only. Note that this does not alter stats.
	// If given `false`, output will fall into a normal distribution between
	// minimum and maximum affixes.
	void RandomizeAffixes(bool rerandomize = true)
	{
		if (MaxAffixes < 1)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Tried to randomize affixes on a weapon with `MaxAffixes` of 0.");
			return;
		}

		ClearAffixes();

		uint fl = Min(2, MaxAffixes);
		uint c = Random[BIO_Afx](fl, MaxAffixes);

		if (rerandomize) c = Random[BIO_Afx](fl, c);

		let globals = BIO_GlobalData.Get();
		Array<Class<BIO_WeaponAffix> > eligibles;
		globals.EligibleWeaponAffixes(eligibles, AsConst());

		for (uint i = 0; i < c; i++)
		{
			for (uint j = eligibles.Size() - 1; j >= 0; j--)
			{
				if (!globals.WeaponAffixCompatible(eligibles[j], AsConst()))
					eligibles.Delete(j);
			}

			if (eligibles.Size() < 1)
				break;

			uint r = Random[BIO_Afx](0, eligibles.Size() - 1);
			let afx = BIO_WeaponAffix(new(eligibles[r]));
			afx.Init(AsConst());
			Affixes.Push(afx);
		}
	}

	void ClearAffixes(bool implicitsToo = false)
	{
		if (implicitsToo) ImplicitAffixes.Clear();
		Affixes.Clear();
	}

	void ModifyFireTime(uint grp, int modifier)
	{
		if (grp >= FireTimeGroups.Size())
		{
			Console.Printf(
				"Illegal fire time group index of %d given to %s.",
				grp, GetClassName());
			return;
		}

		if (modifier == 0)
		{
			Console.Printf(
				"Illegal fire time modifier of 0 given to %s.",
				GetClassName());
			return;
		}

		uint e = Abs(modifier);

		for (uint i = 0; i < e; i++)
		{
			uint idx = 0, minOrMax = 0;

			if (modifier > 0)
				[minOrMax, idx] = BIO_Utils.IntArrayMin(FireTimeGroups[grp].Times);
			else
				[minOrMax, idx] = BIO_Utils.IntArrayMax(FireTimeGroups[grp].Times);

			FireTimeGroups[grp].Times[idx] = modifier > 0 ?
				FireTimeGroups[grp].Times[idx] + 1 :
				FireTimeGroups[grp].Times[idx] - 1;
		}
	}

	void ModifyReloadTime(uint grp, int modifier)
	{
		if (grp >= ReloadTimeGroups.Size())
		{
			Console.Printf(
				"Illegal reload time group index of %d given to %s.",
				grp, GetClassName());
			return;
		}

		if (modifier == 0)
		{
			Console.Printf(
				"Illegal reload time modifier of 0 given to %s.",
				GetClassName());
			return;
		}

		uint e = Abs(modifier);

		for (uint i = 0; i < e; i++)
		{
			uint idx = 0, minOrMax = 0;

			if (modifier > 0)
				[minOrMax, idx] = BIO_Utils.IntArrayMin(ReloadTimeGroups[grp].Times);
			else
				[minOrMax, idx] = BIO_Utils.IntArrayMax(ReloadTimeGroups[grp].Times);

			ReloadTimeGroups[grp].Times[idx] = modifier > 0 ?
				ReloadTimeGroups[grp].Times[idx] + 1 :
				ReloadTimeGroups[grp].Times[idx] - 1;
		}
	}

	private void ReorderAffixes(in out Array<BIO_WeaponAffix> arr)
	{
		Array<BIO_WeaponAffix> temp;
		temp.Move(arr);

		while (temp.Size() > 0)
		{
			int highest = int.MIN;
			uint highest_idx = uint.MAX;

			for (uint i = 0; i < temp.Size(); i++)
			{
				int prio = temp[i].OrderPriority();

				if (prio > highest)
				{
					highest = prio;
					highest_idx = i;
				}
			}

			arr.Push(temp[highest_idx]);
			temp.Delete(highest_idx);
		}
	}

	// Recomputes rarity, re-orders affixes, recolors tag, and rewrites readouts.
	void OnChange()
	{
		Reset();

		if (Default.Rarity == BIO_RARITY_UNIQUE)
			Rarity = BIO_RARITY_UNIQUE;
		else if (Affixes.Size() > 0)
			Rarity = BIO_RARITY_MUTATED;
		else
			Rarity = BIO_RARITY_COMMON;

		ReorderAffixes(ImplicitAffixes);
		ReorderAffixes(Affixes);

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].Apply(self);

		// If a corruption effect or something similar has modified implicits
		// in a way that causes an explicit to become incompatible, cull it

		Array<bool> incompatibleExplicits;

		for (uint i = 0; i < Affixes.Size(); i++)
		{
			incompatibleExplicits.Push(!Affixes[i].Compatible(AsConst()));

			if (!incompatibleExplicits[i])
				Affixes[i].Apply(self);
		}

		for (uint i = Affixes.Size() - 1; i >= 0; i--)
		{
			if (incompatibleExplicits[i])
				Affixes.Delete(i);
		}

		SetTag(FullTag());

		StatReadout.Clear();

		for (uint i = 0; i < Pipelines.Size(); i++)
		{
			Pipelines[i].ToString(StatReadout, i, Pipelines.Size() == 1);
			StatReadout.Push("");
		}

		// Incidental blank line between pipeline readouts and fire time readouts

		Array<BIO_StateTimeGroup> fireTimeDefs, reloadTimeDefs;

		InitFireTimes(fireTimeDefs);
		InitReloadTimes(reloadTimeDefs);

		for (uint i = 0; i < FireTimeGroups.Size(); i++)
		{
			int total = BIO_Utils.IntArraySum(FireTimeGroups[i].Times),
				totalDef = BIO_Utils.IntArraySum(fireTimeDefs[i].Times);

			string template = !FireTimeGroups[i].Melee ?
				StringTable.Localize("$BIO_WEAPTOSTR_FIRETIME") :
				StringTable.Localize("$BIO_WEAPTOSTR_ATTACKTIME");

			string str = String.Format(template,
				BIO_Utils.StatFontColor(total, totalDef, true),
				float(total) / float(TICRATE));

			string qual = FireTimeGroups[i].GetTagAsQualifier("\c[MidGrey]");
			
			if (qual.Length() > 0)
				str.AppendFormat(" %s", qual);
			
			StatReadout.Push(str);
		}

		// Blank line between fire times and reload times
		if (ReloadTimeGroups.Size() > 0) StatReadout.Push("");

		for (uint i = 0; i < ReloadTimeGroups.Size(); i++)
		{
			int total = BIO_Utils.IntArraySum(ReloadTimeGroups[i].Times),
				totalDef = BIO_Utils.IntArraySum(reloadTimeDefs[i].Times);

			string str = String.Format(
				StringTable.Localize("$BIO_WEAPTOSTR_RELOADTIME"),
				BIO_Utils.StatFontColor(total, totalDef, true),
				float(total) / float(TICRATE));

			string grpTag = StringTable.Localize(ReloadTimeGroups[i].Tag);

			if (grpTag.Length() > 1)
				str.AppendFormat(" (\c[Yellow]%s\c[MidGrey])", grpTag);

			StatReadout.Push(str);
		}

		AffixReadout.Clear();

		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].ToString(AffixReadout, AsConst());

		// Blank line between stats/implicit affixes and explicit affixes
		AffixReadout.Push("");

		if (BIOFlags & BIO_WF_AFFIXESHIDDEN)
			AffixReadout.Push("\c[DarkRed]" .. StringTable.Localize("$BIO_AFFIXESUNKNOWN"));
		else
		{
			for (uint i = 0; i < Affixes.Size(); i++)
				Affixes[i].ToString(AffixReadout, AsConst());
		}
	}

	// Utility =================================================================

	void ApplyLifeSteal(float percent, int dmg) const
	{
		let lsp = Min(percent, 1.0);
		let given = int(float(dmg) * lsp);
		Owner.GiveBody(given, Owner.GetMaxHealth(true) + 100);
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnKill(self, killed, inflictor);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnKill(self, killed, inflictor);
	}

	void OnCriticalShot(in out BIO_FireData fireData)
	{
		for (uint i = 0; i < ImplicitAffixes.Size(); i++)
			ImplicitAffixes[i].OnCriticalShot(self, fireData);
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnCriticalShot(self, fireData);
	}

	// Weapon-making helpers ===================================================

	// Shortcut for `BIO_StateTimeGroup::FromState()`.
	protected BIO_StateTimeGroup StateTimeGroupFrom(
		statelabel lbl, string tag = "", bool melee = false) const
	{
		state s = FindState(lbl);
		if (s == null)
		{
			// XXX: This hits a string format exception.
			// How to convert a state label into a real string?
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"`StateTimeGroupFrom()` Failed to find state %s.", lbl);
			return null;
		}

		return BIO_StateTimeGroup.FromState(s, tag, melee);
	}

	// Shortcut for `BIO_StateTimeGroup::FromRange()`.
	protected BIO_StateTimeGroup StateTimeGroupFromRange(
		statelabel from, statelabel to, string tag = "", bool melee = false) const
	{
		state f = FindState(from);
		if (f == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"`StateTimeGroupFromRange()` Failed to find state %s.", from);
			return null;
		}

		state t = FindState(to);
		if (t == null)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"`StateTimeGroupFromRange()` Failed to find state %s.", to);
			return null;
		}

		return BIO_StateTimeGroup.FromStateRange(f, t, tag, melee);
	}

	// Shortcut for `BIO_StateTimeGroup::FromArray()`.
	protected BIO_StateTimeGroup StateTimeGroupFromArray(
		in out Array<statelabel> labels, string tag = "", bool melee = false) const
	{
		Array<state> arr;

		for (uint i = 0; i < labels.Size(); i++)
		{
			state s = FindState(labels[i]);
			if (s == null)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
				"`StateTimeGroupFromArray()` Failed to find state %s.", labels[i]);
			}
			else
				arr.Push(s);
		}

		return BIO_StateTimeGroup.FromStates(arr, tag, melee);
	}

	// Customised variations on attack actions =================================

	Actor BIO_FireProjectile(Class<Actor> proj_t, double angle = 0,
		double spawnOfs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle - 90.0;
		Vector2 ofs = AngleToVector(ang, spawnOfs_xy);
		double shootangle = Owner.Angle;

		if (flags & FPF_AIMATANGLE) shootangle += angle;

		// Temporarily adjusts the pitch
		double playerPitch = Owner.Pitch;
		Owner.Pitch += pitch;
		let misl = Owner.SpawnPlayerMissile(proj_t, shootangle, ofs.X, ofs.Y,
			spawnHeight, t, false, (flags & FPF_NOAUTOAIM) != 0);
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

	/* 	This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/
	Actor BIO_FireBullet(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, Class<Actor> puff_t, EFireBulletsFlags flags = FBF_NONE,
		double range = 0.0, Class<Actor> missile = null,
		double spawnHeight = 32.0, double spawnOfs_xy = 0.0)
	{
		int i = 0;
		double bAngle = 0.0, bSlope = 0.0;
		int laFlags = (flags & FBF_NORANDOMPUFFZ) ? LAF_NORANDOMPUFFZ : 0;
		FTranslatedLineTarget t;

		if (range ~== 0.0) range = PLAYERMISSILERANGE;

		if (!(flags & FBF_NOFLASH)) BIO_Player(Owner).PlayAttacking2();
		if (!(flags & FBF_NOPITCH)) bSlope = Owner.BulletSlope();

		bAngle = Owner.Angle;

		if ((numBullets == 1 && !Owner.Player.Refire) || numBullets == 0)
		{
			int damage = bulletDmg;

			Actor puff = null; int realDmg = -1;
			[puff, realDmg] = Owner.LineAttack(bAngle, range,
				bSlope, damage, 'Hitscan', puff_t, laFlags, t);
			
			if (puff == null)
			{
				FLineTraceData ltd;
				LineTrace(bAngle, range, bSlope, TRF_NONE, data: ltd);
				puff = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
				puff.DamageType = GetDefaultByType(puff_t).DamageType;
				puff.Tracer = t.LineTarget;
			}

			puff.SetDamage(realDmg);

			if (missile != null)
			{
				bool temp = false;
				double ang = Owner.Angle - 90;
				Vector2 ofs = Owner.AngleToVector(ang, spawnOfs_xy);
				Actor proj = Owner.SpawnPlayerMissile(missile, bAngle,
					ofs.X, ofs.Y, spawnHeight);

				if (proj)
				{
					if (!puff)
					{
						temp = true;
						puff = Owner.LineAttack(bAngle, range, bSlope, 0,
							'Hitscan', puff_t, laFlags | LAF_NOINTERACT, t);
					}
					Owner.AimBulletMissile(proj, puff, flags, temp, false);
					if (t.Unlinked)
					{
						// Arbitary portals will make angle and pitch calculations 
						// unreliable. So use the angle and pitch we passed instead.
						proj.Angle = bAngle;
						proj.Pitch = bSlope;
						proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
					}
				}
			}

			return puff;
		}
		else // `numBullets` -1; all bullets spread
		{
			double pAngle = bAngle;
			double slope = bSlope;

			if (flags & FBF_EXPLICITANGLE)
			{
				pAngle += spread_xy;
				slope += spread_z;
			}
			else
			{
				pAngle += spread_xy * Random2[cabullet]() / 255.;
				slope += spread_z * Random2[cabullet]() / 255.;
			}

			int damage = bulletDmg;

			Actor puff = null; int realDmg = -1;
			[puff, realDmg] = Owner.LineAttack(pAngle, range, 
				slope, damage, 'Hitscan', puff_t, laflags, t);

			if (puff == null)
			{
				FLineTraceData ltd;
				LineTrace(pAngle, range, slope, TRF_NONE, data: ltd);
				puff = Actor.Spawn('BIO_FakePuff', ltd.HitLocation);
				puff.DamageType = GetDefaultByType(puff_t).DamageType;
				puff.Tracer = t.LineTarget;
			}

			puff.SetDamage(realDmg);
			if (missile == null) return puff;

			bool temp = false;
			double ang = Owner.Angle - 90;
			Vector2 ofs = Owner.AngleToVector(ang, spawnOfs_xy);
			Actor proj = Owner.SpawnPlayerMissile(missile, bAngle, ofs.X, ofs.Y, spawnHeight);
			
			if (proj)
			{
				if (!puff)
				{
					temp = true;
					puff = Owner.LineAttack(
						bAngle, range, bSlope, 0, 'Hitscan', puff_t,
						laFlags | LAF_NOINTERACT, t);
				}
				Owner.AimBulletMissile(proj, puff, flags, temp, false);
				if (t.Unlinked)
				{
					// Arbitary portals will make angle and pitch calculations 
					// unreliable. So use the angle and pitch we passed instead.
					proj.Angle = bAngle;
					proj.Pitch = bSlope;
					proj.Vel3DFromAngle(proj.Speed, proj.Angle, proj.Pitch);
				}
			}

			return puff;
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
		p.Flags = flags | RGF_SILENT;
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

	/* 	This always returns a puff; if one of `puff_t` doesn't get spawned, a fake
		stand-in will be spawned in its place. This fake puff lasts 2 tics, has
		the hit thing in its `Target` field, the real damage dealt in its `Damage` field,
		and `puff_t`'s default damage type.
	*/ 
	Actor BIO_Punch(in out BIO_FireData fireData, double range = DEFMELEERANGE,
		float lifesteal = 0.0, sound hitSound = 0, sound missSound = "",
		ECustomPunchFlags flags = CPF_NONE)
	{
		FTranslatedLineTarget t;

		fireData.Angle = Owner.Angle + Random2[CWPunch]() * (5.625 / 256);
		fireData.Pitch = Owner.AimLineAttack(fireData.Angle, range, t, 0.0, ALF_CHECK3D);
		
		Actor ret = null;
		int actualDmg = -1;

		ELineAttackFlags puffFlags = LAF_ISMELEEATTACK |
			((flags & CPF_NORANDOMPUFFZ) ? LAF_NORANDOMPUFFZ : 0);

		[ret, actualDmg] = Owner.LineAttack(fireData.Angle, range, fireData.Pitch,
			fireData.Damage, 'Melee', fireData.FireType, puffFlags, t);

		if (t.LineTarget == null)
		{
			Owner.A_StartSound(missSound, CHAN_WEAPON);
			return null;
		}

		Owner.A_StartSound(hitSound, CHAN_WEAPON);

		if (!(flags & CPF_NOTURN))
		{
			// Turn to face target
			Owner.Angle = t.AngleFromSource;
		}

		if (flags & CPF_PULLIN) Owner.bJustAttacked = true;

		if (!t.LineTarget.bDontDrain)
			ApplyLifeSteal(lifesteal, actualDmg);

		if (ret == null)
		{
			ret = Spawn('BIO_FakePuff', t.LineTarget.Pos);
			ret.SetDamage(actualDmg);
			ret.DamageType = 'Melee';
			ret.Tracer = t.LineTarget;
		}

		return ret;
	}

	void BIO_Saw(sound fullSound, sound hitSound, int dmg, Class<Actor> puff_t,
		ESawFlags flags, float range, float lifestealPercent)
	{
		FTranslatedLineTarget t;

		double ang = Owner.Angle + 2.8125 * (Random2[Saw]() / 255.0);
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
			
			Owner.A_StartSound(fullSound, CHAN_WEAPON);
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

		Owner.A_StartSound(hitSound, CHAN_WEAPON);

		// Turn to face target
		if (!(flags & SF_NOTURN))
		{
			double angleDiff = DeltaAngle(Owner.Angle, t.AngleFromSource);

			if (angleDiff < 0.0)
			{
				if (angleDiff < -4.5)
					Owner.Angle = t.AngleFromSource + 90.0 / 21;
				else
					Owner.Angle -= 4.5;
			}
			else
			{
				if (angleDiff > 4.5)
					Owner.Angle = t.AngleFromSource - 90.0 / 21;
				else
					Owner.Angle += 4.5;
			}
		}
	
		if (!(flags & SF_NOPULLIN))
			bJustAttacked = true;
	}

	// A specialized variation on `A_BFGSpray()`, for use by
	// `BIO_FireFunc_BFGSpray()`. Shoots only one ray and returns a fake puff.
	Actor BIO_BFGSpray(in out BIO_FireData fireData, double distance = 16.0 * 64.0,
		double vrange = 32.0, EBFGSprayFlags flags = BFGF_NONE)
	{
		FTranslatedLineTarget t;
		double an = Owner.Angle - fireData.Angle / 2 + fireData.Angle /
			fireData.Count * fireData.Number;

		Owner.AimLineAttack(an, distance, t, vrange);

		if (t.LineTarget == null) return null;

		Actor
			spray = Spawn(fireData.FireType, t.LineTarget.Pos +
			(0, 0, t.LineTarget.Height / 4), ALLOW_REPLACE),
			ret = Spawn('BIO_FakePuff', t.LineTarget.Pos);

		int dmgFlags = 0;
		name dmgType = 'BFGSplash';

		if (spray != null)
		{
			// [XA] Don't hit oneself unless we say so.
			if ((spray.bMThruSpecies &&
				Owner.GetSpecies() == t.LineTarget.GetSpecies()) || 
				(!(flags & BFGF_HURTSOURCE) && Owner == t.LineTarget)) 
			{
				// [MC] Remove it because technically, the spray isn't trying to "hit" them.
				spray.Destroy(); 
				return null;
			}

			if (spray.bPuffGetsOwner) spray.Target = Owner;
			if (spray.bFoilInvul) dmgFlags |= DMG_FOILINVUL;
			if (spray.bFoilBuddha) dmgFlags |= DMG_FOILBUDDHA;
			dmgType = spray.DamageType;
		}

		int newdam = t.LineTarget.DamageMObj(
			ret, Owner, fireData.Damage, dmgType,
			dmgFlags | DMG_USEANGLE, t.AngleFromSource);
		ret.SetDamage(newDam);
		ret.DamageType = 'BFGSplash';
		ret.Tracer = t.LineTarget;
		t.TraceBleed(newdam > 0 ? newdam : fireData.Damage, Owner);
		return ret;
	}
}

class BIO_WeaponZoomCooldown : Powerup
{
	Default
	{
		Powerup.Duration 15;
		+INVENTORY.UNTOSSABLE
	}
}

mixin class BIO_Magazine
{
	Default
	{
		+INVENTORY.IGNORESKILL
		Inventory.Icon '';
		Inventory.MaxAmount BIO_Weapon.MAGAZINE_MAXAMOUNT;
	}
}
