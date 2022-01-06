enum BIO_PerkCategory : uint8
{
	BIO_PRKCAT_MINOR,
	BIO_PRKCAT_MAJOR,
	BIO_PRKCAT_KEYSTONE,
	BIO_PRKCAT_START
}

class BIO_PerkGraphNode
{
	uint UUID;
	string Tag, Description, VerboseDesc, FlavorText;
	TextureID Icon;
	Vector2 Position;
	BIO_PerkCategory Category;
	Class<BIO_Passive> PerkClass;
	Array<uint> Neighbors;
	uint DistanceFromStart;
}

// Information about what nodes on the perk graph
// a player has filled out, alongside related data.
class BIO_PlayerPerkGraph
{
	PlayerInfo Player;
	Array<bool> PerkActive;
	uint Points, Refunds;

	readOnly<BIO_PlayerPerkGraph> AsConst() const { return self; }
}

// The prototype; the global thinker holds the one and only instance of this.
class BIO_BasePerkGraph
{
	Array<BIO_PerkGraphNode> Nodes;

	private void ResolveDistImpl(uint node, uint distance, in out Array<uint> visited)
	{
		visited.Push(node);
		Nodes[node].DistanceFromStart = distance;

		for (uint i = 0; i < Nodes[node].Neighbors.Size(); i++)
		{
			let n = Nodes[node].Neighbors[i];

			if (visited.Find(n) != visited.Size())
				continue;
			
			ResolveDistImpl(n, distance + 1, visited);
		}
	}

	void ResolveDistances()
	{
		Array<uint> visited;
		ResolveDistImpl(0, 0, visited);
	}

	private bool IsAccessibleImpl(uint tgt, uint cur, in out Array<uint> active) const
	{
		for (uint i = 0; i < Nodes[cur].Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Neighbors[i];
			
			if (ndx == tgt)
				return true;
			
			if (Nodes[ndx].DistanceFromStart <= Nodes[cur].DistanceFromStart)
				continue;

			if (active.Find(ndx) != active.Size() &&
				IsAccessibleImpl(tgt, ndx, active))
				return true;
		}

		return false;
	}

	bool IsAccessible(uint node, in out Array<uint> active) const
	{
		if (node >= Nodes.Size())
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Queried accessibility of illegal node %d.", node);
			return false;
		}

		if (node == 0)
			return true;

		// Completely unconnected nodes are permanently accessible
		if (Nodes[node].Neighbors.Size() < 1)
			return true;

		return IsAccessibleImpl(node, 0, active);
	}

	bool HasNode(uint uuid) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
			if (Nodes[i].UUID == uuid)
				return true;

		return false;
	}

	void DebugPrint() const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			Console.Printf("Node %d has neigbors:", i);
			for (uint j = 0; j < Nodes[i].Neighbors.Size(); j++)
				Console.Printf("\t%d", Nodes[i].Neighbors[j]);
		}
	}

	readOnly<BIO_BasePerkGraph> AsConst() const { return self; }
}

