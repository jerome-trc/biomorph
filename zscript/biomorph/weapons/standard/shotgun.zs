class BIO_Shotgun : BIO_Weapon
{
	Default
	{
		Obituary "$OB_MPSHOTGUN";
		Tag "$TAG_SHOTGUN";

		Weapon.AmmoGive 8;
		Weapon.AmmoType "Shell";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1300;
		Weapon.SlotNumber 3;
		Weapon.UpSound "weapons/gunswap1";

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireCount 7;
		BIO_Weapon.FireType "BIO_Bullet";
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType "BIO_Magazine_Shotgun";
		BIO_Weapon.Spread 4.0, 2.0;
	}

	States
	{
	Ready:
		SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect.Loop:
		SHTG A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		SHTG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		SHTG A 3;
		SHTG A 7
		{
			A_BIO_Fire();
			A_StartSound("weapons/shotgf", CHAN_WEAPON);
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		SHTG BC 5;
		SHTG D 4 A_LoadMag();
		SHTG CB 5;
		SHTG A 3;
		SHTG A 7 A_ReFire;
		Goto Ready;
	Flash:
		SHTF A 4 Bright A_Light(1);
		SHTF B 3 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		SHOT A -1;
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

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_SPREAD"),
			HSpread1, VSpread1));
	}
}

class BIO_Magazine_Shotgun : BIO_Magazine
{
	Default
	{
		Inventory.Amount 1;
	}
}
