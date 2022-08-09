class BIO_PermanentInventory : Inventory abstract
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
		Loop;
	}
}

class BIO_IntangibleActor : Actor abstract
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

		Height 8;
		Radius 16;
		RenderStyle 'None';
	}
}

class BIO_WanderingSpawner : BIO_IntangibleActor
{
	private class<Actor> ToSpawn;
	private uint WanderCount;

	Default
	{
		Speed 15;
	}	

	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 1
		{
			if (invoker.WanderCount <= 0 || invoker.ToSpawn == null)
				return ResolveState('Spawn');

			for (uint i = 0; i < invoker.WanderCount; i++)
				A_Wander();

			Actor.Spawn(ToSpawn, Pos);
			return state(null);
		}
		Stop;
	}

	void Initialize(class<Actor> toSpawn, uint wanderCount)
	{
		self.WanderCount = wanderCount;
		self.ToSpawn = toSpawn;
	}
}
