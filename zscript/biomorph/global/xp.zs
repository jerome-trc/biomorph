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
	string Tag, Description, VerboseDesc, FlavorText; // Pre-localized
	TextureID Icon;
	Vector2 Position;
	BIO_PerkCategory Category;
	BIO_Perk Perk;
	Array<uint> Neighbors;
}

class BIO_PerkTemplate
{
	string ID;
	string Tag, Description, VerboseDesc, FlavorText; // Un-localized
	TextureID Icon;
	Class<BIO_Perk> PerkClass;
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

	private bool IsAccessibleImpl(uint tgt, uint cur,
		in out Array<uint> active, in out Array<uint> visited) const
	{
		if (cur == tgt) return true;
		visited.Push(cur);

		for (uint i = 0; i < Nodes[cur].Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;
			
			for (uint j = 0; j < Nodes[ndx].Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Neighbors[j];
				if (active.Find(nb) != active.Size() &&
					IsAccessibleImpl(tgt, ndx, active, visited))
					return true;
			}
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

		Array<uint> visited;
		return IsAccessibleImpl(node, 0, active, visited);
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
	uint XPToNextLevel() const { return 1000 * (PartyLevel ** 1.7); }

	void AddPartyXP(uint xp)
	{
		bool anylevelup = false;
		PartyXP += xp;

		while (PartyXP >= XPToNextLevel())
		{
			anylevelup = true;

			if (++PartyLevel < BasePerkGraph.Nodes.Size())
				AddPerkPoint();

			if (BIO_debug)
				Console.Printf(Biomorph.LOGPFX_DEBUG ..
					"Party leveled up to %d.", PartyLevel);
		}

		if (anylevelup)
			S_StartSound("bio/levelup", CHAN_AUTO);
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
			if (PerkGraphs[i].Player == pInfo)
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

	void GetPlayerPerkObjects(PlayerInfo pInfo, in out Array<BIO_Perk> output) const
	{
		if (output.Size() > 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegally passed non-empty array to `GetPlayerPerkObjects()`.");
			return;
		}

		let pGraph = GetPerkGraph(pInfo);

		for (uint i = 0; i < BasePerkGraph.Nodes.Size(); i++)
		{
			if (BasePerkGraph.Nodes[i].Perk == null)
				continue;

			if (pGraph.PerkActive[i])
				output.Push(BasePerkGraph.Nodes[i].Perk);
		}
	}

	void XPReset()
	{
		PartyXP = 0;
		PartyLevel = 0;

		for (uint i = 0; i < PerkGraphs.Size(); i++)
		{
			PerkGraphs[i].Points = 0;
			PerkGraphs[i].Refunds = 0;
			
			for (uint j = 1; j < PerkGraphs[i].PerkActive.Size(); j++)
				PerkGraphs[i].PerkActive[j] = false;
		}
	}

	// Initialization ==========================================================

	const LMPNAME_PERKS = "BIOPERK";

	private void CreateBasePerkGraph()
	{
		// Cache JSON objects so only one read/parse pass over VFS is needed
		Array<BIO_JsonObject> perkObjs;
		// Also cache the lumps corresponding to each object, and the index of 
		// the object relative to that lump, for better error messaging
		Array<int> perkObjLumps;
		Array<uint> perkObjIndices;
		uint currentPerk = 0;
		Array<BIO_PerkCategory> perkObjCats;
		Array<bool> perkObjValid;

		Array<BIO_PerkTemplate> templates;

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

			let templateJSON = BIO_Utils.TryGetJsonArray(
				obj.get("templates"), errMsg: false);
			
			if (templateJSON != null)
				ReadPerkTemplateJSON(lump, templateJSON, templates);

			let perks = BIO_Utils.TryGetJsonObject(obj.get("perks"), errMsg: false);
			if (perks == null) continue;

			let arrMinor = BIO_Utils.TryGetJsonArray(perks.get("minor"), errMsg: false);
			if (arrMinor != null)
			{
				ReadPerkArrayJSON(arrMinor, perkObjs,
					perkObjLumps, perkObjIndices, currentPerk, lump);

				while (perkObjCats.Size() < perkObjs.Size())
					perkObjCats.Push(BIO_PRKCAT_MINOR);
			}

			let arrMajor = BIO_Utils.TryGetJsonArray(perks.get("major"), errMsg: false);
			if (arrMajor != null)
			{
				ReadPerkArrayJSON(arrMajor, perkObjs,
					perkObjLumps, perkObjIndices, currentPerk, lump);

				while (perkObjCats.Size() < perkObjs.Size())
					perkObjCats.Push(BIO_PRKCAT_MAJOR);
			}

			let arrKeystone = BIO_Utils.TryGetJsonArray(perks.get("keystone"), errMsg: false);
			if (arrKeystone != null)
			{
				ReadPerkArrayJSON(arrKeystone, perkObjs,
					perkObjLumps, perkObjIndices, currentPerk, lump);

				while (perkObjCats.Size() < perkObjs.Size())
					perkObjCats.Push(BIO_PRKCAT_KEYSTONE);
			}
		}

		perkObjValid.Resize(perkObjs.Size());

		for (uint i = 0; i < perkObjs.Size(); i++)
		{
			string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
				LMPNAME_PERKS .. " lump %d, perk object %d; ",
				perkObjLumps[i], perkObjIndices[i]);

			let perk = perkObjs[i];

			let stringID = BIO_Utils.StringFromJson(perk.get("uuid"));
			if (stringID.Length() < 1)
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

			let template = BIO_Utils.StringFromJson(
				perk.get("template"), errMsg: false);
			if (template.Length() > 0)
			{
				let node = new('BIO_PerkGraphNode');
				node.Position = (posX_json.i, posY_json.i);
				node.Category = perkObjCats[i];

				if (TryCreatePerkFromTemplate(templates, template, node, errpfx))
				{
					stringIDs.Push(stringID);
					perkObjValid[i] = true;
				}
				
				continue;
			}

			let perk_t = (Class<BIO_Perk>)
				(BIO_Utils.TryGetJsonClassName(perk.get("class")));
			if (perk_t == null)
			{
				Console.Printf(errpfx .. "malformed or invalid class name.");
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

			uint e = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
			BasePerkGraph.Nodes[e].UUID = e;
			BasePerkGraph.Nodes[e].Perk = BIO_Perk(new(perk_t));
			BasePerkGraph.Nodes[e].Position = (posX_json.i, posY_json.i);
			BasePerkGraph.Nodes[e].Tag = StringTable.Localize(tag);
			BasePerkGraph.Nodes[e].Description = StringTable.Localize(desc);
			BasePerkGraph.Nodes[e].VerboseDesc = StringTable.Localize(descV);
			BasePerkGraph.Nodes[e].Icon = icon;
			BasePerkGraph.Nodes[e].Category = perkObjCats[i];
			perkObjValid[i] = true;
			stringIDs.Push(stringID);
		}

		for (uint i = perkObjs.Size() - 1; i >= 0; i--)
		{
			if (!perkObjValid[i]) perkObjs.Delete(i);
		}

		perkObjValid.Clear();

		// This time, map strings in neighbour arrays to numeric UUIDs
		for (uint i = 0; i < perkObjs.Size(); i++)
		{
			string warnpfx = String.Format(Biomorph.LOGPFX_WARN ..
				LMPNAME_PERKS .. " lump %d, perk object %d; ",
				perkObjLumps[i], perkObjIndices[i]);
			string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
				LMPNAME_PERKS .. " lump %d, perk object %d; ",
				perkObjLumps[i], perkObjIndices[i]);

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

				if (strID ~== BIO_Utils.StringFromJson(perk.get("uuid")))
				{
					Console.Printf(errpfx ..
						"illegal self-reference by node `%s`.", strID);
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
	}

	private static void ReadPerkArrayJSON(BIO_JsonArray perks,
		in out Array<BIO_JsonObject> perkObjs,
		in out Array<int> perkObjLumps,
		in out Array<uint> perkObjIndices,
		in out uint currentPerk, int lump)
	{
		for (uint i = 0; i < perks.arr.Size(); i++)
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
			perkObjIndices.Push(currentPerk);
			perkObjLumps.Push(lump);
		}
	}

	private static void ReadPerkTemplateJSON(int lump,
		BIO_JsonArray templateJSON, in out Array<BIO_PerkTemplate> templates)
	{
		for (uint i = 0; i < templateJSON.arr.Size(); i++)
		{
			string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
				LMPNAME_PERKS .. " lump %d, perk template object %d; ", lump, i);

			let obj = BIO_Utils.TryGetJsonObject(templateJSON.arr[i]);
			if (obj == null)
			{
				Console.Printf(errpfx .. "skipping it.");
				continue;
			}

			let id = BIO_Utils.StringFromJson(obj.get("id"));
			if (id.Length() < 1)
			{
				Console.Printf(errpfx .. "malformed or missing ID.");
				continue;
			}

			bool nameOverlap = false;

			for (uint j = 0; j < templates.Size(); j++)
			{
				if (templates[j].ID ~== id)
				{
					nameOverlap = true;
					break;	
				}
			}

			if (nameOverlap)
			{
				Console.Printf(errpfx ..
					"name %s overlaps with an existing template.",
					id);
				continue;
			}

			let perk_t = (Class<BIO_Perk>)
				(BIO_Utils.TryGetJsonClassName(obj.get("class")));
			if (perk_t == null)
			{
				Console.Printf(errpfx .. "malformed or invalid class name.");
				continue;
			}

			let tag = BIO_Utils.StringFromJson(obj.get("tag"));
			let desc = BIO_Utils.StringFromJson(obj.get("desc"));
			let descV = BIO_Utils.StringFromJson(
				obj.get("desc_verbose"), errMsg: false);
			let flavor = BIO_Utils.StringFromJson(
				obj.get("flavor"), errMsg: false);
			let icon = Texman.CheckForTexture(
				BIO_Utils.StringFromJson(obj.get("icon")), TexMan.TYPE_ANY);

			uint e = templates.Push(new('BIO_PerkTemplate'));
			templates[e].ID = id;
			templates[e].PerkClass = perk_t;
			templates[e].Tag = tag;
			templates[e].Description = desc;
			templates[e].VerboseDesc = descV;
			templates[e].Icon = icon;
		}
	}

	bool TryCreatePerkFromTemplate(in out Array<BIO_PerkTemplate> templates,
		string templID, BIO_PerkGraphNode node, string errpfx)
	{
		BIO_PerkTemplate template = null;

		for (uint i = 0; i < templates.Size(); i++)
		{
			if (templates[i].ID ~== templID)
			{
				template = templates[i];
				break;
			}
		}

		if (template == null)
		{
			Console.Printf(errpfx .. "invalid template ID: %s", templID);
			return false;
		}

		uint e = BasePerkGraph.Nodes.Push(node);
		BasePerkGraph.Nodes[e].UUID = e;
		BasePerkGraph.Nodes[e].Perk = BIO_Perk(new(template.PerkClass));
		// Position should have been pre-filled by caller
		BasePerkGraph.Nodes[e].Tag = StringTable.Localize(template.Tag);
		BasePerkGraph.Nodes[e].Description = StringTable.Localize(template.Description);
		BasePerkGraph.Nodes[e].VerboseDesc = StringTable.Localize(template.VerboseDesc);
		BasePerkGraph.Nodes[e].Icon = template.Icon;
		return true;
	}
}
