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
