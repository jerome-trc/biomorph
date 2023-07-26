/// A Pistol counterpart.
/// Infinite ammo, 7-round magazine, highly damaging.
/// Abbreviation: `SVP`
class biom_ServicePistol : biom_Weapon
{
	protected biom_wdat_ServicePistol data;

	flagdef slideBack: dynFlags, 31;

	Default
	{
		Tag "$BIOM_SERVICEPISTOL_TAG";
		Obituary "$BIOM_SERVICEPISTOL_OB";
		Scale 0.33;

		Inventory.Icon 'SVPZZ0';
		Inventory.PickupMessage "$BIOM_SERVICEPISTOL_PKUP";

		Weapon.SelectionOrder SELORDER_PISTOL;
		Weapon.SlotNumber 2;

		biom_Weapon.DataClass 'biom_wdat_ServicePistol';
		biom_Weapon.Grade BIOM_WEAPGRADE_2;
		biom_Weapon.Family BIOM_WEAPFAM_SIDEARM;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		SVPS ABCDEF 2 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		SVPS FEDCBA 2;
		goto Ready.Main;
	Ready.Main:
		// TODO: Diverge based on magazine state.
	Ready.Chambered:
		SVPA A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;
	Ready.Empty:
		SVP1 D 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;
	Fire:
		// Baseline time: 10 tics; 9 fewer than the vanilla Pistol.
		SVPA A 1 offset(0 + 5, 32 + 5)
		{
			A_StartSound("biom/weap/servicepistol/fire", CHAN_AUTO);
			A_GunFlash();
			A_biom_Recoil('biom_recoil_Handgun');
		}
		SVP1 C 1 offset(0 + 3, 32 + 3);
		SVP1 D 1 offset(0 + 2, 32 + 2);
		SVP1 C 1 offset(0 + 1, 32 + 1);
		SVPA A 6 A_WeaponOffset(0.0, 32.0);
		goto Ready.Main;
	Dryfire:
		SVPA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/weap/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Flash:
		TNT1 A 0 A_Jump(256, 'Flash.A', 'Flash.B');
		TNT1 A 0 A_Unreachable;
	Flash.A:
		SVP1 A 1 bright offset(0 + 3, 32 + 5) A_Light(1);
		goto Flash.Finish;
	Flash.B:
		SVP1 B 1 bright offset(0 + 3, 32 + 5) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 0 A_Light(0);
		goto LightDone;
	Reload:
		// TODO: Separate set of frames for when a round isn't chambered.
		SVPA A 1;
		SVPR A 4;
		SVPR B 4;
		SVPR C 4;
		SVPR D 4;
		SVPR E 10;
		SVPR F 4;
		SVPR G 4;
		SVPR H 4;
		SVPR I 4;
		goto Ready.Main;
	}
}

class biom_wdat_ServicePistol : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
