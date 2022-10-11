class BIO_Gene : Inventory abstract
{
	mixin BIO_Rarity;

	const LOOTWEIGHT_MAX = 18;
	const LOOTWEIGHT_VERYCOMMON = 14;
	const LOOTWEIGHT_COMMON = 10;
	const LOOTWEIGHT_UNCOMMON = 6;
	const LOOTWEIGHT_RARE = 3;
	const LOOTWEIGHT_VERYRARE = 2;
	const LOOTWEIGHT_MIN = 1;

	meta uint LootWeight;
	property LootWeight: LootWeight;

	protected BIO_GeneData Data;

	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR // Just for the sake of being able to drop them

		Tag "$BIO_GENE_TAG";
		Height 16;
        Radius 20;
		Scale 0.75;

		Inventory.PickupMessage "$BIO_GENE_PKUP";
		Inventory.RestrictedTo 'BIO_Player';
	}

	override bool CanPickup(Actor toucher)
	{
		// Fundamental checks (toucher isn't null, class restrictions)
		if (!super.CanPickup(toucher))
			return false;

		let pawn = BIO_Player(toucher);
		return pawn.HeldGeneCount() < pawn.MaxGenesHeld;		
	}

	// Prevent gene pickups from being folded together.
	override bool HandlePickup(Inventory item) { return false; }

	// This gene will never drop as loot if this returns `false`.
	virtual bool CanGenerate() const { return true; }

	virtual void Initialize() {}

	BIO_GeneData Inner() const
	{
		return Data;
	}

	BIO_GeneData Drain()
	{
		let ret = Data;
		Data = null;
		return ret;
	}

	void Fill(BIO_GeneData data)
	{
		self.Data = data;
	}

	bool IsEmpty() const { return Data == null; }
}

// 1 modifier is baked into the class to define its sprite/icon and loot weight.
// 1 random modifier to create balance is then added on afterwards.
class BIO_ProceduralGene : BIO_Gene abstract
{
	meta class<BIO_WeaponModifier> Modifier;
	property Modifier: Modifier;

	// Tag will never have more than 2 consecutive letters.
	// Why? It's an easy fix to the Scunthorpe problem.
	static string GenerateTag()
	{
		let ret = "";
		let r = Random[BIO_Loot](3, 8);
		uint prevLetters = 0;

		for (uint i = 0; i < r; i++)
		{
			if (prevLetters >= 2 || Random[BIO_Loot](0, 3) == 0)
			{
				ret.AppendCharacter(Random[BIO_Loot](48, 57));
				prevLetters = 0;
			}
			else
			{
				ret.AppendCharacter(Random[BIO_Loot](65, 90));
				prevLetters++;
			}
		}

		return String.Format(
			StringTable.Localize("$BIO_PROCGENE_TAGTEMPLATE"),
			ret
		);
	}

	static BIO_GeneData DefaultData(class<BIO_ProceduralGene> subtype)
	{
		let globals = BIO_Global.Get();
		let defs = GetDefaultByType(subtype);
		let mod = globals.GetWeaponModifierByType(defs.Modifier);
		Array<BIO_WeaponModifier> mods;
		mods.Push(mod);
		return BIO_GeneData.Create(GenerateTag(), subtype, mods);
	}

	final override void PostBeginPlay()
	{
		super.PostBeginPlay();

		if (GetTag() == Default.GetTag())
		{
			if (Data == null)
				Data = DefaultData(GetClass());

			SetTag(Data.GetTag());
		}
	}

	final override void Initialize()
	{
		let globals = BIO_Global.Get();
		let base = globals.PopProcGenePermutation();
		base.Modifiers.Insert(0, globals.GetWeaponModifierByType(Modifier));
		Data = BIO_GeneData.Create(base.Tag, GetClass(), base.Modifiers);
		SetTag(Data.GetTag());
	}

	final override string PickupMessage()
	{
		return String.Format(
			StringTable.Localize("$BIO_PROCGENE_PKUPTEMPLATE"),
			GetTag()
		);
	}
}

class BIO_GeneData
{
	private string Tag;
	private class<BIO_Gene> ActorType;
	// References to instances owned by the global singleton.
	private Array<BIO_WeaponModifier> Modifiers;

	class<BIO_Gene> GetActorType() const { return ActorType; }
	string GetTag() const { return Tag; }

