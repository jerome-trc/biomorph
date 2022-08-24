class BIO_Weapon : DoomWeapon abstract
{
	// `SelectionOrder` is for when ammo runs out; lower number, higher priority

	const SELORDER_PLASRIFLE = 100;
	const SELORDER_SSG = 400;
	const SELORDER_CHAINGUN = 700;
	const SELORDER_SHOTGUN = 1300;
	const SELORDER_PISTOL = 1900;
	const SELORDER_CHAINSAW = 2200;
	const SELORDER_RLAUNCHER = 2500;
	const SELORDER_BFG = 2800;
	const SELORDER_FIST = 3700;

	// `SlotPriority` is for manual selection; higher number, higher priority

	const SLOTPRIO_MAX = 1.0;
	const SLOTPRIO_HIGH = 0.6;
	const SLOTPRIO_LOW = 0.3;
	const SLOTPRIO_MIN = 0.0;

	// (Rat) Who designed those two properties to be so counter-intuitive?

	const SWITCHSPEED_MAX = 96;

	// If this weapon is unmodified and this field is false, it will
	// be destroyed if both of its `AmmoGive` values are drained.
	meta bool ScavengePersist;
	property ScavengePersist: ScavengePersist;

	meta string ScavengeMsg;
	property PickupMessages: PickupMsg, ScavengeMsg;

	meta bool Unique;
	property Unique: Unique;

	meta BIO_WeaponFamily Family;
	property Family: Family;

	// Which vanilla weapon will this potentially replace?
	// Can be left undefined.
	meta BIO_WeaponSpawnCategory SpawnCategory;
	property SpawnCategory: SpawnCategory;

	// Dictates how many nodes a newly-spawned weapon will get
	// when its mod graph is first generated.
	meta uint GraphQuality;
	property GraphQuality: GraphQuality;

	// Shown to the user when they examine a weapon on the ground.
	meta string Summary;
	property Summary: Summary;

	int RaiseSpeed, LowerSpeed;
	property SwitchSpeeds: RaiseSpeed, LowerSpeed;

	meta sound GroundHitSound; property GroundHitSound: GroundHitSound;

	// - For dual-wield weapons, `XYZ2` is for the left weapon.
	// - A null ammo type and a non-null magazine type means reloads are free.
	// - A null ammo type and a null magazine type means infinite ammo.

	// By default, the player pawn generates no
	// magazines for a weapon class whatsoever.
	meta BIO_MagazineFlags MagazineFlags;
	property MagazineFlags: MagazineFlags;

	// Defines the type of magazine that the weapon will attempt to acquire.
	class<BIO_Magazine> MagazineType1, MagazineType2;
	property MagazineType: MagazineType1;
	property MagazineType1: MagazineType1;
	property MagazineType2: MagazineType2;
	property MagazineTypes: MagazineType1, MagazineType2;

	uint MagazineSize1, MagazineSize2;
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
	uint16 MinAmmoReserve1, MinAmmoReserve2;
	property MinAmmoReserve: MinAmmoReserve1;
	property MinAmmoReserve1: MinAmmoReserve1;
	property MinAmmoReserve2: MinAmmoReserve2;
	property MinAmmoReserves: MinAmmoReserve1, MinAmmoReserve2;

	// If this weapon changes to ETMF, `ETMFDuration` is used to fill
	// `MagazineSize` (tics) and `ETMFCellCost` is used to fill `AmmoUse`.
	// Positive duration is interpreted as time in tics; negative as time in seconds.
	meta int ETMFDuration1, ETMFDuration2; meta uint ETMFCellCost1, ETMFCellCost2;
	property EnergyToMatter: ETMFDuration1, ETMFCellCost1;
	property EnergyToMatter1: ETMFDuration1, ETMFCellCost1;
	property EnergyToMatter2: ETMFDuration2, ETMFCellCost2;
	property EnergyToMatters: ETMFDuration1, ETMFCellCost1, ETMFDuration2, ETMFCellCost2;

	protected uint DynFlags;
	flagdef HitGround: DynFlags, 0;
	flagdef PreviouslyPickedUp: DynFlags, 1;
	// i.e. scoped in. Making a universal flag out of this allows, for example,
	// affixes which increase damage while zoomed in for sniper weapons, etc. 
	flagdef Zoomed: DynFlags, 2;
	// The last 4 flags (28 to 31) are reserved for derived classes.

	meta class<BIO_WeaponOperatingMode> OperatingMode1, OperatingMode2;
	property OperatingMode: OperatingMode1;
	property OperatingMode1: OperatingMode1;
	property OperatingMode2: OperatingMode2;
	property OperatingModes: OperatingMode1, OperatingMode2;

	BIO_WeaponOperatingMode OpModes[2];
	Array<BIO_StateTimeGroup> ReloadTimeGroups;
	Array<BIO_WeaponAffix> Affixes;
	BIO_WeaponModGraph ModGraph;
	BIO_WeaponSpecialFunctor SpecialFunc; // Invoked via the `Zoom` input.
	BIO_Magazine Magazine1, Magazine2;

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
		Inventory.RestrictedTo 'BIO_Player';

		Weapon.BobStyle 'InverseSmooth';
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobSpeed 2.0;

		BIO_Weapon.GroundHitSound "bio/weap/groundhit/0";
		BIO_Weapon.MinAmmoReserves 1, 1;
		BIO_Weapon.ReloadRatio1 1, 1;
		BIO_Weapon.ReloadRatio2 1, 1;
		BIO_Weapon.ScavengePersist true;
		BIO_Weapon.SwitchSpeeds 6, 6;
		BIO_Weapon.SpawnCategory __BIO_WSCAT_COUNT__;
	}

	States
	{
	Select.Loop:
		#### # 1 A_BIO_Raise;
		Loop;
	Deselect.Loop:
		#### # 1 A_BIO_Lower;
		Loop;
	Spawn.Normal:
		#### # 10; // Prevent player instantly picking weapon back up
		#### # 1 A_BIO_GroundHit;
		Goto Spawn.Normal + 1;
	Spawn.Mutated:
		#### # 10; // Prevent player instantly picking weapon back up
		#### # 1
		{
			A_BIO_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_BIO_GroundHit;
		#### # 1 Bright Light("BIO_MutatedLoot")
		{
			A_BIO_GroundHit();
			A_SetTranslation('BIO_Mutated');
		}
		#### ##### 1 Bright Light("BIO_MutatedLoot") A_BIO_GroundHit;
		Goto Spawn.Mutated + 1;
	Spawn.Unique:
		#### # 10; // Prevent player instantly picking weapon back up
		#### # 1
		{
			A_BIO_GroundHit();
			A_SetTranslation('');
		}
		#### ##### 1 A_BIO_GroundHit;
		#### # 1 Bright Light("BIO_UniqueLoot")
		{
			A_BIO_GroundHit();
			A_SetTranslation('BIO_Unique');
		}
		#### ##### 1 Bright Light("BIO_UniqueLoot") A_BIO_GroundHit;
		Goto Spawn.Unique + 1;
	Zoom:
		TNT1 A 0 A_BIO_WeaponSpecial;
		TNT1 A 0 A_Jump(256, 'Ready');
		TNT1 A 0 {
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Reached an illegal state through `BIO_Weapon::Zoom`. (%s)",
				invoker.GetClassName()
			);
		}
		Stop;
	}

	// Virtuals/abstracts //////////////////////////////////////////////////////

	// Build pipelines and reload time groups.
	// Called by `LazyInit()` after the operating mode has been instantiated.
	abstract void SetDefaults();

	/*	Intrinsic mod graphs can't be created in `SetDefaults()`, since that
		function gets called during the weapon mod simulation process (causing
		infinite recursion and stack overflow). Do it here instead.

		If `onMutate` is false, the call is being made during `LazyInit()`.
		Otherwise it's being made during application of a general mutagen.

		If your intent is for the unique weapon to have a pre-filled mod graph,
		act upon the former.
		If your intent is for a weapon to start un-mutated but gain certain
		properties implicitly upon mutation, act upon the latter.
	*/
	virtual void IntrinsicModGraph(bool onMutate) {}

	// Each is called once before starting its respective loop.
	virtual void OnDeselect()
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnDeselect(self);
	}

	virtual void OnSelect()
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnSelect(self);
	}

	// When calculating the cost to modify or morph a weapon, each gene has a base
	// value of 1, and the sum of those gene values is passed into this.
	virtual uint ModCost(uint base) const { return base; }

	virtual ui void RenderOverlay(BIO_RenderContext context) const
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].RenderOverlay(context);
	}
}

extend class BIO_Weapon
{
	Dictionary Serialize() const
	{
		let ret = Dictionary.Create();
		
		ret.Insert("type", GetClassName());

		if (ModGraph != null)
		{
			ret.Insert("modgraph.size", String.Format("%d", ModGraph.Nodes.Size()));

			for (uint i = 0; i < ModGraph.Nodes.Size(); i++)
			{
				ModGraph.Nodes[i].Serialize(ret);
			}
		}

		return ret;
	}

	static BIO_Weapon Deserialize(string input, Vector3 pos)
	{
		let dict = Dictionary.FromString(input);

		let ret = BIO_Weapon(Actor.Spawn(dict.At("type"), pos));
		ret.LazyInit();

		let sz = dict.At("modgraph.size").ToInt();

		if (sz > 0 && ret.ModGraph == null)
			ret.ModGraph = BIO_WeaponModGraph.Create(0);

		ret.ModGraph.Nodes[0] = BIO_WMGNode.Deserialize(dict, 0);

		for (uint i = 1; i < sz; i++)
			ret.ModGraph.Nodes.Push(BIO_WMGNode.Deserialize(dict, i));

		ret.SetTag(ret.ColoredTag());
		return ret;
	}
}
