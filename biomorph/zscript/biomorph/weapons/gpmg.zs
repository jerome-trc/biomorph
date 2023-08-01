/// A Chaingun counterpart. "General purpose machine gun".
/// Works almost the same as its vanilla cousin but without the 2-round burst.
/// Abbreviation: `GMG`
class biom_GPMG : biom_Weapon
{
	protected biom_wdat_GPMG data;

	Default
	{
		Tag "$BIOM_GPMG_TAG";
		Obituary "$BIOM_GPMG_OB";
		Scale 0.5;

		Inventory.Icon 'GMGZZ0';
		Inventory.PickupMessage "$BIOM_GPMG_PKUP";

		Weapon.AmmoType 'biom_Slot4Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;

		biom_Weapon.DataClass 'biom_wdat_GPMG';
		biom_Weapon.Grade BIOM_WEAPGRADE_3;
		biom_Weapon.Family BIOM_WEAPFAM_AUTOGUN;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		GMGS ABCDE 2 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		GMGS EDCBA 2;
		goto Ready.Main;
	Ready.Main:
		GMGA A 1 A_WeaponReady;
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		// Baseline time: 4 ticks, like the vanilla Chaingun.
		GMGA A 1 offset(0 + 5, 32 + 5)
		{
			A_FireBullets(3.0, 3.0, 1, RandomPick(18, 19), 'biom_BulletPuff', FBF_NORANDOM);
			invoker.DepleteAmmo(false, false);
			A_AlertMonsters();
			A_StartSound("biom/gpmg/fire", CHAN_AUTO);
			A_GunFlash();
			A_biom_Recoil('biom_recoil_Autogun');
		}
		GMGA A 1 offset(0 + 3, 32 + 3);
		GMGA A 1 offset(0 + 2, 32 + 2);
		GMGA A 1 offset(0 + 1, 32 + 1);
		goto Ready.Main;
	Dryfire:
		GMGA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Flash:
		TNT1 A 0 A_Jump(256, 'Flash.A', 'Flash.B');
		TNT1 A 0 A_Unreachable;
	Flash.A:
		GMG1 A 1 bright offset(0 + 3, 32 + 5) A_Light(1);
		goto Flash.Finish;
	Flash.B:
		GMG1 B 1 bright offset(0 + 3, 32 + 5) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 1 bright offset(0 + 1, 32 + 3) A_Light(0);
		goto LightDone;
	}
}

class biom_wdat_GPMG : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
