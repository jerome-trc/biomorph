class BIO_BFG9000 : BIO_Weapon
{
	Default
	{
		+WEAPON.NOAUTOFIRE;

		Height 20;
		Tag "$TAG_BFG9000";

		Weapon.SlotNumber 7;
		Weapon.AmmoUse 40;
		Weapon.AmmoGive 80;
		Weapon.AmmoType "Cell";
		
		// Affixes cannot change that this weapon fires exactly 1 BFG ball
		BIO_Weapon.AffixMask BIO_WAM_FIRECOUNT_1 | BIO_WAM_FIRETYPE_1;
		BIO_Weapon.FireTypes "BIO_BFGBall", "BIO_BFGExtra";
		BIO_Weapon.FireCounts 1, 40;
		BIO_Weapon.DamageRanges 100, 800, 49, 87;
		BIO_Weapon.MagazineSize 80;
		BIO_Weapon.MagazineType "BIO_Magazine_BFG9000";
		BIO_Weapon.Spread 0.2, 0.2;
		BIO_Weapon.SwitchSpeeds 5, 5;
	}

	States
	{
	Ready:
		BFGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		BFGG A 1 A_BIO_Lower;
		Loop;
	Select:
		BFGG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		BFGG A 20 A_BFGsound;
		BFGG B 10 A_GunFlash;
		BFGG B 10 A_BIO_Fire;
		BFGG B 20 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		BFGG A 1 A_WeaponReady(WRF_NOFIRE);
		BFGG A 1 Offset(0, 32 + 2);
		BFGG A 1 Offset(0, 32 + 4);
		BFGG A 1 Offset(0, 32 + 6);
		BFGG A 1 Offset(0, 32 + 8);
		BFGG A 1 Offset(0, 32 + 10);
		BFGG A 1 Offset(0, 32 + 12);
		BFGG A 1 Offset(0, 32 + 14);
		BFGG A 1 Offset(0, 32 + 16);
		BFGG A 1 Offset(0, 32 + 18);
		BFGG A 30 Offset(0, 32 + 20);
		TNT1 A 0 A_LoadMag(); // TODO: Reload sounds
		BFGG A 1 Offset(0, 32 + 18);
		BFGG A 1 Offset(0, 32 + 16);
		BFGG A 1 Offset(0, 32 + 14);
		BFGG A 1 Offset(0, 32 + 12);
		BFGG A 1 Offset(0, 32 + 10);
		BFGG A 1 Offset(0, 32 + 8);
		BFGG A 1 Offset(0, 32 + 6);
		BFGG A 1 Offset(0, 32 + 4);
		BFGG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		BFGF A 11 Bright A_Light(1);
		BFGF B 6 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		BFUG A -1;
		Stop;
	}

	override void OnProjectileFired(Actor proj) const
	{
		let bfgBall = BIO_BFGBall(proj);
		bfgBall.BFGRays = FireCount2;
		bfgBall.MinRayDamage = MinDamage2;
		bfgBall.MaxRayDamage = MaxDamage2;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		// Ball stats
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
			DamageFontColor(false),
			MinDamage1, MaxDamage1,
			FireCountFontColor(false),
			FireCount1 == -1 ? 1 : FireCount1,
			FireTypeFontColor(false),
			GetDefaultByType(FireType1).GetTag()));

		// Ray stats
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
			DamageFontColor(true),
			MinDamage2, MaxDamage2,
			FireCountFontColor(true),
			FireCount2 == -1 ? 1 : FireCount2,
			FireTypeFontColor(true),
			GetDefaultByType(FireType2).GetTag()));
	}
}

class BIO_Magazine_BFG9000 : BIO_Magazine
{
	Default
	{
		Inventory.Amount 80;
	}
}
