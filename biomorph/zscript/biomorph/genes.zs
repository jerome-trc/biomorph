class BIO_Gene : Inventory abstract
{
	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR // Just for the sake of being able to drop them

		Tag "$BIO_GENE_TAG";
		Inventory.PickupMessage "$BIO_GENE_PKUP";

		Height 16;
        Radius 20;
		Scale 0.75;
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		// Needed for network event communication
		ChangeTID(Level.FindUniqueTID(int.MIN, int.MAX));
	}

	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher))
			return false;

		let pawn = BIO_Player(toucher);

		if (pawn == null)
			return false;

		return pawn.CanCarryGene(self);		
	}

	// Prevent gene pickups from being folded together.
	override bool HandlePickup(Inventory item) { return false; }

	// This gene will never drop as loot if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	static BIO_Gene FindByTID(int tid)
	{
		let iter = Level.CreateActorIterator(tid, 'BIO_Gene');
		return BIO_Gene(iter.Next());
	}
}

class BIO_ModifierGene : BIO_Gene abstract
{
	meta class<BIO_WeaponModifier> ModType;
	property ModType: ModType;
}

// Support genes have effects on other nodes, rather than imparting a modifier.
class BIO_SupportGene : BIO_Gene abstract
{
	abstract bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const;

	abstract void Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const;

	abstract void Summary(in out Array<string> strings) const;
}

// Active genes do something to the graph upon being committed, sometimes
// being destroyed in the process.
class BIO_ActiveGene : BIO_Gene abstract
{
	abstract bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const;

	abstract void Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		uint node
	) const;

	abstract void Summary(in out Array<string> strings) const;
}

class BIO_SGene_AddNorth : BIO_SupportGene
{
	Default
	{
		Tag "$BIO_SGENE_ADDNORTH_TAG";
		Inventory.Icon 'GENSN0';
		Inventory.PickupMessage "$BIO_SGENE_ADDNORTH_PKUP";
	}

	States
	{
	Spawn:
		GENS N 6;
		#### # 6 Bright Light("BIO_MutaGene_Green");
		Loop;
	}

	final override bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let north = sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		if (north == null)
			return false, "$BIO_MODSUP_INCOMPAT_NONODENORTH";

		let mod = north.GetModifier();

		if (mod == null)
			return false, "$BIO_MODSUP_INCOMPAT_NOMODNORTH";

		return true, "";
	}

	final override void Apply(
		readOnly<BIO_WeaponModSimulator> sim,
		uint node
	) const
	{
		let myNode = sim.Nodes[node];

		let north = sim.GetNodeByPosition(
			myNode.Basis.PosX, myNode.Basis.PosY - 1
		);

		north.Multiplier++;
	}

	final override void Summary(in out Array<string> strings) const
	{
		strings.Push("$BIO_MODSUP_ADDNORTH_SUMM");
	}
}

class BIO_MGene_MagSize : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_MAGSIZE_TAG";
		Inventory.Icon 'GEN1M0';
		Inventory.PickupMessage "$BIO_MGENE_MAGSIZE_PKUP";
		BIO_ModifierGene.ModType 'BIO_WMod_MagSize';
	}

	States
	{
	Spawn:
		GEN1 M 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}

class BIO_MGene_DemonSlayer : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_DEMONSLAYER_TAG";
		Inventory.Icon 'GEN2D0';
		Inventory.PickupMessage "$BIO_MGENE_DEMONSLAYER_PKUP";
		BIO_ModifierGene.ModType 'BIO_WMod_DemonSlayer';
	}

	States
	{
	Spawn:
		GEN2 D 6;
		#### # 6 Bright Light("BIO_MutaGene_Red");
		Loop;
	}

	final override bool CanGenerate() const
	{
		return BIO_Utils.LegenDoom();
	}
}

class BIO_MGene_ReserveFeed : BIO_ModifierGene
{
	Default
	{
		Tag "$BIO_MGENE_RESERVEFEED_TAG";
		Inventory.Icon 'GEN2R0';
		Inventory.PickupMessage "$BIO_MGENE_RESERVEFEED_PKUP";
		BIO_ModifierGene.ModType 'BIO_WMod_ReserveFeed';
	}

	States
	{
	Spawn:
		GEN2 R 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}
}
