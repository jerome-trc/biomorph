// Determines what vanilla weapon a Biomorph weapon is intended to replace.
enum BIO_WeaponSpawnCategory : uint8
{
	BIO_WSCAT_SHOTGUN,
	BIO_WSCAT_CHAINGUN,
	BIO_WSCAT_SSG,
	BIO_WSCAT_RLAUNCHER,
	BIO_WSCAT_PLASRIFLE,
	BIO_WSCAT_BFG9000,
	BIO_WSCAT_CHAINSAW,
	BIO_WSCAT_PISTOL,
	__BIO_WSCAT_COUNT__
}

// Without this, there's no way for outside code to know that a weapon
// which isn't explicitly `BIO_Fist` is another fist-type weapon.
// Will probably expand this as technical needs become clearer.
enum BIO_WeaponFamily : uint8
{
	BIO_WEAPFAM_NONE,
	BIO_WEAPFAM_FIST
}

// Prevent one button push from toggling a weapon's zoom multiple times.
class BIO_WeaponZoomCooldown : Powerup
{
	Default
	{
		Powerup.Duration 15;
		+INVENTORY.UNTOSSABLE
	}
}

class BIO_Magazine : Ammo
{
	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.IGNORESKILL
		Inventory.MaxAmount uint16.MAX;
		Inventory.PickupMessage
			"If you see this message, please report a bug to RatCircus.";
	}

	// This class can't be abstract because it would cause a VM abort if the
	// player invoked the `give all` CCMD
	// Why doesn't this command check for abstract classes?
	// I assume there's an underlying technical reason
	// To work around this, just pretend the base class doesn't exist

	final override void BeginPlay()
	{
		super.BeginPlay();

		if (GetClass() == 'BIO_Magazine')
			Destroy();
	}

	final override void AttachToOwner(Actor other)
	{
		if (GetClass() == 'BIO_Magazine')
			return;
		else
			super.AttachToOwner(other);
	}

	final override bool CanPickup(Actor _)
	{
		return GetClass() != 'BIO_Magazine';
	}
}

class BIO_MagazineETM : BIO_Magazine
{
	meta class<BIO_EnergyToMatterPowerup> PowerupType;
	property PowerupType: PowerupType;

	Default
	{
		Inventory.MaxAmount 0;
	}
}

class BIO_EnergyToMatterPowerup : Powerup abstract
{
	meta int CellCost;
	property CellCost: CellCost;

	Default
	{
		+INVENTORY.UNTOSSABLE
		Powerup.Duration -3;
		BIO_EnergyToMatterPowerup.CellCost 5;
	}
}

class BIO_StateTimeGroup
{
	string Tag;
	bool Melee;
	Array<uint8> Times, Minimums;

	uint TotalTime() const
	{
		uint ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Times[i];

		return ret;
	}

	// Used for checking if fire/reload time modifications are possible,
	// and the allowances on any reductions made. Returns a positive number.
	uint PossibleReduction() const
	{
		uint ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Max(Times[i] - Minimums[i], 0);

		return ret;
	}

	uint MinTotalTime() const
	{
		uint ret = 0;

		for (uint i = 0; i < Times.Size(); i++)
			ret += Minimums[i];

		return ret;
	}

	void Modify(int modifier)
	{
		if (modifier == 0)
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..
				"Illegal time modifier of 0 given to state time group %s.", Tag);
			return;
		}

		let pr = PossibleReduction();

		uint e = Abs(modifier);

		for (uint i = 0; i < e; i++)
		{
			if (pr <= 0)
				break;

			uint idx = 0, minOrMax = 0;

			if (modifier > 0)
			{
				[minOrMax, idx] = BIO_Utils.Uint8ArrayMin(Times);
				pr++;
			}
			else
			{
				[minOrMax, idx] = BIO_Utils.Uint8ArrayMax(Times);
				pr--;
			}

			Times[idx] = modifier > 0 ? Times[idx] + 1 : Times[idx] - 1;
		}
	}

	void SetTotalTime(uint newTotal)
	{
		Modify(-(int(TotalTime()) - int(newTotal)));
	}

	void SetToMinTotalTime()
	{
		for (uint i = 0; i < Times.Size(); i++)
			Times[i] = Minimums[i];
	}

	private void Populate(state base)
	{
		Array<state> done;

		for (state s = base; s.InStateSequence(base); s = s.NextState)
		{
			if (done.Find(s) != done.Size())
				return; // Infinite loop protection

			if (s.Tics == 0)
				continue; // `TNT1 A 0` and the like

			done.Push(s);
			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set  
			// to 0, effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			// States marked `Slow` are kept immutable
			else if (s.bSlow)
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	private void RangePopulate(state from, state to)
	{
		for (state s = from; s.InStateSequence(from); s = s.NextState)
		{
			if (s.DistanceTo(to) <= 0)
				return;

			if (s.Tics == 0)
				continue; // `TNT1 A 0` and the like

			Times.Push(s.Tics);
			int min;

			// States marked `Fast` are allowed to have their tic time set  
			// to 0, effectively eliminating them from the state sequence
			if (s.bFast)
				min = 0;
			// States marked `Slow` are kept immutable
			else if (s.bSlow)
				min = s.Tics;
			else
				min = 1;

			Minimums.Push(min);
		}
	}

	string GetTagAsQualifier(string parenthClr = "\c[White]") const
	{
		if (Tag.Length() < 1)
			return "";
		else
			return String.Format("%s(\c[Yellow]%s%s)",
				parenthClr, StringTable.Localize(Tag), parenthClr);
	}

	// Add the tic times from all states in a contiguous sequence from `basis`
	// to this group. Beware that this will skip labels, and treats
	// `Goto MyState; MyState:` as contiguous. `tag` should be a string ID.
	static BIO_StateTimeGroup FromState(
		state basis, string tag = "", bool melee = false)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Melee = melee;
		ret.Populate(basis);
		return ret;
	}

	// `tag` should be a string ID.
	static BIO_StateTimeGroup FromStates(
		Array<state> basisArr, string tag = "", bool melee = false)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Melee = melee;

		for (uint i = 0; i < basisArr.Size(); i++)
			ret.Populate(basisArr[i]);

		return ret;
	}

	// Does the same thing as `FromState()`, but stops adding times 
	// upon arriving at `to`. `tag` should be a string ID.
	static BIO_StateTimeGroup FromStateRange(
		state from, state to, string tag = "", bool melee = false)
	{
		let ret = new('BIO_StateTimeGroup');
		ret.Tag = Tag;
		ret.Melee = melee;
		ret.RangePopulate(from, to);
		return ret;
	}
}