// Includes perk information.
extend class BIO_GlobalData
{
	private uint PartyXP, PartyLevel;
	private BIO_BasePerkGraph BasePerkGraph; // Generated on Thinker creation
	private Array<BIO_PlayerPerkGraph> PerkGraphs; // One per player

	uint GetPartyXP() const { return PartyXP; }
	uint GetPartyLevel() const { return PartyLevel; }
	uint XPToNextLevel() const { return 1000 * (PartyLevel ** 1.4); }

	void AddPartyXP(uint xp)
	{
		PartyXP += xp;

		while (PartyXP >= XPToNextLevel())
		{
			PartyLevel++;
			AddPerkPoint();

			if (BIO_debug)
				Console.Printf(Biomorph.LOGPFX_DEBUG ..
					"Party leveled up to %d.", PartyLevel);
		}
	}

	void LevelUp()
	{
		PartyXP = XPToNextLevel();
		AddPartyXP(0);
	}

	void AddPerkPoint()
	{
		for (uint i = 0; i < PerkGraphs.Size(); i++)
			PerkGraphs[i].Points++;
	}

	BIO_PlayerPerkGraph GetPerkGraph(PlayerInfo pInfo) const
	{
		if (!(pInfo.Cls is 'BIO_Player')) return null;

		for (uint i = 0; i < PerkGraphs.Size(); i++)
		{
			if (PerkGraphs[i].Player != pInfo) continue;
			return PerkGraphs[i];
		}

		// This player has no perk graph yet. Create it
		uint e = PerkGraphs.Push(new('BIO_PlayerPerkGraph'));
		PerkGraphs[e].Player = pInfo;
		PerkGraphs[e].PerkActive.Resize(BasePerkGraph.Nodes.Size());
		PerkGraphs[e].PerkActive[0] = true;
		PerkGraphs[e].Points = PartyLevel;
		return PerkGraphs[e];
	}

	readOnly<BIO_BasePerkGraph> GetBasePerkGraph() const
	{
		return BasePerkGraph.AsConst();
	}

	const LMPNAME_PERKS = "BIOPERK";

	private void CreateBasePerkGraph()
	{
		// Cache JSON objects so only one read/parse pass over VFS is needed
		Array<BIO_JsonObject> perkObjs;
		// Also cache the lumps corresponding to each object, and the index of 
		// the object relative to that lump, for better error messaging
		Array<int> perkObjLump, perkObjIndex;

		BasePerkGraph = new('BIO_BasePerkGraph');
		Array<string> stringIDs;
		
		// Create the starter node
		uint sn = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
		BasePerkGraph.Nodes[sn].Category = BIO_PRKCAT_START;
		stringIDs.Push("bio_start");

		for (int lump = 0; lump < Wads.GetNumLumps(); lump++)
		{
			if (Wads.GetLumpNamespace(lump) != Wads.NS_GLOBAL)
				continue;
			if (!(Wads.GetLumpFullName(lump).Left(LMPNAME_PERKS.Length())
				~== LMPNAME_PERKS))
				continue;

			BIO_JsonElementOrError fileOpt = BIO_JSON.parse(Wads.ReadLump(lump));
			if (fileOpt is 'BIO_JsonError')
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. 
					"Skipping malformed %s lump %d. Details: %s", lump,
					LMPNAME_PERKS, BIO_JsonError(fileOpt).what);
				continue;
			}

			let obj = BIO_Utils.TryGetJsonObject(BIO_JsonElement(fileOpt));
			if (obj == null)
			{
				Console.Printf(Biomorph.LOGPFX_ERR .. LMPNAME_PERKS ..
					" lump %d has malformed contents.", lump);
				continue;
			}

			let perks = BIO_Utils.TryGetJsonArray(obj.get("perks"), errMsg: false);
			if (perks == null) continue;
			
			for (uint i = 0; i < perks.size(); i++)
			{
				string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
					LMPNAME_PERKS .. " lump %d, perk object %d; ", lump, i);

				let perk = BIO_Utils.TryGetJsonObject(perks.get(i));
				if (perk == null)
				{
					Console.Printf(errpfx .. "skipping it.");
					continue;
				}

				perkObjs.Push(perk);
				perkObjIndex.Push(i);
				perkObjLump.Push(lump);
			}
		}

		for (uint i = 0; i < perkObjs.Size(); i++)
		{
			string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
				LMPNAME_PERKS .. " lump %d, perk object %d; ",
				perkObjLump[i], perkObjIndex[i]);

			let perk = perkObjs[i];

			let stringID = BIO_Utils.StringFromJson(perk.get("uuid"));
			if (stringID == "")
			{
				Console.Printf(errpfx .. "malformed or missing UUID.");
				continue;
			}

			if (stringIDs.Find(stringID) != stringIDs.Size())
			{
				Console.Printf(errpfx .. "UUID `%s` has already been defined.",
					stringID);
				continue;
			}

			if (stringID == "bio_start")
			{
				Console.Printf(errpfx .. "the starting node cannot be modified.");
				continue;
			}

			let perk_t = (Class<BIO_Passive>)
				(BIO_Utils.TryGetJsonClassName(perk.get("class")));
			if (perk_t == null)
			{
				Console.Printf(errpfx .. "malformed or invalid class name.");
				continue;
			}

			let posX_json = BIO_Utils.TryGetJsonInt(perk.get("x"));
			if (posX_json == null)
			{
				Console.Printf(errpfx .. "malformed or missing x-position.");
				continue;
			}

			let posY_json = BIO_Utils.TryGetJsonInt(perk.get("y"));
			if (posY_json == null)
			{
				Console.Printf(errpfx .. "malformed or missing y-position.");
				continue;
			}

			let tag = BIO_Utils.StringFromJson(perk.get("tag"));
			let desc = BIO_Utils.StringFromJson(perk.get("desc"));
			let descV = BIO_Utils.StringFromJson(
				perk.get("desc_verbose"), errMsg: false);
			let flavor = BIO_Utils.StringFromJson(
				perk.get("flavor"), errMsg: false);
			let icon = Texman.CheckForTexture(
				BIO_Utils.StringFromJson(perk.get("icon")), TexMan.TYPE_ANY);

			let catStr = BIO_Utils.StringFromJson(perk.get("category"));
			BIO_PerkCategory cat = BIO_PRKCAT_MINOR;

			if (catStr ~== "minor")
				cat = BIO_PRKCAT_MINOR;
			else if (catStr ~== "major")
				cat = BIO_PRKCAT_MAJOR;
			else if (catStr ~== "keystone")
				cat = BIO_PRKCAT_KEYSTONE;
			else if (catStr.Length() < 1)
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					errpfx .. "missing category field.");
				continue;
			}
			else
			{
				Console.Printf(Biomorph.LOGPFX_ERR ..
					errpfx .. "invalid perk category: %s", catStr);
				continue;
			}

			uint e = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
			BasePerkGraph.Nodes[e].UUID = e;
			BasePerkGraph.Nodes[e].PerkClass = perk_t;
			BasePerkGraph.Nodes[e].Position = (posX_json.i, posY_json.i);
			BasePerkGraph.Nodes[e].Tag = StringTable.Localize(tag);
			BasePerkGraph.Nodes[e].Description = StringTable.Localize(desc);
			BasePerkGraph.Nodes[e].VerboseDesc = StringTable.Localize(descV);
			BasePerkGraph.Nodes[e].Icon = icon;
			BasePerkGraph.Nodes[e].Category = cat;
			stringIDs.Push(stringID);
		}

		// This time, map strings in neighbour arrays to numeric UUIDs
		for (uint i = 0; i < perkObjs.Size(); i++)
		{
			string warnpfx = String.Format(Biomorph.LOGPFX_WARN ..
				LMPNAME_PERKS .. " lump %d, perk object %d; ",
				perkObjLump[i], perkObjIndex[i]);
			string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
				LMPNAME_PERKS .. " lump %d, perk object %d; ",
				perkObjLump[i], perkObjIndex[i]);

			let perk = perkObjs[i];

			let nbs = BIO_Utils.TryGetJsonArray(
				perk.get("neighbors"), errMsg: false);

			// A node can be completely unconnected; this is legal and
			// makes it permanently accessible for activation
			if (nbs == null) continue;

			if (nbs.arr.Size() < 1)
			{
				Console.Printf(warnpfx .. 
					"definition contains an empty `neighbours` array.");
				continue;
			}

			for (uint j = 0; j < nbs.arr.Size(); j++)
			{
				string strID = BIO_Utils.StringFromJson(nbs.arr[j]);

				if (strID.Length() < 1)
				{
					Console.Printf(errpfx .. "invalid UUID for perk neighbour.");
					continue;
				}

				// `stringIDs` and `BasePerkGraph.Nodes` are parallel,
				// so `k` is a node index/UUID here
				for (uint k = 0; k < stringIDs.Size(); k++)
				{
					if (!(stringIDs[k] ~== strID))
						continue;

					// `ni` is the node which defined neighbor(s)
					// `nk` is the node requested for neighboring by `ni`
					let ni = BasePerkGraph.Nodes[i + 1], nk = BasePerkGraph.Nodes[k];

					if (ni.Neighbors.Find(nk.UUID) == ni.Neighbors.Size())
						ni.Neighbors.Push(nk.UUID);
					if (nk.Neighbors.Find(i + 1) == nk.Neighbors.Size())
						nk.Neighbors.Push(i + 1);
				}
			}
		}

		BasePerkGraph.ResolveDistances();
	}
}
