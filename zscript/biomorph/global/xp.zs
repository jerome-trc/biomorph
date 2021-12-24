// The associated perk class and a position on the perk menu.
class BIO_PerkGraphNode
{
	string UUID;
	bool Active;
	Vector2 Position;
	Class<BIO_Passive> PerkClass;
}

// Information about what nodes on the perk graph a player has filled out.
class BIO_PerkGraph
{
	PlayerInfo Player;
	Array<BIO_PerkGraphNode> Nodes;
}

// Includes perk information.
extend class BIO_GlobalData
{
	private uint PartyXP, PartyLevel;
	BIO_PerkGraph BasePerkGraph; // Generated on Thinker creation
	private Array<BIO_PerkGraph> PerkGraphs; // One per player

	uint GetPartyXP() const { return PartyXP; }
	uint GetPartyLevel() const { return PartyLevel; }
	uint XPToNextLevel() const { return 1000 * (PartyLevel ** 1.4); }

	void AddPartyXP(uint xp)
	{
		PartyXP += xp;
		while (PartyXP >= XPToNextLevel())
		{
			PartyLevel++;

			if (BIO_debug)
				Console.Printf(Biomorph.LOGPFX_DEBUG ..
					"Party leveled up to %d.", PartyLevel);
		}
	}

	BIO_PerkGraph GetPerkGraph(PlayerInfo pInfo) const
	{
		if (!(pInfo.Cls is 'BIO_Player')) return null;

		for (uint i = 0; i < PerkGraphs.Size(); i++)
		{
			if (PerkGraphs[i].Player != pInfo) continue;
			return PerkGraphs[i];
		}

		// This player has no perk graph yet. Create it
		uint e = PerkGraphs.Push(new('BIO_PerkGraph'));
		PerkGraphs[e].Player = pInfo;
		PerkGraphs[e].Nodes.Copy(BasePerkGraph.Nodes);
		return PerkGraphs[e];
	}

	const LMPNAME_PERKS = "BIOPERK";

	private void CreateBasePerkGraph()
	{
		BasePerkGraph = new('BIO_PerkGraph');

		{
			// Create the starter node
			uint e = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
			BasePerkGraph.Nodes[e].UUID = "bio_start";
		}

		int lump = -1, next = 0;

		do
		{
			lump = Wads.FindLump(LMPNAME_PERKS, next, Wads.GLOBALNAMESPACE);
			if (lump == -1) break;
			next = lump + 1;

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
			if (perks != null)
			{
				for (uint i = 0; i < perks.size(); i++)
				{
					string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
						LMPNAME_PERKS .. " lump %d, upgrade object %d; ", lump, i);

					let perk = BIO_Utils.TryGetJsonObject(perks.get(i));
					if (perk == null)
					{
						Console.Printf(errpfx .. "skipping it.");
						continue;
					}

					let uuid = BIO_Utils.StringFromJson(perk.get("uuid"));
					if (uuid == "")
					{
						Console.Printf(errpfx .. "malformed or missing UUID.");
						continue;
					}

					if (uuid == "bio_start")
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

					uint e = BasePerkGraph.Nodes.Push(new('BIO_PerkGraphNode'));
					BasePerkGraph.Nodes[e].UUID = uuid;
					BasePerkGraph.Nodes[e].PerkClass = perk_t;
					BasePerkGraph.Nodes[e].Position = (posX_json.i, posY_json.i);
				}
			}
		} while (true);
	}
}
