class BIO_Autocannon : BIO_Weapon
{
	Default
	{
		Tag "$BIO_WEAP_TAG_AUTOCANNON";

		Inventory.Icon "ACANX0";
		Inventory.PickupMessage "$BIO_WEAP_PICKUP_AUTOCANNON";

		Weapon.AmmoGive 100;
		Weapon.AmmoType "Clip";
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder 1600;
		Weapon.SlotNumber 4;
		
		BIO_Weapon.AffixMasks
			BIO_WAM_FIRETIME | BIO_WAM_RELOADTIME,
			BIO_WAM_ALL, BIO_WAM_NONE;
		BIO_Weapon.Grade BIO_GRADE_EXPERIMENTAL;
		BIO_Weapon.DamageRange 10, 30;
		BIO_Weapon.FireType "BIO_Bullet";
		BIO_Weapon.MagazineType "Clip";
		BIO_Weapon.Spread 3.5, 1.5;
	}

	States
	{
	Ready:
		ACAN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		ACAN A 0 A_BIO_Deselect;
		Stop;
	Select:
		ACAN A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.MagazineEmpty(), "Ready");
	WindUp:
		ACAN BCD 1;
		ACAN EFGH 1;
	Wound:
		ACAN E 1 Bright
		{
			if (invoker.MagazineEmpty()) return ResolveState("WindDown");
			A_GunFlash("Flash.I");
			A_BIO_Fire();
			A_StartSound("weapons/autocannon", CHAN_WEAPON);
			return state(null);
		}
		ACAN F 1 Bright A_GunFlash("Flash.J");
		ACAN G 1 Bright
		{
			if (invoker.MagazineEmpty()) return ResolveState("WindDown");
			A_GunFlash("Flash.K");
			A_BIO_Fire();
			A_StartSound("weapons/autocannon", CHAN_7);
			return state(null);
		}
		ACAN H 1 Bright A_GunFlash("Flash.L");
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), "WindDown");
		Loop;
	WindDown:
		ACAN EFGH 1;
		ACAN ABCD 1;
		Goto Ready;
	Flash:
		TNT1 A 0;
		Goto LightDone;
	Flash.I:
		ACAN I 1 Bright A_Light(1);
		Goto LightDone;
	Flash.J:
		ACAN J 1 Bright A_Light(2);
		Goto LightDone;
	Flash.K:
		ACAN K 1 Bright A_Light(1);
		Goto LightDone;
	Flash.L:
		ACAN L 1 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		ACAN X 0;
		ACAN X 0 A_BIO_Spawn;
		Loop;
	}

	override void GetFireTimes(in out Array<int> fireTimes, bool _) const {}
	override void SetFireTimes(Array<int> fireTimes, bool _) {}
	override void GetReloadTimes(in out Array<int> reloadTimes, bool _) const {}
	override void SetReloadTimes(Array<int> reloadTimes, bool _) {}

	override void StatsToString(in out Array<string> stats) const
	{
		stats.Push(GenericFireDataReadout());
		stats.Push(GenericSpreadReadout());
		stats.Push(GenericFireTimeReadout(2));
	}
	
	override int DefaultFireTime() const { return 2; }
}
