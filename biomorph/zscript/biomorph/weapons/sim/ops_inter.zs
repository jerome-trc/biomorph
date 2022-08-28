// Intermediate (non-critical path) operations.
extend class BIO_WeaponModSimulator
{
	// Take a gene out of the inventory and put it into a node.
	void InsertGene(uint node, uint slot)
	{
		if (Nodes[node].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to add gene to occupied node %d.",
				node
			);
			return;
		}

		if (Genes[slot] == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to add gene from empty slot %d.",
				slot
			);
			return;
		}

		Nodes[node].Gene = Genes[slot];
		Genes[slot] = null;
	}

	// Move a gene from one node to another.
	void NodeMove(uint fromNode, uint toNode)
	{
		if (!Nodes[fromNode].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene from unfilled node %d.",
				fromNode
			);
			return;
		}

		let temp = Nodes[toNode].Gene;
		Nodes[toNode].Gene = Nodes[fromNode].Gene;
		Nodes[fromNode].Gene = temp;
	}

	// Move a gene from one inventory slot to another.
	void InventoryMove(uint fromSlot, uint toSlot)
	{
		if (Genes[fromSlot] == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene from empty slot %d.",
				fromSlot
			);
			return;
		}

		if (Genes[toSlot] != null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene to occupied slot %d.",
				toSlot
			);
			return;
		}

		Genes[toSlot] = Genes[fromSlot];
		Genes[fromSlot] = null;
	}

	void SwapNodeAndSlot(uint node, uint slot)
	{
		if (!Nodes[node].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene from unfilled node %d.",
				node
			);
			return;
		}

		if (Genes[slot] == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to move gene from unoccupied slot %d.",
				slot
			);
			return;
		}

		let ng = Nodes[node].Gene;
		Nodes[node].Gene = Genes[slot];
		Genes[slot] = ng;
	}

	// Take a gene out of a node and put it back into the inventory.
	void ExtractGene(uint node, uint slot)
	{
		if (!Nodes[node].IsOccupied())
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to remove gene from gene-less node %d.",
				node
			);
			return;
		}

		// User specified a slot to return the gene to
		if (Genes[slot] != null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"Illegal attempt to extract gene into occupied slot %d.",
				slot
			);
			return;
		}

		Genes[slot] = Nodes[node].Gene;
		Nodes[node].Gene = null;
	}

	void InsertNewGene(class<BIO_Gene> type, uint node)
	{
		let g = new('BIO_WMS_GeneVirtual');
		g.Type = type;
		Nodes[node].Gene = g;
		Nodes[node].Update();
	}

	void InsertNewGenesAtRandom(uint count = 1, bool noDuplication = false)
	{
		let globals = BIO_Global.Get();

		for (uint i = 0; i < count; i++)
		{
			let r = RandomNode(accessible: true, unoccupied: true);
			uint a1 = 0;

			do
			{
				class<BIO_Gene> gene_t = null;

				if (noDuplication)
				{
					uint a2 = 0;

					do
					{
						gene_t = globals.RandomGeneType();
					} while (ContainsGeneOfType(gene_t) && a2++ < 50)

					if (ContainsGeneOfType(gene_t))
					{
						Nodes[r].Gene = null;
						Nodes[r].Update();
						return;
					}
				}
				else
				{
					gene_t = globals.RandomGeneType();
				}

				InsertNewGene(gene_t, r);
				Simulate();
			}
			while (!IsValid() && a1++ < 50);

			if (!IsValid())
			{
				if (BIO_debug)
				{
					Console.Printf(
						Biomorph.LOGPFX_DEBUG ..
						"Failed to insert a new random gene into node %d "
						"after 50 attempts.", r
					);
				}

				Nodes[r].Gene = null;
				Nodes[r].Update();
				return;
			}
		}
	}

	void GraphRemoveByType(class<BIO_Gene> type)
	{
		for (uint i = 1; i < Nodes.Size(); i++)
			if (Nodes[i].GetGeneType() == type)
				Nodes[i].Gene = null;
	}

	void GraphUnlockByType(class<BIO_Gene> type)
	{
		for (uint i = 1; i < Nodes.Size(); i++)
			if (Nodes[i].GetGeneType() == type)
				Nodes[i].Basis.Unlock();
	}
}
