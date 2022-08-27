// Extended accessibility checker.
extend class BIO_WeaponModSimulator
{
	bool NodeAccessibleEx(uint node, in out Array<uint> active) const
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

		if (NodeAccessibleViaFreeAccessEx(node, active, visited))
			return true;

		return NodeAccessibleExImpl(node, 0, active, visited);
	}

	private bool NodeAccessibleExImpl(uint tgt, uint cur,
		in out Array<uint> active, in out Array<uint> visited) const
	{
		if (cur == tgt)
			return true;

		visited.Push(cur);
		bool curActive = active.Find(cur) != active.Size();

		for (uint i = 0; i < Nodes[cur].Basis.Neighbors.Size(); i++)
		{
			uint ndx = Nodes[cur].Basis.Neighbors[i];

			if (visited.Find(ndx) != visited.Size())
				continue;

			for (uint j = 0; j < Nodes[ndx].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[ndx].Basis.Neighbors[j];

				if (active.Find(nb) != active.Size() && curActive &&
					NodeAccessibleExImpl(tgt, ndx, active, visited))
					return true;
			}
		}

		return false;
	}

	private bool NodeAccessibleViaFreeAccessEx(uint tgt,
		in out Array<uint> active, in out Array<uint> visited) const
	{
		for (uint i = 0; i < Nodes.Size(); i++)
		{
			if (!Nodes[i].Basis.FreeAccess())
				continue;

			for (uint j = 0; j < Nodes[i].Basis.Neighbors.Size(); j++)
			{
				let nb = Nodes[i].Basis.Neighbors[j];

				if (NodeAccessibleExImpl(tgt, i, active, visited))
					return true;
			}
		}

		return false;
	}
}
