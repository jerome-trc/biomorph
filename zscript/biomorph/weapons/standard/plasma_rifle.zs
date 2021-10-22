class BIO_PlasmaRifle : BIO_Weapon
{
	Default
	{
		Tag "$TAG_PLASMARIFLE";
		Obituary "$OB_MPPLASMARIFLE";

		Inventory.Icon "PLASA0";

		Weapon.AmmoGive 50;
		Weapon.AmmoType "Cell";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 100;
		Weapon.SlotNumber 6;

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 40;
		BIO_Weapon.FireType "BIO_PlasmaBall";
		BIO_Weapon.MagazineSize 50;
		BIO_Weapon.MagazineType "BIO_Magazine_PlasmaRifle";
		BIO_Weapon.Spread 0.2, 0.2; 
	}

	States
	{
	Ready:
		PLSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PLSG A 1 A_BIO_Lower;
		Loop;
	Select:
		PLSG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		PLSG A 3 A_BIO_Fire;
		PLSG B 20 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		PLSG A 1 A_WeaponReady(WRF_NOFIRE);
		PLSG A 1 Offset(0, 32 + 2);
		PLSG A 1 Offset(0, 32 + 4);
		PLSG A 1 Offset(0, 32 + 6);
		PLSG A 1 Offset(0, 32 + 8);
		PLSG A 1 Offset(0, 32 + 10);
		PLSG A 1 Offset(0, 32 + 12);
		PLSG A 1 Offset(0, 32 + 14);
		PLSG A 1 Offset(0, 32 + 16);
		PLSG A 1 Offset(0, 32 + 18);
		PLSG A 30 Offset(0, 32 + 20);
		TNT1 A 0 A_LoadMag(); // TODO: Reload sounds
		PLSG A 1 Offset(0, 32 + 18);
		PLSG A 1 Offset(0, 32 + 16);
		PLSG A 1 Offset(0, 32 + 14);
		PLSG A 1 Offset(0, 32 + 12);
		PLSG A 1 Offset(0, 32 + 10);
		PLSG A 1 Offset(0, 32 + 8);
		PLSG A 1 Offset(0, 32 + 6);
		PLSG A 1 Offset(0, 32 + 4);
		PLSG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		PLSF A 4 Bright A_Light(1);
		Goto LightDone;
		PLSF B 4 Bright A_Light(1);
		Goto LightDone;
	Spawn:
		PLAS A -1;
		Stop;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIREDATA"),
			DamageFontColor(),
			MinDamage1, MaxDamage1,
			FireCountFontColor(),
			FireCount1 == -1 ? 1 : FireCount1,
			FireTypeFontColor(),
			GetDefaultByType(FireType1).GetTag()));
	}
}

class BIO_Magazine_PlasmaRifle : BIO_Magazine
{
	Default
	{
		Inventory.Amount 50;
	}
}