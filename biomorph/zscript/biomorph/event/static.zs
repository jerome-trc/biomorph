// Static helpers for sending network events.
extend class BIO_EventHandler
{
	const EVENT_FIRSTPKUP = "bio_firstpkup";

	static clearscope void BroadcastFirstPickup(name typeName)
	{
		EventHandler.SendNetworkEvent(EVENT_FIRSTPKUP .. ":" .. typeName);
	}

	static clearscope void WeapModSim_Start()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_START
		);
	}

	static clearscope void WeapModSim_InsertGeneFromInventory(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_INSERT,
			node, slot
		);
	}

	static clearscope void WeapModSim_MoveGeneBetweenNodes(
		uint fromNode, uint toNode)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_NODEMOVE,
			fromNode, toNode
		);
	}

	static clearscope void WeapModSim_MoveGeneBetweenInventorySlots(
		uint fromSlot, uint toSlot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_INVMOVE,
			fromSlot, toSlot
		);
	}

	static clearscope void WeapModSim_SwapNodeAndSlot(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_SWAPNODEANDSLOT,
			node, slot
		);
	}

	static clearscope void WeapModSim_ExtractGeneFromNode(uint node, uint slot)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_EXTRACT,
			node, slot
		);
	}

	static clearscope void WeapModSim_Run()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_SIMULATE	
		);
	}

	static clearscope void WeapModSim_Commit()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_COMMIT
		);
	}

	static clearscope void WeapModSim_Revert()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_REVERT
		);
	}

	static clearscope void WeapModSim_Morph(uint node)
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_MORPH,
			node
		);
	}

	static clearscope void WeapModSim_Stop()
	{
		EventHandler.SendNetworkEvent(
			EVENT_WEAPMOD,
			WEAPMODOP_STOP
		);
	}
}
