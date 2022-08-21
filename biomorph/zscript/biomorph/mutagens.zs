class BIO_Mutagen : Inventory abstract
{
	mixin BIO_Rarity;

	const LOOTWEIGHT_MAX = 32;
	const LOOTWEIGHT_RARE = 4;
	const LOOTWEIGHT_MIN = 1;

	meta uint LootWeight; property LootWeight: LootWeight;
	meta bool NoLoot; property NoLoot: NoLoot;

	Default
    {
		-COUNTITEM
		+DONTGIB
		+FLOATBOB
		+INVENTORY.INVBAR

		Height 16;
        Radius 20;
		Scale 0.75;

		Inventory.InterHubAmount 999;
		Inventory.MaxAmount 999;
		Inventory.RestrictedTo 'BIO_Player';

		BIO_Mutagen.LootWeight 0;
		BIO_Mutagen.NoLoot false;
    }

	// Provides preliminary checks, and prints failure messaging.
	override bool Use(bool pickup)
	{
		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);

		if (weap == null)
		{
			Owner.A_Print("$BIO_MUTA_FAIL_NULL", 4.0);
			return false;
		}

		return true;
	}
}

class BIO_ConfirmMutagen : BIO_Mutagen abstract
{
	protected bool Primed;

	bool IsPrimed() const { return Primed; }
	void Disarm() { Primed = false; }
}

class BIO_MutagenDisarmer : Thinker
{
	private BIO_ConfirmMutagen ToDisarm;
	private int Lifetime;

	static BIO_MutagenDisarmer Create(BIO_ConfirmMutagen toDisarm)
	{
		let ret = new('BIO_MutagenDisarmer');
		ret.ToDisarm = toDisarm;
		return ret;
	}

	final override void Tick()
	{
		super.Tick();

		if (ToDisarm == null)
		{
			if (!bDestroyed)
				Destroy();

			return;
		}

		if (ToDisarm.Owner == null)
		{
			if (!bDestroyed)
				Destroy();

			return;
		}

		if (Lifetime++ >= TICRATE * 3 ||
			BIO_Player(ToDisarm.Owner).InvSel != ToDisarm)
		{
			ToDisarm.Disarm();

			if (!bDestroyed)
				Destroy();

			return;
		}
	}
}

// Used to mutate weapons; that is, to initialise `BIO_Weapon::ModGraph`
// (thus qualifying a weapon as "mutated" in the first place) and to commit
// changes to its node graph.
class BIO_Muta_General : BIO_Mutagen
{
	Default
	{
		Tag "$BIO_MUTA_GENERAL_TAG";
		Inventory.Icon 'MUTAG0';
		Inventory.PickupMessage "$BIO_MUTA_GENERAL_PKUP";
		Inventory.UseSound "bio/mutation/general";
		BIO_Mutagen.LootWeight LOOTWEIGHT_MAX;
	}

	States
	{
	Spawn:
		MUTA G 6;
		#### # 6 Bright Light("BIO_MutaGene_Cyan");
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup))
			return false;

		let weap = BIO_Weapon(Owner.Player.ReadyWeapon);
		
		if (weap.IsMutated())
		{
			Owner.A_Print("$BIO_MUTA_FAIL_ALREADYMUTATED");
			return false;
		}

		weap.Mutate();
		Owner.A_Print("$BIO_MUTA_GENERAL_USE");
		return true;
	}
}

class BIO_Muta_Recycle : BIO_ConfirmMutagen
{
	Default
	{
		Tag "$BIO_MUTA_RECYCLE_TAG";
		Inventory.Icon 'MUTAR0';
		Inventory.PickupMessage "$BIO_MUTA_RECYCLE_PKUP";
		Inventory.UseSound "bio/mutation/general";
		BIO_Mutagen.LootWeight LOOTWEIGHT_MAX / 4;
	}

	States
	{
	Spawn:
		MUTA R 6;
		#### # 6 Bright Light("BIO_MutaGene_Yellow");
		Loop;
	}

	final override bool Use(bool pickup)
	{
		if (!super.Use(pickup))
			return false;

		let pawn = BIO_Player(Owner);

		if (pawn.HeldGeneCount() < pawn.MaxGenesHeld)
		{
			pawn.A_Print("$BIO_MUTA_FAIL_INSUFFICIENTGENES");
			return false;
		}


		if (!Primed)
		{
			pawn.A_StartSound("bio/ui/beep", CHAN_AUTO);
			pawn.A_Print("$BIO_MUTA_RECYCLE_CONFIRM", 3.0);
			Primed = true;
			BIO_MutagenDisarmer.Create(self);
			return false;
		}
		else
		{
			// Flush confirm message off screen
			pawn.A_Print("", 0.0);
			Primed = false;

			uint sumWeight = 0, count = 0;
			BIO_Gene toDestroy = null;

			while ((toDestroy = BIO_Gene(pawn.FindInventory('BIO_Gene', true))) != null)
			{
				count++;
				sumWeight += toDestroy.LootWeight;
				toDestroy.DepleteOrDestroy();
			}

			uint avgWeight = sumWeight / count;

			let wrt = new('BIO_LootTable');

			for (uint i = 0; i < AllActorClasses.Size(); i++)
			{
				let gene_t = (class<BIO_Gene>)(AllActorClasses[i]);

				if (gene_t == null || gene_t.IsAbstract())
					continue;

				let defs = GetDefaultByType(gene_t);

				if (defs.LootWeight <= 0 || defs.LootWeight > avgWeight)
					continue;

				wrt.Push(gene_t, defs.LootWeight);
			}

			let gene_t = (class<BIO_Gene>)(wrt.Result());
			let defs = GetDefaultByType(gene_t);
			defs.PlayRaritySound(defs.LootWeight);
			pawn.GiveInventory(gene_t, 1);
		}

		return true;
	}
}
