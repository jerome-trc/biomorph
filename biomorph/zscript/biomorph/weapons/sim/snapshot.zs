// (Rat): boilerplate boilerplate boilerplate

class BIO_WeaponSnapshot
{
	class<BIO_Weapon> Type;

	class<Ammo> AmmoType1, AmmoType2;
	int AmmoUse1, AmmoUse2;
	int KickBack;

	int RaiseSpeed, LowerSpeed;
	class<BIO_Magazine> MagazineType1, MagazineType2;
	uint MagazineSize1, MagazineSize2;
	uint8 ReloadCost1, ReloadCost2, ReloadOutput1, ReloadOutput2;
	uint16 MinAmmoReserve1, MinAmmoReserve2;

	BIO_WeaponOperatingMode OpModes[2];
	Array<BIO_StateTimeGroup> ReloadTimeGroups;
	Array<BIO_WeaponAffix> Affixes;
	BIO_WeaponSpecialFunctor SpecialFunc;

	static BIO_WeaponSnapshot FromReal(readOnly<BIO_Weapon> weap)
	{
		let ret = new('BIO_WeaponSnapshot');
		ret.ImitateReal(weap);
		return ret;
	}

	void ImitateReal(readOnly<BIO_Weapon> weap)
	{
		Type = weap.GetClass();

		AmmoType1 = weap.AmmoType1;
		AmmoType2 = weap.AmmoType2;
		AmmoUse1 = weap.AmmoUse1;
		AmmoUse2 = weap.AmmoUse2;
		Kickback = weap.Kickback;

		RaiseSpeed = weap.LowerSpeed;
		LowerSpeed = weap.LowerSpeed;
		MagazineType1 = weap.MagazineType1;
		MagazineType2 = weap.MagazineType2;
		MagazineSize1 = weap.MagazineSize1;
		MagazineSize2 = weap.MagazineSize2;
		ReloadCost1 = weap.ReloadCost1;
		ReloadCost2 = weap.ReloadCost2;
		ReloadOutput1 = weap.ReloadOutput1;
		ReloadOutput2 = weap.ReloadOutput2;
		MinAmmoReserve1 = weap.MinAmmoReserve1;
		MinAmmoReserve2 = weap.MinAmmoReserve2;

		if (weap.OpModes[0] != null)
			OpModes[0] = weap.OpModes[0].Copy();
		if (weap.OpModes[1] != null)
			OpModes[1] = weap.OpModes[1].Copy();

		for (uint i = 0; i < weap.Affixes.Size(); i++)
			Affixes.Push(weap.Affixes[i].Copy());

		for (uint i = 0; i < weap.ReloadTimeGroups.Size(); i++)
			ReloadTimeGroups.Push(weap.ReloadTimeGroups[i].Copy());

		if (weap.SpecialFunc != null)
			SpecialFunc = weap.SpecialFunc.Copy();
	}

	void Imitate(readOnly<BIO_WeaponSnapshot> other)
	{
		AmmoType1 = other.AmmoType1;
		AmmoType2 = other.AmmoType2;
		AmmoUse1 = other.AmmoUse1;
		AmmoUse2 = other.AmmoUse2;
		Kickback = other.Kickback;

		RaiseSpeed = other.LowerSpeed;
		LowerSpeed = other.LowerSpeed;
		MagazineType1 = other.MagazineType1;
		MagazineType2 = other.MagazineType2;
		MagazineSize1 = other.MagazineSize1;
		MagazineSize2 = other.MagazineSize2;
		ReloadCost1 = other.ReloadCost1;
		ReloadCost2 = other.ReloadCost2;
		ReloadOutput1 = other.ReloadOutput1;
		ReloadOutput2 = other.ReloadOutput2;
		MinAmmoReserve1 = other.MinAmmoReserve1;
		MinAmmoReserve2 = other.MinAmmoReserve2;

		if (other.OpModes[0] != null)
			OpModes[0] = other.OpModes[0].Copy();
		if (other.OpModes[1] != null)
			OpModes[1] = other.OpModes[1].Copy();

		for (uint i = 0; i < other.Affixes.Size(); i++)
			Affixes.Push(other.Affixes[i].Copy());

		for (uint i = 0; i < other.ReloadTimeGroups.Size(); i++)
			ReloadTimeGroups.Push(other.ReloadTimeGroups[i].Copy());

		if (other.SpecialFunc != null)
			SpecialFunc = other.SpecialFunc.Copy();
	}

	readOnly<BIO_WeaponSnapshot> AsConst() const { return self; }
}
