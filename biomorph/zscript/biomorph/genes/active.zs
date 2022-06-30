class BIO_AGene_ToggleConnected : BIO_ActiveGene
{
	Default
	{
		Tag "$BIO_AGENE_TOGGLECONNECTED_TAG";
		Inventory.Icon 'GEN9A0';
		Inventory.PickupMessage "$BIO_AGENE_TOGGLECONNECTED_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_UNCOMMON;
		BIO_Gene.Limit 1;
		BIO_Gene.Summary "$BIO_AGENE_TOGGLECONNECTEDSUMM";
	}

	States
	{
	Spawn:
		GEN9 A 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}

	final override bool, string Compatible(
		readOnly<BIO_WeaponModSimulator> sim, uint node
	) const
	{
		let weap = sim.GetWeapon();

		if (weap.SpecialFunc != null)
			return false, "$BIO_AGENE_INCOMPAT_EXISTINGSPECIAL";

		let n = sim.Nodes[node];

		for (uint i = 0; i < n.Basis.Neighbors.Size(); i++)
		{
			let nbi = n.Basis.Neighbors[i];
			let nb = sim.Nodes[nbi];

			if (nb.Basis.Neighbors.Size() > 1)
				return true, "";
		}

		return false, "$BIO_AGENE_INCOMPAT_ALLNEIGHBORSHAVENEIGHBORS";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		uint node
	) const
	{
		let func = new('BIO_WSF_NodeToggle');
		weap.SpecialFunc = func;
		let n = sim.Nodes[node];
		
		for (uint i = 0; i < n.Basis.Neighbors.Size(); i++)
		{
			let nbi = n.Basis.Neighbors[i];
			let nb = sim.Nodes[nbi];

			if (nb.Basis.Neighbors.Size() > 1)
				continue;

			if (!nb.HasModifier())
				continue;

			func.ToggledNodes.Push(nbi);
		}

		return "";
	}
}

class BIO_WSF_NodeToggle : BIO_WeaponSpecialFunctor
{
	Array<uint> ToggledNodes;

	final override state Invoke(BIO_Weapon weap) const
	{
		for (uint i = 0; i < ToggledNodes.Size(); i++)
		{
			weap.ModGraph.Nodes[ToggledNodes[i]].Toggle();
		}

		BIO_WeaponModSimulator.Create(weap).CommitAndClose();
		weap.Owner.A_StartSound("bio/ui/beep");
		return state(null);
	}
}
