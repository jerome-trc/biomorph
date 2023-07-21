class biom_PermanentInventory : Inventory abstract
{
	Default
	{
		Inventory.Icon 'TNT1A0';
		Inventory.InterHubAmount 1;
		Inventory.MaxAmount 1;
		Inventory.PickupMessage
			"If you're seeing this message, things might break.";

		-COUNTITEM
		+INVENTORY.KEEPDEPLETED
		+INVENTORY.PERSISTENTPOWER
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	States
	{
	Spawn:
		TNT1 A -1;
		loop;
	}
}

class biom_IntangibleActor : Actor abstract
{
	Default
	{
		-SOLID
		+CANPASS
		+DONTSPLASH
		+FLOORCLIP
		+NOBLOCKMAP
		+NOBLOCKMONST
		+NOTELEPORT
		+NOTIMEFREEZE
		+NOTONAUTOMAP
		+NOTRIGGER

		Height 8.0;
		Radius 16.0;
		RenderStyle 'None';
	}
}

class biom_WanderingSpawner : biom_IntangibleActor
{
	private class<Actor> toSpawn;
	private uint wanderCount;

	Default
	{
		Speed 15.0;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 1
		{
			if (invoker.wanderCount <= 0 || invoker.toSpawn == null)
				return ResolveState('Spawn');

			for (uint i = 0; i < invoker.wanderCount; i++)
				A_Wander();

			Actor.Spawn(invoker.toSpawn, invoker.pos);
			return state(null);
		}
		stop;
	}

	void Initialize(class<Actor> toSpawn, uint wanderCount)
	{
		self.wanderCount = wanderCount;
		self.toSpawn = toSpawn;
	}
}