	bool, string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context,
		BIO_WeaponModSimPass simPass
	) const
	{
		let ret1 = true;
		let ret2 = "";

		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			if (Modifiers[i].SimPass() != simPass)
				continue;

			let compat = true;
			let cmsg = "";

			[compat, cmsg] = Modifiers[i].Compatible(context);

			ret1 &= compat;

			if (!ret1)
			{
				if (cmsg.Length() > 0)
					ret2.AppendFormat("%s\n\c[Gray]-\n", StringTable.Localize(cmsg));

				break;
			}

			let amsg = Modifiers[i].Apply(weap, sim, context);

			if (amsg.Length() > 0)
				ret2.AppendFormat("%s\n\c[Gray]-\n", StringTable.Localize(amsg));
		}

		ret2.DeleteLastCharacter();
		ret2.DeleteLastCharacter();
		return ret1, ret2;
	}

	string Summary() const
	{
		let ret = "";

		for (uint i = 0; i < Modifiers.Size(); i++)
			ret.AppendFormat(
				"%s\n\c[Gray]-\n",
				StringTable.Localize(Modifiers[i].Summary())
			);

		ret.DeleteLastCharacter();
		ret.DeleteLastCharacter();
		return ret;
	}

	uint Limit() const
	{
		uint ret = 0;

		for (uint i = 0; i < Modifiers.Size(); i++)
			ret = Max(ret, Modifiers[i].Limit());

		return ret;
	}

	void FlavorRules(Dictionary dict) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
			Modifiers[i].FlavorRules(dict);
	}

	BIO_WeaponCoreModFlags, BIO_WeaponPipelineModFlags CombinedModifierFlags() const
	{
		BIO_WeaponCoreModFlags ret1 = BIO_WCMF_NONE;
		BIO_WeaponPipelineModFlags ret2 = BIO_WPMF_NONE;

		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			BIO_WeaponCoreModFlags cf = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags pf = BIO_WPMF_NONE;

			[cf, pf] = Modifiers[i].Flags();

			ret1 |= cf;
			ret2 |= pf;
		}

		return ret1, ret2;
	}

	uint CountCoreModFlags(BIO_WeaponCoreModFlags flags) const
	{
		uint ret = 0;

		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			BIO_WeaponCoreModFlags cf = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags _ = BIO_WPMF_NONE;
			[cf, _] = Modifiers[i].Flags();

			if ((cf & flags) == flags)
				ret++;
		}
		
		return ret;
	}

	uint CountPipelineModFlags(BIO_WeaponPipelineModFlags flags) const
	{
		uint ret = 0;

		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			BIO_WeaponCoreModFlags _ = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags pf = BIO_WPMF_NONE;
			[_, pf] = Modifiers[i].Flags();

			if ((pf & flags) == flags)
				ret++;
		}

		return ret;
	}

	uint CountModifierFlags(
		BIO_WeaponCoreModFlags coreFlags,
		BIO_WeaponPipelineModFlags pipelineFlags
	) const
	{
		uint ret = 0;

		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			BIO_WeaponCoreModFlags cf = BIO_WCMF_NONE;
			BIO_WeaponPipelineModFlags pf = BIO_WPMF_NONE;
			[cf, pf] = Modifiers[i].Flags();

			if (((cf & coreFlags) == coreFlags) &&
				((pf & pipelineFlags) == pipelineFlags))
				ret++;
		}

		return ret;
	}

	bool ContainsModifierOfType(class<BIO_WeaponModifier> type) const
	{
		for (uint i = 0; i < Modifiers.Size(); i++)
			if (Modifiers[i].GetClass() == type)
				return true;

		return false;
	}

	// Returns `true` if a modifier within pushes the host node
	// over that modifier's limit.
	bool IncrementModTypeCounts(
		in out Array<class<BIO_WeaponModifier> > modTypes,
		in out Array<uint> modCounts
	) const
	{
		bool ret = false;

		for (uint i = 0; i < Modifiers.Size(); i++)
		{
			let mod_t = Modifiers[i].GetClass();
			let mtc = modTypes.Find(mod_t);

			if (mtc == modTypes.Size())
			{
				mtc = modTypes.Push(mod_t);
				modCounts.Push(0);
			}

			let limit = Modifiers[i].Limit();

			if (++modCounts[mtc] > limit)
				ret = true;
		}

		return ret;
	}

	static BIO_GeneData Create(
		string tag,
		class<BIO_Gene> actorType,
		in out Array<BIO_WeaponModifier> mods
	)
	{
		let ret = new('BIO_GeneData');
		ret.Tag = tag;
		ret.ActorType = actorType;
		ret.Modifiers.Move(mods);
		return ret;
	}

	// Debug representation string.
	string Repr() const
	{
		string ret = "";

		for (uint i = 0; i < Modifiers.Size(); i++)
			ret.AppendFormat("%s/", Modifiers[i].GetClassName());

		ret.DeleteLastCharacter();
		return ret;
	}

	readOnly<BIO_GeneData> AsConst() const { return self; }
}

struct BIO_GeneContext
{
	readOnly<BIO_WeaponModSimulator> Sim;
	readOnly<BIO_Weapon> Weap;

	// More specifically, the node's UUID.
	uint Node;
	// Loaded with `BIO_WMS_Node::Multiplier`.
	uint NodeCount;

	bool IsLastNode() const { return Node == Sim.RealNodeSize() - 1; }
}
