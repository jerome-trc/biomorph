class BIO_NewWeapon : DoomWeapon abstract
{
	mixin BIO_Gear;

	meta Class<BIO_NewWeapon> UniqueBase; property UniqueBase: UniqueBase;
	BIO_WeaponFlags BIOFlags; property Flags: BIOFlags;
	uint AffixMask; property AffixMask: AffixMask;
	int RaiseSpeed, LowerSpeed;
	property SwitchSpeeds: RaiseSpeed, LowerSpeed;

	private uint LastPipeline;
	Array<BIO_WeaponPipeline> Pipelines;

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
		BIO_NewWeapon.Rarity BIO_RARITY_COMMON;
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
		Construct();
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

		if (Pipelines.Size() < 1) Construct();
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

		if (Pipelines.Size() < 1) Construct();

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

	override string GetObituary(Actor victim, Actor inflictor, Name mod, bool playerAtk)
	{
		return Pipelines[LastPipeline].GetObituary();
	}

	// Virtuals and abstracts ==================================================

	// Build this weapon's default firing pipelines.
	abstract void Construct();

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

	protected action bool A_BIO_Fire(uint pipeline = 0)
	{
		if (!invoker.Pipelines[pipeline].DepleteAmmo()) return false;
		return true;
	}

	// Call from the weapon's Spawn state, after two frames of the weapon's 
	// pickup sprite (each 0 tics long). Puts the weapon into a new loop with
	// appropriate behaviour for its rarity (e.g., blinking cyan if mutated).
	protected action state A_BIO_Spawn()
	{
		if (invoker.Rarity == BIO_RARITY_UNIQUE)
			return ResolveState('Spawn.Unique');
		else if (invoker.Affixes.Size() > 0)
			return ResolveState('Spawn.Mutated');
		else
			return ResolveState('Spawn.Common');
	}

	// Call from the weapon's Deselect state, during one frame of the weapon's
	// ready sprite (0 tics long). Runs a callback and puts the weapon in a 
	// lowering loop.
	protected action state A_BIO_Deselect()
	{
		invoker.OnDeselect();
		return ResolveState('Deselect.Loop');
	}

	// Call from the weapon's Select state, during one frame of the weapon's
	// ready sprite (0 tics long). Runs a callback and puts the weapon in a 
	// raising loop.
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

	action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }

	// Getters =================================================================

	bool DamageMutable() const
	{
		for (uint i = 0; i < Pipelines.Size(); i++)
			if (Pipelines[i].DamageMutable())
				return true;

		return false;
	}
}
