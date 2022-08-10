class BIO_AGene_ToggleConnected : BIO_ActiveGene
{
	Default
	{
		Tag "$BIO_AGENE_TOGGLECONNECTED_TAG";
		Inventory.Icon 'GEN4A0';
		Inventory.PickupMessage "$BIO_AGENE_TOGGLECONNECTED_PKUP";
		BIO_Gene.LootWeight LOOTWEIGHT_COMMON;
		BIO_Gene.Limit 1;
		BIO_Gene.Summary "$BIO_AGENE_TOGGLECONNECTED_SUMM";
	}

	States
	{
	Spawn:
		GEN4 A 6;
		#### # 6 Bright Light("BIO_MutaGene_LightRed");
		Loop;
	}

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		let weap = context.Weap;

		if (weap.SpecialFunc != null)
			return false, "$BIO_AGENE_INCOMPAT_EXISTINGSPECIAL";

		let n = context.Sim.Nodes[context.Node];

		for (uint i = 0; i < n.Basis.Neighbors.Size(); i++)
		{
			let nbi = n.Basis.Neighbors[i];
			let nb = context.Sim.Nodes[nbi];

			if (nb.Basis.Neighbors.Size() == 1)
				return true, "";
		}

		return false, "$BIO_AGENE_INCOMPAT_ALLNEIGHBORSHAVENEIGHBORS";
	}

	final override string Apply(
		BIO_Weapon weap,
		BIO_WeaponModSimulator sim,
		BIO_GeneContext context
	) const
	{
		let func = new('BIO_WSF_NodeToggle');
		weap.SpecialFunc = func;
		let n = sim.Nodes[context.Node];
		
		for (uint i = 0; i < n.Basis.Neighbors.Size(); i++)
		{
			let nbi = n.Basis.Neighbors[i];
			let nb = sim.Nodes[nbi];

			if (nb.Basis.Neighbors.Size() > 1)
				continue;

			if (!nb.HasModifier())
				continue;

			func.AddNode(nbi, nb.Basis.Flags & BIO_WMGNF_MUTED);
		}

		return "";
	}
}

class BIO_WSF_NodeToggle : BIO_WeaponSpecialFunctor
{
	Array<uint> NodesToToggle;
	private Array<bool> NodeState; // `true` if the corresponding node is muted.

	void AddNode(uint uuid, bool alreadyMuted)
	{
		NodesToToggle.Push(uuid);
		NodeState.Push(alreadyMuted);
	}

	final override state Invoke(BIO_Weapon weap) const
	{
		let sim = BIO_WeaponModSimulator.Create(weap);

		for (uint i = 0; i < NodesToToggle.Size(); i++)
		{
			let node = sim.Nodes[NodesToToggle[i]];
			let gene_tag = GetDefaultByType(node.Basis.GeneType).GetTag();

			if (!NodeState[i])
			{
				node.Basis.Flags |= BIO_WMGNF_MUTED;

				weap.PrintPickupMessage(
					weap.Owner.CheckLocalView(),
					String.Format(
						StringTable.Localize("$BIO_AGENE_TOGGLECONNECTED_TOAST_MUTED"),
						gene_tag
					)
				);
			}
			else
			{
				node.Basis.Flags &= ~BIO_WMGNF_MUTED;

				weap.PrintPickupMessage(
					weap.Owner.CheckLocalView(),
					String.Format(
						StringTable.Localize("$BIO_AGENE_TOGGLECONNECTED_TOAST_UNMUTED"),
						gene_tag
					)
				);
			}

			NodeState[i] = node.Basis.Flags & BIO_WMGNF_MUTED;
		}

		sim.RunAndClose();
		weap.Owner.A_StartSound("bio/ui/beep");
		return state(null);
	}
}
