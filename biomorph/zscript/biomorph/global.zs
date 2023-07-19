// Note to reader: classes may be defined using `extend` blocks for code folding.

class BIOM_Global : Thinker
{
	/// The monster value threshold between mutagen drops is divided by this.
	private uint playerCount;
	/// One per active player.
	private array<BIOM_PlayerData> playerData;
	/// The prototype data that all the other code points back to.
	private array<BIOM_Mutator> mutators;

	readonly<BIOM_PlayerData> GetPlayerData(uint player) const
	{
		return self.playerData[player].AsConst();
	}

	readonly<BIOM_PlayerData> FindPlayerData(PlayerInfo pInfo) const
	{
		for (uint i = 0; i < MAXPLAYERS; ++i)
			if (players[i] == pInfo)
				return self.playerData[i].AsConst();

		Biomorph.Unreachable();
		return null;
	}

	static BIOM_Global Create()
	{
		let iter = ThinkerIterator.Create('BIOM_Global', STAT_STATIC);

		if (iter.Next(true) != null)
		{
			Console.PrintF(
				Biomorph.LOGPFX_WARN ..
				"Attempted to re-create global data."
			);

			return null;
		}

		uint ms = MSTime();
		let ret = new('BIOM_Global');
		ret.ChangeStatNum(STAT_STATIC);

		for (uint i = 0; i < MAXPLAYERS; ++i)
		{
			if (!playerInGame[i])
				continue;

			ret.playerData.Push(BIOM_PlayerData.Create());
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

	static clearscope BIOM_Global Get()
	{
		let iter = ThinkerIterator.Create('BIOM_Global', STAT_STATIC);
		return BIOM_Global(iter.Next(true));
	}

	final override void OnDestroy()
	{
		if (developer >= 1)
			Console.PrintF(Biomorph.LOGPFX_DEBUG .. "Global data teardown.");

		super.OnDestroy();
	}
}

/// One exists per active player.
class BIOM_PlayerData
{
	/// What weapons will this player currently receive if they collect a weapon
	/// pickup? No element will ever be `null`.
	class<BIOM_Weapon> weapons[__BIOM_WEAPSLOT_COUNT__];
	/// Each subclass of `BIOM_WeaponData` appears in this array exactly once.
	array<BIOM_WeaponData> weaponData;
	/// Invariants:
	/// - Nodes are in a k-tree.
	/// - Element 0 always has only the root node.
	/// - Append-only. Removal only happens during a reset, at which point only
	/// layer 0 with its root is left behind. Indices are otherwise always valid.
	array<BIOM_MutatorNodeLayer> mutTree;

	static BIOM_PlayerData Create()
	{
		let ret = new('BIOM_PlayerData');

		ret.weapons[BIOM_WEAPSLOT_1] = 'BIOM_Melee';
		ret.weapons[BIOM_WEAPSLOT_2] = 'BIOM_Pistol';
		ret.weapons[BIOM_WEAPSLOT_3] = 'BIOM_RiotStormgun';
		ret.weapons[BIOM_WEAPSLOT_3_SUPER] = 'BIOM_CombatStormgun';
		ret.weapons[BIOM_WEAPSLOT_4] = 'BIOM_GPMG';
		ret.weapons[BIOM_WEAPSLOT_5] = 'BIOM_MANPAT';
		ret.weapons[BIOM_WEAPSLOT_6] = 'BIOM_BiteRifle';
		ret.weapons[BIOM_WEAPSLOT_7] = 'BIOM_CasterCannon';

		for (uint i = 0; i < allClasses.Size(); ++i)
		{
			let wdat = (class<BIOM_WeaponData>)(allClasses[i]);

			if (wdat == null || wdat.IsAbstract())
				continue;

			let e = ret.weaponData.Push(BIOM_WeaponData(new(wdat)));
			ret.weaponData[e].Reset();
		}

		let root = new('BIOM_MutatorNode');
		root.active = true;
		root.children.Push(0);
		root.children.Push(1);

		let layer1 = new('BIOM_MutatorNodeLayer');
		layer1.nodes.Push(root);

		ret.mutTree.Push(layer1);

		return ret;
	}

	readonly<BIOM_PlayerData> AsConst() const
	{
		return self;
	}
}

/// Maps to one concentric ring in the mutation menu.
class BIOM_MutatorNodeLayer
{
	array<BIOM_MutatorNode> nodes;
}

class BIOM_MutatorNode
{
	/// If `false`, this is just one choice available.
	/// If `true`, the effects have been applied.
	/// Always `true` for the root node.
	bool active;
	/// This is only `null` for the root node.
	/// The backing value should be considered "owned" by `BIOM_Global`.
	BIOM_Mutator mutator;

	/// This is only `null` for the root node.
	BIOM_MutatorNode parent;
	/// Each element corresponds to an element in `BIOM_MutatorNodeLayer::nodes`,
	/// and always points into the next layer.
	array<uint> children;
}

/// Each variant corresponds to an element in `BIOM_PlayerData::weapons`.
enum BIOM_WeaponSlot
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
