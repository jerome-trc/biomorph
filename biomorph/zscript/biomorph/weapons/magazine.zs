// Dictate which magazine types get instantiated for a given weapon.
enum BIO_MagazineFlags : uint8
{
	BIO_MAGF_NONE = 0,
	BIO_MAGF_NORMAL_1 = 1 << 0,
	BIO_MAGF_NORMAL_2 = 1 << 1,
	BIO_MAGF_RECHARGING_1 = 1 << 2,
	BIO_MAGF_RECHARGING_2 = 1 << 3,
	BIO_MAGF_ETMF_1 = 1 << 4,
	BIO_MAGF_ETMF_2 = 1 << 5,

	BIO_MAGF_BALLISTIC_1 = BIO_MAGF_NORMAL_1 | BIO_MAGF_ETMF_1,
	BIO_MAGF_BALLISTIC_2 = BIO_MAGF_NORMAL_2 | BIO_MAGF_ETMF_2,
	BIO_MAGF_PLASMA_1 = BIO_MAGF_RECHARGING_1 | BIO_MAGF_ETMF_1,
	BIO_MAGF_PLASMA_2 = BIO_MAGF_RECHARGING_2 | BIO_MAGF_ETMF_2,

	BIO_MAGF_BALLISTIC = BIO_MAGF_BALLISTIC_1 | BIO_MAGF_BALLISTIC_2,
	BIO_MAGF_PLASMA = BIO_MAGF_PLASMA_1 | BIO_MAGF_PLASMA_2,

	BIO_MAGF_ALL = uint8.MAX
}

class BIO_Magazine play abstract
{
	protected class<BIO_Weapon> WeaponType;
	protected bool Secondary;

	class<BIO_Weapon> GetWeaponType() const { return WeaponType; }
	bool IsSecondary() const { return Secondary; }

	virtual void Tick(BIO_Player owner) {}

	abstract int GetAmount() const;
	abstract uint MaxAmount(uint magazineSize) const;

	abstract bool Sufficient(readOnly<BIO_Weapon> weap, int amount) const;
	abstract bool CanReload(readOnly<BIO_Weapon> weap) const;
	abstract bool IsFull(uint magSize) const;
	abstract bool IsEmpty() const;

	abstract void SetAmount(int amount);
	abstract void Add(int amount);
	abstract void Deplete(BIO_Weapon weap, int amount);
	abstract void Drain(int amount);
}

class BIO_NormalMagazine : BIO_Magazine
{
	private int Amount;

	final override int GetAmount() const { return Amount; }
	final override uint MaxAmount(uint magazineSize) const { return magazineSize; } 

	final override bool Sufficient(readOnly<BIO_Weapon> _, int amount) const
	{
		return self.Amount >= amount;
	}

	final override bool CanReload(readOnly<BIO_Weapon> weap) const
	{
		Ammo reserve = null;
		int cost = -1, magSize = -1, minReserve = -1;

		if (!Secondary)
		{
			magSize = weap.MagazineSize1;
			reserve = weap.Ammo1;
			cost = weap.ReloadCost1;
			minReserve = weap.MinAmmoReserve1;
		}
		else
		{
			magSize = weap.MagazineSize2;
			reserve = weap.Ammo2;
			cost = weap.ReloadCost2;
			minReserve = weap.MinAmmoReserve2;
		}

		bool alreadyFull = Amount < magSize;

		if (reserve == null)
			return alreadyFull;

		int minAmt = minReserve * cost;

		if (reserve.Amount < minAmt)
			return false;

		// Is this magazine already full?
		return alreadyFull;
	}

	final override bool IsFull(uint magSize) const
	{
		return Amount >= magSize;
	}

	final override bool IsEmpty() const
	{
		return Amount <= 0;
	}

	final override void SetAmount(int amount)
	{
		self.Amount = amount;
	}

	final override void Add(int amount)
	{
		self.Amount += amount;
	}

	final override void Deplete(BIO_Weapon _, int amount)
	{
		self.Amount = Max(self.Amount - amount, 0);
	}

	final override void Drain(int amount)
	{
		Deplete(null, amount);
	}

	static BIO_NormalMagazine Create(
		class<BIO_Weapon> weap_t,
		bool secondary
	)
	{
		let ret = new('BIO_NormalMagazine');
		ret.WeaponType = weap_t;
		ret.Secondary = secondary;

		let defs = GetDefaultByType(weap_t);
		ret.Amount = !ret.Secondary ? defs.MagazineSize1 : defs.MagazineSize2;

		return ret;
	}
}

// User can't conventionally reload. Instead, as long as:
// - the user has selected a weapon with a pointer to this magazine,
// - the magazine isn't full, and
// - the user has reserves left,
// ammunition passively flows in, according to the weapon's reload ratio.
class BIO_RechargingMagazine : BIO_Magazine
{
	private int Amount;

