/// A slot 6 weapon. The baseline magazine holds one round; holding the fire button
/// charges a shot which gains more damage as the charge approaches 100%.
/// Reloading costs 10 `Slot4Ammo`.
/// Conceptually derived from DoomRL Arsenal's Gauss Rifle.
/// Abbreviation: `COI`
class biom_Coilgun : biom_Weapon
{
	Default
	{
		Tag "$BIOM_COILGUN_TAG";
		Obituary "$BIOM_COILGUN_OB";

		Inventory.Icon 'COIZZ0';
		Inventory.PickupMessage "$BIOM_COILGUN_PKUP";

		Weapon.AmmoType 'biom_Slot4Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;

		biom_Weapon.DataClass 'biom_wdat_Coilgun';
		biom_Weapon.Family BIOM_WEAPFAM_ENERGY;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		COIS ABC 3 A_Lower;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		COIS CBA 3;
		goto Ready.Main;
	Ready.Main:
		COIA A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		COIA A 1 offset(0 + 7, 32 + 7)
		{
			A_StartSound("biom/coilgun/fire", CHAN_WEAPON);
			A_AlertMonsters();
			A_GunFlash();
			A_biom_Recoil('biom_recoil_DoubleShotgun');
		}
		COIA A 1 offset(0 + 5, 32 + 5);
		COIA A 1 offset(0 + 2, 32 + 2);
		COIA A 1 offset(0 + 1, 32 + 1);
		goto Ready.Main;
	Flash:
		TNT1 A 0 A_Jump(256, 'Flash.A', 'Flash.B');
		TNT1 A 0 A_Unreachable;
	Flash.A:
		COI1 A 1 bright offset(0 + 7, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.B:
		COI1 B 1 bright offset(0 + 7, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 0 A_Light(0);
		goto LightDone;
	Dryfire:
		COIA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Reload:
		TNT1 A 0 A_biom_CheckReload;
		COIR ABCD 3;
		COIR E 2;
		COIR F 30;
		COIR G 2;
		COIR DCBA 3;
		goto Ready.Main;
	}

	/* 	Baseline timing stats (tics):
		- Reload: 58
	*/
}

class biom_wdat_Coilgun : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
