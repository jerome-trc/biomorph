class BIO_Pistol : BIO_Weapon
{
	Default
	{
		Obituary "$OB_MPPISTOL";
		Tag "$TAG_PISTOL";
		
		Weapon.AmmoGive 15;
		Weapon.AmmoType "Clip";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1900;
		Weapon.SlotNumber 2;
		Weapon.UpSound "weapons/gunswap1";

		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireType "BIO_Bullet";
		BIO_Weapon.MagazineSize 15;
		BIO_Weapon.MagazineType "BIO_Magazine_Pistol";
		BIO_Weapon.Spread 4.0, 2.0;
		BIO_Weapon.SwitchSpeeds 4, 4;
	}

	States
	{
	Ready:
		PISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect.Loop:
		PISG A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		PISG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		PISG A 4;
		PISG B 6 A_BIO_Fire;
		TNT1 A 0 A_StartSound("weapons/pistol", CHAN_WEAPON);
		PISG C 4;
		PISG B 5 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		PISG A 1 A_WeaponReady(WRF_NOFIRE);
		PISG A 1 Offset(0, 32 + 2);
		PISG A 1 Offset(0, 32 + 4);
		PISG A 1 Offset(0, 32 + 6);
		PISG A 1 Offset(0, 32 + 8);
		PISG A 1 Offset(0, 32 + 10);
		PISG A 1 Offset(0, 32 + 12);
		PISG A 1 Offset(0, 32 + 14);
		PISG A 1 Offset(0, 32 + 16);
		PISG A 1 Offset(0, 32 + 18);
		PISG A 30 Offset(0, 32 + 20);
		TNT1 A 0 A_LoadMag();
		PISG A 1 Offset(0, 32 + 18);
		PISG A 1 Offset(0, 32 + 16);
		PISG A 1 Offset(0, 32 + 14);
		PISG A 1 Offset(0, 32 + 12);
		PISG A 1 Offset(0, 32 + 10);
		PISG A 1 Offset(0, 32 + 8);
		PISG A 1 Offset(0, 32 + 6);
		PISG A 1 Offset(0, 32 + 4);
		PISG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		PISF A 7 Bright A_Light(1);
		Goto LightDone;
		PISF A 7 Bright A_Light(1);
		Goto LightDone;
 	Spawn:
		PIST A -1;
		Stop;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(String.Format(StringTable.Localize("$BIO_STAT_FIREDATA"),
			DamageFontColor(),
			MinDamage1, MaxDamage1,
			FireCountFontColor(),
			FireCount1 == -1 ? 1 : FireCount1,
			FireTypeFontColor(),
			GetDefaultByType(FireType1).GetTag()));

		stats.Push(String.Format(StringTable.Localize("$BIO_STAT_SPREAD"),
			HSpread1, VSpread1));
	}
}

class BIO_Magazine_Pistol : BIO_Magazine
{
	Default
	{
		Inventory.Amount 15;
	}
}