	final override int GetAmount() const { return Amount; }
	final override uint MaxAmount(uint magazineSize) const { return magazineSize; } 

	final override void Tick(BIO_Player owner)
	{
		let weap = BIO_Weapon(owner.Player.ReadyWeapon);

		if (weap == null)
			return;

		BIO_StateTimeGroup rtime = null;

		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
			if (weap.ReloadTimeGroups[i].Flags & BIO_STGF_AUXILIARY)
			{
				rtime = weap.ReloadTimeGroups[i];
				break;
			}

		if (rtime != null && (Level.MapTime % rtime.Times[0]) != 0)
			return;

		if (weap.Magazine1 == self)
		{
			if (IsFull(weap.MagazineSize1))
				return;

			let reserve = owner.FindInventory(weap.AmmoType1);

			if (reserve == null)
				return;

			int toLoad = weap.ReloadOutput1, toDraw = -1;
			toDraw = Min(toLoad * weap.ReloadCost1, reserve.Amount);
			toLoad = Min(toLoad, toDraw) * weap.ReloadOutput1;

			reserve.Amount -= toDraw;
			Amount += toLoad;
		}
		else if (weap.Magazine2 == self)
		{
			if (IsFull(weap.MagazineSize2))
				return;

			let reserve = owner.FindInventory(weap.AmmoType2);

			if (reserve == null)
				return;

			int toLoad = weap.ReloadOutput2, toDraw = -1;
			toDraw = Min(toLoad * weap.ReloadCost2, reserve.Amount);
			toLoad = Min(toLoad, toDraw) * weap.ReloadOutput2;

			reserve.Amount -= toDraw;
			Amount += toLoad;
		}
	}

	final override bool CanReload(readOnly<BIO_Weapon> _) const
	{
		return false;
	}

	final override bool Sufficient(readOnly<BIO_Weapon> _, int amount) const
	{
		return self.Amount >= amount;
	}

	final override bool IsFull(uint magSize) const
	{
		return Amount >= magSize;
	}

	final override bool IsEmpty() const
	{
		return Amount <= 0;
	}

	final override void SetAmount(int amount)
	{
		self.Amount = amount;
	}

	final override void Add(int amount)
	{
		self.Amount += amount;
	}

	final override void Deplete(BIO_Weapon _, int amount)
	{
		self.Amount = Max(self.Amount - amount, 0);
	}

	final override void Drain(int amount)
	{
		Deplete(null, amount);
	}

	static BIO_RechargingMagazine Create(
		class<BIO_Weapon> weap_t,
		bool secondary
	)
	{
		let ret = new('BIO_RechargingMagazine');
		ret.WeaponType = weap_t;
		ret.Secondary = secondary;

		let defs = GetDefaultByType(weap_t);
		ret.Amount = !ret.Secondary ? defs.MagazineSize1 : defs.MagazineSize2;

		return ret;
	}
}

// When the user submits fire input, they expend a certain quantity of Cell ammo
// to gain a certain duration of infinite-ammo firing time, if this status
// isn't already present. Inspired by DUMP3's Powered Machineguns.
class BIO_ETMFMagazine : BIO_Magazine
{
	private uint Clock;

	final override int GetAmount() const
	{
		return Clock / TICRATE;
	}

	final override uint MaxAmount(uint magazineSize) const
	{
		return magazineSize / TICRATE; 
	}

	final override void Tick(BIO_Player _)
	{
		if (Clock > 0)
			Clock--;
	}

	final override bool CanReload(readOnly<BIO_Weapon> _) const
	{
		return false;
	}

	final override bool Sufficient(readOnly<BIO_Weapon> weap, int _) const
	{
		if (Clock > 0)
			return true;

		return
			weap.Owner.CountInv('Cell') >= (!Secondary ? weap.AmmoUse1 : weap.AmmoUse2);
	}

	final override bool IsFull(uint _) const
	{
		return Clock > 0;
	}

	final override bool IsEmpty() const
	{
		return Clock <= 0;
	}

	final override void SetAmount(int _) {}
	final override void Add(int _) {}

	final override void Deplete(BIO_Weapon weap, int _)
	{
		if (!IsEmpty())
			return;

		weap.Owner.A_TakeInventory(
			'Cell',
			!Secondary ? weap.AmmoUse1 : weap.AmmoUse2,
			TIF_NOTAKEINFINITE
		);

		Clock = !Secondary ? weap.MagazineSize1 : weap.MagazineSize2;

		weap.Owner.A_StartSound("bio/weap/etmf", CHAN_AUTO);
	}

	final override void Drain(int _) {}

	static BIO_ETMFMagazine Create(
		class<BIO_Weapon> weap_t,
		bool secondary
	)
	{
		let ret = new('BIO_ETMFMagazine');
		ret.WeaponType = weap_t;
		ret.Secondary = secondary;
		return ret;
	}
}
