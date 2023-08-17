class biom_Alterant abstract
{
	/// If returning `false`, whether this alterant is an upgrade or downgrade
	/// is determined by the return value of `Balance`. If that returns 0,
	/// this alterant is considered a sidegrade regardless of the return value
	/// of this function.
	virtual bool IsSidegrade() const
	{
		return false;
	}

	/// Dictates if this alterant is allowed to appear in batches. Return `false`
	/// if you want the only possible source for this alterant to be loot items.
	virtual bool Natural() const
	{
		return true;
	}

	/// The returned value gets clamped by calling code to the 0-255 range (inclusive).
	virtual uint Weight() const
	{
		return uint8.MAX;
	}

	/// A flavor name.
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
}

class biom_PawnAlterant : biom_Alterant abstract
{
	abstract play void Apply(biom_Player pawn) const;
	/// If returning `false`, also return a string (localization not necessary)
	/// explaining to the user why this alterant is incompatible.
	abstract bool, string Compatible(readonly<biom_Player> pawn) const;

	abstract int Balance(readonly<biom_Player> pawn) const;
}

class biom_WeaponAlterant : biom_Alterant abstract
{
	abstract void Apply(biom_WeaponData wdat) const;
	/// If returning `false`, also return a string (localization not necessary)
	/// explaining to the user why this alterant is incompatible.
	abstract bool, string Compatible(readonly<biom_WeaponData> wdat) const;

	abstract int Balance(readonly<biom_WeaponData> wdat) const;
}

class biom_PendingAlterant
{
	biom_Alterant inner;
	/// `null` if `inner` is a `biom_PawnAlterant`.
	biom_WeaponData weaponData;
}

enum biom_AlterantKind : uint8
{
	BIOM_ALTK_DOWNGRADE,
	BIOM_ALTK_SIDEGRADE,
	BIOM_ALTK_UPGRADE
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

		if (self.alterant is 'biom_PawnAlterant')
		{
			let alter = sdat.GetPawnAlterant((class<biom_PawnAlterant>)(self.ALTERANT));
			let compat = false;
			let msg = "";

			[compat, msg] = alter.Compatible(pawn.AsConst());

			if (!compat)
			{
				pawn.A_Log(msg);
				return false;
			}

			let p = new('biom_PendingAlterant');
			p.inner = alter;
			pdat.NextAlteration(p);
			return true;
		}
		else if (self.alterant is 'biom_WeaponAlterant')
		{
			let alter = sdat.GetWeaponAlterant((class<biom_WeaponAlterant>)(self.ALTERANT));

			for (int i = 0; i < pdat.weapons.Size(); ++i)
			{
				let wtdefs = GetDefaultByType(pdat.weapons[i]);
				let wdat = pdat.GetWeaponDataMut(wtdefs.DATA_CLASS);
				let compat = alter.Compatible(wdat.AsConst());

				let p = new('biom_PendingAlterant');
				p.inner = alter;
				p.weaponData = wdat;
				pdat.NextAlteration(p);
				return true;
			}

			pawn.A_Log("$BIOM_ALTERITEM_USEFAIL_NOCOMPATIBLEWEAPS");
			return false;
		}

		return false;
	}
}
