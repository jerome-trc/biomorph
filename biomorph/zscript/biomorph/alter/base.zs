class biom_Alterant abstract
{
	abstract void Apply(biom_Player pawn) const;
	/// If returning `false`, also return a string (localization not necessary)
	/// explaining to the user why this alterant is incompatible.
	abstract bool, string Compatible(readonly<biom_Player> pawn) const;
	/// Positive return values means this alterant makes the player stronger;
	/// negative return values means this alterant makes the player weaker.
	abstract int Balance() const;
	/// If returning `false`, whether this alterant is an upgrade or downgrade
	/// is determined by the return value of `Balance`. If that returns 0,
	/// this alterant is considered a sidegrade regardless of the return value
	/// of this function.
	abstract bool IsSidegrade() const;

	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Tag() const;
	/// Output does not need to be localized, but it must be fully colorized.
	abstract string Summary() const;

	virtual textureID Icon() const
	{
		textureID ret;
		ret.SetNull();
		return ret;
	}

	readonly<biom_Alterant> AsConst() const
	{
		return self;
	}
}

/// Whereas one prototype instance for each direct subtype of `biom_Alterant` is
/// stored, the set of prototype instances kept for each subtype of this class is
/// the Cartesian product of all subtypes of this class and all subtypes of `biom_Weapon`.
class biom_WeaponAlterant : biom_Alterant abstract
{
	class<biom_Weapon> weaponType;
}

const BIOM_BALMOD_INC_XS = 1;
const BIOM_BALMOD_INC_S = 5;
const BIOM_BALMOD_INC_M = 10;
const BIOM_BALMOD_INC_L = 20;
const BIOM_BALMOD_INC_XL = 40;
const BIOM_BALMOD_DEC_XS = -BIOM_BALMOD_INC_XS;
const BIOM_BALMOD_DEC_S = -BIOM_BALMOD_INC_S;
const BIOM_BALMOD_DEC_M = -BIOM_BALMOD_INC_M;
const BIOM_BALMOD_DEC_L = -BIOM_BALMOD_INC_L;
const BIOM_BALMOD_DEC_XL = -BIOM_BALMOD_INC_XL;

/// An inventory bar item which, upon use, gives the player an alterant batch
/// which is guaranteed to include one specific alterant.
class biom_AlterantItem : Inventory abstract
{
	meta class<biom_Alterant> ALTERANT;
	property Alterant: ALTERANT;

	Default
	{
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR

		Height 16.0;
		Radius 20.0;

		Inventory.Amount 1;
		Inventory.MaxAmount 99;
		Inventory.RestrictedTo 'biom_Player';
		Inventory.UseSound "biom/alter/item";
	}

	States
	{
	Spawn:
		MUTA G 6;
		#### # 6 bright light("biom_AlterantItem");
		loop;
	}

	override bool Use(bool pickup)
	{
		let pawn = biom_Player(self.owner);
		let pdat = pawn.GetDataMut();

		if (!pdat.pendingAlterants.IsEmpty())
		{
			pawn.A_Log("$BIOM_ALTERITEM_USEFAIL_PENDINGBATCH");
			return false;
		}

		let sdat = biom_Static.Get();

		if (self.ALTERANT is 'biom_WeaponAlterant')
		{
			let weap = self.ApplicableWeapon(pawn.AsConst());

			if (weap == null)
			{
				pawn.A_Log("$BIOM_ALTERITEM_USEFAIL_NOCOMPATIBLEWEAPS");
				return false;
			}

			let alter = sdat.GetWeaponAlterant(
				(class<biom_WeaponAlterant>)(self.ALTERANT),
				weap
			);

			Biomorph.Assert(alter != null);
		}
		else
		{
			let alter = sdat.GetAlterant(self.ALTERANT);
			Biomorph.Assert(alter != null);

			bool compat = false;
			string compatMsg = "";
			[compat, compatMsg] = alter.Compatible(pawn.AsConst());

			if (!compat)
			{
				pawn.A_Log(compatMsg);
				return false;
			}
		}

		pdat.NextAlteration();
		return true;
	}

	/// When attempting to use this item, it will check if its alterant type
	/// inherits from `biom_WeaponAlterant`. If so, it will invoke this function
	/// to find a weapon type to pair with the alterant type.
	/// Returning `null` is always valid.
	virtual class<biom_Weapon> ApplicableWeapon(readonly<biom_Player> pawn) const
	{
		return null;
	}
}
