// Note to reader: classes may be defined using `extend` blocks for code folding.

class biom_Global : Thinker
{
	/// The monster value threshold between mutagen drops is divided by this.
	private uint playerCount;
	/// One per active player.
	private array<biom_PlayerData> playerData;
	/// The prototype data that all the other code points back to.
	private array<biom_Mutator> mutators;

	readonly<biom_PlayerData> GetPlayerData(uint player) const
	{
		return self.playerData[player].AsConst();
	}

	readonly<biom_PlayerData> FindPlayerData(PlayerInfo pInfo) const
	{
		for (uint i = 0; i < MAXPLAYERS; ++i)
			if (players[i] == pInfo)
				return self.playerData[i].AsConst();

		Biomorph.Unreachable();
		return null;
	}

	static biom_Global Create()
	{
		let iter = ThinkerIterator.Create('biom_Global', STAT_STATIC);

		if (iter.Next(true) != null)
		{
			Console.PrintF(
				Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data."
			);

			return null;
		}

		uint ms = MSTime();
		let ret = new('biom_Global');
		ret.ChangeStatNum(STAT_STATIC);

		for (uint i = 0; i < MAXPLAYERS; ++i)
		{
			if (!playerInGame[i])
				continue;

			ret.playerData.Push(biom_PlayerData.Create());
			ret.playerCount++;
		}

		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Global init done (took %d ms).",
				MsTime() - ms
			);
		}

		return ret;
	}

	static clearscope biom_Global Get()
	{
		let iter = ThinkerIterator.Create('biom_Global', STAT_STATIC);
		return biom_Global(iter.Next(true));
	}

	final override void OnDestroy()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");

		super.OnDestroy();
	}
}

/// One exists per active player.
class biom_PlayerData
{
	/// What weapons will this player currently receive if they collect a weapon
	/// pickup? No element will ever be `null`.
	class<biom_Weapon> weapons[__BIOM_WEAPSLOT_COUNT__];
	/// Each subclass of `biom_WeaponData` appears in this array exactly once.
	array<biom_WeaponData> weaponData;
	/// Invariants:
	/// - Nodes are in a k-tree.
	/// - Element 0 always has only the root node.
	/// - Append-only. Removal only happens during a reset, at which point only
	/// layer 0 with its root is left behind. Indices are otherwise always valid.
	array<biom_MutatorNodeLayer> mutTree;

	static biom_PlayerData Create()
	{
		let ret = new('biom_PlayerData');

		ret.weapons[BIOM_WEAPSLOT_1] = 'biom_Melee';
		ret.weapons[BIOM_WEAPSLOT_2] = 'biom_ServicePistol';
		ret.weapons[BIOM_WEAPSLOT_3] = 'biom_PumpShotgun';
		ret.weapons[BIOM_WEAPSLOT_3_SUPER] = 'biom_CombatStormgun';
		ret.weapons[BIOM_WEAPSLOT_4] = 'biom_GPMG';
		ret.weapons[BIOM_WEAPSLOT_5] = 'biom_MANPAT';
		ret.weapons[BIOM_WEAPSLOT_6] = 'biom_BiteRifle';
		ret.weapons[BIOM_WEAPSLOT_7] = 'biom_CasterCannon';

		for (uint i = 0; i < allClasses.Size(); ++i)
		{
			let wdat = (class<biom_WeaponData>)(allClasses[i]);

			if (wdat == null || wdat.IsAbstract())
				continue;

			let e = ret.weaponData.Push(biom_WeaponData(new(wdat)));
			ret.weaponData[e].Reset();
		}

		let root = new('biom_MutatorNode');
		root.active = true;
		root.children.Push(0);
		root.children.Push(1);

		let layer1 = new('biom_MutatorNodeLayer');
		layer1.nodes.Push(root);

		ret.mutTree.Push(layer1);

		return ret;
	}

	readonly<biom_PlayerData> AsConst() const
	{
		return self;
	}
}

/// Maps to one concentric ring in the mutation menu.
class biom_MutatorNodeLayer
{
	array<biom_MutatorNode> nodes;
}

class biom_MutatorNode
{
	/// If `false`, this is just one choice available.
	/// If `true`, the effects have been applied.
	/// Always `true` for the root node.
	bool active;
	/// This is only `null` for the root node.
	/// The backing value should be considered "owned" by `biom_Global`.
	biom_Mutator mutator;

	/// This is only `null` for the root node.
	biom_MutatorNode parent;
	/// Each element corresponds to an element in `biom_MutatorNodeLayer::nodes`,
	/// and always points into the next layer.
	array<uint> children;
}

/// Each variant corresponds to an element in `biom_PlayerData::weapons`.
enum biom_WeaponSlot
{
	BIOM_WEAPSLOT_1 = 0,
	BIOM_WEAPSLOT_2 = 1,
	BIOM_WEAPSLOT_3 = 2,
	BIOM_WEAPSLOT_3_SUPER = 3,
	BIOM_WEAPSLOT_4 = 4,
	BIOM_WEAPSLOT_5 = 5,
	BIOM_WEAPSLOT_6 = 6,
	BIOM_WEAPSLOT_7 = 7,
	__BIOM_WEAPSLOT_COUNT__,
}
