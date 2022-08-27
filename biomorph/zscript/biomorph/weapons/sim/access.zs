// Accessibility checker.
extend class BIO_WeaponModSimulator
{
	bool NodeAccessible(uint node) const
	{
		if (node >= Nodes.Size())
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Queried accessibility of illegal node %d.", node);
			return false;
		}

		if (node == 0) // Home node
			return true;

		// Completely unconnected nodes are permanently accessible
		if (Nodes[node].Basis.Neighbors.Size() < 1 ||
			Nodes[node].Basis.FreeAccess())
			return true;

		Array<uint> visited;

		if (NodeAccessibleViaFreeAccess(node, visited))
			return true;

		return NodeAccessibleImpl(node, 0, visited);
	}

	private bool NodeAccessibleImpl(uint tgt, uint cur,
		in out Array<uint> visited) const
	{
		if (cur == tgt)
			return true;

		visited.Push(cur);
		bool curActive = Nodes[cur].IsActive();

		for (uint i = 0; i < Nodes[cur].Basis.Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Basis.Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;

			for (uint j = 0; j < Nodes[ndx].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Basis.Neighbors[j];

				if (Nodes[nb].IsActive() && curActive &&
					NodeAccessibleImpl(tgt, ndx, visited))
					return true;
			}
		}

		return false;
	}

	private bool NodeAccessibleViaFreeAccess(uint tgt,
		in out Array<uint> visited) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].Basis.FreeAccess())
				continue;

			for (uint j = 0; j < Nodes[i].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[i].Basis.Neighbors[j];

				if (NodeAccessibleImpl(tgt, i, visited))
					return true;
			}
		}

		return false;
	}
}
