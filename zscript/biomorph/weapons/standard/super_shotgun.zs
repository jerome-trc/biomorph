class BIO_SuperShotgun : BIO_Weapon replaces SuperShotgun
{
	int FireTime1, FireTime2; property FireTimes: FireTime1, FireTime2;
	int ReloadTime1, ReloadTime2, ReloadTime3;
	property ReloadTimes: ReloadTime1, ReloadTime2, ReloadTime3;

	Default
	{
		Obituary "$OB_MPSSHOTGUN";
		Tag "$TAG_SUPERSHOTGUN";

		Inventory.Icon 'SGN2A0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_SUPERSHOTGUN";

		Weapon.AmmoGive 8;
		Weapon.AmmoType1 'Shell';
		Weapon.AmmoUse1 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireCount 7;
		BIO_Weapon.FireType 'BIO_ShotPellet';
		BIO_Weapon.MagazineSize 2;
		BIO_Weapon.MagazineType 'BIO_MAG_SuperShotgun';
		BIO_Weapon.Spread 12.0, 7.5;

		BIO_SuperShotgun.FireTimes 3, 7;
		BIO_SuperShotgun.ReloadTimes 7, 6, 5;
	}

	States
	{
	Ready:
		SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		SHT2 A 0 A_BIO_Deselect;
		Stop;
	Select:
		SHT2 A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0
		{
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Double');
			else
				return ResolveState('Fire.Single');
		}
	AltFire:
		TNT1 A 0
		{
			invoker.bAltFire = false;
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Single');
			else
				return ResolveState('Fire.Double');
		}
	Fire.Single:
		TNT1 A 0 A_AutoReload;
		SHT2 A 3 A_SetTics(invoker.FireTime1);
		SHT2 A 7 Bright
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire(spreadFactor: 0.5);
			A_PresetRecoil('BIO_ShotgunRecoil');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			// TODO: Replace with a smaller sound
			A_StartSound("weapons/sshotf", CHAN_WEAPON);
		}
		Goto Ready;
	Fire.Double:
		TNT1 A 0 A_AutoReload(single: true, min: 2);
		SHT2 A 3 A_SetTics(invoker.FireTime1);
		SHT2 A 7 Bright
		{
			A_SetTics(invoker.FireTime2);
			A_BIO_Fire(fireFactor: 2);
			A_PresetRecoil('BIO_SuperShotgunRecoil');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_StartSound("weapons/sshotf", CHAN_WEAPON);
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		SHT2 B 7 A_SetTics(invoker.ReloadTime1);
		SHT2 C 7
		{
			A_SetTics(invoker.ReloadTime1);
			A_CheckReload();
		}
		SHT2 D 7
		{
			A_SetTics(invoker.ReloadTime1);
			A_OpenShotgun2();
		}
		SHT2 E 7 A_SetTics(invoker.ReloadTime1);
		SHT2 F 7
		{
			A_LoadMag();
			A_SetTics(invoker.ReloadTime1);
			A_LoadShotgun2();
		}
		SHT2 G 6 A_SetTics(invoker.ReloadTime2);
		SHT2 H 6
		{
			A_SetTics(invoker.ReloadTime2);
			A_CloseShotgun2();
		}
		SHT2 A 5
		{
			A_SetTics(invoker.ReloadTime3);
			A_ReFire();
		}
		Goto Ready;
	Flash:
		SHT2 I 4 Bright A_Light(1);
		SHT2 J 3 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		SGN2 A 0;
		SGN2 A 0 A_BIO_Spawn;
		Stop;
	}

	override void UpdateDictionary()
	{
		Dict = Dictionary.FromString(String.Format("{\"%s\": \"%d\"}",
			DICTKEY_PELLETCOUNT_1, Default.FireCount1));
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const
	{
		fireTimes.PushV(FireTime1, FireTime2);
	}

	override void SetFireTimes(Array<int> fireTimes, bool _)
	{
		FireTime1 = fireTimes[0];
		FireTime2 = fireTimes[1];
	}

	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const
	{
		reloadTimes.PushV(ReloadTime1, ReloadTime2, ReloadTime3);
	}

	override void SetReloadTimes(Array<int> reloadTimes, bool _)
	{
		ReloadTime1 = reloadTimes[0];
		ReloadTime2 = reloadTimes[1];
		ReloadTime3 = reloadTimes[2];
	}

	override void ResetStats()
	{
		super.ResetStats();

		FireTime1 = Default.FireTime1;
		FireTime2 = Default.FireTime2;

		ReloadTime1 = Default.ReloadTime1;
		ReloadTime2 = Default.ReloadTime2;
		ReloadTime3 = Default.ReloadTime3;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout() .. "\c[MidGrey] "
			.. StringTable.Localize("$BIO_PER_BARREL"));
		stats.Push(GenericSpreadReadout());
		stats.Push(GenericFireTimeReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
	}

	override int TrueFireTime() const { return FireTime1 + FireTime2; }
	override int TrueReloadTime() const { return ReloadTime1 + ReloadTime2 + ReloadTime3; }
}

class BIO_MAG_SuperShotgun : Ammo { mixin BIO_Magazine; }