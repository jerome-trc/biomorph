extend class BIO_Weapon
{
	// Destroys this weapon's operating mode instance, and
	// prepares for another call to `SetDefaults()`.
	// Has no effect whatsoever on the mod graph, or `AmmoGive` values.
	virtual void Reset()
	{
		OpMode = null;
		Pipelines.Clear();
		Affixes.Clear();
		ReloadTimeGroups.Clear();
		SpecialFunc = null;

		AmmoType1 = Default.AmmoType1;
		AmmoType2 = Default.AmmoType2;
		AmmoUse1 = Default.AmmoUse1;
		AmmoUse2 = Default.AmmoUse2;

		KickBack = Default.KickBack;

		RaiseSpeed = Default.RaiseSpeed;
		LowerSpeed = Default.LowerSpeed;

		MagazineType1 = Default.MagazineType1;
		MagazineType2 = Default.MagazineType2;
		MagazineSize1 = Default.MagazineSize1;
		MagazineSize2 = Default.MagazineSize2;

		ReloadCost1 = Default.ReloadCost1;
		ReloadOutput1 = Default.ReloadOutput1;
		ReloadCost2 = Default.ReloadCost2;
		ReloadOutput2 = Default.ReloadOutput2;

		MinAmmoReserve1 = Default.MinAmmoReserve1;
		MinAmmoReserve2 = Default.MinAmmoReserve2;

		Ammo1 = Ammo2 = null;
		Magazine1 = Magazine2 = null;
	}

	void LazyInit()
	{
		if (Uninitialised())
		{
			OpMode = BIO_WeaponOperatingMode.Create(OperatingMode, self);
			SetDefaults();
			IntrinsicModGraph(false);
			OpMode.SideEffects(self);

			if (ModGraph != null)
				SetTag(ColoredTag());
		}
	}

	void SetupAmmo()
	{
		if (Owner == null)
			return;

		if (!(Ammo1 is AmmoType1))
			Ammo1 = AddAmmo(Owner, AmmoType1, 0);
		if (!(Ammo2 is AmmoType2))
			Ammo2 = AddAmmo(Owner, AmmoType2, 0);
	}

	void SetupMagazines()
	{
		if (Owner == null)
			return;

		if (!(Magazine1 is MagazineType1))
			Magazine1 = BIO_Player(Owner).GetMagazine(GetClass(), MagazineType1, false);
		if (!(Magazine2 is MagazineType2))
			Magazine2 = BIO_Player(Owner).GetMagazine(GetClass(), MagazineType2, true);
	}

	// Empty the magazine and return rounds in it to the reserve, with
	// consideration given to the relevant reload ratio.
	void DrainMagazine(bool secondary = false, int toDrain = 0)
	{
		BIO_Magazine mag = null;
		Ammo reserve = null;
		int cost = -1, output = -1;

		if (!secondary)
		{
			mag = Magazine1;
			reserve = Ammo1;
			cost = ReloadCost1;
			output = ReloadOutput1;
		}
		else
		{
			mag = Magazine2;
			reserve = Ammo2;
			cost = ReloadCost2;
			output = ReloadOutput2;
		}

		if (mag == null || reserve == null)
			return;

		if (toDrain <= 0)
		{
			if (mag.GetAmount() <= 0)
				return;

			toDrain = mag.GetAmount();
		}

		mag.Drain(toDrain);
		let toGive = (toDrain / output) * cost;
		reserve.Amount = Clamp(reserve.Amount + toGive, 0, reserve.MaxAmount);
	}

	void DrainMagazineExcess(bool secondary = false)
	{
		let mag = !secondary ? Magazine1 : Magazine2;
		int msize = !secondary ? MagazineSize1 : MagazineSize2;
		DrainMagazine(secondary, msize - mag.GetAmount());
	}

	void Mutate()
	{
		ModGraph = BIO_WeaponModGraph.Create(GraphQuality);
		IntrinsicModGraph(true);
		SetTag(ColoredTag());
	}

	// Used for supply box weapons and Legendary drops.
	void SpecialLootMutate(
		uint extraNodes = 0,
		uint geneCount = 1,
		bool noDuplicateGenes = false,
		bool raritySound = true
	)
	{
		if (Unique)
			return;

		LazyInit();

		if (ModGraph == null)
			Mutate();

		ModGraph.TryGenerateNodes(extraNodes);
		let sim = BIO_WeaponModSimulator.Create(self);

		sim.InsertNewGenesAtRandom(
			Min(ModGraph.Nodes.Size() - 1, geneCount),
			noDuplication: noDuplicateGenes
		);

		if (raritySound)
			BIO_Gene.PlayRaritySound(sim.LowestGeneLootWeight());

		sim.CommitAndClose();
		SetState(FindState('Spawn'));
	}

	void ApplyLifeSteal(float percent, int dmg)
	{
		let lsp = Min(percent, 1.0);
		let given = int(float(dmg) * lsp);
		Owner.GiveBody(given, Owner.GetMaxHealth(true) + 100);
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		for (uint i = 0; i < Affixes.Size(); i++)
			Affixes[i].OnKill(self, killed, inflictor);
	}
}
