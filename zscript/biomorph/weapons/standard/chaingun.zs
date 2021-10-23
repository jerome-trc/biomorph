class BIO_Chaingun : BIO_Weapon
{
	int FireTime; property FireTimes: FireTime;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Obituary "$OB_MPCHAINGUN";
		Tag "$TAG_CHAINGUN";

		Inventory.Icon "MGUNA0";

		Weapon.AmmoGive 40;
		Weapon.AmmoType "Clip";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 700;
		Weapon.SlotNumber 4;
		Weapon.UpSound "weapons/gunswap";

		BIO_Weapon.AffixMask BIO_WAM_SECONDARY;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireType "BIO_Bullet";
		BIO_Weapon.MagazineSize 40;
		BIO_Weapon.MagazineType "BIO_Magazine_Chaingun";
		BIO_Weapon.Spread 4.0, 2.0;
		
		BIO_Chaingun.FireTimes 4;
		BIO_Chaingun.ReloadTimes 40;
	}

	States
	{
	Ready:
		CHGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect.Loop:
		CHGG A 1 A_BIO_Lower;
		Loop;
	Select.Loop:
		CHGG A 1 A_BIO_Raise;
		Loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Reload");
		CHGG AB 4
		{
			A_SetTics(invoker.FireTime);
			A_BIO_Fire();
			A_StartSound("weapons/chngun", CHAN_WEAPON);
		}
		CHGG B 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), "Ready");
		CHGG A 1 A_WeaponReady(WRF_NOFIRE);
		CHGG A 1 Offset(0, 32 + 2);
		CHGG A 1 Offset(0, 32 + 4);
		CHGG A 1 Offset(0, 32 + 6);
		CHGG A 1 Offset(0, 32 + 8);
		CHGG A 1 Offset(0, 32 + 10);
		CHGG A 1 Offset(0, 32 + 12);
		CHGG A 1 Offset(0, 32 + 14);
		CHGG A 1 Offset(0, 32 + 16);
		CHGG A 1 Offset(0, 32 + 18);
		// TODO: Reload sounds
		CHGG A 40 Offset(0, 32 + 20) A_SetTics(invoker.ReloadTime);
		CHGG A 1 Offset(0, 32 + 18) A_LoadMag;
		CHGG A 1 Offset(0, 32 + 16);
		CHGG A 1 Offset(0, 32 + 14);
		CHGG A 1 Offset(0, 32 + 12);
		CHGG A 1 Offset(0, 32 + 10);
		CHGG A 1 Offset(0, 32 + 8);
		CHGG A 1 Offset(0, 32 + 6);
		CHGG A 1 Offset(0, 32 + 4);
		CHGG A 1 Offset(0, 32 + 2);
		Goto Ready;
	Flash:
		CHGF A 5 Bright A_Light(1);
		Goto LightDone;
		CHGF B 5 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		MGUN A -1;
		Stop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.Push(FireTime);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime = fireTimes[0];
	}

	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const
	{
		reloadTimes.Push(ReloadTime);
	}

	override void SetReloadTimes(Array<int> reloadTimes, bool _)
	{
		ReloadTime = reloadTimes[0];
	}

	override void ResetStats()
	{
		super.ResetStats();
		let defs = GetDefaultByType(GetClass());

		FireTime = defs.FireTime;
		ReloadTime = defs.ReloadTime;
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

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_FIRETIME"),
			FireTime != GetDefaultByType(GetClass()).FireTime ?
				CRESC_STATMODIFIED : CRESC_STATUNMODIFIED,
			float(FireTime) / 35.0));

		stats.Push(String.Format(StringTable.Localize("$BIO_WEAPSTAT_SPREAD"),
			HSpread1, VSpread1));
	}
}

class BIO_Magazine_Chaingun : Ammo
{
	mixin BIO_Magazine;

	Default
	{
		Inventory.Amount 40;
	}
}
