class BIO_Chaingun : BIO_Weapon replaces Chaingun
{
	int FireTime; property FireTimes: FireTime;
	int ReloadTime; property ReloadTimes: ReloadTime;

	Default
	{
		Obituary "$OB_MPCHAINGUN";
		Tag "$TAG_CHAINGUN";

		Inventory.Icon 'MGUNA0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_CHAINGUN";

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "weapons/gunswap";

		BIO_Weapon.AffixMasks BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.DamageRange 5, 15;
		BIO_Weapon.FireType 'BIO_Bullet';
		BIO_Weapon.MagazineSize 40;
		BIO_Weapon.MagazineType 'BIO_MAG_Chaingun';
		BIO_Weapon.Spread 4.0, 2.0;
		
		BIO_Chaingun.FireTimes 4;
		BIO_Chaingun.ReloadTimes 40;
	}

	States
	{
	Ready:
		CHGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		CHGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		CHGG A 0 A_BIO_Select;
		Stop;
	Fire:
		CHGG A 0 A_AutoReload;
		CHGG AB 4
		{
			A_BIO_Fire();
			Player.SetSafeFlash(invoker, ResolveState('Flash'),
				ResolveState('Fire') + 1 == Player.GetPSprite(PSP_WEAPON).CurState ? 0 : 1);
			A_StartSound("weapons/chngun", CHAN_WEAPON);
			A_PresetRecoil('BIO_AutogunRecoil');
		}
		CHGG B 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
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
		MGUN A 0;
		MGUN A 0 A_BIO_Spawn;
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

		FireTime = Default.FireTime;
		ReloadTime = Default.ReloadTime;
	}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericSpreadReadout());
		stats.Push(GenericFireTimeReadout(TrueFireTime()));
		stats.Push(GenericReloadTimeReadout(TrueReloadTime()));
	}

	override int TrueFireTime() const { return FireTime; }
	override int TrueReloadTime() const { return ReloadTime + 19; }
}

class BIO_MAG_Chaingun : Ammo { mixin BIO_Magazine; }